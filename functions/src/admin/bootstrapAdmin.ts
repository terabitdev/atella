import { onCall, HttpsError } from 'firebase-functions/v2/https';
import { admin, db, FUNCTIONS_REGION } from '../lib/admin';

// One-time bootstrap: grants the 'admin' custom claim to a user by email.
// Guarded by a shared secret (ADMIN_BOOTSTRAP_SECRET in functions/.env)
// because every other admin-granting path requires an existing admin to
// call it — this is how the very first admin account gets created.
export const bootstrapAdmin = onCall(
  { region: FUNCTIONS_REGION },
  async (request) => {
    const { email, secret } = request.data || {};
    const expectedSecret = process.env.ADMIN_BOOTSTRAP_SECRET || '';

    if (!expectedSecret || secret !== expectedSecret) {
      throw new HttpsError('permission-denied', 'Invalid bootstrap secret.');
    }
    if (!email || typeof email !== 'string') {
      throw new HttpsError('invalid-argument', 'email is required.');
    }

    const userRecord = await admin.auth().getUserByEmail(email.toLowerCase().trim());
    await admin.auth().setCustomUserClaims(userRecord.uid, { role: 'admin' });
    await db.collection('users').doc(userRecord.uid).set(
      { accountType: 'admin' },
      { merge: true }
    );

    console.log(`✅ Granted admin role to ${email} (${userRecord.uid})`);
    return { success: true, uid: userRecord.uid };
  }
);
