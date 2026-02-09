import * as functions from 'firebase-functions/v1';
import * as admin from 'firebase-admin';
import Stripe from 'stripe';

// Initialize Firebase Admin
admin.initializeApp();
const db = admin.firestore();

// Get Stripe keys from environment variables
const stripeSecretKey = process.env.STRIPE_SECRET_KEY || '';
const stripeWebhookSecretKey = process.env.STRIPE_WEBHOOK_SECRET || '';

// Initialize Stripe
const stripe = new Stripe(stripeSecretKey, {
  apiVersion: '2023-10-16',
});

// Stripe webhook Cloud Function (1st Gen)
export const stripeWebhook = functions.https.onRequest(async (req, res) => {
  const sig = req.headers['stripe-signature'] as string;
  const webhookSecret = stripeWebhookSecretKey;
  
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

// Helper function to find user by Stripe customer ID or email
async function findUserByCustomerIdOrEmail(customerId: string): Promise<{ userId: string | null; userDoc: FirebaseFirestore.DocumentSnapshot | null }> {
  try {
    // First, try to find user by Stripe customer ID
    let usersSnapshot = await db.collection('users')
      .where('stripeCustomerId', '==', customerId)
      .limit(1)
      .get();

    if (!usersSnapshot.empty) {
      const userDoc = usersSnapshot.docs[0];
      return { userId: userDoc.id, userDoc };
    }

    // If not found by customer ID, try to find by email from Stripe customer
    console.log(`🔍 User not found by customer ID, fetching customer email from Stripe...`);
    const customer = await stripe.customers.retrieve(customerId);

    if ('deleted' in customer || !customer.email) {
      console.log(`❌ Customer ${customerId} is deleted or has no email`);
      return { userId: null, userDoc: null };
    }

    const email = customer.email.toLowerCase().trim();
    console.log(`🔍 Searching for user with email: ${email}`);

    usersSnapshot = await db.collection('users')
      .where('email', '==', email)
      .limit(1)
      .get();

    if (usersSnapshot.empty) {
      console.log(`❌ No user found for email ${email}`);
      return { userId: null, userDoc: null };
    }

    const userDoc = usersSnapshot.docs[0];
    const userId = userDoc.id;

    // Update the user's stripeCustomerId for future webhooks
    await db.collection('users').doc(userId).update({
      stripeCustomerId: customerId
    });

    console.log(`✅ User ${userId} found by email and stripeCustomerId updated`);
    return { userId, userDoc };

  } catch (error) {
    console.error('❌ Error finding user:', error);
    return { userId: null, userDoc: null };
  }
}

// Subscription created
async function handleSubscriptionCreated(subscription: Stripe.Subscription) {
  const customerId = subscription.customer as string;
  const subscriptionId = subscription.id;
  const status = subscription.status;
  const priceId = subscription.items.data[0].price.id;
  const currentPeriodEnd = new Date(subscription.current_period_end * 1000);
  const currentPeriodStart = new Date(subscription.current_period_start * 1000);

  try {
    // Find user by Stripe customer ID or email
    const { userId } = await findUserByCustomerIdOrEmail(customerId);

    if (!userId) {
      console.log(`❌ No user found for customer ${customerId}`);
      return;
    }

    const planName = getPlanNameFromPriceId(priceId);

    console.log(`📋 Subscription created - Price ID: ${priceId} → Plan: ${planName}`);

    const isYearly = planName.includes('YEARLY');
    const billingPeriod = isYearly ? 'YEARLY' : 'MONTHLY';
    
    const updateData: any = {
      subscriptionPlan: planName,
      subscriptionStatus: status,
      currentSubscriptionId: subscriptionId,
      billingPeriod: billingPeriod,
      currentPeriodStart: admin.firestore.Timestamp.fromDate(currentPeriodStart),
      currentPeriodEnd: admin.firestore.Timestamp.fromDate(currentPeriodEnd),
      lastUpdated: admin.firestore.FieldValue.serverTimestamp(),
      updatedBy: 'WEBHOOK' // Debug field to identify source
    };
    
    // Reset all counters when creating a new subscription
    updateData.techpacksUsedThisMonth = 0;
    updateData.techpacksUsedThisYear = 0;
    updateData.designsGeneratedThisMonth = 0;  // Reset (unlimited for paid plans anyway)
    updateData.extraDesignsPurchased = 0;
    updateData.extraTechpacksPurchased = 0;

    await db.collection('users').doc(userId).update(updateData);

    console.log(`🚀 WEBHOOK: Firebase updated - User ${userId} to ${planName} plan (all counters reset)`);
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
    // Find user by Stripe customer ID or email
    const { userId, userDoc } = await findUserByCustomerIdOrEmail(customerId);

    if (!userId || !userDoc) {
      console.log(`❌ No user found for customer ${customerId}`);
      return;
    }

    const planName = getPlanNameFromPriceId(priceId);

    console.log(`📋 Subscription updated - Price ID: ${priceId} → Plan: ${planName}`);

    // Check if it's a new billing period to reset techpack count
    const currentData = userDoc.data();
    const oldPeriodStart = currentData?.currentPeriodStart?.toDate();
    const shouldResetTechpacks = !oldPeriodStart || currentPeriodStart > oldPeriodStart;
    
    const isYearly = planName.includes('YEARLY');
    const billingPeriod = isYearly ? 'YEARLY' : 'MONTHLY';
    
    const updateData: any = {
      subscriptionPlan: planName,
      subscriptionStatus: status,
      currentSubscriptionId: subscriptionId,
      billingPeriod: billingPeriod,
      currentPeriodStart: admin.firestore.Timestamp.fromDate(currentPeriodStart),
      currentPeriodEnd: admin.firestore.Timestamp.fromDate(currentPeriodEnd),
      lastUpdated: admin.firestore.FieldValue.serverTimestamp()
    };
    
    if (shouldResetTechpacks) {
      if (isYearly) {
        updateData.techpacksUsedThisYear = 0;
        updateData.techpacksUsedThisMonth = 0; // Keep monthly counter for designs
      } else {
        updateData.techpacksUsedThisMonth = 0;
        updateData.techpacksUsedThisYear = 0; // Initialize yearly counter
      }
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
    // Find user by Stripe customer ID or email
    const { userId } = await findUserByCustomerIdOrEmail(customerId);

    if (!userId) {
      console.log(`❌ No user found for customer ${customerId}`);
      return;
    }
    
    await db.collection('users').doc(userId).update({
      subscriptionPlan: 'FREE',
      subscriptionStatus: 'canceled',
      currentSubscriptionId: null,
      techpacksUsedThisMonth: 0,
      techpacksUsedThisYear: 0,
      designsGeneratedThisMonth: 0,  // Reset design counter for FREE plan limit
      extraDesignsPurchased: 0,
      extraTechpacksPurchased: 0,
      extraDesignsUsed: 0,  // Reset add-on usage counters
      extraTechpacksUsed: 0,  // Reset add-on usage counters
      lastUpdated: admin.firestore.FieldValue.serverTimestamp(),
      updatedBy: 'WEBHOOK' // Debug field to identify source
    });

    console.log(`🚀 WEBHOOK: Firebase updated - User ${userId} downgraded to FREE plan (all counters reset)`);
  } catch (error) {
    console.error(`❌ Error handling subscription deleted:`, error);
  }
}

// Payment succeeded
async function handlePaymentSucceeded(invoice: Stripe.Invoice) {
  const customerId = invoice.customer as string;

  try {
    // Find user by Stripe customer ID or email
    const { userId } = await findUserByCustomerIdOrEmail(customerId);

    if (!userId) {
      console.log(`❌ No user found for customer ${customerId}`);
      return;
    }

    // Update payment status
    const updateData: any = {
      lastPaymentStatus: 'succeeded',
      lastPaymentDate: admin.firestore.FieldValue.serverTimestamp()
    };

    // If this payment is for a subscription, also update the subscription plan
    if (invoice.subscription) {
      const subscriptionId = invoice.subscription as string;

      // Fetch the subscription details from Stripe to get the price ID
      const subscription = await stripe.subscriptions.retrieve(subscriptionId);
      const priceId = subscription.items.data[0].price.id;
      const planName = getPlanNameFromPriceId(priceId);
      const status = subscription.status;

      console.log(`📋 Payment for subscription - Price ID: ${priceId} → Plan: ${planName}`);
      const currentPeriodEnd = new Date(subscription.current_period_end * 1000);
      const currentPeriodStart = new Date(subscription.current_period_start * 1000);

      const isYearly = planName.includes('YEARLY');
      const billingPeriod = isYearly ? 'YEARLY' : 'MONTHLY';

      // Update subscription details
      updateData.subscriptionPlan = planName;
      updateData.subscriptionStatus = status;
      updateData.currentSubscriptionId = subscriptionId;
      updateData.billingPeriod = billingPeriod;
      updateData.currentPeriodStart = admin.firestore.Timestamp.fromDate(currentPeriodStart);
      updateData.currentPeriodEnd = admin.firestore.Timestamp.fromDate(currentPeriodEnd);
      updateData.lastUpdated = admin.firestore.FieldValue.serverTimestamp();
      updateData.updatedBy = 'WEBHOOK_PAYMENT';

      console.log(`✅ Payment succeeded for user ${userId} - Updating to ${planName} plan`);
    } else {
      console.log(`✅ Payment succeeded for user ${userId} - One-time payment (no subscription update)`);
    }

    await db.collection('users').doc(userId).update(updateData);
  } catch (error) {
    console.error(`❌ Error handling payment succeeded:`, error);
  }
}

// Payment failed
async function handlePaymentFailed(invoice: Stripe.Invoice) {
  const customerId = invoice.customer as string;

  try {
    // Find user by Stripe customer ID or email
    const { userId } = await findUserByCustomerIdOrEmail(customerId);

    if (!userId) {
      console.log(`❌ No user found for customer ${customerId}`);
      return;
    }
    
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
    case 'price_1SokjDB0j1hBhcavV5F0hkvX': // STARTER monthly
      return 'STARTER';
    case 'price_1Sokk3B0j1hBhcavbpjVtnGv': // STARTER yearly
      return 'STARTER_YEARLY';
    case 'price_1SoklQB0j1hBhcavYA4erwqY': // PRO monthly
      return 'PRO';
    case 'price_1SokkxB0j1hBhcaviwspqhPv': // PRO yearly
      return 'PRO_YEARLY';
    case 'price_1SokmOB0j1hBhcavZWbByj8F': // STUDIO monthly
      return 'STUDIO';
    case 'price_1SokmqB0j1hBhcavGcXmnQEk': // STUDIO yearly
      return 'STUDIO_YEARLY';
    default:
      return 'FREE';
  }
}

// HTTP Cloud Function to verify user for payment (checks existence and subscription status)
export const verifyUserForPayment = functions.https.onRequest(async (req, res) => {
  // Enable CORS for all origins (you can restrict this to your website domain)
  res.set('Access-Control-Allow-Origin', '*');
  res.set('Access-Control-Allow-Methods', 'POST, OPTIONS');
  res.set('Access-Control-Allow-Headers', 'Content-Type');

  // Handle preflight OPTIONS request
  if (req.method === 'OPTIONS') {
    res.status(204).send('');
    return;
  }

  // Only allow POST requests
  if (req.method !== 'POST') {
    res.status(405).json({ error: 'Method not allowed' });
    return;
  }

  const { email } = req.body;

  // Validate email parameter
  if (!email || typeof email !== 'string') {
    res.status(400).json({ error: 'Missing or invalid email parameter' });
    return;
  }

  try {
    console.log(`🔍 Verifying user for payment - email: ${email}`);

    // Query Firestore for user with this email
    const usersSnapshot = await db.collection('users')
      .where('email', '==', email.toLowerCase().trim())
      .limit(1)
      .get();

    if (usersSnapshot.empty) {
      console.log(`❌ No user found for email: ${email}`);
      res.json({ exists: false });
      return;
    }

    const userDoc = usersSnapshot.docs[0];
    const userId = userDoc.id;
    const userData = userDoc.data();

    console.log(`✅ User found: ${userId} for email: ${email}`);

    // Check if user has an active subscription
    const subscriptionPlan = userData.subscriptionPlan || 'FREE';
    const subscriptionStatus = userData.subscriptionStatus || '';

    // Define what counts as "already subscribed"
    // Active subscription = paid plan (not FREE) with active, trialing, or past_due status
    const isPaidPlan = subscriptionPlan !== 'FREE';
    const activeStatuses = ['active', 'trialing', 'past_due'];
    const hasActiveStatus = activeStatuses.includes(subscriptionStatus);
    const hasActiveSubscription = isPaidPlan && hasActiveStatus;

    // Build response - always include hasActiveSubscription as boolean
    const response: any = {
      exists: true,
      userId: userId,
      hasActiveSubscription: hasActiveSubscription
    };

    // If user has active subscription, include details
    if (hasActiveSubscription) {
      response.currentPlan = subscriptionPlan;
      response.subscriptionStatus = subscriptionStatus;

      // Include billing period if available
      if (userData.billingPeriod) {
        response.billingPeriod = userData.billingPeriod;
      }

      // Include subscription end date if available
      if (userData.currentPeriodEnd) {
        response.currentPeriodEnd = userData.currentPeriodEnd.toDate().toISOString();
      }

      console.log(`⚠️ User ${userId} already has active subscription: ${subscriptionPlan} (${subscriptionStatus})`);
    } else {
      console.log(`✅ User ${userId} can proceed to payment (current plan: ${subscriptionPlan})`);
    }

    res.json(response);

  } catch (error) {
    console.error('❌ Error verifying user for payment:', error);
    res.status(500).json({ error: 'Internal server error' });
  }
});