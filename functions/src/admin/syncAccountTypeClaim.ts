import { onDocumentWritten } from 'firebase-functions/v2/firestore';
import { admin, FUNCTIONS_REGION } from '../lib/admin';

// The app and firestore.rules gate admin access on the Auth custom claim
// `role`, not on this Firestore field — but accountType is what's easy to
// edit by hand (console, support tooling). This keeps the two in sync so
// setting accountType: 'admin' on a user doc actually grants admin access,
// instead of silently doing nothing until bootstrapAdmin is called directly.
export const onUserAccountTypeChanged = onDocumentWritten(
  { document: 'users/{userId}', region: FUNCTIONS_REGION },
  async (event) => {
    const after = event.data?.after.data();
    if (!after) return; // user document deleted

    const beforeType = event.data?.before.data()?.accountType;
    const afterType = after.accountType;
    if (beforeType === afterType) return;

    const uid = event.params.userId;
    const userRecord = await admin.auth().getUser(uid);
    const currentRole = userRecord.customClaims?.role;

    if (afterType === 'admin') {
      if (currentRole === 'admin') return;
      await admin.auth().setCustomUserClaims(uid, { role: 'admin' });
      console.log(`✅ Granted admin role to ${uid} via accountType change`);
      return;
    }

    // Moved away from admin — only touch claims if this doc previously made them admin.
    if (currentRole === 'admin') {
      if (afterType === 'supplier') {
        await admin.auth().setCustomUserClaims(uid, {
          role: 'supplier',
          supplierId: after.supplierId,
        });
      } else {
        await admin.auth().setCustomUserClaims(uid, {});
      }
      console.log(`✅ Revoked admin role from ${uid} via accountType change`);
    }
  }
);
