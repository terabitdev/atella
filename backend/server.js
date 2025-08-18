const express = require('express');
const stripe = require('stripe')(process.env.STRIPE_SECRET_KEY);
const admin = require('firebase-admin');
const cors = require('cors');

// Initialize Firebase Admin
const serviceAccount = require('./firebase-service-account.json'); // Download from Firebase Console
admin.initializeApp({
  credential: admin.credential.cert(serviceAccount)
});

const db = admin.firestore();
const app = express();

// Middleware
app.use(cors());

// Stripe webhook endpoint - MUST use raw body parser
app.post('/stripe-webhook', express.raw({type: 'application/json'}), async (req, res) => {
  const sig = req.headers['stripe-signature'];
  const endpointSecret = process.env.STRIPE_WEBHOOK_SECRET;
  
  let event;
  
  try {
    event = stripe.webhooks.constructEvent(req.body, sig, endpointSecret);
  } catch (err) {
    console.log(`❌ Webhook signature verification failed.`, err.message);
    return res.status(400).send(`Webhook Error: ${err.message}`);
  }
  
  console.log(`✅ Received webhook: ${event.type}`);
  
  // Handle the event
  switch (event.type) {
    case 'customer.subscription.created':
      await handleSubscriptionCreated(event.data.object);
      break;
    case 'customer.subscription.updated':
      await handleSubscriptionUpdated(event.data.object);
      break;
    case 'customer.subscription.deleted':
      await handleSubscriptionDeleted(event.data.object);
      break;
    case 'invoice.payment_succeeded':
      await handlePaymentSucceeded(event.data.object);
      break;
    case 'invoice.payment_failed':
      await handlePaymentFailed(event.data.object);
      break;
    default:
      console.log(`🤷‍♀️ Unhandled event type: ${event.type}`);
  }
  
  res.json({received: true});
});

// Subscription created
async function handleSubscriptionCreated(subscription) {
  const customerId = subscription.customer;
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
      lastUpdated: admin.firestore.FieldValue.serverTimestamp()
    });
    
    console.log(`✅ Updated user ${userId} to ${planName} plan`);
  } catch (error) {
    console.error(`❌ Error handling subscription created:`, error);
  }
}

// Subscription updated
async function handleSubscriptionUpdated(subscription) {
  const customerId = subscription.customer;
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
    const oldPeriodStart = currentData.currentPeriodStart?.toDate();
    const shouldResetTechpacks = !oldPeriodStart || currentPeriodStart > oldPeriodStart;
    
    const updateData = {
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
async function handleSubscriptionDeleted(subscription) {
  const customerId = subscription.customer;
  
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
      lastUpdated: admin.firestore.FieldValue.serverTimestamp()
    });
    
    console.log(`✅ Downgraded user ${userId} to FREE plan`);
  } catch (error) {
    console.error(`❌ Error handling subscription deleted:`, error);
  }
}

// Payment succeeded
async function handlePaymentSucceeded(invoice) {
  const customerId = invoice.customer;
  
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
async function handlePaymentFailed(invoice) {
  const customerId = invoice.customer;
  
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
function getPlanNameFromPriceId(priceId) {
  switch (priceId) {
    case 'price_1RxPj0B0j1hBhcav6vIJlc1C': // Your actual STARTER price ID
      return 'STARTER';
    case 'price_1RxPlDB0j1hBhcavA9lDOp9F': // Your actual PRO price ID
      return 'PRO';
    default:
      return 'FREE';
  }
}

// Health check endpoint
app.get('/health', (req, res) => {
  res.json({ status: 'OK', timestamp: new Date().toISOString() });
});

const PORT = process.env.PORT || 3000;
app.listen(PORT, () => {
  console.log(`🚀 Server running on port ${PORT}`);
  console.log(`📡 Webhook endpoint: http://localhost:${PORT}/stripe-webhook`);
});