import { onRequest } from 'firebase-functions/v2/https';
import Stripe from 'stripe';
import { admin, db, stripe, FUNCTIONS_REGION, SERVICE_ACCOUNT } from '../lib/admin';
import { handleOrderPaymentSucceeded, handleOrderPaymentFailed } from '../orders/webhookHandlers';
import { sendAppsFlyerPurchaseEvent } from '../analytics/appsflyerS2S';

const stripeWebhookSecretKey = process.env.STRIPE_WEBHOOK_SECRET || '';

// Stripe webhook Cloud Function (2nd Gen)
export const stripeWebhook = onRequest(
  {
    serviceAccount: SERVICE_ACCOUNT,
    cors: true,
    region: FUNCTIONS_REGION,
  },
  async (req, res) => {
    const sig = req.headers['stripe-signature'] as string;
    const webhookSecret = stripeWebhookSecretKey;

    let event: Stripe.Event;

    try {
      // Must use raw body buffer — never the parsed req.body object
      const rawBody = (req as any).rawBody;
      if (!rawBody) {
        console.error('❌ WEBHOOK: rawBody is undefined — cannot verify signature');
        res.status(400).send('Webhook Error: raw body not available');
        return;
      }
      event = stripe.webhooks.constructEvent(rawBody, sig, webhookSecret);
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
      case 'payment_intent.succeeded':
        await handleOrderPaymentSucceeded(event.data.object as Stripe.PaymentIntent);
        break;
      case 'payment_intent.payment_failed':
        await handleOrderPaymentFailed(event.data.object as Stripe.PaymentIntent);
        break;
      default:
        console.log(`🤷‍♀️ Unhandled event type: ${event.type}`);
    }

    res.json({ received: true });
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
      updateData.designsGeneratedThisMonth = 0;
      if (isYearly) {
        updateData.techpacksUsedThisYear = 0;
        updateData.techpacksUsedThisMonth = 0;
      } else {
        updateData.techpacksUsedThisMonth = 0;
        updateData.techpacksUsedThisYear = 0;
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
    const { userId, userDoc } = await findUserByCustomerIdOrEmail(customerId);

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

      // Track first subscription payment only — skip monthly/yearly renewals
      if (invoice.billing_reason === 'subscription_create') {
        const userData = userDoc?.data();
        const appsflyerId = userData?.appsflyerId as string | undefined;
        const appsflyerPlatform = userData?.appsflyerPlatform as string | undefined;

        if (!appsflyerId) {
          console.log(
            `⚠️ AppsFlyer S2S: No appsflyerId for user ${userId}, skipping af_purchase`,
          );
        } else {
          const platform: 'android' | 'ios' =
            appsflyerPlatform === 'ios' ? 'ios' : 'android';
          const revenue = (invoice.amount_paid ?? 0) / 100;
          const currency = (invoice.currency ?? 'eur').toUpperCase();

          await sendAppsFlyerPurchaseEvent({
            appsflyerId,
            platform,
            customerUserId: userId,
            contentId: planName,
            revenue,
            currency,
          });
        }
      }
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
    case 'price_1SrIZmB0j1hBhcavLizS6xZ0':
    case 'price_1SokjDB0j1hBhcavV5F0hkvX':
      return 'STARTER';
    case 'price_1SrIZcB0j1hBhcaveKKfhFDc':
    case 'price_1Sokk3B0j1hBhcavbpjVtnGv':
      return 'STARTER_YEARLY';
    case 'price_1SrIZgB0j1hBhcavcgFGjJFy':
    case 'price_1SoklQB0j1hBhcavYA4erwqY':
      return 'PRO';
    case 'price_1SrIZVB0j1hBhcavd3DPsClC':
    case 'price_1SokkxB0j1hBhcaviwspqhPv':
      return 'PRO_YEARLY';
    case 'price_1SrIZQB0j1hBhcavuPe13RH2':
    case 'price_1SokmOB0j1hBhcavZWbByj8F':
      return 'STUDIO';
    case 'price_1SrIZLB0j1hBhcavy3NJMTzh':
    case 'price_1SokmqB0j1hBhcavGcXmnQEk':
      return 'STUDIO_YEARLY';
    default:
      return 'FREE';
  }
}
