enum SubscriptionPlanType {
  FREE,
  STARTER,
  PRO,
}

enum BillingPeriod {
  MONTHLY,
  YEARLY,
}

class SubscriptionPlan {
  final SubscriptionPlanType type;
  final String name;
  final String displayName;
  final double price;
  final double? yearlyPrice;
  final String currency;
  final String stripePriceId;
  final String? stripeYearlyPriceId;
  final List<String> features;
  final int? techpackLimit;
  final bool hasCustomPDFExport;
  final bool hasManufacturerAccess;
  final BillingPeriod billingPeriod;

  const SubscriptionPlan({
    required this.type,
    required this.name,
    required this.displayName,
    required this.price,
    this.yearlyPrice,
    required this.currency,
    required this.stripePriceId,
    this.stripeYearlyPriceId,
    required this.features,
    this.techpackLimit,
    required this.hasCustomPDFExport,
    required this.hasManufacturerAccess,
    this.billingPeriod = BillingPeriod.MONTHLY,
  });

  static const SubscriptionPlan freePlan = SubscriptionPlan(
    type: SubscriptionPlanType.FREE,
    name: 'FREE',
    displayName: 'Free',
    price: 0.0,
    currency: 'EUR',
    stripePriceId: '',
    features: [
      '3 AI design generations per month',
      'No techpack generation - upgrade to access',
      'No PDF export - upgrade to access',
      'No factory access - upgrade to access',
      'Product discovery & testing only',
    ],
    techpackLimit: 0,
    hasCustomPDFExport: false,
    hasManufacturerAccess: false,
  );

  static const SubscriptionPlan starterPlan = SubscriptionPlan(
    type: SubscriptionPlanType.STARTER,
    name: 'STARTER',
    displayName: 'Starter',
    price: 14.99,
    yearlyPrice: 149.0,
    currency: 'EUR',
    stripePriceId: 'price_1RxPj0B0j1hBhcav6vIJlc1C', // Monthly Stripe price ID
    stripeYearlyPriceId: 'price_1RyT4WB0j1hBhcavwtIZ1kOU', // Replace with actual yearly Stripe price ID
    features: [
      '5 AI design generations per month',
      '2 techpacks per month',
      'Custom PDF export (includes logo)',
      'Access to a curated list of manufacturers',
      'Early-stage creators testing production',
    ],
    techpackLimit: 2,
    hasCustomPDFExport: true,
    hasManufacturerAccess: true,
    billingPeriod: BillingPeriod.MONTHLY,
  );

  static const SubscriptionPlan starterYearlyPlan = SubscriptionPlan(
    type: SubscriptionPlanType.STARTER,
    name: 'STARTER_YEARLY',
    displayName: 'Starter (Yearly)',
    price: 149.0,
    yearlyPrice: 149.0,
    currency: 'EUR',
    stripePriceId: 'price_1RyT4WB0j1hBhcavwtIZ1kOU', // Replace with actual yearly Stripe price ID
    features: [
      '5 AI design generations per month',
      '2 techpacks per month',
      'Custom PDF export (includes logo)',
      'Access to a curated list of manufacturers',
      'Early-stage creators testing production',
    ],
    techpackLimit: 2,
    hasCustomPDFExport: true,
    hasManufacturerAccess: true,
    billingPeriod: BillingPeriod.YEARLY,
  );

  static const SubscriptionPlan proPlan = SubscriptionPlan(
    type: SubscriptionPlanType.PRO,
    name: 'PRO',
    displayName: 'Pro',
    price: 34.99,
    yearlyPrice: 349.0,
    currency: 'EUR',
    stripePriceId: 'price_1RxPlDB0j1hBhcavA9lDOp9F', // Monthly Stripe price ID
    stripeYearlyPriceId: 'price_1RyT5pB0j1hBhcav7uph680L', // Replace with actual yearly Stripe price ID
    features: [
      '15 AI design generations per month',
      '8 techpacks per month',
      'Custom PDF export (includes logo)',
      'Access to a curated list of manufacturers',
      'Active independent creators',
    ],
    techpackLimit: 8,
    hasCustomPDFExport: true,
    hasManufacturerAccess: true,
    billingPeriod: BillingPeriod.MONTHLY,
  );

  static const SubscriptionPlan proYearlyPlan = SubscriptionPlan(
    type: SubscriptionPlanType.PRO,
    name: 'PRO_YEARLY',
    displayName: 'Pro (Yearly)',
    price: 349.0,
    yearlyPrice: 349.0,
    currency: 'EUR',
    stripePriceId: 'price_1RyT5pB0j1hBhcav7uph680L', // Replace with actual yearly Stripe price ID
    features: [
      '15 AI design generations per month',
      '8 techpacks per month',
      'Custom PDF export (includes logo)',
      'Access to a curated list of manufacturers',
      'Active independent creators',
    ],
    techpackLimit: 8,
    hasCustomPDFExport: true,
    hasManufacturerAccess: true,
    billingPeriod: BillingPeriod.YEARLY,
  );

  static List<SubscriptionPlan> get allPlans => [
        freePlan,
        starterPlan,
        starterYearlyPlan,
        proPlan,
        proYearlyPlan,
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
      case 'STARTER_YEARLY':
        return starterYearlyPlan;
      case 'PRO':
        return proPlan;
      case 'PRO_YEARLY':
        return proYearlyPlan;
      default:
        return freePlan;
    }
  }

  static SubscriptionPlan getPlanByTypeAndPeriod(SubscriptionPlanType type, BillingPeriod period) {
    if (type == SubscriptionPlanType.FREE) return freePlan;
    
    if (type == SubscriptionPlanType.STARTER) {
      return period == BillingPeriod.YEARLY ? starterYearlyPlan : starterPlan;
    }
    
    if (type == SubscriptionPlanType.PRO) {
      return period == BillingPeriod.YEARLY ? proYearlyPlan : proPlan;
    }
    
    return freePlan;
  }
}