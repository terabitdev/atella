enum SubscriptionPlanType {
  FREE,
  STARTER,
  PRO,
}

class SubscriptionPlan {
  final SubscriptionPlanType type;
  final String name;
  final String displayName;
  final double price;
  final String currency;
  final String stripePriceId;
  final List<String> features;
  final int? techpackLimit;
  final bool hasCustomPDFExport;
  final bool hasManufacturerAccess;

  const SubscriptionPlan({
    required this.type,
    required this.name,
    required this.displayName,
    required this.price,
    required this.currency,
    required this.stripePriceId,
    required this.features,
    this.techpackLimit,
    required this.hasCustomPDFExport,
    required this.hasManufacturerAccess,
  });

  static const SubscriptionPlan freePlan = SubscriptionPlan(
    type: SubscriptionPlanType.FREE,
    name: 'FREE',
    displayName: 'Free',
    price: 0.0,
    currency: 'EUR',
    stripePriceId: '',
    features: [
      'Unlimited AI-generated designs',
      'No techpack generation - upgrade to access',
      'No PDF export - upgrade to access',
      'No access to manufacturers - upgrade to access',
    ],
    techpackLimit: 0,
    hasCustomPDFExport: false,
    hasManufacturerAccess: false,
  );

  static const SubscriptionPlan starterPlan = SubscriptionPlan(
    type: SubscriptionPlanType.STARTER,
    name: 'STARTER',
    displayName: 'Starter',
    price: 9.99,
    currency: 'EUR',
    stripePriceId: 'price_1RxPj0B0j1hBhcav6vIJlc1C', // Replace with actual Stripe price ID
    features: [
      'Unlimited AI-generated designs',
      'Up to 3 techpacks per month',
      'Custom PDF export (includes logo)',
      'Access to a curated list of manufacturers',
    ],
    techpackLimit: 3,
    hasCustomPDFExport: true,
    hasManufacturerAccess: true,
  );

  static const SubscriptionPlan proPlan = SubscriptionPlan(
    type: SubscriptionPlanType.PRO,
    name: 'PRO',
    displayName: 'Pro',
    price: 24.99,
    currency: 'EUR',
    stripePriceId: 'price_1RxPlDB0j1hBhcavA9lDOp9F', // Replace with actual Stripe price ID
    features: [
      'Unlimited AI-generated designs',
      'Unlimited techpacks',
      'Custom PDF export (includes logo)',
      'Access to a curated list of manufacturers',
      'Priority support',
    ],
    techpackLimit: null, // Unlimited
    hasCustomPDFExport: true,
    hasManufacturerAccess: true,
  );

  static List<SubscriptionPlan> get allPlans => [
        freePlan,
        starterPlan,
        proPlan,
      ];

  static SubscriptionPlan getPlanByType(SubscriptionPlanType type) {
    switch (type) {
      case SubscriptionPlanType.FREE:
        return freePlan;
      case SubscriptionPlanType.STARTER:
        return starterPlan;
      case SubscriptionPlanType.PRO:
        return proPlan;
    }
  }

  static SubscriptionPlan getPlanByName(String name) {
    switch (name.toUpperCase()) {
      case 'STARTER':
        return starterPlan;
      case 'PRO':
        return proPlan;
      default:
        return freePlan;
    }
  }
}