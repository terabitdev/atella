import 'package:atella/Data/Models/subscription_plan.dart';
import 'package:atella/Data/Models/user_subscription.dart';
import 'package:flutter/material.dart';
import 'package:flutter_stripe/flutter_stripe.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:flutter_dotenv/flutter_dotenv.dart';

class StripeSubscriptionService {
  static final StripeSubscriptionService _instance = StripeSubscriptionService._internal();
  factory StripeSubscriptionService() => _instance;
  StripeSubscriptionService._internal();

  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;
  
  String get _stripeSecretKey => dotenv.env['StripeSecretKey'] ?? '';
  static const String _stripeApiUrl = 'https://api.stripe.com/v1';

  // Get current user's subscription
  Future<UserSubscription?> getCurrentUserSubscription() async {
    User? user = _auth.currentUser;
    if (user == null) return null;

    try {
      DocumentSnapshot doc = await _firestore.collection('users').doc(user.uid).get();
      if (doc.exists) {
        return UserSubscription.fromFirestore(doc);
      }
    } catch (e) {
      print('Error getting user subscription: $e');
    }
    return null;
  }

  // Create or get Stripe customer
  Future<String?> _createOrGetStripeCustomer(String email, String userId) async {
    try {
      // Check if user already has a Stripe customer ID
      DocumentSnapshot userDoc = await _firestore.collection('users').doc(userId).get();
      Map<String, dynamic>? userData = userDoc.data() as Map<String, dynamic>?;
      
      if (userData != null && userData['stripeCustomerId'] != null) {
        return userData['stripeCustomerId'];
      }

      // Create new Stripe customer
      final response = await http.post(
        Uri.parse('$_stripeApiUrl/customers'),
        headers: {
          'Authorization': 'Bearer $_stripeSecretKey',
          'Content-Type': 'application/x-www-form-urlencoded',
        },
        body: {
          'email': email,
          'metadata[firebase_uid]': userId,
        },
      );

      if (response.statusCode == 200) {
        final customerData = json.decode(response.body);
        String customerId = customerData['id'];
        
        // Save customer ID to Firebase
        await _firestore.collection('users').doc(userId).update({
          'stripeCustomerId': customerId,
        });
        
        return customerId;
      }
    } catch (e) {
      print('Error creating Stripe customer: $e');
    }
    return null;
  }

  // Create payment sheet for subscription
  Future<bool> createSubscriptionPaymentSheet(SubscriptionPlan plan) async {
    print('🔥 DEBUG: createSubscriptionPaymentSheet called for plan: ${plan.name}');
    try {
      User? user = _auth.currentUser;
      if (user == null) return false;

      // Get or create Stripe customer
      String? customerId = await _createOrGetStripeCustomer(user.email!, user.uid);
      if (customerId == null) return false;

      // Get the appropriate Stripe price ID based on billing period
      String priceId = plan.billingPeriod == BillingPeriod.YEARLY && plan.stripeYearlyPriceId != null
          ? plan.stripeYearlyPriceId!
          : plan.stripePriceId;
      
      // Create subscription on the backend
      final response = await http.post(
        Uri.parse('$_stripeApiUrl/subscriptions'),
        headers: {
          'Authorization': 'Bearer $_stripeSecretKey',
          'Content-Type': 'application/x-www-form-urlencoded',
        },
        body: {
          'customer': customerId,
          'items[0][price]': priceId,
          'payment_behavior': 'default_incomplete',
          'payment_settings[save_default_payment_method]': 'on_subscription',
          'expand[]': 'latest_invoice.payment_intent',
          'metadata[firebase_uid]': user.uid,
          'metadata[plan_name]': plan.name,
          'metadata[billing_period]': plan.billingPeriod == BillingPeriod.YEARLY ? 'YEARLY' : 'MONTHLY',
        },
      );

      if (response.statusCode == 200) {
        final subscriptionData = json.decode(response.body);
        final clientSecret = subscriptionData['latest_invoice']['payment_intent']['client_secret'];
        
        // Initialize payment sheet
        await Stripe.instance.initPaymentSheet(
          paymentSheetParameters: SetupPaymentSheetParameters(
            paymentIntentClientSecret: clientSecret,
            merchantDisplayName: 'Atella',
            customerId: customerId,
            customerEphemeralKeySecret: await _getEphemeralKey(customerId),
            style: ThemeMode.dark,
            
          ),
        );

        // Present payment sheet
        print('🔥 DEBUG: About to present payment sheet');
        await Stripe.instance.presentPaymentSheet();
        print('🔥 DEBUG: Payment sheet completed successfully');

        // NOTE: Firebase updates are now handled by webhooks only
        // No client-side updates to prevent dual updates
        print('✅ Payment completed successfully. Webhook will update Firebase automatically.');
        print('🔍 DEBUG: Plan being sent to webhook: ${plan.name}');
        print('🔍 DEBUG: Billing period: ${plan.billingPeriod}');
        print('🔍 DEBUG: Stripe Price ID used: $priceId');
        
        return true;
      }
    } catch (e) {
      if (e is StripeException) {
        print('Stripe error: ${e.error.message}');
      } else {
        print('Error creating subscription: $e');
      }
    }
    return false;
  }

  // Get ephemeral key for customer
  Future<String> _getEphemeralKey(String customerId) async {
    final response = await http.post(
      Uri.parse('$_stripeApiUrl/ephemeral_keys'),
      headers: {
        'Authorization': 'Bearer $_stripeSecretKey',
        'Stripe-Version': '2024-11-20.acacia',
        'Content-Type': 'application/x-www-form-urlencoded',
      },
      body: {
        'customer': customerId,
      },
    );

    if (response.statusCode == 200) {
      final data = json.decode(response.body);
      return data['secret'];
    }
    throw Exception('Failed to create ephemeral key');
  }

  // Update user subscription in Firebase
  Future<void> _updateUserSubscription(String userId, SubscriptionPlan plan, String subscriptionId) async {
    print('🔥 CLIENT-SIDE: Writing to Firebase - User: $userId, Plan: ${plan.name}, SubID: $subscriptionId');
    
    bool isYearly = plan.billingPeriod == BillingPeriod.YEARLY;
    int periodDays = isYearly ? 365 : 30;
    
    await _firestore.collection('users').doc(userId).update({
      'subscriptionPlan': plan.name,
      'subscriptionStatus': 'active',
      'currentSubscriptionId': subscriptionId,
      'billingPeriod': isYearly ? 'YEARLY' : 'MONTHLY',
      'currentPeriodStart': FieldValue.serverTimestamp(),
      'currentPeriodEnd': Timestamp.fromDate(DateTime.now().add(Duration(days: periodDays))),
      'techpacksUsedThisMonth': 0,
      'techpacksUsedThisYear': 0,
      'updatedBy': 'CLIENT-SIDE', // Debug field to identify source
    });
    print('🔥 CLIENT-SIDE: Firebase write completed successfully');
  }

  // Cancel subscription
  Future<bool> cancelSubscription() async {
    try {
      User? user = _auth.currentUser;
      if (user == null) return false;

      DocumentSnapshot userDoc = await _firestore.collection('users').doc(user.uid).get();
      Map<String, dynamic>? userData = userDoc.data() as Map<String, dynamic>?;
      
      if (userData == null || userData['currentSubscriptionId'] == null) {
        return false;
      }

      String subscriptionId = userData['currentSubscriptionId'];

      // Cancel subscription in Stripe
      final response = await http.delete(
        Uri.parse('$_stripeApiUrl/subscriptions/$subscriptionId'),
        headers: {
          'Authorization': 'Bearer $_stripeSecretKey',
        },
      );

      if (response.statusCode == 200) {
        // NOTE: Firebase updates are now handled by webhooks only
        // Client-side updates commented out to prevent dual updates
        // print('🔥 CLIENT-SIDE: About to cancel subscription in Firebase for user ${user.uid}');
        // await _firestore.collection('users').doc(user.uid).update({
        //   'subscriptionPlan': 'FREE',
        //   'subscriptionStatus': 'canceled',
        //   'currentSubscriptionId': null,
        //   'updatedBy': 'CLIENT-SIDE', // Debug field to identify source
        // });
        // print('🔥 CLIENT-SIDE: Firebase cancellation update completed');
        
        print('✅ Subscription cancelled successfully. Webhook will update Firebase automatically.');
        return true;
      }
    } catch (e) {
      print('Error canceling subscription: $e');
    }
    return false;
  }

  // Check if user can use premium feature
  Future<bool> canUsePremiumFeature(String feature) async {
    UserSubscription? subscription = await getCurrentUserSubscription();
    if (subscription == null) {
      print('❌ Cannot check feature access: No subscription found');
      return false;
    }

    bool canUse = false;
    switch (feature) {
      case 'techpack':
        canUse = subscription.canGenerateTechpack;
        print('🔍 Techpack access check: ${subscription.subscriptionPlan} plan, ${subscription.techpacksUsedThisMonth}/${subscription.totalAllowedTechpacks} used, can generate: $canUse');
        break;
      case 'pdf_export':
        canUse = subscription.subscriptionPlan != 'FREE';
        print('🔍 PDF export access check: ${subscription.subscriptionPlan} plan, access: $canUse');
        break;
      case 'manufacturers':
        canUse = subscription.subscriptionPlan != 'FREE';
        print('🔍 Manufacturers access check: ${subscription.subscriptionPlan} plan, access: $canUse');
        break;
      default:
        print('❌ Unknown feature: $feature');
        return false;
    }
    
    return canUse;
  }

  // Increment techpack usage
  Future<void> incrementTechpackUsage() async {
    User? user = _auth.currentUser;
    if (user == null) {
      print('❌ Cannot increment techpack usage: No authenticated user');
      return;
    }

    try {
      UserSubscription? subscription = await getCurrentUserSubscription();
      if (subscription == null) return;
      
      bool isYearly = subscription.billingPeriod == 'YEARLY' || subscription.subscriptionPlan.contains('YEARLY');
      
      Map<String, dynamic> updates = {};
      if (isYearly) {
        updates['techpacksUsedThisYear'] = FieldValue.increment(1);
      } else {
        updates['techpacksUsedThisMonth'] = FieldValue.increment(1);
      }
      
      await _firestore.collection('users').doc(user.uid).update(updates);
      print('✅ Incremented techpack usage for user: ${user.uid} (${isYearly ? 'yearly' : 'monthly'})');
      
      // Log current usage after increment
      final updatedSubscription = await getCurrentUserSubscription();
      if (updatedSubscription != null) {
        String maxTechpacks = '${updatedSubscription.totalAllowedTechpacks}';
        int techpacksUsed = isYearly ? updatedSubscription.techpacksUsedThisYear : updatedSubscription.techpacksUsedThisMonth;
        print('📊 Current techpack usage: $techpacksUsed/$maxTechpacks (${updatedSubscription.subscriptionPlan} plan)');
      }
    } catch (e) {
      print('❌ Error incrementing techpack usage: $e');
    }
  }

  // Increment design generation count
  Future<void> incrementDesignUsage() async {
    User? user = _auth.currentUser;
    if (user == null) {
      print('❌ Cannot increment design usage: No authenticated user');
      return;
    }

    try {
      await _firestore.collection('users').doc(user.uid).update({
        'designsGeneratedThisMonth': FieldValue.increment(1),
      });
      print('✅ Incremented design usage for user: ${user.uid}');
      
      // Log current usage after increment
      final updatedSubscription = await getCurrentUserSubscription();
      if (updatedSubscription != null) {
        print('📊 Current design usage: ${updatedSubscription.designCounterDisplay} (${updatedSubscription.subscriptionPlan} plan)');
      }
    } catch (e) {
      print('❌ Error incrementing design usage: $e');
    }
  }

  // Check if user can generate designs
  Future<bool> canGenerateDesign() async {
    UserSubscription? subscription = await getCurrentUserSubscription();
    if (subscription == null) {
      print('❌ Cannot check design generation access: No subscription found');
      return false;
    }

    bool canGenerate = subscription.canGenerateDesign;
    print('🔍 Design generation check: ${subscription.designCounterDisplay}, can generate: $canGenerate');
    return canGenerate;
  }

  // Purchase extra techpacks (one-time payment) 
  Future<bool> purchaseExtraTechpacks(int count, double price) async {
    try {
      User? user = _auth.currentUser;
      if (user == null) return false;

      // Get or create Stripe customer
      String? customerId = await _createOrGetStripeCustomer(user.email!, user.uid);
      if (customerId == null) return false;

      // Create payment intent for one-time payment
      final response = await http.post(
        Uri.parse('$_stripeApiUrl/payment_intents'),
        headers: {
          'Authorization': 'Bearer $_stripeSecretKey',
          'Content-Type': 'application/x-www-form-urlencoded',
        },
        body: {
          'amount': '${(price * 100).round()}', // Convert euros to cents
          'currency': 'eur',
          'customer': customerId,
          'description': 'Extra $count techpacks for this month',
          'metadata[firebase_uid]': user.uid,
          'metadata[extra_techpacks]': count.toString(),
        },
      );

      if (response.statusCode == 200) {
        final paymentIntentData = json.decode(response.body);
        final clientSecret = paymentIntentData['client_secret'];
        
        // Initialize payment sheet
        await Stripe.instance.initPaymentSheet(
          paymentSheetParameters: SetupPaymentSheetParameters(
            paymentIntentClientSecret: clientSecret,
            merchantDisplayName: 'Atella',
            customerId: customerId,
            customerEphemeralKeySecret: await _getEphemeralKey(customerId),
            style: ThemeMode.dark,
          ),
        );

        // Present payment sheet
        await Stripe.instance.presentPaymentSheet();
        
        // Payment completed successfully - update user's extra techpacks
        int packagesToAdd = count == 5 ? 1 : 2; // 5 techpacks = 1 package, 10 techpacks = 2 packages
        await _firestore.collection('users').doc(user.uid).update({
          'extraTechpacksPurchased': FieldValue.increment(packagesToAdd),
        });
        
        print('✅ Extra techpacks purchased successfully: $count techpacks for €$price');
        return true;
      }
    } catch (e) {
      if (e is StripeException) {
        print('Stripe error: ${e.error.message}');
      } else {
        print('Error purchasing extra techpacks: $e');
      }
    }
    return false;
  }

  // Purchase extra designs (one-time payment)
  Future<bool> purchaseExtraDesigns() async {
    try {
      User? user = _auth.currentUser;
      if (user == null) return false;

      // Get or create Stripe customer
      String? customerId = await _createOrGetStripeCustomer(user.email!, user.uid);
      if (customerId == null) return false;

      // Create payment intent for one-time payment
      final response = await http.post(
        Uri.parse('$_stripeApiUrl/payment_intents'),
        headers: {
          'Authorization': 'Bearer $_stripeSecretKey',
          'Content-Type': 'application/x-www-form-urlencoded',
        },
        body: {
          'amount': '399', // €3.99 in cents
          'currency': 'eur',
          'customer': customerId,
          'description': 'Extra 20 designs for this month',
          'metadata[firebase_uid]': user.uid,
          'metadata[extra_designs]': '20',
        },
      );

      if (response.statusCode == 200) {
        final paymentIntentData = json.decode(response.body);
        final clientSecret = paymentIntentData['client_secret'];
        
        // Initialize payment sheet
        await Stripe.instance.initPaymentSheet(
          paymentSheetParameters: SetupPaymentSheetParameters(
            paymentIntentClientSecret: clientSecret,
            merchantDisplayName: 'Atella',
            customerId: customerId,
            customerEphemeralKeySecret: await _getEphemeralKey(customerId),
            style: ThemeMode.dark,
          ),
        );

        // Present payment sheet
        await Stripe.instance.presentPaymentSheet();
        
        // Payment completed successfully - update user's extra designs
        await _firestore.collection('users').doc(user.uid).update({
          'extraDesignsPurchased': FieldValue.increment(1),
        });
        
        print('✅ Extra designs purchased successfully');
        return true;
      }
    } catch (e) {
      if (e is StripeException) {
        print('Stripe error: ${e.error.message}');
      } else {
        print('Error purchasing extra designs: $e');
      }
    }
    return false;
  }

  // Reset counts based on billing period (call this from a scheduled function)
  Future<void> resetMonthlyCounts(String userId) async {
    UserSubscription? subscription = await getCurrentUserSubscription();
    if (subscription == null) return;
    
    bool isYearly = subscription.billingPeriod == 'YEARLY' || subscription.subscriptionPlan.contains('YEARLY');
    int periodDays = isYearly ? 365 : 30;
    
    Map<String, dynamic> updates = {
      'extraDesignsPurchased': 0,
      'extraTechpacksPurchased': 0,
      'currentPeriodStart': FieldValue.serverTimestamp(),
      'currentPeriodEnd': Timestamp.fromDate(DateTime.now().add(Duration(days: periodDays))),
    };
    
    if (isYearly) {
      updates['techpacksUsedThisYear'] = 0;
      updates['designsGeneratedThisMonth'] = 0; // Still reset monthly for designs
    } else {
      updates['techpacksUsedThisMonth'] = 0;
      updates['designsGeneratedThisMonth'] = 0;
    }
    
    await _firestore.collection('users').doc(userId).update(updates);
  }

  // Legacy method - keeping for backward compatibility
  Future<void> resetMonthlyTechpackCount(String userId) async {
    await resetMonthlyCounts(userId);
  }
  
  // Check and handle monthly reset for current user
  Future<void> checkAndHandleMonthlyReset() async {
    User? user = _auth.currentUser;
    if (user == null) return;
    
    try {
      UserSubscription? subscription = await getCurrentUserSubscription();
      if (subscription == null) return;
      
      // Check if current period has ended
      if (subscription.currentPeriodEnd != null && 
          DateTime.now().isAfter(subscription.currentPeriodEnd!)) {
        
        // Reset the monthly usage counts
        await resetMonthlyCounts(user.uid);
        
        print('Monthly techpack count reset for user: ${user.uid}');
      }
    } catch (e) {
      print('Error checking monthly reset: $e');
    }
  }
  
  // Enhanced method that checks reset before checking premium features
  Future<bool> canUsePremiumFeatureWithReset(String feature) async {
    // First check and handle monthly reset
    await checkAndHandleMonthlyReset();
    
    // Then check if user can use the feature
    return await canUsePremiumFeature(feature);
  }
  
  // Get subscription status for UI display
  Future<Map<String, dynamic>> getSubscriptionStatus() async {
    UserSubscription? subscription = await getCurrentUserSubscription();
    if (subscription == null) {
      return {
        'plan': 'FREE',
        'displayName': 'Free',
        'remainingTechpacks': 0,
        'maxTechpacks': 0,
        'isActive': false,
        'periodEnd': null,
      };
    }
    
    return {
      'plan': subscription.subscriptionPlan,
      'displayName': _getPlanDisplayName(subscription.subscriptionPlan),
      'remainingTechpacks': subscription.remainingTechpacks,
      'maxTechpacks': subscription.subscriptionPlan == 'PRO' ? -1 : 
                      subscription.subscriptionPlan == 'STARTER' ? 3 : 0,
      'isActive': subscription.subscriptionStatus == 'active',
      'periodEnd': subscription.currentPeriodEnd,
    };
  }
  
  String _getPlanDisplayName(String plan) {
    switch (plan) {
      case 'FREE':
        return 'Free';
      case 'STARTER':
        return 'Starter (€9.99/month)';
      case 'STARTER_YEARLY':
        return 'Starter (€99/year)';
      case 'PRO':
        return 'Pro (€24.99/month)';
      case 'PRO_YEARLY':
        return 'Pro (€249/year)';
      default:
        return 'Free';
    }
  }

}