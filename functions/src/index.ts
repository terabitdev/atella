import * as functions from 'firebase-functions';
import * as admin from 'firebase-admin';
import Stripe from 'stripe';

// Initialize Firebase Admin
admin.initializeApp();
const db = admin.firestore();

// Initialize Stripe
const stripe = new Stripe(functions.config().stripe.secret_key, {
  apiVersion: '2023-10-16',
});

// Stripe webhook Cloud Function
export const stripeWebhook = functions.https.onRequest(async (req, res) => {
  const sig = req.headers['stripe-signature'] as string;
  const webhookSecret = functions.config().stripe.webhook_secret;
  
  let event: Stripe.Event;
  
  try {
    // Use req.rawBody for signature verification (not req.body)
    event = stripe.webhooks.constructEvent(req.rawBody, sig, webhookSecret);
    console.log('✅ WEBHOOK: Signature verified successfully');
  } catch (err: any) {
    console.error(`❌ WEBHOOK: Signature verification failed.`, err.message);
    res.status(400).send(`Webhook Error: ${err.message}`);
    return;
  }
  
  console.log(`✅ Received webhook: ${event.type}`);
  
  try {
    switch (event.type) {
      case 'customer.subscription.created':
        await handleSubscriptionCreated(event.data.object as Stripe.Subscription);
        break;
      case 'customer.subscription.updated':
        await handleSubscriptionUpdated(event.data.object as Stripe.Subscription);
        break;
      case 'customer.subscription.deleted':
        await handleSubscriptionDeleted(event.data.object as Stripe.Subscription);
        break;
      case 'invoice.payment_succeeded':
        await handlePaymentSucceeded(event.data.object as Stripe.Invoice);
        break;
      case 'invoice.payment_failed':
        await handlePaymentFailed(event.data.object as Stripe.Invoice);
        break;
      default:
        console.log(`🤷‍♀️ Unhandled event type: ${event.type}`);
    }
    
    res.json({received: true});
  } catch (error) {
    console.error('Error processing webhook:', error);
    res.status(500).send('Webhook processing failed');
  }
});

// Subscription created
async function handleSubscriptionCreated(subscription: Stripe.Subscription) {
  const customerId = subscription.customer as string;
  const subscriptionId = subscription.id;
  const status = subscription.status;
  const priceId = subscription.items.data[0].price.id;
  const currentPeriodEnd = new Date(subscription.current_period_end * 1000);
  const currentPeriodStart = new Date(subscription.current_period_start * 1000);
  
  try {
    // Find user by Stripe customer ID
    const usersSnapshot = await db.collection('users')
      .where('stripeCustomerId', '==', customerId)
      .get();
    
    if (usersSnapshot.empty) {
      console.log(`❌ No user found for customer ${customerId}`);
      return;
    }
    
    const userDoc = usersSnapshot.docs[0];
    const userId = userDoc.id;
    const planName = getPlanNameFromPriceId(priceId);
    
    await db.collection('users').doc(userId).update({
      subscriptionPlan: planName,
      subscriptionStatus: status,
      currentSubscriptionId: subscriptionId,
      currentPeriodStart: admin.firestore.Timestamp.fromDate(currentPeriodStart),
      currentPeriodEnd: admin.firestore.Timestamp.fromDate(currentPeriodEnd),
      techpacksUsedThisMonth: 0,
      lastUpdated: admin.firestore.FieldValue.serverTimestamp(),
      updatedBy: 'WEBHOOK' // Debug field to identify source
    });
    
    console.log(`🚀 WEBHOOK: Firebase updated - User ${userId} to ${planName} plan`);
  } catch (error) {
    console.error(`❌ Error handling subscription created:`, error);
  }
}

// Subscription updated
async function handleSubscriptionUpdated(subscription: Stripe.Subscription) {
  const customerId = subscription.customer as string;
  const subscriptionId = subscription.id;
  const status = subscription.status;
  const priceId = subscription.items.data[0].price.id;
  const currentPeriodEnd = new Date(subscription.current_period_end * 1000);
  const currentPeriodStart = new Date(subscription.current_period_start * 1000);
  
  try {
    const usersSnapshot = await db.collection('users')
      .where('stripeCustomerId', '==', customerId)
      .get();
    
    if (usersSnapshot.empty) {
      console.log(`❌ No user found for customer ${customerId}`);
      return;
    }
    
    const userDoc = usersSnapshot.docs[0];
    const userId = userDoc.id;
    const planName = getPlanNameFromPriceId(priceId);
    
    // Check if it's a new billing period to reset techpack count
    const currentData = userDoc.data();
    const oldPeriodStart = currentData?.currentPeriodStart?.toDate();
    const shouldResetTechpacks = !oldPeriodStart || currentPeriodStart > oldPeriodStart;
    
    const updateData: any = {
      subscriptionPlan: planName,
      subscriptionStatus: status,
      currentSubscriptionId: subscriptionId,
      currentPeriodStart: admin.firestore.Timestamp.fromDate(currentPeriodStart),
      currentPeriodEnd: admin.firestore.Timestamp.fromDate(currentPeriodEnd),
      lastUpdated: admin.firestore.FieldValue.serverTimestamp()
    };
    
    if (shouldResetTechpacks) {
      updateData.techpacksUsedThisMonth = 0;
    }
    
    await db.collection('users').doc(userId).update(updateData);
    
    console.log(`✅ Updated user ${userId} subscription to ${planName} (${status})`);
  } catch (error) {
    console.error(`❌ Error handling subscription updated:`, error);
  }
}

// Subscription deleted/canceled
async function handleSubscriptionDeleted(subscription: Stripe.Subscription) {
  const customerId = subscription.customer as string;
  
  try {
    const usersSnapshot = await db.collection('users')
      .where('stripeCustomerId', '==', customerId)
      .get();
    
    if (usersSnapshot.empty) {
      console.log(`❌ No user found for customer ${customerId}`);
      return;
    }
    
    const userDoc = usersSnapshot.docs[0];
    const userId = userDoc.id;
    
    await db.collection('users').doc(userId).update({
      subscriptionPlan: 'FREE',
      subscriptionStatus: 'canceled',
      currentSubscriptionId: null,
      techpacksUsedThisMonth: 0,
      lastUpdated: admin.firestore.FieldValue.serverTimestamp(),
      updatedBy: 'WEBHOOK' // Debug field to identify source
    });
    
    console.log(`🚀 WEBHOOK: Firebase updated - User ${userId} downgraded to FREE plan`);
  } catch (error) {
    console.error(`❌ Error handling subscription deleted:`, error);
  }
}

// Payment succeeded
async function handlePaymentSucceeded(invoice: Stripe.Invoice) {
  const customerId = invoice.customer as string;
  
  try {
    const usersSnapshot = await db.collection('users')
      .where('stripeCustomerId', '==', customerId)
      .get();
    
    if (usersSnapshot.empty) {
      console.log(`❌ No user found for customer ${customerId}`);
      return;
    }
    
    const userDoc = usersSnapshot.docs[0];
    const userId = userDoc.id;
    
    await db.collection('users').doc(userId).update({
      lastPaymentStatus: 'succeeded',
      lastPaymentDate: admin.firestore.FieldValue.serverTimestamp()
    });
    
    console.log(`✅ Payment succeeded for user ${userId}`);
  } catch (error) {
    console.error(`❌ Error handling payment succeeded:`, error);
  }
}

// Payment failed
async function handlePaymentFailed(invoice: Stripe.Invoice) {
  const customerId = invoice.customer as string;
  
  try {
    const usersSnapshot = await db.collection('users')
      .where('stripeCustomerId', '==', customerId)
      .get();
    
    if (usersSnapshot.empty) {
      console.log(`❌ No user found for customer ${customerId}`);
      return;
    }
    
    const userDoc = usersSnapshot.docs[0];
    const userId = userDoc.id;
    
    await db.collection('users').doc(userId).update({
      lastPaymentStatus: 'failed',
      lastPaymentDate: admin.firestore.FieldValue.serverTimestamp(),
      subscriptionStatus: 'past_due'
    });
    
    console.log(`⚠️ Payment failed for user ${userId}`);
  } catch (error) {
    console.error(`❌ Error handling payment failed:`, error);
  }
}

// Helper function to map price IDs to plan names
function getPlanNameFromPriceId(priceId: string): string {
  switch (priceId) {
    case 'price_1RxPj0B0j1hBhcav6vIJlc1C': // Your actual STARTER price ID
      return 'STARTER';
    case 'price_1RxPlDB0j1hBhcavA9lDOp9F': // Your actual PRO price ID
      return 'PRO';
    default:
      return 'FREE';
  }
}