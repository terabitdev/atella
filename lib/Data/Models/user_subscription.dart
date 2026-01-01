import 'package:cloud_firestore/cloud_firestore.dart';

class UserSubscription {
  final String userId;
  final String subscriptionPlan;
  final String subscriptionStatus;
  final String? stripeCustomerId;
  final String? currentSubscriptionId;
  final int techpacksUsedThisMonth;
  final int designsGeneratedThisMonth;
  final int extraDesignsPurchased;
  final int extraTechpacksPurchased;
  final int extraDesignsUsed; // Track how many add-on designs have been used
  final int extraTechpacksUsed; // Track how many add-on techpacks have been used
  final DateTime? currentPeriodStart;
  final DateTime? currentPeriodEnd;
  final String billingPeriod; // 'MONTHLY' or 'YEARLY'
  final int techpacksUsedThisYear; // For yearly subscriptions

  UserSubscription({
    required this.userId,
    required this.subscriptionPlan,
    required this.subscriptionStatus,
    this.stripeCustomerId,
    this.currentSubscriptionId,
    this.techpacksUsedThisMonth = 0,
    this.designsGeneratedThisMonth = 0,
    this.extraDesignsPurchased = 0,
    this.extraTechpacksPurchased = 0,
    this.extraDesignsUsed = 0,
    this.extraTechpacksUsed = 0,
    this.currentPeriodStart,
    this.currentPeriodEnd,
    this.billingPeriod = 'MONTHLY',
    this.techpacksUsedThisYear = 0,
  });

  factory UserSubscription.fromFirestore(DocumentSnapshot doc) {
    Map<String, dynamic> data = doc.data() as Map<String, dynamic>;
    return UserSubscription(
      userId: data['uid'] ?? '',
      subscriptionPlan: data['subscriptionPlan'] ?? 'FREE',
      subscriptionStatus: data['subscriptionStatus'] ?? 'active',
      stripeCustomerId: data['stripeCustomerId'],
      currentSubscriptionId: data['currentSubscriptionId'],
      techpacksUsedThisMonth: data['techpacksUsedThisMonth'] ?? 0,
      designsGeneratedThisMonth: data['designsGeneratedThisMonth'] ?? 0,
      extraDesignsPurchased: data['extraDesignsPurchased'] ?? 0,
      extraTechpacksPurchased: data['extraTechpacksPurchased'] ?? 0,
      extraDesignsUsed: data['extraDesignsUsed'] ?? 0,
      extraTechpacksUsed: data['extraTechpacksUsed'] ?? 0,
      currentPeriodStart: data['currentPeriodStart'] != null
          ? (data['currentPeriodStart'] as Timestamp).toDate()
          : null,
      currentPeriodEnd: data['currentPeriodEnd'] != null
          ? (data['currentPeriodEnd'] as Timestamp).toDate()
          : null,
      billingPeriod: data['billingPeriod'] ?? 'MONTHLY',
      techpacksUsedThisYear: data['techpacksUsedThisYear'] ?? 0,
    );
  }

  Map<String, dynamic> toFirestore() {
    return {
      'uid': userId,
      'subscriptionPlan': subscriptionPlan,
      'subscriptionStatus': subscriptionStatus,
      'stripeCustomerId': stripeCustomerId,
      'currentSubscriptionId': currentSubscriptionId,
      'techpacksUsedThisMonth': techpacksUsedThisMonth,
      'designsGeneratedThisMonth': designsGeneratedThisMonth,
      'extraDesignsPurchased': extraDesignsPurchased,
      'extraTechpacksPurchased': extraTechpacksPurchased,
      'extraDesignsUsed': extraDesignsUsed,
      'extraTechpacksUsed': extraTechpacksUsed,
      'currentPeriodStart': currentPeriodStart != null
          ? Timestamp.fromDate(currentPeriodStart!)
          : null,
      'currentPeriodEnd': currentPeriodEnd != null
          ? Timestamp.fromDate(currentPeriodEnd!)
          : null,
      'billingPeriod': billingPeriod,
      'techpacksUsedThisYear': techpacksUsedThisYear,
    };
  }

  bool get canGenerateTechpack {
    // CRITICAL: Only allow if subscription is actually active or in trial
    if (subscriptionStatus != 'active' && subscriptionStatus != 'trialing') return false;

    if (subscriptionPlan == 'FREE') return false;

    bool isYearly = billingPeriod == 'YEARLY' || subscriptionPlan.contains('YEARLY');

    if (subscriptionPlan.startsWith('PRO')) {
      int baseLimit = 8;
      // Check if user has consumed all monthly quota
      if (techpacksUsedThisMonth < baseLimit) {
        return true; // Still have monthly quota
      }
      // Monthly quota exhausted, check add-ons
      int totalAddonsPurchased = extraTechpacksPurchased * 1; // Each add-on = +1 techpack
      int addonsAvailable = totalAddonsPurchased - extraTechpacksUsed;
      return addonsAvailable > 0;
    }
    if (subscriptionPlan.startsWith('STARTER')) {
      int monthlyLimit = 2;
      // Check if user has consumed all monthly quota
      if (techpacksUsedThisMonth < monthlyLimit) {
        // For yearly plans, also check yearly limit
        if (isYearly) {
          int yearlyLimit = 24;
          return techpacksUsedThisYear < yearlyLimit;
        }
        return true; // Still have monthly quota
      }
      // Monthly quota exhausted, check add-ons
      int totalAddonsPurchased = extraTechpacksPurchased * 1; // Each add-on = +1 techpack
      int addonsAvailable = totalAddonsPurchased - extraTechpacksUsed;
      return addonsAvailable > 0;
    }
    return false;
  }

  int get totalAllowedTechpacks {
    // Return base limit + total add-ons purchased (not remaining)
    int baseLimit = 0;
    if (subscriptionPlan.startsWith('PRO')) {
      baseLimit = 8;
    } else if (subscriptionPlan.startsWith('STARTER')) {
      baseLimit = 2;
    }
    int totalAddonsPurchased = extraTechpacksPurchased * 1; // Each add-on = +1 techpack
    return baseLimit + totalAddonsPurchased;
  }

  int get remainingTechpacks {
    if (subscriptionPlan.startsWith('PRO') || subscriptionPlan.startsWith('STARTER')) {
      // Always use monthly count for remaining techpacks
      int totalAllowed = totalAllowedTechpacks;
      return totalAllowed - techpacksUsedThisMonth;
    }
    return 0;
  }

  bool get canGenerateDesign {
    // For FREE users, only check quotas (no subscription status check needed)
    if (subscriptionPlan == 'FREE') {
      int baseLimit = _getBaseDesignLimit();
      return designsGeneratedThisMonth < baseLimit;
    }

    // CRITICAL: For paid plans, validate subscription is active
    if (subscriptionStatus != 'active' && subscriptionStatus != 'trialing') return false;

    int baseLimit = _getBaseDesignLimit();
    // Check if user has consumed all monthly quota
    if (designsGeneratedThisMonth < baseLimit) {
      return true; // Still have monthly quota
    }
    // Monthly quota exhausted, check add-ons
    int totalAddonsPurchased = extraDesignsPurchased * 5; // Each add-on = +5 designs
    int addonsAvailable = totalAddonsPurchased - extraDesignsUsed;
    return addonsAvailable > 0;
  }

  int _getBaseDesignLimit() {
    if (subscriptionPlan.startsWith('PRO')) return 15;
    if (subscriptionPlan.startsWith('STARTER')) return 5;
    return 3; // FREE
  }

  int getTotalAllowedDesigns() {
    // Return base limit + total add-ons purchased (not remaining)
    int baseDesigns = _getBaseDesignLimit();
    int totalAddonsPurchased = extraDesignsPurchased * 5; // Each add-on = +5 designs
    return baseDesigns + totalAddonsPurchased;
  }

  int get remainingDesigns {
    // All plans have limited designs
    return getTotalAllowedDesigns() - designsGeneratedThisMonth;
  }

  // Get design count for display (used/total)
  String get designsUsedCount => '$designsGeneratedThisMonth';

  String get designsTotalCount {
    return '${getTotalAllowedDesigns()}';
  }

  // Get techpack count for display (used/total)
  String get techpacksUsedCount {
    if (subscriptionPlan == 'FREE') {
      return '0';
    }
    return '$techpacksUsedThisMonth';
  }

  String get techpacksTotalCount {
    if (subscriptionPlan == 'FREE') {
      return '0';
    }
    return '$totalAllowedTechpacks';
  }

  // Check if user is at 80% usage threshold (for warning modals)
  // NOTE: This checks ONLY against base plan limit, NOT including add-ons
  // If user has purchased add-ons, don't show warning for rest of the month
  bool get isDesignUsageAt80Percent {
    // Don't show warning if user has purchased add-ons this month
    if (extraDesignsPurchased > 0) return false;

    int baseLimit = _getBaseDesignLimit(); // Base plan limit only
    if (baseLimit == 0) return false; // No quota
    double usagePercent = (designsGeneratedThisMonth / baseLimit) * 100;
    return usagePercent >= 80 && usagePercent < 100;
  }

  bool get isTechpackUsageAt80Percent {
    if (subscriptionPlan == 'FREE') return false;

    // Don't show warning if user has purchased add-ons this month
    if (extraTechpacksPurchased > 0) return false;

    // Get base limit only (without add-ons)
    int baseLimit = 0;
    if (subscriptionPlan.startsWith('PRO')) {
      baseLimit = 8;
    } else if (subscriptionPlan.startsWith('STARTER')) {
      baseLimit = 2;
    }
    if (baseLimit == 0) return false;
    double usagePercent = (techpacksUsedThisMonth / baseLimit) * 100;
    return usagePercent >= 80 && usagePercent < 100;
  }

  bool get hasReachedDesignLimit {
    int total = getTotalAllowedDesigns();
    return designsGeneratedThisMonth >= total;
  }

  bool get hasReachedTechpackLimit {
    return !canGenerateTechpack;
  }

  // Backward compatibility - non-localized display strings
  String get designCounterDisplay {
    // All plans show limited count
    return 'Designs used: $designsGeneratedThisMonth/${getTotalAllowedDesigns()} this month';
  }

  String get techpackCounterDisplay {
    // For FREE plan, techpack is disabled
    if (subscriptionPlan == 'FREE') {
      return 'Techpacks used: 0 / 0';
    }
    // For paid plans, show monthly usage
    return 'Techpacks used: $techpacksUsedThisMonth / $totalAllowedTechpacks';
  }
}