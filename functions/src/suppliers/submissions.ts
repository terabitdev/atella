import { onDocumentCreated } from 'firebase-functions/v2/firestore';
import { admin, db, FUNCTIONS_REGION } from '../lib/admin';

// Fires when a user sends a tech pack to a supplier. Notifies the supplier
// (in-app only for v1 — email lands in Section 8) and bumps their unread
// badge count.
export const onSupplierSubmissionCreated = onDocumentCreated(
  { document: 'supplierSubmissions/{submissionId}', region: FUNCTIONS_REGION },
  async (event) => {
    const snap = event.data;
    if (!snap) return;

    const submission = snap.data();
    const supplierId = submission.supplierId as string;
    const submissionId = event.params.submissionId;

    const supplierRef = db.collection('suppliers').doc(supplierId);
    const supplierSnap = await supplierRef.get();
    if (!supplierSnap.exists) {
      console.log(`🤷 Submission ${submissionId}: supplier ${supplierId} not found`);
      return;
    }

    const supplier = supplierSnap.data();
    const ownerUid = supplier?.ownerUid;

    const batch = db.batch();
    batch.update(supplierRef, {
      unreadSubmissionCount: admin.firestore.FieldValue.increment(1),
    });

    if (ownerUid) {
      const notificationRef = db.collection('notifications').doc();
      batch.set(notificationRef, {
        recipientUid: ownerUid,
        type: 'submission_received',
        title: 'New tech pack received',
        body: `${submission.techPackProjectName || 'A designer'} sent you a tech pack.`,
        linkRoute: null,
        relatedId: submissionId,
        read: false,
        createdAt: admin.firestore.FieldValue.serverTimestamp(),
      });
    }

    await batch.commit();
    console.log(`✅ Submission ${submissionId}: notified supplier ${supplierId}`);
  }
);
