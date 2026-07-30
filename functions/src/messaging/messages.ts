import { onDocumentCreated } from 'firebase-functions/v2/firestore';
import { admin, db, FUNCTIONS_REGION } from '../lib/admin';

// Fires on every new message. Keeps the parent conversation's summary
// (lastMessage, unread counts) in sync and notifies the recipient — in-app
// only for v1, email lands in Section 8.
export const onMessageCreated = onDocumentCreated(
  { document: 'conversations/{conversationId}/messages/{messageId}', region: FUNCTIONS_REGION },
  async (event) => {
    const snap = event.data;
    if (!snap) return;

    const message = snap.data();
    const conversationId = event.params.conversationId;
    const conversationRef = db.collection('conversations').doc(conversationId);
    const conversationSnap = await conversationRef.get();
    if (!conversationSnap.exists) return;

    const conversation = conversationSnap.data()!;
    const participantUids: string[] = conversation.participantUids || [];
    const recipientUid = participantUids.find((uid) => uid !== message.senderUid);

    const preview =
      message.type === 'text' ? message.text : message.type === 'sample_order_form' ? 'Sent a sample order form' : message.text;

    const batch = db.batch();
    batch.update(conversationRef, {
      lastMessage: preview,
      lastMessageAt: admin.firestore.FieldValue.serverTimestamp(),
      ...(recipientUid
        ? { [`unreadCountByUid.${recipientUid}`]: admin.firestore.FieldValue.increment(1) }
        : {}),
    });

    if (recipientUid) {
      const notificationRef = db.collection('notifications').doc();
      batch.set(notificationRef, {
        recipientUid,
        type: 'message_received',
        title: 'New message',
        body: preview.length > 120 ? `${preview.slice(0, 117)}...` : preview,
        linkRoute: null,
        relatedId: conversationId,
        read: false,
        createdAt: admin.firestore.FieldValue.serverTimestamp(),
      });
    }

    await batch.commit();
    console.log(`✅ Message in ${conversationId}: notified ${recipientUid || 'nobody (no recipient found)'}`);
  }
);
