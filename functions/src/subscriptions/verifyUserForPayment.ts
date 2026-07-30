import { onRequest } from 'firebase-functions/v2/https';
import { db, FUNCTIONS_REGION, SERVICE_ACCOUNT } from '../lib/admin';

// HTTP Cloud Function to verify user for payment (2nd Gen)
export const verifyUserForPayment = onRequest(
  {
    serviceAccount: SERVICE_ACCOUNT,
    cors: true,
    region: FUNCTIONS_REGION,
  },
  async (req, res) => {
    // Handle preflight OPTIONS request (CORS already enabled in options)
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
