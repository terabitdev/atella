import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../../services/PaymentService/stripe_subscription_service.dart';
import '../../../models/subscription_plan.dart';
import '../../../models/user_subscription.dart';

class SubscribeController extends GetxController {
  final StripeSubscriptionService _stripeService = StripeSubscriptionService();
  
  RxString selectedPlan = 'FREE'.obs;
  Rx<UserSubscription?> currentSubscription = Rx<UserSubscription?>(null);
  RxBool isLoading = false.obs;
  RxBool isCancellingSubscription = false.obs;

  @override
  void onInit() {
    super.onInit();
    loadCurrentSubscription();
  }

  Future<void> loadCurrentSubscription() async {
    isLoading.value = true;
    try {
      currentSubscription.value = await _stripeService.getCurrentUserSubscription();
      if (currentSubscription.value != null) {
        selectedPlan.value = currentSubscription.value!.subscriptionPlan;
      } else {
        selectedPlan.value = 'FREE';
      }
    } catch (e) {
      Get.snackbar('Error', 'Failed to load subscription details');
    } finally {
      isLoading.value = false;
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

  Future<void> subscribeToPlan(SubscriptionPlan plan) async {
    if (plan.type == SubscriptionPlanType.FREE) {
      // Free plan doesn't need payment
      Get.snackbar('Info', 'You are on the free plan');
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
        Get.snackbar(
          'Success', 
          'Successfully subscribed to ${plan.displayName} plan',
          snackPosition: SnackPosition.TOP,
          duration: Duration(seconds: 3),
        );
        await loadCurrentSubscription();
        Get.back(); // Go back to previous screen
      } else {
        Get.snackbar(
          'Error', 
          'Failed to complete subscription',
          snackPosition: SnackPosition.TOP,
          duration: Duration(seconds: 3),
          backgroundColor: Colors.black,
          colorText: Colors.white,
        );
      }
    } catch (e) {
      print('Error in subscribeToPlan: $e');
      Get.snackbar(
        'Error', 
        'An error occurred: $e',
        snackPosition: SnackPosition.TOP,
        duration: Duration(seconds: 3),
        backgroundColor: Colors.black,
        colorText: Colors.white,
      );
    } finally {
      print('Setting loading to false');
      isLoading.value = false;
    }
  }

  Future<void> cancelSubscription() async {
    isCancellingSubscription.value = true;
    try {
      bool success = await _stripeService.cancelSubscription();
      if (success) {
        Get.snackbar(
          'Success', 
          'Subscription cancelled successfully',
          snackPosition: SnackPosition.TOP,
          duration: Duration(seconds: 3),
          backgroundColor: Colors.black,
          colorText: Colors.white,
        );
        await loadCurrentSubscription();
      } else {
        Get.snackbar(
          'Error', 
          'Failed to cancel subscription',
          snackPosition: SnackPosition.TOP,
          duration: Duration(seconds: 3),
          backgroundColor: Colors.black,
          colorText: Colors.white,
        );
      }
    } catch (e) {
      Get.snackbar(
        'Error', 
        'An error occurred: $e',
        snackPosition: SnackPosition.TOP,
        duration: Duration(seconds: 3),
        backgroundColor: Colors.black,
        colorText: Colors.white,
      );
    } finally {
      isCancellingSubscription.value = false;
    }
  }

  bool get canGenerateTechpack {
    return currentSubscription.value?.canGenerateTechpack ?? false;
  }

  int get remainingTechpacks {
    return currentSubscription.value?.remainingTechpacks ?? 0;
  }
}
