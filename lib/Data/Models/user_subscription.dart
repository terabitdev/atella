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
    };
  }

  bool get canGenerateTechpack {
    if (subscriptionPlan == 'FREE') return false;
    if (subscriptionPlan == 'PRO') {
      int totalAllowed = 20 + (extraTechpacksPurchased * 5); // 20 base + 5 per purchase
      return techpacksUsedThisMonth < totalAllowed;
    }
    if (subscriptionPlan == 'STARTER') {
      int totalAllowed = 3 + (extraTechpacksPurchased * 5); // 5 techpacks per purchase
      return techpacksUsedThisMonth < totalAllowed;
    }
    return false;
  }

  int get totalAllowedTechpacks {
    if (subscriptionPlan == 'PRO') {
      return 20 + (extraTechpacksPurchased * 5); // 20 base + 5 per purchase
    }
    if (subscriptionPlan == 'STARTER') {
      return 3 + (extraTechpacksPurchased * 5); // 5 techpacks per purchase
    }
    return 0; // Free plan gets 0 techpacks
  }

  int get remainingTechpacks {
    if (subscriptionPlan == 'PRO') {
      int totalAllowed = totalAllowedTechpacks;
      return totalAllowed - techpacksUsedThisMonth;
    }
    if (subscriptionPlan == 'STARTER') {
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