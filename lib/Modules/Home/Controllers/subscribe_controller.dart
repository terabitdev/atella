import 'package:atella/Data/Models/subscription_plan.dart';
import 'package:atella/Data/Models/user_subscription.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../../services/PaymentService/stripe_subscription_service.dart';
import '../../../services/PaymentService/subscription_callback_service.dart';

class SubscribeController extends GetxController {
  final StripeSubscriptionService _stripeService = StripeSubscriptionService();
  
  RxString selectedPlan = 'FREE'.obs;
  Rx<UserSubscription?> currentSubscription = Rx<UserSubscription?>(null);
  RxBool isLoading = false.obs;
  RxBool isCancellingSubscription = false.obs;
  RxBool isYearlyBilling = false.obs; // Toggle for monthly/yearly billing
  
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

      // Force UI update
      print('🔄 Forcing UI update...');
      update();
      print('✅ loadCurrentSubscription completed');
    } catch (e) {
      print('❌ Error loading subscription: $e');
      Get.snackbar('Error', 'Failed to load subscription details',
        snackPosition: SnackPosition.TOP,
        backgroundColor: Colors.red,
        colorText: Colors.white,
        duration: Duration(seconds: 3),
      );
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
      Get.snackbar('Info', 'You are on the free plan',
        snackPosition: SnackPosition.TOP,
        backgroundColor: Colors.black,
        colorText: Colors.white,
        duration: Duration(seconds: 3),
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
        
        if (showSuccessMessage) {
          Get.snackbar(
            'Success! 🎉', 
            'Welcome to ${plan.displayName}! You can now generate techpacks.',
            snackPosition: SnackPosition.TOP,
            duration: Duration(seconds: 4),
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
              Get.snackbar(
                'Subscription Active! 🎉',
                'You can now generate your techpack. Click "Generate Tech Pack" button.',
                snackPosition: SnackPosition.TOP,
                backgroundColor: Colors.black,
                colorText: Colors.white,
                duration: Duration(seconds: 4),
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
        print('✅ Subscription cancelled successfully');

        // Wait for webhook to process (Firebase update might take a moment)
        print('⏳ Waiting 2 seconds for webhook to process...');
        await Future.delayed(Duration(seconds: 2));

        // Reload subscription data (no navigation needed - already on subscribe screen)
        print('🔄 Reloading subscription data after cancellation...');
        await loadCurrentSubscription();
        print('🔄 Subscription data reloaded. Current plan: ${selectedPlan.value}');

        Get.snackbar(
          'Success',
          'Subscription cancelled successfully',
          snackPosition: SnackPosition.TOP,
          duration: Duration(seconds: 3),
          backgroundColor: Colors.black,
          colorText: Colors.white,
        );
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
        backgroundColor: Colors.red,
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

  String getStarterPriceText() {
    return isYearlyBilling.value 
        ? 'Starter €99/Year' 
        : 'Starter €9.99/Month';
  }

  String getProPriceText() {
    return isYearlyBilling.value 
        ? 'Pro €249/Year' 
        : 'Pro €24.99/Month';
  }
}
