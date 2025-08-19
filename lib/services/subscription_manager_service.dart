import '../services/PaymentService/stripe_subscription_service.dart';

/// Service to manage subscription-related tasks and periodic checks
class SubscriptionManagerService {
  static final SubscriptionManagerService _instance = SubscriptionManagerService._internal();
  factory SubscriptionManagerService() => _instance;
  SubscriptionManagerService._internal();

  final StripeSubscriptionService _subscriptionService = StripeSubscriptionService();

  /// Initialize subscription manager - call this on app start
  Future<void> initialize() async {
    try {
      // Check for monthly reset on app start
      await _subscriptionService.checkAndHandleMonthlyReset();
      print('Subscription manager initialized successfully');
    } catch (e) {
      print('Error initializing subscription manager: $e');
    }
  }

  /// Get current subscription status for UI
  Future<Map<String, dynamic>> getSubscriptionStatus() async {
    return await _subscriptionService.getSubscriptionStatus();
  }

  /// Check if user can use premium feature with monthly reset check
  Future<bool> canUsePremiumFeature(String feature) async {
    return await _subscriptionService.canUsePremiumFeatureWithReset(feature);
  }

  /// Manually trigger monthly reset check (for testing or manual refresh)
  Future<void> checkMonthlyReset() async {
    await _subscriptionService.checkAndHandleMonthlyReset();
  }
}