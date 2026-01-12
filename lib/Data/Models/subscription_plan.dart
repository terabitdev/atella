enum SubscriptionPlanType {
  FREE,
  STARTER,
  PRO,
  STUDIO,
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
    price: 19.99,
    yearlyPrice: 199.99,
    currency: 'EUR',
    stripePriceId: 'price_1SkpjzB0j1hBhcavgG4UB87r', // Monthly Stripe price ID
    stripeYearlyPriceId: 'price_1Skpl7B0j1hBhcav7os5P9pw', // Yearly Stripe price ID
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
    price: 199.99,
    yearlyPrice: 199.99,
    currency: 'EUR',
    stripePriceId: 'price_1Skpl7B0j1hBhcav7os5P9pw', // Yearly Stripe price ID
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
    price: 49.99,
    yearlyPrice: 499.99,
    currency: 'EUR',
    stripePriceId: 'price_1SkpjMB0j1hBhcavs7UzslCL', // Monthly Stripe price ID
    stripeYearlyPriceId: 'price_1SklhgB0j1hBhcavEji0sk0o', // Yearly Stripe price ID
    features: [
      '12 AI design generations per month',
      '6 techpacks per month',
      'Custom PDF export (includes logo)',
      'Access to a curated list of manufacturers',
      'Active independent creators',
    ],
    techpackLimit: 6,
    hasCustomPDFExport: true,
    hasManufacturerAccess: true,
    billingPeriod: BillingPeriod.MONTHLY,
  );

  static const SubscriptionPlan proYearlyPlan = SubscriptionPlan(
    type: SubscriptionPlanType.PRO,
    name: 'PRO_YEARLY',
    displayName: 'Pro (Yearly)',
    price: 499.99,
    yearlyPrice: 499.99,
    currency: 'EUR',
    stripePriceId: 'price_1SklhgB0j1hBhcavEji0sk0o', // Yearly Stripe price ID
    features: [
      '12 AI design generations per month',
      '6 techpacks per month',
      'Custom PDF export (includes logo)',
      'Access to a curated list of manufacturers',
      'Active independent creators',
    ],
    techpackLimit: 6,
    hasCustomPDFExport: true,
    hasManufacturerAccess: true,
    billingPeriod: BillingPeriod.YEARLY,
  );

  static const SubscriptionPlan studioPlan = SubscriptionPlan(
    type: SubscriptionPlanType.STUDIO,
    name: 'STUDIO',
    displayName: 'Studio',
    price: 99.99,
    yearlyPrice: 999.99,
    currency: 'EUR',
    stripePriceId: 'price_1SkqNeB0j1hBhcavJhDuJAbm', // Monthly Stripe price ID
    stripeYearlyPriceId: 'price_1SkqO3B0j1hBhcavvZewFYVF', // Yearly Stripe price ID
    features: [
      '25 AI design generations per month',
      '10 techpacks per month',
      'Priority access',
      'Full branding',
      'Full exports',
      'Factory access',
    ],
    techpackLimit: 10,
    hasCustomPDFExport: true,
    hasManufacturerAccess: true,
    billingPeriod: BillingPeriod.MONTHLY,
  );

  static const SubscriptionPlan studioYearlyPlan = SubscriptionPlan(
    type: SubscriptionPlanType.STUDIO,
    name: 'STUDIO_YEARLY',
    displayName: 'Studio (Yearly)',
    price: 999.99,
    yearlyPrice: 999.99,
    currency: 'EUR',
    stripePriceId: 'price_1SkqO3B0j1hBhcavvZewFYVF', // Yearly Stripe price ID
    features: [
      '25 AI design generations per month',
      '10 techpacks per month',
      'Priority access',
      'Full branding',
      'Full exports',
      'Factory access',
    ],
    techpackLimit: 10,
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
        studioPlan,
        studioYearlyPlan,
      ];

  static SubscriptionPlan getPlanByType(SubscriptionPlanType type) {
    switch (type) {
      case SubscriptionPlanType.FREE:
        return freePlan;
      case SubscriptionPlanType.STARTER:
        return starterPlan;
      case SubscriptionPlanType.PRO:
        return proPlan;
      case SubscriptionPlanType.STUDIO:
        return studioPlan;
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
      case 'STUDIO':
        return studioPlan;
      case 'STUDIO_YEARLY':
        return studioYearlyPlan;
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

    if (type == SubscriptionPlanType.STUDIO) {
      return period == BillingPeriod.YEARLY ? studioYearlyPlan : studioPlan;
    }

    return freePlan;
  }
}