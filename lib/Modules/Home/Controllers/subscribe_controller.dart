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
        print('✅ Subscription successful! Plan: ${plan.displayName}');
        print('📍 Return route: $returnRoute');
        print('📍 Show success message: $showSuccessMessage');
        
        if (showSuccessMessage) {
          Get.snackbar(
            'Success! 🎉', 
            'Welcome to ${plan.displayName}! You can now generate techpacks.',
            snackPosition: SnackPosition.TOP,
            duration: Duration(seconds: 4),
            backgroundColor: Colors.green,
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
                backgroundColor: Colors.green,
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
