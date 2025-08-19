import 'package:cloud_firestore/cloud_firestore.dart';

class UserSubscription {
  final String userId;
  final String subscriptionPlan;
  final String subscriptionStatus;
  final String? stripeCustomerId;
  final String? currentSubscriptionId;
  final int techpacksUsedThisMonth;
  final DateTime? currentPeriodStart;
  final DateTime? currentPeriodEnd;

  UserSubscription({
    required this.userId,
    required this.subscriptionPlan,
    required this.subscriptionStatus,
    this.stripeCustomerId,
    this.currentSubscriptionId,
    this.techpacksUsedThisMonth = 0,
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
    if (subscriptionPlan == 'PRO') return true;
    if (subscriptionPlan == 'STARTER') {
      return techpacksUsedThisMonth < 3;
    }
    return false;
  }

  int get remainingTechpacks {
    if (subscriptionPlan == 'PRO') return -1; // Unlimited
    if (subscriptionPlan == 'STARTER') {
      return 3 - techpacksUsedThisMonth;
    }
    return 0;
  }
}