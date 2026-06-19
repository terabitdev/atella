import 'package:atella/Data/Models/subscription_plan.dart';
import 'package:atella/Data/Models/user_subscription.dart';
import 'package:atella/services/analytics/posthog_analytics_service.dart';
import 'package:atella/services/firebase/services/design_quota_service.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:atella/l10n/generated/app_localizations.dart';
import '../../../services/PaymentService/stripe_subscription_service.dart';

import 'package:atella/core/utils/app_snackbar.dart';
class SubscribeController extends GetxController {
  final StripeSubscriptionService _stripeService = StripeSubscriptionService();
  final DesignQuotaService _quotaService = DesignQuotaService();
  final FirebaseAuth _auth = FirebaseAuth.instance;

  RxString selectedPlan = 'FREE'.obs;
  Rx<UserSubscription?> currentSubscription = Rx<UserSubscription?>(null);
  RxBool isLoading = false.obs;
  RxBool isCancellingSubscription = false.obs;
  RxBool isYearlyBilling = false.obs; // Toggle for monthly/yearly billing

  // Email-based quota for FREE users (persists across account deletions)
  Rx<Map<String, dynamic>?> emailBasedQuota = Rx<Map<String, dynamic>?>(null);

  // Cancellation reasons for analytics
  // Cancellation reasons - will be populated with localized strings
  List<String> get cancellationReasons {
    final context = Get.context;
    if (context == null) return [];
    final l10n = AppLocalizations.of(context);
    if (l10n == null) return [];

    return [
      l10n.cancellationReasonTooExpensive,
      l10n.cancellationReasonNotUsing,
      l10n.cancellationReasonMissingFeatures,
      l10n.cancellationReasonBetterAlternative,
      l10n.cancellationReasonTechnicalIssues,
      l10n.cancellationReasonOther,
    ];
  }

  // Navigation handling
  String? returnRoute;
  bool showSuccessMessage = false;

  @override
  void onInit() {
    super.onInit();
    
    // Check for arguments passed from other screens
    final arguments = Get.arguments;
    print('📍 SubscribeController received arguments: $arguments');
    
    if (arguments != null && arguments is Map<String, dynamic>) {
      returnRoute = arguments['returnRoute'];
      showSuccessMessage = arguments['showSuccessMessage'] ?? false;
      print('📍 Return route set to: $returnRoute');
      print('📍 Show success message: $showSuccessMessage');
    }
    
    loadCurrentSubscription();
  }

  Future<void> loadCurrentSubscription() async {
    isLoading.value = true;
    try {
      print('📥 Loading subscription from Firebase...');
      final loadedSubscription = await _stripeService.getCurrentUserSubscription();
      print('📥 Loaded subscription: ${loadedSubscription?.subscriptionPlan ?? "null (FREE)"}');

      // Force reactive update by setting to null first, then to new value
      print('🔄 Resetting currentSubscription to null...');
      currentSubscription.value = null;
      await Future.delayed(Duration(milliseconds: 50)); // Small delay to ensure rebuild
      print('🔄 Setting currentSubscription to new value...');
      currentSubscription.value = loadedSubscription;

      if (currentSubscription.value != null) {
        selectedPlan.value = currentSubscription.value!.subscriptionPlan;
        print('📌 Updated selectedPlan to: ${selectedPlan.value}');
      } else {
        selectedPlan.value = 'FREE';
        print('📌 Updated selectedPlan to: FREE (no subscription)');
      }

      // Load email-based quota for FREE users
      if (selectedPlan.value == 'FREE') {
        await loadEmailBasedQuota();
      }

      // Force UI update
      print('🔄 Forcing UI update...');
      update();
      print('✅ loadCurrentSubscription completed');
      // Track subscription page viewed
      PostHogAnalyticsService().trackSubscriptionViewed(
        currentPlan: selectedPlan.value,
      );
    } catch (e) {
      print('❌ Error loading subscription: $e');
      final l10n = AppLocalizations.of(Get.context!)!;
      showAppSnackbar(l10n.error, l10n.failedToLoadSubscription,
        snackPosition: SnackPosition.TOP,
        backgroundColor: Colors.red,
        colorText: Colors.white,
        duration: const Duration(milliseconds: 1500),
      );
    } finally {
      isLoading.value = false;
    }
  }

  /// Load email-based quota for FREE users
  /// This data persists across account deletions to prevent abuse
  Future<void> loadEmailBasedQuota() async {
    try {
      final user = _auth.currentUser;
      if (user?.email == null) {
        print('⚠️ No user email found for loading quota');
        return;
      }

      print('📥 Loading email-based quota for: ${user!.email}');
      final quota = await _quotaService.getQuotaByEmail(user.email!);
      emailBasedQuota.value = quota;
      print('✅ Email-based quota loaded: ${quota['designsUsed']}/${quota['monthlyLimit']}');
    } catch (e) {
      print('❌ Error loading email-based quota: $e');
      emailBasedQuota.value = null;
    }
  }

  @override
  void onReady() {
    super.onReady();
    // Reset selected plan to current subscription when returning to screen
    ever(currentSubscription, (subscription) {
      if (subscription != null) {
        selectedPlan.value = subscription.subscriptionPlan;
      } else {
        selectedPlan.value = 'FREE';
      }
    });
  }

  void resetToCurrentPlan() {
    if (currentSubscription.value != null) {
      selectedPlan.value = currentSubscription.value!.subscriptionPlan;
    } else {
      selectedPlan.value = 'FREE';
    }
  }

  // COMMENTED OUT: In-app subscription flow removed - Users now subscribe via website
  // Subscriptions are handled exclusively through https://atelia.app/
  // This code is preserved for potential future use
  /*
  Future<void> subscribeToPlan(SubscriptionPlan plan) async {
    if (plan.type == SubscriptionPlanType.FREE) {
      // Free plan doesn't need payment
      final l10n = AppLocalizations.of(Get.context!)!;
      showAppSnackbar(l10n.infoMessage, l10n.youAreOnFreePlan,
        snackPosition: SnackPosition.TOP,
        backgroundColor: Colors.black,
        colorText: Colors.white,
        duration: const Duration(milliseconds: 1500),
      );
      return;
    }

    print('Setting loading to true for plan: ${plan.name}');
    isLoading.value = true;

    try {
      // Add a small delay to ensure loading state is visible
      await Future.delayed(Duration(milliseconds: 500));

      print('Calling stripe service for plan: ${plan.name}');
      bool success = await _stripeService.createSubscriptionPaymentSheet(plan);

      if (success) {
        print('✅ Subscription successful! Plan: ${plan.displayName}');
        print('📍 Return route: $returnRoute');
        print('📍 Show success message: $showSuccessMessage');

        // Track subscription started
        PostHogAnalyticsService().trackSubscriptionStarted(
          plan: plan.name,
          billingCycle: isYearlyBilling.value ? 'yearly' : 'monthly',
          price: isYearlyBilling.value ? (plan.yearlyPrice ?? plan.price) : plan.price,
        );

        if (showSuccessMessage) {
          final l10n = AppLocalizations.of(Get.context!)!;
          showAppSnackbar(
            l10n.subscriptionSuccessTitle,
            l10n.welcomeToPlan(plan.displayName),
            snackPosition: SnackPosition.TOP,
            duration: const Duration(milliseconds: 1500),
            backgroundColor: Colors.black,
            colorText: Colors.white,
            icon: Icon(Icons.check_circle, color: Colors.white),
          );
        }

        await loadCurrentSubscription();

        // Wait a moment for the subscription to be processed
        await Future.delayed(Duration(milliseconds: 500));

        // Navigate back to the original screen if specified
        if (returnRoute != null) {
          print('📍 Starting navigation back to: $returnRoute');

          if (returnRoute == '/tech_pack_details_screen') {
            print('📍 Navigating back to tech pack details...');

            // Use a more reliable navigation approach
            Get.until((route) => route.settings.name == '/tech_pack_details_screen');

            // Show success message after a short delay
            Future.delayed(Duration(milliseconds: 500), () {
              final l10n = AppLocalizations.of(Get.context!)!;
              showAppSnackbar(
                l10n.subscriptionActive,
                l10n.canNowGenerateTechpack,
                snackPosition: SnackPosition.TOP,
                backgroundColor: Colors.black,
                colorText: Colors.white,
                duration: const Duration(milliseconds: 1500),
                icon: Icon(Icons.check_circle, color: Colors.white),
              );
            });

          } else if (returnRoute == '/generate_tech_pack_screen') {
            print('📍 Navigating back to generate screen...');

            Get.until((route) => route.settings.name == '/generate_tech_pack_screen');

            Future.delayed(Duration(milliseconds: 1000), () {
              SubscriptionCallbackService().executeSubscriptionSuccessCallback();
            });

          } else {
            // Default fallback
            print('📍 Using fallback navigation to: $returnRoute');
            Get.offAllNamed(returnRoute!);
          }
        } else {
          print('📍 No return route specified, going back');
          Get.back();
        }
      } else {
        final l10n = AppLocalizations.of(Get.context!)!;
        showAppSnackbar(
          l10n.error,
          l10n.failedToCompleteSubscription,
          snackPosition: SnackPosition.TOP,
          duration: const Duration(milliseconds: 1500),
          backgroundColor: Colors.black,
          colorText: Colors.white,
        );
      }
    } catch (e) {
      print('Error in subscribeToPlan: $e');
      final l10n = AppLocalizations.of(Get.context!)!;
      showAppSnackbar(
        l10n.error,
        l10n.anErrorOccurred(e.toString()),
        snackPosition: SnackPosition.TOP,
        duration: const Duration(milliseconds: 1500),
        backgroundColor: Colors.black,
        colorText: Colors.white,
      );
    } finally {
      print('Setting loading to false');
      isLoading.value = false;
    }
  }
  */

  Future<void> cancelSubscription({String? reason}) async {
    final currentPlan = currentSubscription.value?.subscriptionPlan ?? '';
    isCancellingSubscription.value = true;
    try {
      bool success = await _stripeService.cancelSubscription();
      if (success) {
        print('✅ Subscription cancelled successfully');

        // Wait for webhook to process (Firebase update might take a moment)
        print('⏳ Waiting 2 seconds for webhook to process...');
        await Future.delayed(Duration(seconds: 2));

        // Reload subscription data (no navigation needed - already on subscribe screen)
        print('🔄 Reloading subscription data after cancellation...');
        await loadCurrentSubscription();
        print('🔄 Subscription data reloaded. Current plan: ${selectedPlan.value}');
        // Track subscription cancellation
        PostHogAnalyticsService().trackSubscriptionCancelled(
          plan: currentPlan,
          reason: reason,
        );

        final l10n = AppLocalizations.of(Get.context!)!;
        showAppSnackbar(
          l10n.success,
          l10n.subscriptionCancelledSuccessfully,
          snackPosition: SnackPosition.TOP,
          duration: const Duration(milliseconds: 1500),
          backgroundColor: Colors.black,
          colorText: Colors.white,
        );
      } else {
        final l10n = AppLocalizations.of(Get.context!)!;
        showAppSnackbar(
          l10n.error,
          l10n.failedToCancelSubscription,
          snackPosition: SnackPosition.TOP,
          duration: const Duration(milliseconds: 1500),
          backgroundColor: Colors.black,
          colorText: Colors.white,
        );
      }
    } catch (e) {
      final l10n = AppLocalizations.of(Get.context!)!;
      showAppSnackbar(
        l10n.error,
        l10n.anErrorOccurred(e.toString()),
        snackPosition: SnackPosition.TOP,
        duration: const Duration(milliseconds: 1500),
        backgroundColor: Colors.red,
        colorText: Colors.white,
      );
    } finally {
      isCancellingSubscription.value = false;
    }
  }

  // One-time fix: Reset add-on counters for current user
  Future<void> resetAddOnCounters() async {
    await _stripeService.resetAddOnCounters();
    await loadCurrentSubscription();
  }

  bool get canGenerateTechpack {
    return currentSubscription.value?.canGenerateTechpack ?? false;
  }

  int get remainingTechpacks {
    return currentSubscription.value?.remainingTechpacks ?? 0;
  }

  // Getter methods for design usage - returns correct values for FREE users from email-based quota
  int get designsUsedThisMonth {
    if (selectedPlan.value == 'FREE' && emailBasedQuota.value != null) {
      // For FREE users, use email-based quota
      return emailBasedQuota.value!['designsUsed'] as int? ?? 0;
    } else if (currentSubscription.value != null) {
      // For paid users, use subscription data
      return currentSubscription.value!.designsGeneratedThisMonth;
    }
    return 0;
  }

  int get monthlyDesignLimit {
    if (selectedPlan.value == 'FREE' && emailBasedQuota.value != null) {
      // For FREE users, use email-based quota
      return emailBasedQuota.value!['monthlyLimit'] as int? ?? 3;
    } else if (currentSubscription.value != null) {
      // For paid users, use subscription data
      return currentSubscription.value!.getTotalAllowedDesigns();
    }
    return 3; // Default FREE limit
  }

  int get remainingDesigns {
    final remaining = monthlyDesignLimit - designsUsedThisMonth;
    return remaining > 0 ? remaining : 0;
  }

  // Helper methods for billing period
  void toggleBillingPeriod() {
    isYearlyBilling.value = !isYearlyBilling.value;
  }

  SubscriptionPlan getStarterPlan() {
    return isYearlyBilling.value 
        ? SubscriptionPlan.starterYearlyPlan 
        : SubscriptionPlan.starterPlan;
  }

  SubscriptionPlan getProPlan() {
    return isYearlyBilling.value
        ? SubscriptionPlan.proYearlyPlan
        : SubscriptionPlan.proPlan;
  }

  SubscriptionPlan getStudioPlan() {
    return isYearlyBilling.value
        ? SubscriptionPlan.studioYearlyPlan
        : SubscriptionPlan.studioPlan;
  }

  String getStarterPriceText() {
    return isYearlyBilling.value
        ? 'Starter €199.99/Year'
        : 'Starter €19.99/Month';
  }

  String getProPriceText() {
    return isYearlyBilling.value
        ? 'Pro €499.99/Year'
        : 'Pro €49.99/Month';
  }

  String getStudioPriceText() {
    return isYearlyBilling.value
        ? 'Studio €999.99/Year'
        : 'Studio €99.99/Month';
  }
}
