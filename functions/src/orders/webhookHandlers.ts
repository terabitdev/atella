import Stripe from 'stripe';
import { admin, db } from '../lib/admin';

// Destination-charge PaymentIntents for orders are created on the platform
// account (not a Connect account), so their events land on the same
// stripeWebhook endpoint as subscriptions — routed here via metadata.orderId.

export async function handleOrderPaymentSucceeded(paymentIntent: Stripe.PaymentIntent) {
  const orderId = paymentIntent.metadata?.orderId;
  if (!orderId) return;

  const orderRef = db.collection('orders').doc(orderId);
  const orderSnap = await orderRef.get();
  if (!orderSnap.exists) {
    console.log(`🤷 ORDER WEBHOOK: order ${orderId} not found`);
    return;
  }
  const order = orderSnap.data()!;

  if (order.status === 'paid') {
    console.log(`ℹ️ ORDER WEBHOOK: order ${orderId} already marked paid, skipping`);
    return;
  }

  await orderRef.update({
    status: 'paid',
    paidAt: admin.firestore.FieldValue.serverTimestamp(),
  });

  await db.collection('conversations').doc(order.conversationId).collection('messages').add({
    senderUid: order.supplierOwnerUid,
    text: 'Payment received ✅. The supplier can now prepare your order.',
    attachmentUrl: null,
    type: 'system',
    orderId,
    createdAt: admin.firestore.FieldValue.serverTimestamp(),
    readBy: [],
  });

  await db.collection('notifications').add({
    recipientUid: order.supplierOwnerUid,
    type: 'payment_received',
    title: 'Payment received',
    body: `${order.userName} paid for their ${order.type} order.`,
    linkRoute: null,
    relatedId: orderId,
    read: false,
    createdAt: admin.firestore.FieldValue.serverTimestamp(),
  });

  console.log(`✅ ORDER WEBHOOK: order ${orderId} marked paid`);
}

export async function handleOrderPaymentFailed(paymentIntent: Stripe.PaymentIntent) {
  const orderId = paymentIntent.metadata?.orderId;
  if (!orderId) return;

  console.log(`⚠️ ORDER WEBHOOK: payment failed for order ${orderId}`);
  // Order stays 'awaiting_payment' so the user can retry from the checkout screen.
}
