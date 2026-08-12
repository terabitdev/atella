import * as crypto from 'crypto';
import { onCall, HttpsError } from 'firebase-functions/v2/https';
import { admin, db, FUNCTIONS_REGION } from '../lib/admin';
import { requireAdmin } from '../lib/roles';

const INVITE_EXPIRY_DAYS = 7;

function normalizeEmail(email: string): string {
  return email.toLowerCase().trim();
}

// Admin-only: creates a supplier profile (pending_invite) plus an invite
// token. The supplier account cannot be self-serve created — this is the
// only way a `suppliers` doc comes into existence.
export const createSupplierInvite = onCall(
  { region: FUNCTIONS_REGION },
  async (request) => {
    requireAdmin(request);

    const { companyName, specialty, moqTiers, originCountry, description, logoUrl, email } =
      request.data || {};

    if (!companyName || typeof companyName !== 'string') {
      throw new HttpsError('invalid-argument', 'companyName is required.');
    }
    if (!email || typeof email !== 'string') {
      throw new HttpsError('invalid-argument', 'email is required.');
    }

    const normalizedEmail = normalizeEmail(email);
    const adminUid = request.auth!.uid;

    const supplierRef = db.collection('suppliers').doc();
    const inviteRef = db.collection('supplierInvites').doc();
    const token = crypto.randomBytes(24).toString('hex');
    const expiresAt = admin.firestore.Timestamp.fromMillis(
      Date.now() + INVITE_EXPIRY_DAYS * 24 * 60 * 60 * 1000
    );

    const batch = db.batch();
    batch.set(supplierRef, {
      companyName,
      logoUrl: logoUrl || null,
      specialty: specialty || null,
      moqTiers: moqTiers || [],
      originCountry: originCountry || null,
      description: description || null,
      status: 'pending_invite',
      ownerUid: null,
      inviteEmail: normalizedEmail,
      stripeConnectAccountId: null,
      payoutsEnabled: false,
      createdAt: admin.firestore.FieldValue.serverTimestamp(),
      createdBy: adminUid,
    });
    batch.set(inviteRef, {
      email: normalizedEmail,
      supplierId: supplierRef.id,
      token,
      status: 'pending',
      createdAt: admin.firestore.FieldValue.serverTimestamp(),
      createdBy: adminUid,
      expiresAt,
    });
    await batch.commit();

    console.log(`✅ Supplier invite created: ${supplierRef.id} for ${normalizedEmail}`);

    return {
      supplierId: supplierRef.id,
      inviteId: inviteRef.id,
      token,
      // Real https:// link, verified as an Android App Link / iOS Universal
      // Link (see public/.well-known/) so it's an actual tappable link in
      // messaging apps, not just a custom scheme that sits as plain text.
      inviteLink: `https://atelia-123.web.app/supplier-invite?token=${token}`,
    };
  }
);

// Admin-only: kills a pending invite before it's accepted (e.g. suspected leak).
export const revokeSupplierInvite = onCall(
  { region: FUNCTIONS_REGION },
  async (request) => {
    requireAdmin(request);

    const { inviteId } = request.data || {};
    if (!inviteId || typeof inviteId !== 'string') {
      throw new HttpsError('invalid-argument', 'inviteId is required.');
    }

    const inviteRef = db.collection('supplierInvites').doc(inviteId);
    const inviteSnap = await inviteRef.get();
    if (!inviteSnap.exists) {
      throw new HttpsError('not-found', 'Invite not found.');
    }
    if (inviteSnap.data()?.status !== 'pending') {
      throw new HttpsError('failed-precondition', 'Only pending invites can be revoked.');
    }

    await inviteRef.update({ status: 'revoked' });
    return { success: true };
  }
);

// No auth required — this runs before the invitee has an account. Only
// reveals the locked email + company name, never the token's existence
// beyond validity.
export const validateSupplierInvite = onCall(
  { region: FUNCTIONS_REGION },
  async (request) => {
    const { token } = request.data || {};
    if (!token || typeof token !== 'string') {
      throw new HttpsError('invalid-argument', 'token is required.');
    }

    const snap = await db.collection('supplierInvites').where('token', '==', token).limit(1).get();
    if (snap.empty) {
      throw new HttpsError('not-found', 'This invite link is invalid.');
    }

    const inviteDoc = snap.docs[0];
    const invite = inviteDoc.data();

    if (invite.status !== 'pending') {
      throw new HttpsError('failed-precondition', 'This invite has already been used or revoked.');
    }
    if (invite.expiresAt.toMillis() < Date.now()) {
      throw new HttpsError('deadline-exceeded', 'This invite link has expired.');
    }

    const supplierSnap = await db.collection('suppliers').doc(invite.supplierId).get();
    const supplier = supplierSnap.data();

    return {
      email: invite.email,
      supplierId: invite.supplierId,
      companyName: supplier?.companyName || '',
    };
  }
);

// Requires the caller to already have a freshly-created Firebase Auth
// account whose email matches the invite — this is what turns a
// pending_invite supplier into an active, owned account.
export const acceptSupplierInvite = onCall(
  { region: FUNCTIONS_REGION },
  async (request) => {
    if (!request.auth) {
      throw new HttpsError('unauthenticated', 'You must be signed in to accept an invite.');
    }

    const { token } = request.data || {};
    if (!token || typeof token !== 'string') {
      throw new HttpsError('invalid-argument', 'token is required.');
    }

    const uid = request.auth.uid;
    const callerEmail = request.auth.token.email ? normalizeEmail(request.auth.token.email) : null;

    const snap = await db.collection('supplierInvites').where('token', '==', token).limit(1).get();
    if (snap.empty) {
      throw new HttpsError('not-found', 'This invite link is invalid.');
    }

    const inviteDoc = snap.docs[0];
    const invite = inviteDoc.data();

    if (invite.status !== 'pending') {
      throw new HttpsError('failed-precondition', 'This invite has already been used or revoked.');
    }
    if (invite.expiresAt.toMillis() < Date.now()) {
      throw new HttpsError('deadline-exceeded', 'This invite link has expired.');
    }
    if (!callerEmail || callerEmail !== invite.email) {
      throw new HttpsError(
        'permission-denied',
        'This invite was sent to a different email address.'
      );
    }

    const supplierRef = db.collection('suppliers').doc(invite.supplierId);

    await admin.auth().setCustomUserClaims(uid, { role: 'supplier', supplierId: invite.supplierId });

    const batch = db.batch();
    batch.update(supplierRef, {
      ownerUid: uid,
      status: 'active',
    });
    batch.set(
      db.collection('users').doc(uid),
      { accountType: 'supplier', supplierId: invite.supplierId },
      { merge: true }
    );
    batch.update(inviteDoc.ref, {
      status: 'accepted',
      acceptedAt: admin.firestore.FieldValue.serverTimestamp(),
      acceptedByUid: uid,
    });
    await batch.commit();

    console.log(`✅ Supplier invite accepted: ${invite.supplierId} by ${uid}`);

    return { success: true, supplierId: invite.supplierId };
  }
);
