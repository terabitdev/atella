import 'package:get/get.dart';
import '../../../services/stripe_subscription_service.dart';
import '../../../models/subscription_plan.dart';
import '../../../models/user_subscription.dart';

class SubscribeController extends GetxController {
  final StripeSubscriptionService _stripeService = StripeSubscriptionService();
  
  RxString selectedPlan = 'FREE'.obs;
  Rx<UserSubscription?> currentSubscription = Rx<UserSubscription?>(null);
  RxBool isLoading = false.obs;

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
      }
    } catch (e) {
      Get.snackbar('Error', 'Failed to load subscription details');
    } finally {
      isLoading.value = false;
    }
  }

  void selectPlan(String plan) {
    selectedPlan.value = plan;
  }

  Future<void> subscribeToPlan(SubscriptionPlan plan) async {
    if (plan.type == SubscriptionPlanType.FREE) {
      // Free plan doesn't need payment
      Get.snackbar('Info', 'You are on the free plan');
      return;
    }

    isLoading.value = true;
    try {
      bool success = await _stripeService.createSubscriptionPaymentSheet(plan);
      if (success) {
        Get.snackbar(
          'Success', 
          'Successfully subscribed to ${plan.displayName} plan',
          snackPosition: SnackPosition.BOTTOM,
        );
        await loadCurrentSubscription();
        Get.back(); // Go back to previous screen
      } else {
        Get.snackbar(
          'Error', 
          'Failed to complete subscription',
          snackPosition: SnackPosition.BOTTOM,
        );
      }
    } catch (e) {
      Get.snackbar(
        'Error', 
        'An error occurred: $e',
        snackPosition: SnackPosition.BOTTOM,
      );
    } finally {
      isLoading.value = false;
    }
  }

  Future<void> cancelSubscription() async {
    isLoading.value = true;
    try {
      bool success = await _stripeService.cancelSubscription();
      if (success) {
        Get.snackbar(
          'Success', 
          'Subscription cancelled successfully',
          snackPosition: SnackPosition.BOTTOM,
        );
        await loadCurrentSubscription();
      } else {
        Get.snackbar(
          'Error', 
          'Failed to cancel subscription',
          snackPosition: SnackPosition.BOTTOM,
        );
      }
    } catch (e) {
      Get.snackbar(
        'Error', 
        'An error occurred: $e',
        snackPosition: SnackPosition.BOTTOM,
      );
    } finally {
      isLoading.value = false;
    }
  }

  bool get canGenerateTechpack {
    return currentSubscription.value?.canGenerateTechpack ?? false;
  }

  int get remainingTechpacks {
    return currentSubscription.value?.remainingTechpacks ?? 0;
  }
}
