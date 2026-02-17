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
  static final StripeSubscriptionService _instance =
      StripeSubscriptionService._internal();
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
      DocumentSnapshot doc = await _firestore
          .collection('users')
          .doc(user.uid)
          .get();
      if (doc.exists) {
        return UserSubscription.fromFirestore(doc);
      }
    } catch (e) {
      print('Error getting user subscription: $e');
    }
    return null;
  }

  // Create or get Stripe customer
  Future<String?> _createOrGetStripeCustomer(
    String email,
    String userId,
  ) async {
    try {
      // Check if user already has a Stripe customer ID
      DocumentSnapshot userDoc = await _firestore
          .collection('users')
          .doc(userId)
          .get();
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
        body: {'email': email, 'metadata[firebase_uid]': userId},
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

  // COMMENTED OUT: In-app subscription payment removed - Users now subscribe via website
  // Subscriptions are now handled exclusively through https://atelia.app/
  // This code is preserved for potential future use
  /*
  // Create payment sheet for subscription
  Future<bool> createSubscriptionPaymentSheet(SubscriptionPlan plan) async {
    print(
      '🔥 DEBUG: createSubscriptionPaymentSheet called for plan: ${plan.name}',
    );
    try {
      User? user = _auth.currentUser;
      if (user == null) return false;

      // Get or create Stripe customer
      String? customerId = await _createOrGetStripeCustomer(
        user.email!,
        user.uid,
      );
      if (customerId == null) return false;

      // Get the appropriate Stripe price ID based on billing period
      String priceId =
          plan.billingPeriod == BillingPeriod.YEARLY &&
              plan.stripeYearlyPriceId != null
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
          'metadata[billing_period]': plan.billingPeriod == BillingPeriod.YEARLY
              ? 'YEARLY'
              : 'MONTHLY',
        },
      );

      if (response.statusCode == 200) {
        final subscriptionData = json.decode(response.body);
        final clientSecret =
            subscriptionData['latest_invoice']['payment_intent']['client_secret'];
        final subscriptionId = subscriptionData['id'];

        print('🔍 DEBUG: Created subscription with ID: $subscriptionId');

        // Initialize payment sheet
        await Stripe.instance.initPaymentSheet(
          paymentSheetParameters: SetupPaymentSheetParameters(
            paymentIntentClientSecret: clientSecret,
            merchantDisplayName: 'Atelia',
            customerId: customerId,
            customerEphemeralKeySecret: await _getEphemeralKey(customerId),
            style: ThemeMode.dark,
          ),
        );

        // Present payment sheet
        print('🔥 DEBUG: About to present payment sheet');
        bool paymentSuccessful = false;
        try {
          await Stripe.instance.presentPaymentSheet();
          print('🔥 DEBUG: Payment sheet completed successfully');
          paymentSuccessful = true;

          // NOTE: Firebase updates are now handled by webhooks only
          // No client-side updates to prevent dual updates
          print(
            '✅ Payment completed successfully. Webhook will update Firebase automatically.',
          );
          print('🔍 DEBUG: Plan being sent to webhook: ${plan.name}');
          print('🔍 DEBUG: Billing period: ${plan.billingPeriod}');
          print('🔍 DEBUG: Stripe Price ID used: $priceId');
        } catch (paymentSheetError) {
          // User dismissed payment sheet or payment failed
          print('⚠️ Payment sheet dismissed or failed: $paymentSheetError');
          paymentSuccessful = false;

          // Cancel the incomplete subscription in Stripe
          print('🔄 Cancelling incomplete subscription: $subscriptionId');
          try {
            final cancelResponse = await http.delete(
              Uri.parse('$_stripeApiUrl/subscriptions/$subscriptionId'),
              headers: {'Authorization': 'Bearer $_stripeSecretKey'},
            );

            if (cancelResponse.statusCode == 200) {
              print('✅ Incomplete subscription cancelled successfully');
            } else {
              print(
                '⚠️ Failed to cancel incomplete subscription: ${cancelResponse.statusCode}',
              );
            }
          } catch (cancelError) {
            print('❌ Error cancelling incomplete subscription: $cancelError');
          }

          // CRITICAL: Clean up any Firestore data that might have been created
          print(
            '🧹 Cleaning up any incomplete subscription data from Firestore',
          );
          try {
            DocumentSnapshot userDoc = await _firestore
                .collection('users')
                .doc(user.uid)
                .get();
            Map<String, dynamic>? userData =
                userDoc.data() as Map<String, dynamic>?;

            // If this subscription ID matches what's in Firestore, revert to FREE
            if (userData != null &&
                userData['currentSubscriptionId'] == subscriptionId) {
              await _revertToFreePlan(user.uid);
              print('✅ Reverted user to FREE plan due to cancelled payment');
            }
          } catch (cleanupError) {
            print('❌ Error cleaning up Firestore data: $cleanupError');
          }

          // Rethrow the original error
          rethrow;
        } finally {
          // EXTRA SAFEGUARD: Always validate subscription status after payment sheet interaction
          // This catches edge cases where the catch block might not execute properly
          if (!paymentSuccessful) {
            print(
              '🔍 SAFEGUARD: Validating subscription status as extra precaution...',
            );
            await _validateAndCleanupFailedSubscription(
              user.uid,
              subscriptionId,
            );
          }
        }

        return paymentSuccessful;
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
  */

  // Get ephemeral key for customer
  Future<String> _getEphemeralKey(String customerId) async {
    final response = await http.post(
      Uri.parse('$_stripeApiUrl/ephemeral_keys'),
      headers: {
        'Authorization': 'Bearer $_stripeSecretKey',
        'Stripe-Version': '2024-11-20.acacia',
        'Content-Type': 'application/x-www-form-urlencoded',
      },
      body: {'customer': customerId},
    );

    if (response.statusCode == 200) {
      final data = json.decode(response.body);
      return data['secret'];
    }
    throw Exception('Failed to create ephemeral key');
  }

  Future<bool> cancelSubscription() async {
    try {
      User? user = _auth.currentUser;
      if (user == null) {
        print('❌ Cancel subscription failed: No authenticated user');
        return false;
      }

      print('🔍 Cancelling subscription for user: ${user.uid}');
      DocumentSnapshot userDoc = await _firestore
          .collection('users')
          .doc(user.uid)
          .get();
      Map<String, dynamic>? userData = userDoc.data() as Map<String, dynamic>?;

      if (userData == null) {
        print('❌ Cancel subscription failed: No user data found');
        return false;
      }

      if (userData['currentSubscriptionId'] == null) {
        print('❌ Cancel subscription failed: No subscription ID found');
        return false;
      }

      String subscriptionId = userData['currentSubscriptionId'];
      print('🔍 Attempting to cancel subscription: $subscriptionId');

      // Cancel subscription in Stripe
      final response = await http.delete(
        Uri.parse('$_stripeApiUrl/subscriptions/$subscriptionId'),
        headers: {'Authorization': 'Bearer $_stripeSecretKey'},
      );

      print('📤 Stripe API response status: ${response.statusCode}');
      print('📤 Stripe API response body: ${response.body}');

      if (response.statusCode == 200) {
        print('✅ Subscription cancelled successfully in Stripe.');

        // Proactively update Firebase immediately (don't wait for webhook)
        print('🔄 Updating Firebase immediately to reset all counters...');
        await _firestore.collection('users').doc(user.uid).update({
          'subscriptionPlan': 'FREE',
          'subscriptionStatus': 'canceled',
          'currentSubscriptionId': null,
          'techpacksUsedThisMonth': 0,
          'techpacksUsedThisYear': 0,
          // NOTE: Do NOT reset designsGeneratedThisMonth
          // Free designs are now tracked via email-based quota service (design_quotas collection)
          'extraDesignsPurchased': 0,
          'extraTechpacksPurchased': 0,
          'extraDesignsUsed': 0,
          'extraTechpacksUsed': 0,
        });
        print(
          '✅ Firebase updated immediately. Webhook will also run as backup.',
        );
        return true;
      } else if (response.statusCode == 404) {
        print('⚠️ Subscription not found in Stripe - cleaning up user data');
        // Subscription doesn't exist in Stripe, so clean up user's subscription data
        await _firestore.collection('users').doc(user.uid).update({
          'currentSubscriptionId': null,
          'subscriptionPlan': 'FREE',
          'subscriptionStatus': 'cancelled',
          'planEndDate': null,
          'techpacksUsedThisMonth': 0,
          'techpacksUsedThisYear': 0,
          // NOTE: Do NOT reset designsGeneratedThisMonth
          // Free designs are now tracked via email-based quota service (design_quotas collection)
          'extraDesignsPurchased': 0,
          'extraTechpacksPurchased': 0,
          'extraDesignsUsed': 0,
          'extraTechpacksUsed': 0,
        });
        print('✅ User subscription data cleaned up - user is now on FREE plan');
        return true;
      } else {
        print(
          '❌ Failed to cancel subscription. Status: ${response.statusCode}, Body: ${response.body}',
        );
      }
    } catch (e) {
      print('❌ Error canceling subscription: $e');
    }
    return false;
  }

  // One-time reset function for cleaning up add-on counters
  Future<void> resetAddOnCounters() async {
    User? user = _auth.currentUser;
    if (user == null) {
      print('❌ Reset failed: No authenticated user');
      return;
    }

    try {
      print('🔄 Resetting add-on counters for user: ${user.uid}');

      final docRef = _firestore.collection('users').doc(user.uid);

      // Read current values before reset
      DocumentSnapshot userDoc = await docRef.get();
      Map<String, dynamic>? userData = userDoc.data() as Map<String, dynamic>?;

      print('📊 Current values before reset:');
      print('  extraDesignsPurchased: ${userData?['extraDesignsPurchased']}');
      print(
        '  extraTechpacksPurchased: ${userData?['extraTechpacksPurchased']}',
      );
      print('  extraDesignsUsed: ${userData?['extraDesignsUsed']}');
      print('  extraTechpacksUsed: ${userData?['extraTechpacksUsed']}');

      // Use Firestore transaction to ensure atomic update
      print('📝 Using Firestore transaction for guaranteed update...');

      await _firestore.runTransaction((transaction) async {
        // Get the document
        DocumentSnapshot snapshot = await transaction.get(docRef);

        if (!snapshot.exists) {
          throw Exception('Document does not exist!');
        }

        // Update all fields in a single transaction
        transaction.update(docRef, {
          'extraDesignsPurchased': 0,
          'extraTechpacksPurchased': 0,
          'extraDesignsUsed': 0,
          'extraTechpacksUsed': 0,
        });

        print(
          '   ✓ Transaction prepared - will update all 4 fields atomically',
        );
      });

      print('✅ Transaction completed successfully');

      // Wait for Firestore to propagate
      await Future.delayed(Duration(seconds: 1));

      // Read values after reset to confirm - force fresh read
      userDoc = await docRef.get(GetOptions(source: Source.server));
      userData = userDoc.data() as Map<String, dynamic>?;

      print('📊 Values after reset (fresh from server):');
      print('  extraDesignsPurchased: ${userData?['extraDesignsPurchased']}');
      print(
        '  extraTechpacksPurchased: ${userData?['extraTechpacksPurchased']}',
      );
      print('  extraDesignsUsed: ${userData?['extraDesignsUsed']}');
      print('  extraTechpacksUsed: ${userData?['extraTechpacksUsed']}');

      // Print ALL fields to debug
      print('📋 All extra/design related fields:');
      userData?.forEach((key, value) {
        if (key.toLowerCase().contains('extra') ||
            key.toLowerCase().contains('design')) {
          print('     $key: $value');
        }
      });

      // If extraDesignsUsed is STILL not 0, there's something very wrong
      if (userData?['extraDesignsUsed'] != 0) {
        print(
          '🚨 CRITICAL: extraDesignsUsed did NOT reset! Current value: ${userData?['extraDesignsUsed']}',
        );
        print('🚨 This suggests either:');
        print('   1. Firestore security rules are blocking the write');
        print('   2. A Cloud Function is reverting the value');
        print('   3. There\'s a listener overwriting the value');
        print(
          '   4. You\'re looking at a different document in Firebase Console',
        );
      }
    } catch (e) {
      print('❌ Error resetting add-on counters: $e');
      print('❌ Stack trace: ${StackTrace.current}');
    }
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
        print(
          '🔍 Techpack access check: ${subscription.subscriptionPlan} plan, ${subscription.techpacksUsedThisMonth}/${subscription.totalAllowedTechpacks} used, can generate: $canUse',
        );
        break;
      case 'pdf_export':
        canUse = subscription.subscriptionPlan != 'FREE';
        print(
          '🔍 PDF export access check: ${subscription.subscriptionPlan} plan, access: $canUse',
        );
        break;
      case 'manufacturers':
        canUse = subscription.subscriptionPlan != 'FREE';
        print(
          '🔍 Manufacturers access check: ${subscription.subscriptionPlan} plan, access: $canUse',
        );
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

      bool isYearly =
          subscription.billingPeriod == 'YEARLY' ||
          subscription.subscriptionPlan.contains('YEARLY');

      // Determine base limit
      int baseLimit = 0;
      if (subscription.subscriptionPlan.startsWith('STUDIO')) {
        baseLimit = 10;
      } else if (subscription.subscriptionPlan.startsWith('PRO')) {
        baseLimit = 6;
      } else if (subscription.subscriptionPlan.startsWith('STARTER')) {
        baseLimit = 2;
      }

      // Current usage counts BEFORE increment
      int currentMonthlyUsage = subscription.techpacksUsedThisMonth;
      int currentExtraUsage = subscription.extraTechpacksUsed;
      int extrasPurchased = subscription.extraTechpacksPurchased;

      print('🔍 BEFORE INCREMENT:');
      print('   Base limit: $baseLimit');
      print('   Monthly usage: $currentMonthlyUsage');
      print('   Extras purchased: $extrasPurchased');
      print('   Extras used: $currentExtraUsage');

      // Determine if this generation will use base quota or extras
      bool usingExtra = currentMonthlyUsage >= baseLimit && extrasPurchased > 0;

      Map<String, dynamic> updates = {
        // Always increment monthly counter - this tracks TOTAL techpacks generated
        'techpacksUsedThisMonth': FieldValue.increment(1),
      };

      // ONLY increment extraTechpacksUsed if:
      // 1. User has purchased add-ons (extraTechpacksPurchased > 0)
      // 2. User has ALREADY exceeded their base quota (current usage >= base limit)
      if (usingExtra) {
        // User is consuming from add-on pool
        updates['extraTechpacksUsed'] = FieldValue.increment(1);
        print(
          '📦 Consuming EXTRA techpack (will be: ${currentExtraUsage + 1}/$extrasPurchased)',
        );
      } else {
        print(
          '📦 Consuming BASE techpack (will be: ${currentMonthlyUsage + 1}/$baseLimit)',
        );
      }

      // For yearly plans, also increment yearly counter
      if (isYearly) {
        updates['techpacksUsedThisYear'] = FieldValue.increment(1);
      }

      await _firestore.collection('users').doc(user.uid).update(updates);
      print(
        '✅ Incremented techpack usage for user: ${user.uid} (${isYearly ? 'yearly + monthly' : 'monthly'})',
      );

      // Log current usage after increment
      final updatedSubscription = await getCurrentUserSubscription();
      if (updatedSubscription != null) {
        String maxTechpacks = '${updatedSubscription.totalAllowedTechpacks}';
        print('🔍 AFTER INCREMENT:');
        print(
          '   Monthly usage: ${updatedSubscription.techpacksUsedThisMonth}/$maxTechpacks',
        );
        print(
          '   Extras used: ${updatedSubscription.extraTechpacksUsed}/$extrasPurchased',
        );
        print(
          '   Plan: ${updatedSubscription.subscriptionPlan}',
        );
        if (isYearly) {
          print(
            '   Yearly usage: ${updatedSubscription.techpacksUsedThisYear}',
          );
        }

        // Check if all add-ons are fully consumed and reset if needed
        await _checkAndResetFullyConsumedAddons(user.uid, updatedSubscription);
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
      UserSubscription? subscription = await getCurrentUserSubscription();
      if (subscription == null) return;

      // For FREE plan users, do nothing - email-based quota is handled in final_detail_controller
      if (subscription.subscriptionPlan == 'FREE') {
        print('ℹ️ FREE plan user - design usage tracked via email-based quota service');
        return;
      }

      // For paid plans, use the regular counter
      // Determine base limit
      int baseLimit = 3; // FREE (fallback)
      if (subscription.subscriptionPlan.startsWith('STUDIO')) {
        baseLimit = 25;
      } else if (subscription.subscriptionPlan.startsWith('PRO')) {
        baseLimit = 12;
      } else if (subscription.subscriptionPlan.startsWith('STARTER')) {
        baseLimit = 5;
      }

      // Current usage counts BEFORE increment
      int currentDesignUsage = subscription.designsGeneratedThisMonth;
      int currentExtraUsage = subscription.extraDesignsUsed;
      int extrasPurchased = subscription.extraDesignsPurchased;

      print('🔍 DESIGN BEFORE INCREMENT:');
      print('   Base limit: $baseLimit');
      print('   Designs generated: $currentDesignUsage');
      print('   Extra packs purchased: $extrasPurchased (${extrasPurchased * 5} designs)');
      print('   Extras used: $currentExtraUsage');

      // Determine if this generation will use base quota or extras
      bool usingExtra = currentDesignUsage >= baseLimit && extrasPurchased > 0;

      Map<String, dynamic> updates = {
        // Always increment monthly counter - this tracks TOTAL designs generated
        'designsGeneratedThisMonth': FieldValue.increment(1),
      };

      // ONLY increment extraDesignsUsed if:
      // 1. User has purchased add-ons (extraDesignsPurchased > 0)
      // 2. User has ALREADY exceeded their base quota (current usage >= base limit)
      if (usingExtra) {
        // User is consuming from add-on pool
        updates['extraDesignsUsed'] = FieldValue.increment(1);
        print(
          '📦 Consuming EXTRA design (will be: ${currentExtraUsage + 1}/${extrasPurchased * 5})',
        );
      } else {
        print(
          '📦 Consuming BASE design (will be: ${currentDesignUsage + 1}/$baseLimit)',
        );
      }

      await _firestore.collection('users').doc(user.uid).update(updates);
      print('✅ Incremented design usage for user: ${user.uid}');

      // Log current usage after increment
      final updatedSubscription = await getCurrentUserSubscription();
      if (updatedSubscription != null) {
        int totalAllowed = updatedSubscription.getTotalAllowedDesigns();
        print('🔍 DESIGN AFTER INCREMENT:');
        print(
          '   Designs generated: ${updatedSubscription.designsGeneratedThisMonth}/$totalAllowed',
        );
        print(
          '   Extras used: ${updatedSubscription.extraDesignsUsed}/${extrasPurchased * 5}',
        );
        print(
          '   Plan: ${updatedSubscription.subscriptionPlan}',
        );

        // Check if all add-ons are fully consumed and reset if needed
        await _checkAndResetFullyConsumedAddons(user.uid, updatedSubscription);
      }
    } catch (e) {
      print('❌ Error incrementing design usage: $e');
    }
  }

  // Check if add-ons are fully consumed and reset them
  Future<void> _checkAndResetFullyConsumedAddons(
    String userId,
    UserSubscription subscription,
  ) async {
    Map<String, dynamic> updates = {};

    // NOTE: Add-ons now accumulate - we don't reset them when fully consumed
    // Users can purchase multiple add-on packs and the total will accumulate
    // Example: Buy 1 pack (5 designs) + use all 5 + buy another pack = 2 packs total (10 designs)

    // Check design add-ons - REMOVED AUTO-RESET
    // int totalDesignAddons = subscription.extraDesignsPurchased * 5;
    // if (subscription.extraDesignsUsed >= totalDesignAddons && totalDesignAddons > 0) {
    //   updates['extraDesignsPurchased'] = 0;
    //   updates['extraDesignsUsed'] = 0;
    //   print('♻️ All design add-ons fully consumed, resetting to 0');
    // }

    // Check techpack add-ons - REMOVED AUTO-RESET
    // int totalTechpackAddons = subscription.extraTechpacksPurchased * 1;
    // if (subscription.extraTechpacksUsed >= totalTechpackAddons && totalTechpackAddons > 0) {
    //   updates['extraTechpacksPurchased'] = 0;
    //   updates['extraTechpacksUsed'] = 0;
    //   print('♻️ All techpack add-ons fully consumed, resetting to 0');
    // }

    if (updates.isNotEmpty) {
      await _firestore.collection('users').doc(userId).update(updates);
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
    print(
      '🔍 Design generation check: ${subscription.designCounterDisplay}, can generate: $canGenerate',
    );
    return canGenerate;
  }

  // COMMENTED OUT: Stripe add-on purchases replaced with RevenueCat
  // Now using RevenueCatService for add-on purchases
  // This code is preserved for reference
  /*
  Future<bool> purchaseExtraTechpacks(int count, double price) async {
    try {
      User? user = _auth.currentUser;
      if (user == null) return false;

      // Get or create Stripe customer
      String? customerId = await _createOrGetStripeCustomer(
        user.email!,
        user.uid,
      );
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
            merchantDisplayName: 'Atelia',
            customerId: customerId,
            customerEphemeralKeySecret: await _getEphemeralKey(customerId),
            style: ThemeMode.dark,
          ),
        );

        // Present payment sheet
        await Stripe.instance.presentPaymentSheet();

        // Payment completed successfully - update user's extra techpacks
        // Each add-on = +1 techpack (€5.99)
        await _firestore.collection('users').doc(user.uid).update({
          'extraTechpacksPurchased': FieldValue.increment(count),
        });

        print(
          '✅ Extra techpacks purchased successfully: $count techpacks for €$price',
        );
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
  */

  // COMMENTED OUT: Stripe add-on purchases replaced with RevenueCat
  // Now using RevenueCatService for add-on purchases
  // This code is preserved for reference
  /*
  Future<bool> purchaseExtraDesigns() async {
    try {
      User? user = _auth.currentUser;
      if (user == null) return false;

      // Get or create Stripe customer
      String? customerId = await _createOrGetStripeCustomer(
        user.email!,
        user.uid,
      );
      if (customerId == null) return false;

      // Create payment intent for one-time payment
      final response = await http.post(
        Uri.parse('$_stripeApiUrl/payment_intents'),
        headers: {
          'Authorization': 'Bearer $_stripeSecretKey',
          'Content-Type': 'application/x-www-form-urlencoded',
        },
        body: {
          'amount': '999', // €9.99 in cents
          'currency': 'eur',
          'customer': customerId,
          'description': 'Extra 5 AI designs (one-time purchase)',
          'metadata[firebase_uid]': user.uid,
          'metadata[extra_designs]': '5',
        },
      );

      if (response.statusCode == 200) {
        final paymentIntentData = json.decode(response.body);
        final clientSecret = paymentIntentData['client_secret'];

        // Initialize payment sheet
        await Stripe.instance.initPaymentSheet(
          paymentSheetParameters: SetupPaymentSheetParameters(
            paymentIntentClientSecret: clientSecret,
            merchantDisplayName: 'Atelia',
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
  */

  // Reset counts based on billing period (call this from a scheduled function)
  Future<void> resetMonthlyCounts(String userId) async {
    UserSubscription? subscription = await getCurrentUserSubscription();
    if (subscription == null) return;

    Map<String, dynamic> updates = {
      // Reset monthly usage counters only
      'techpacksUsedThisMonth': 0,
      'designsGeneratedThisMonth': 0,
      // NOTE: Add-ons (extraDesignsPurchased, extraTechpacksPurchased, extraDesignsUsed, extraTechpacksUsed) are NOT reset monthly
      // They accumulate across months - users can purchase multiple add-on packs
      // Example: Buy pack in Jan + buy pack in Feb = 2 packs total available
      'currentPeriodStart': FieldValue.serverTimestamp(),
      'currentPeriodEnd': Timestamp.fromDate(
        DateTime.now().add(Duration(days: 30)),
      ), // Always 30 days for monthly reset
    };

    // Note: techpacksUsedThisYear is only reset at the yearly billing cycle, not monthly
    // This is handled separately in a yearly reset function if needed

    await _firestore.collection('users').doc(userId).update(updates);
  }

  // Reset yearly counts for yearly subscriptions (call this from a scheduled function)
  Future<void> resetYearlyCounts(String userId) async {
    UserSubscription? subscription = await getCurrentUserSubscription();
    if (subscription == null) return;

    // Only reset yearly counter if user has a yearly subscription
    bool isYearly =
        subscription.billingPeriod == 'YEARLY' ||
        subscription.subscriptionPlan.contains('YEARLY');
    if (!isYearly) return;

    await _firestore.collection('users').doc(userId).update({
      'techpacksUsedThisYear': 0,
      // Note: Monthly counters are reset separately every month
    });

    print('✅ Yearly techpack count reset for user: $userId');
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

      // Check if current period has ended (for paid plans)
      if (subscription.currentPeriodEnd != null &&
          DateTime.now().isAfter(subscription.currentPeriodEnd!)) {
        // Reset the monthly usage counts
        await resetMonthlyCounts(user.uid);

        print('Monthly techpack count reset for user: ${user.uid}');
      }

      // Free design reset is now handled by email-based quota service
      // (no longer tracking freeDesignsGeneratedThisMonth in user document)
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
      'maxTechpacks': subscription.subscriptionPlan.startsWith('PRO')
          ? -1
          : subscription.subscriptionPlan.startsWith('STARTER')
          ? 2
          : 0,
      'isActive': subscription.subscriptionStatus == 'active',
      'periodEnd': subscription.currentPeriodEnd,
    };
  }

  String _getPlanDisplayName(String plan) {
    switch (plan) {
      case 'FREE':
        return 'Free';
      case 'STARTER':
        return 'Starter (€19.99/month)';
      case 'STARTER_YEARLY':
        return 'Starter (€199.99/year)';
      case 'PRO':
        return 'Pro (€49.99/month)';
      case 'PRO_YEARLY':
        return 'Pro (€499.99/year)';
      case 'STUDIO':
        return 'Studio (€99.99/month)';
      case 'STUDIO_YEARLY':
        return 'Studio (€999.99/year)';
      default:
        return 'Free';
    }
  }

  /// Validate subscription status from Stripe API
  /// Returns true if subscription is active and paid, false otherwise
  Future<bool> _validateStripeSubscriptionStatus(String subscriptionId) async {
    try {
      print('🔍 Validating Stripe subscription status: $subscriptionId');

      final response = await http.get(
        Uri.parse('$_stripeApiUrl/subscriptions/$subscriptionId'),
        headers: {'Authorization': 'Bearer $_stripeSecretKey'},
      );

      if (response.statusCode == 200) {
        final subscriptionData = json.decode(response.body);
        final status = subscriptionData['status'];

        print('🔍 Stripe subscription status: $status');

        // Valid statuses: 'active', 'trialing'
        // Invalid statuses: 'incomplete', 'incomplete_expired', 'past_due', 'canceled', 'unpaid'
        return status == 'active' || status == 'trialing';
      } else if (response.statusCode == 404) {
        print('⚠️ Subscription not found in Stripe');
        return false;
      } else {
        print('⚠️ Failed to validate subscription: ${response.statusCode}');
        return false;
      }
    } catch (e) {
      print('❌ Error validating subscription status: $e');
      return false;
    }
  }

  /// Validate and clean up incomplete/unpaid subscriptions on app launch
  /// This fixes the issue where users close the app before completing payment
  Future<void> validateAndCleanupSubscription() async {
    User? user = _auth.currentUser;
    if (user == null) return;

    try {
      print('🔍 Validating subscription for user: ${user.uid}');

      DocumentSnapshot userDoc = await _firestore
          .collection('users')
          .doc(user.uid)
          .get();
      Map<String, dynamic>? userData = userDoc.data() as Map<String, dynamic>?;

      if (userData == null) return;

      String? subscriptionId = userData['currentSubscriptionId'];
      String subscriptionPlan = userData['subscriptionPlan'] ?? 'FREE';

      // If user has FREE plan, no validation needed
      if (subscriptionPlan == 'FREE') {
        print('✅ User is on FREE plan, no validation needed');
        return;
      }

      // If user has a paid plan but no subscription ID, revert to FREE
      if (subscriptionId == null || subscriptionId.isEmpty) {
        print(
          '⚠️ User has paid plan but no subscription ID, reverting to FREE',
        );
        await _revertToFreePlan(user.uid);
        return;
      }

      // Validate subscription status from Stripe
      bool isValid = await _validateStripeSubscriptionStatus(subscriptionId);

      if (!isValid) {
        print(
          '❌ Subscription is not valid (incomplete/unpaid/cancelled), reverting to FREE',
        );
        await _revertToFreePlan(user.uid);
      } else {
        print('✅ Subscription is valid and active');
      }
    } catch (e) {
      print('❌ Error during subscription validation: $e');
    }
  }

  /// Revert user to FREE plan and clean up subscription data
  Future<void> _revertToFreePlan(String userId) async {
    try {
      await _firestore.collection('users').doc(userId).update({
        'subscriptionPlan': 'FREE',
        'subscriptionStatus': 'cancelled',
        'currentSubscriptionId': null,
        'techpacksUsedThisMonth': 0,
        'techpacksUsedThisYear': 0,
        // NOTE: Do NOT reset designsGeneratedThisMonth
        // Free designs are now tracked via email-based quota service (design_quotas collection)
        'extraDesignsPurchased': 0,
        'extraTechpacksPurchased': 0,
        'extraDesignsUsed': 0,
        'extraTechpacksUsed': 0,
        'currentPeriodStart': null,
        'currentPeriodEnd': null,
      });
      print('✅ User reverted to FREE plan successfully');
    } catch (e) {
      print('❌ Error reverting user to FREE plan: $e');
    }
  }

  /// Extra safeguard: Validate and cleanup failed subscription
  /// This method is called in the finally block to catch edge cases
  Future<void> _validateAndCleanupFailedSubscription(
    String userId,
    String subscriptionId,
  ) async {
    try {
      // Short delay to allow any pending operations to complete
      await Future.delayed(const Duration(milliseconds: 500));

      // Check Stripe subscription status
      bool isValid = await _validateStripeSubscriptionStatus(subscriptionId);

      if (!isValid) {
        print('⚠️ SAFEGUARD: Subscription is not valid, cleaning up...');

        // Check if this subscription ID is still in Firebase
        DocumentSnapshot userDoc = await _firestore
            .collection('users')
            .doc(userId)
            .get();
        Map<String, dynamic>? userData =
            userDoc.data() as Map<String, dynamic>?;

        if (userData != null &&
            userData['currentSubscriptionId'] == subscriptionId) {
          await _revertToFreePlan(userId);
          print('✅ SAFEGUARD: Successfully cleaned up failed subscription');
        }
      } else {
        print('✅ SAFEGUARD: Subscription is valid, no cleanup needed');
      }
    } catch (e) {
      print('❌ SAFEGUARD: Error during validation: $e');
      // Don't throw - this is a safety check, shouldn't break the flow
    }
  }
}
