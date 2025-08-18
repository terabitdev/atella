import 'package:cloud_firestore/cloud_firestore.dart';

/// This class handles Stripe webhook events for subscription updates.
/// NOTE: This should be implemented on your backend server, not in the Flutter app.
/// This is provided as a reference for what the backend webhook handler should do.
/// 
/// Your backend webhook endpoint should:
/// 1. Verify the webhook signature from Stripe
/// 2. Process the event based on its type
/// 3. Update Firebase Firestore accordingly
class StripeWebhookHandler {
  static final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  /// Process webhook events from Stripe
  /// This method should be called from your backend server
  static Future<void> handleWebhookEvent(Map<String, dynamic> event) async {
    final String eventType = event['type'];
    final Map<String, dynamic> data = event['data']['object'];

    switch (eventType) {
      case 'customer.subscription.created':
        await _handleSubscriptionCreated(data);
        break;
      case 'customer.subscription.updated':
        await _handleSubscriptionUpdated(data);
        break;
      case 'customer.subscription.deleted':
        await _handleSubscriptionDeleted(data);
        break;
      case 'invoice.payment_succeeded':
        await _handlePaymentSucceeded(data);
        break;
      case 'invoice.payment_failed':
        await _handlePaymentFailed(data);
        break;
      default:
        print('Unhandled event type: $eventType');
    }
  }

  static Future<void> _handleSubscriptionCreated(Map<String, dynamic> subscription) async {
    final String customerId = subscription['customer'];
    final String subscriptionId = subscription['id'];
    final String status = subscription['status'];
    final String priceId = subscription['items']['data'][0]['price']['id'];
    final int currentPeriodEnd = subscription['current_period_end'];
    final int currentPeriodStart = subscription['current_period_start'];
    
    // Get user by Stripe customer ID
    final userQuery = await _firestore
        .collection('users')
        .where('stripeCustomerId', isEqualTo: customerId)
        .get();
    
    if (userQuery.docs.isNotEmpty) {
      final userId = userQuery.docs.first.id;
      final String planName = _getPlanNameFromPriceId(priceId);
      
      await _firestore.collection('users').doc(userId).update({
        'subscriptionPlan': planName,
        'subscriptionStatus': status,
        'currentSubscriptionId': subscriptionId,
        'currentPeriodStart': Timestamp.fromMillisecondsSinceEpoch(currentPeriodStart * 1000),
        'currentPeriodEnd': Timestamp.fromMillisecondsSinceEpoch(currentPeriodEnd * 1000),
        'techpacksUsedThisMonth': 0,
      });
    }
  }

  static Future<void> _handleSubscriptionUpdated(Map<String, dynamic> subscription) async {
    final String customerId = subscription['customer'];
    final String subscriptionId = subscription['id'];
    final String status = subscription['status'];
    final String priceId = subscription['items']['data'][0]['price']['id'];
    final int currentPeriodEnd = subscription['current_period_end'];
    final int currentPeriodStart = subscription['current_period_start'];
    
    // Get user by Stripe customer ID
    final userQuery = await _firestore
        .collection('users')
        .where('stripeCustomerId', isEqualTo: customerId)
        .get();
    
    if (userQuery.docs.isNotEmpty) {
      final userId = userQuery.docs.first.id;
      final String planName = _getPlanNameFromPriceId(priceId);
      
      Map<String, dynamic> updates = {
        'subscriptionPlan': planName,
        'subscriptionStatus': status,
        'currentSubscriptionId': subscriptionId,
        'currentPeriodStart': Timestamp.fromMillisecondsSinceEpoch(currentPeriodStart * 1000),
        'currentPeriodEnd': Timestamp.fromMillisecondsSinceEpoch(currentPeriodEnd * 1000),
      };
      
      // Reset techpack count if it's a new billing period
      final currentDoc = await _firestore.collection('users').doc(userId).get();
      final currentData = currentDoc.data();
      if (currentData != null && currentData['currentPeriodStart'] != null) {
        final oldPeriodStart = (currentData['currentPeriodStart'] as Timestamp).millisecondsSinceEpoch;
        if (oldPeriodStart < currentPeriodStart * 1000) {
          updates['techpacksUsedThisMonth'] = 0;
        }
      }
      
      await _firestore.collection('users').doc(userId).update(updates);
    }
  }

  static Future<void> _handleSubscriptionDeleted(Map<String, dynamic> subscription) async {
    final String customerId = subscription['customer'];
    
    // Get user by Stripe customer ID
    final userQuery = await _firestore
        .collection('users')
        .where('stripeCustomerId', isEqualTo: customerId)
        .get();
    
    if (userQuery.docs.isNotEmpty) {
      final userId = userQuery.docs.first.id;
      
      await _firestore.collection('users').doc(userId).update({
        'subscriptionPlan': 'FREE',
        'subscriptionStatus': 'canceled',
        'currentSubscriptionId': null,
        'techpacksUsedThisMonth': 0,
      });
    }
  }

  static Future<void> _handlePaymentSucceeded(Map<String, dynamic> invoice) async {
    final String customerId = invoice['customer'];
    final String subscriptionId = invoice['subscription'];
    
    // Get user by Stripe customer ID
    final userQuery = await _firestore
        .collection('users')
        .where('stripeCustomerId', isEqualTo: customerId)
        .get();
    
    if (userQuery.docs.isNotEmpty) {
      final userId = userQuery.docs.first.id;
      
      await _firestore.collection('users').doc(userId).update({
        'lastPaymentStatus': 'succeeded',
        'lastPaymentDate': FieldValue.serverTimestamp(),
      });
    }
  }

  static Future<void> _handlePaymentFailed(Map<String, dynamic> invoice) async {
    final String customerId = invoice['customer'];
    
    // Get user by Stripe customer ID
    final userQuery = await _firestore
        .collection('users')
        .where('stripeCustomerId', isEqualTo: customerId)
        .get();
    
    if (userQuery.docs.isNotEmpty) {
      final userId = userQuery.docs.first.id;
      
      await _firestore.collection('users').doc(userId).update({
        'lastPaymentStatus': 'failed',
        'lastPaymentDate': FieldValue.serverTimestamp(),
        'subscriptionStatus': 'past_due',
      });
    }
  }


  static String _getPlanNameFromPriceId(String priceId) {
    // Map your actual Stripe price IDs to plan names
    // These should match the price IDs you create in Stripe Dashboard
    switch (priceId) {
      case 'price_starter_id': // Replace with actual Stripe price ID
        return 'STARTER';
      case 'price_pro_id': // Replace with actual Stripe price ID
        return 'PRO';
      default:
        return 'FREE';
    }
  }
}

/// Example backend webhook endpoint (Node.js/Express)
/// This is what your backend should implement:
/// 
/// ```javascript
/// const stripe = require('stripe')(process.env.STRIPE_SECRET_KEY);
/// const admin = require('firebase-admin');
/// 
/// app.post('/stripe-webhook', express.raw({type: 'application/json'}), async (req, res) => {
///   const sig = req.headers['stripe-signature'];
///   const endpointSecret = process.env.STRIPE_WEBHOOK_SECRET;
///   
///   let event;
///   
///   try {
///     event = stripe.webhooks.constructEvent(req.body, sig, endpointSecret);
///   } catch (err) {
///     console.log(`Webhook Error: ${err.message}`);
///     return res.status(400).send(`Webhook Error: ${err.message}`);
///   }
///   
///   // Handle the event based on the examples above
///   // Update Firebase Firestore accordingly
///   
///   res.json({received: true});
/// });
/// ```