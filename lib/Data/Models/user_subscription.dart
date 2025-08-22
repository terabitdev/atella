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
    if (subscriptionPlan == 'FREE') return false;
    
    bool isYearly = billingPeriod == 'YEARLY' || subscriptionPlan.contains('YEARLY');
    
    if (subscriptionPlan.startsWith('PRO')) {
      int baseLimit = 20;
      int totalAllowed = baseLimit + (extraTechpacksPurchased * 5);
      return techpacksUsedThisMonth < totalAllowed;
    }
    if (subscriptionPlan.startsWith('STARTER')) {
      // For Starter plans, always check monthly limit (3 per month)
      int monthlyLimit = 3;
      int totalAllowed = monthlyLimit + (extraTechpacksPurchased * 5);
      
      // For yearly plans, also check yearly limit (36 per year)
      if (isYearly) {
        int yearlyLimit = 36;
        int yearlyAllowed = yearlyLimit + (extraTechpacksPurchased * 5);
        // Must satisfy both monthly AND yearly limits
        return techpacksUsedThisMonth < totalAllowed && techpacksUsedThisYear < yearlyAllowed;
      }
      
      // For monthly plans, just check monthly limit
      return techpacksUsedThisMonth < totalAllowed;
    }
    return false;
  }

  int get totalAllowedTechpacks {
    // Always return the monthly limit for display purposes
    if (subscriptionPlan.startsWith('PRO')) {
      return 20 + (extraTechpacksPurchased * 5);
    }
    if (subscriptionPlan.startsWith('STARTER')) {
      return 3 + (extraTechpacksPurchased * 5);
    }
    return 0;
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
    int totalAllowedDesigns = getTotalAllowedDesigns();
    return designsGeneratedThisMonth < totalAllowedDesigns;
  }

  int getTotalAllowedDesigns() {
    int baseDesigns = 10; // Free plan base limit
    return baseDesigns + (extraDesignsPurchased * 20);
  }

  int get remainingDesigns {
    return getTotalAllowedDesigns() - designsGeneratedThisMonth;
  }

  String get designCounterDisplay {
    return '$designsGeneratedThisMonth/${getTotalAllowedDesigns()}';
  }
}