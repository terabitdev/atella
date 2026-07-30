import { onCall, HttpsError } from 'firebase-functions/v2/https';
import { admin, db, stripe, FUNCTIONS_REGION } from '../lib/admin';
import { requireSupplier } from '../lib/roles';

const COMMISSION_RATE = 0.1;

function supplierIdFromClaims(request: any): string {
  const supplierId = request.auth?.token?.supplierId;
  if (!supplierId || typeof supplierId !== 'string') {
    throw new HttpsError('failed-precondition', 'No supplier account linked to this session.');
  }
  return supplierId;
}

// Supplier sends a priced sample order form into an existing conversation.
export const createSampleOrderForm = onCall(
  { region: FUNCTIONS_REGION },
  async (request) => {
    requireSupplier(request);
    const supplierId = supplierIdFromClaims(request);

    const { conversationId, amountTotal, currency, description } = request.data || {};
    if (!conversationId || typeof conversationId !== 'string') {
      throw new HttpsError('invalid-argument', 'conversationId is required.');
    }
    if (!amountTotal || typeof amountTotal !== 'number' || amountTotal <= 0) {
      throw new HttpsError('invalid-argument', 'amountTotal must be a positive number (smallest currency unit).');
    }

    const conversationRef = db.collection('conversations').doc(conversationId);
    const conversationSnap = await conversationRef.get();
    if (!conversationSnap.exists) {
      throw new HttpsError('not-found', 'Conversation not found.');
    }
    const conversation = conversationSnap.data()!;
    if (conversation.supplierId !== supplierId) {
      throw new HttpsError('permission-denied', 'This conversation does not belong to your supplier account.');
    }

    const supplierRef = db.collection('suppliers').doc(supplierId);
    const supplierSnap = await supplierRef.get();
    const supplier = supplierSnap.data();
    if (!supplier?.payoutsEnabled || !supplier?.stripeConnectAccountId) {
      throw new HttpsError(
        'failed-precondition',
        'Complete Stripe onboarding before sending an order form.'
      );
    }

    const applicationFeeAmount = Math.round(amountTotal * COMMISSION_RATE);

    const orderRef = db.collection('orders').doc();
    await orderRef.set({
      type: 'sample',
      submissionId: conversation.submissionId,
      conversationId,
      userUid: conversation.userUid,
      supplierId,
      supplierOwnerUid: request.auth!.uid,
      stripeConnectAccountId: supplier.stripeConnectAccountId,
      companyName: supplier.companyName || 'Supplier',
      userName: conversation.userName || 'Designer',
      amountTotal,
      currency: (currency || 'usd').toLowerCase(),
      applicationFeeAmount,
      description: description || null,
      status: 'awaiting_payment',
      shipping: null,
      trackingNumber: null,
      trackingCarrier: null,
      stripePaymentIntentId: null,
      createdAt: admin.firestore.FieldValue.serverTimestamp(),
      paidAt: null,
      shippedAt: null,
    });

    await conversationRef.collection('messages').add({
      senderUid: request.auth!.uid,
      text: description || 'Sent a sample order form',
      attachmentUrl: null,
      type: 'sample_order_form',
      orderId: orderRef.id,
      createdAt: admin.firestore.FieldValue.serverTimestamp(),
      readBy: [request.auth!.uid],
    });

    console.log(`✅ Sample order form ${orderRef.id} created for conversation ${conversationId}`);
    return { orderId: orderRef.id };
  }
);

// User pays for an order (sample or production) — creates a destination
// charge PaymentIntent: funds settle on the platform account, then Stripe
// automatically transfers (amountTotal - applicationFeeAmount) to the
// supplier's connected account.
export const createOrderPaymentIntent = onCall(
  { region: FUNCTIONS_REGION },
  async (request) => {
    if (!request.auth) {
      throw new HttpsError('unauthenticated', 'You must be signed in.');
    }

    const { orderId, shipping } = request.data || {};
    if (!orderId || typeof orderId !== 'string') {
      throw new HttpsError('invalid-argument', 'orderId is required.');
    }

    const orderRef = db.collection('orders').doc(orderId);
    const orderSnap = await orderRef.get();
    if (!orderSnap.exists) {
      throw new HttpsError('not-found', 'Order not found.');
    }
    const order = orderSnap.data()!;

    if (order.userUid !== request.auth.uid) {
      throw new HttpsError('permission-denied', 'This order does not belong to you.');
    }
    if (order.status !== 'awaiting_payment') {
      throw new HttpsError('failed-precondition', `Order is not awaiting payment (status: ${order.status}).`);
    }

    const paymentIntent = await stripe.paymentIntents.create({
      amount: order.amountTotal,
      currency: order.currency,
      transfer_data: { destination: order.stripeConnectAccountId },
      application_fee_amount: order.applicationFeeAmount,
      metadata: { orderId, firebase_uid: request.auth.uid },
    });

    await orderRef.update({
      shipping: shipping || null,
      stripePaymentIntentId: paymentIntent.id,
    });

    return { clientSecret: paymentIntent.client_secret };
  }
);

// Supplier marks an order shipped with a tracking number — the simplest
// viable v1 tracking mechanism (no carrier API integration).
export const markOrderShipped = onCall(
  { region: FUNCTIONS_REGION },
  async (request) => {
    requireSupplier(request);

    const { orderId, trackingNumber, trackingCarrier } = request.data || {};
    if (!orderId || typeof orderId !== 'string') {
      throw new HttpsError('invalid-argument', 'orderId is required.');
    }
    if (!trackingNumber || typeof trackingNumber !== 'string') {
      throw new HttpsError('invalid-argument', 'trackingNumber is required.');
    }

    const orderRef = db.collection('orders').doc(orderId);
    const orderSnap = await orderRef.get();
    if (!orderSnap.exists) {
      throw new HttpsError('not-found', 'Order not found.');
    }
    const order = orderSnap.data()!;

    if (order.supplierOwnerUid !== request.auth!.uid) {
      throw new HttpsError('permission-denied', 'This order does not belong to your supplier account.');
    }
    if (order.status !== 'paid') {
      throw new HttpsError('failed-precondition', `Order must be paid before it can be shipped (status: ${order.status}).`);
    }

    await orderRef.update({
      status: 'shipped',
      trackingNumber,
      trackingCarrier: trackingCarrier || null,
      shippedAt: admin.firestore.FieldValue.serverTimestamp(),
    });

    await db.collection('conversations').doc(order.conversationId).collection('messages').add({
      senderUid: request.auth!.uid,
      text: `Order shipped — tracking number: ${trackingNumber}`,
      attachmentUrl: null,
      type: 'system',
      orderId,
      createdAt: admin.firestore.FieldValue.serverTimestamp(),
      readBy: [request.auth!.uid],
    });

    await db.collection('notifications').add({
      recipientUid: order.userUid,
      type: 'order_shipped',
      title: 'Your order has shipped',
      body: `${order.companyName} shipped your order — tracking number ${trackingNumber}.`,
      linkRoute: null,
      relatedId: orderId,
      read: false,
      createdAt: admin.firestore.FieldValue.serverTimestamp(),
    });

    return { success: true };
  }
);
