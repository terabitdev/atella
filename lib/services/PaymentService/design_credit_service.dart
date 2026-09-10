import 'package:firebase_auth/firebase_auth.dart';
import 'stripe_subscription_service.dart';
import '../firebase/services/design_quota_service.dart';

/// Spends exactly one "design" credit — separate from the tech-pack credit,
/// which keeps deducting exactly as it already did.
///
/// Call this only at one of the three moments a design is meant to consume
/// quota: Save Design, Generate Tech Pack, or (later) the 3rd modification.
/// The eligibility check (does the user have quota at all) still happens
/// earlier, when the design is first generated — this only performs the
/// actual spend.
class DesignCreditService {
  static final StripeSubscriptionService _subscriptionService =
      StripeSubscriptionService();
  static final DesignQuotaService _quotaService = DesignQuotaService();

  static Future<void> spendDesignCredit() async {
    try {
      final subscription =
          await _subscriptionService.getCurrentUserSubscription();
      if (subscription == null) return;

      if (subscription.subscriptionPlan == 'FREE') {
        final email = FirebaseAuth.instance.currentUser?.email;
        if (email == null) return;

        final hasQuota = await _quotaService.hasRemainingQuota(email);
        if (hasQuota) {
          await _quotaService.incrementDesignUsage(email);
        } else if (subscription.hasFreeExtraDesigns) {
          await _subscriptionService.incrementFreeExtraDesignUsage();
        }
      } else {
        await _subscriptionService.incrementDesignUsage();
      }
    } catch (e) {
      print('Failed to spend design credit: $e');
    }
  }
}
