import 'package:get/get.dart';
import 'package:atella/Data/Models/user_subscription.dart';
import 'package:atella/l10n/generated/app_localizations.dart';
import 'package:atella/services/PaymentService/stripe_subscription_service.dart';
import 'package:atella/services/analytics/posthog_analytics_service.dart';

class SubscriptionDetailController extends GetxController {
  final StripeSubscriptionService _stripeService = StripeSubscriptionService();

  final Rx<UserSubscription?> subscription = Rx<UserSubscription?>(null);
  final RxBool isLoading = true.obs;
  final RxBool isCancelling = false.obs;

  @override
  void onInit() {
    super.onInit();
    _loadSubscription();
  }

  Future<void> _loadSubscription() async {
    isLoading.value = true;
    subscription.value = await _stripeService.getCurrentUserSubscription();
    isLoading.value = false;
  }

  /// Human-readable plan name, derived from the subscriptionPlan string.
  String getPlanDisplayName(AppLocalizations l10n) {
    final plan = subscription.value?.subscriptionPlan ?? '';
    if (plan.startsWith('STUDIO')) return l10n.planNameStudio;
    if (plan.startsWith('PRO')) return l10n.planNamePro;
    if (plan.startsWith('STARTER')) return l10n.planNameStarter;
    return plan;
  }

  /// 'Monthly' or 'Annual' badge text.
  String getBillingLabel(AppLocalizations l10n) {
    final sub = subscription.value;
    if (sub == null) return '';
    final isYearly =
        sub.billingPeriod == 'YEARLY' || sub.subscriptionPlan.contains('YEARLY');
    return isYearly ? l10n.billingYearly : l10n.billingMonthly;
  }

  /// Formatted renewal date string, or empty string if unknown.
  String getFormattedRenewalDate(AppLocalizations l10n) {
    final end = subscription.value?.currentPeriodEnd;
    if (end == null) return '';
    final months = [
      'Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun',
      'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec',
    ];
    final formatted = '${end.day} ${months[end.month - 1]} ${end.year}';
    return l10n.renewsOn(formatted);
  }

  /// Performs the Stripe cancellation and returns success/failure.
  Future<bool> cancelSubscription({String? reason}) async {
    isCancelling.value = true;
    final plan = subscription.value?.subscriptionPlan ?? '';
    final success = await _stripeService.cancelSubscription();
    if (success) {
      PostHogAnalyticsService().trackSubscriptionCancelled(
        plan: plan,
        reason: reason,
      );
    }
    isCancelling.value = false;
    return success;
  }
}
