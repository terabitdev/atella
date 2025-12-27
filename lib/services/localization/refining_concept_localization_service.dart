import 'package:flutter/material.dart';
import 'package:atella/l10n/generated/app_localizations.dart';

/// Service for bidirectional mapping between English (API) and localized (Display) values
/// for Refining Concept questions, options, and categories.
///
/// CRITICAL: Internal storage and API calls ALWAYS use English keys.
/// This service ONLY converts for display purposes.
class RefiningConceptLocalizationService {
  final BuildContext context;
  late final AppLocalizations l10n;

  RefiningConceptLocalizationService(this.context) {
    l10n = AppLocalizations.of(context)!;
  }

  // ============================================================================
  // QUESTION LOCALIZATION
  // ============================================================================

  /// Get localized question text from English question ID
  String getLocalizedQuestion(String questionId) {
    switch (questionId) {
      case 'garment_type':
        return l10n.rcQuestionGarmentType;
      case 'specific_features':
        return l10n.rcQuestionSpecificFeatures;
      case 'seasonal_constraint':
        return l10n.rcQuestionSeasonalConstraint;
      case 'target_budget':
        return l10n.rcQuestionTargetBudget;
      case 'functionalities_values':
        return l10n.rcQuestionFunctionalitiesValues;
      default:
        return questionId; // Fallback to English
    }
  }

  // ============================================================================
  // CATEGORY LOCALIZATION
  // ============================================================================

  /// Get localized category name from English category name
  String getLocalizedCategory(String categoryName) {
    switch (categoryName) {
      case 'Necklines':
        return l10n.rcCategoryNecklines;
      case 'Sleeves':
        return l10n.rcCategorySleeves;
      case 'Closures':
        return l10n.rcCategoryClosures;
      case 'Pockets':
        return l10n.rcCategoryPockets;
      case 'Waist':
        return l10n.rcCategoryWaist;
      case 'Legs':
        return l10n.rcCategoryLegs;
      case 'Finishes':
        return l10n.rcCategoryFinishes;
      default:
        return categoryName; // Fallback to English
    }
  }

  /// Get English category name from localized category name
  String getEnglishCategory(String localizedCategory) {
    if (localizedCategory == l10n.rcCategoryNecklines) return 'Necklines';
    if (localizedCategory == l10n.rcCategorySleeves) return 'Sleeves';
    if (localizedCategory == l10n.rcCategoryClosures) return 'Closures';
    if (localizedCategory == l10n.rcCategoryPockets) return 'Pockets';
    if (localizedCategory == l10n.rcCategoryWaist) return 'Waist';
    if (localizedCategory == l10n.rcCategoryLegs) return 'Legs';
    if (localizedCategory == l10n.rcCategoryFinishes) return 'Finishes';
    return localizedCategory; // Fallback
  }

  // ============================================================================
  // OPTION LOCALIZATION
  // ============================================================================

  /// Get localized option from English option
  String getLocalizedOption(String englishOption) {
    switch (englishOption) {
      // Garment type/fit options
      case 'Slim':
        return l10n.rcOptionSlim;
      case 'Oversized':
        return l10n.rcOptionOversized;
      case 'Regular':
        return l10n.rcOptionRegular;
      case 'Straight':
        return l10n.rcOptionStraight;
      case 'Fitted':
        return l10n.rcOptionFitted;
      case 'Tailored':
        return l10n.rcOptionTailored;
      case 'Cropped':
        return l10n.rcOptionCropped;
      case 'Relaxed':
        return l10n.rcOptionRelaxed;
      case 'Long':
        return l10n.rcOptionLong;

      // Neckline options
      case 'Crew':
        return l10n.rcOptionCrew;
      case 'V-neck':
        return l10n.rcOptionVNeck;
      case 'Square':
        return l10n.rcOptionSquare;
      case 'Half-shoulder':
        return l10n.rcOptionHalfShoulder;
      case 'Scoop':
        return l10n.rcOptionScoop;
      case 'Boat neck':
        return l10n.rcOptionBoatNeck;

      // Sleeve options
      case 'Sleeveless':
        return l10n.rcOptionSleeveless;
      case 'Short ¾':
        return l10n.rcOptionShortThreeQuarter;
      case 'Puff':
        return l10n.rcOptionPuff;
      case 'Raglan':
        return l10n.rcOptionRaglan;
      case 'Cap':
        return l10n.rcOptionCap;

      // Closure options
      case 'Zipper (metal/plastic/invisible)':
        return l10n.rcOptionZipper;
      case 'Buttons':
        return l10n.rcOptionButtons;
      case 'Hooks':
        return l10n.rcOptionHooks;
      case 'Velcro':
        return l10n.rcOptionVelcro;
      case 'Snaps':
        return l10n.rcOptionSnaps;

      // Pocket options
      case 'Patch':
        return l10n.rcOptionPatch;
      case 'Welt':
        return l10n.rcOptionWelt;
      case 'Flap':
        return l10n.rcOptionFlap;
      case 'Hidden':
        return l10n.rcOptionHidden;
      case 'Cargo':
        return l10n.rcOptionCargo;

      // Waist options
      case 'Elastic':
        return l10n.rcOptionElastic;
      case 'High-waist':
        return l10n.rcOptionHighWaist;
      case 'Low-rise':
        return l10n.rcOptionLowRise;
      case 'Belted':
        return l10n.rcOptionBelted;
      case 'Drawstring':
        return l10n.rcOptionDrawstring;

      // Leg options
      case 'Straight leg':
        return l10n.rcOptionStraightLeg;
      case 'Tapered':
        return l10n.rcOptionTapered;
      case 'Wide leg':
        return l10n.rcOptionWideLeg;
      case 'Bootcut':
        return l10n.rcOptionBootcut;
      case 'Flared':
        return l10n.rcOptionFlared;

      // Finish options
      case 'Lining':
        return l10n.rcOptionLining;
      case 'Topstitching':
        return l10n.rcOptionTopstitching;
      case 'Embroidery':
        return l10n.rcOptionEmbroidery;
      case 'Lace':
        return l10n.rcOptionLace;
      case 'Sequins':
        return l10n.rcOptionSequins;
      case 'Appliqués':
        return l10n.rcOptionAppliques;

      // Seasonal options
      case 'Summer':
        return l10n.rcOptionSummer;
      case 'Mid-Season':
        return l10n.rcOptionMidSeason;
      case 'All-Season':
        return l10n.rcOptionAllSeason;

      // Budget options
      case 'Price Range In €':
        return l10n.rcOptionPriceRangeInEuro;
      case 'An Indication Of The Market Level':
        return l10n.rcOptionIndicationOfMarketLevel;
      case 'Entry':
        return l10n.rcOptionEntry;
      case 'Mid-Range':
        return l10n.rcOptionMidRange;
      case 'Premium':
        return l10n.rcOptionPremium;

      // Functionality/Values options
      case 'Organic Fabric':
        return l10n.rcOptionOrganicFabric;
      case 'Locally Made':
        return l10n.rcOptionLocallyMade;
      case 'Upcycled':
        return l10n.rcOptionUpcycled;
      case 'UV Protection':
        return l10n.rcOptionUVProtection;
      case 'Quick-Dry':
        return l10n.rcOptionQuickDry;
      case 'Wrinkle-Free':
        return l10n.rcOptionWrinkleFree;

      // Custom option (appears in all questions)
      case 'Custom':
        return l10n.rcOptionCustom;

      default:
        return englishOption; // Fallback to English
    }
  }

  /// Get English option from localized option (for API calls)
  String getEnglishOption(String localizedOption) {
    // Garment type/fit options
    if (localizedOption == l10n.rcOptionSlim) return 'Slim';
    if (localizedOption == l10n.rcOptionOversized) return 'Oversized';
    if (localizedOption == l10n.rcOptionRegular) return 'Regular';
    if (localizedOption == l10n.rcOptionStraight) return 'Straight';
    if (localizedOption == l10n.rcOptionFitted) return 'Fitted';
    if (localizedOption == l10n.rcOptionTailored) return 'Tailored';
    if (localizedOption == l10n.rcOptionCropped) return 'Cropped';
    if (localizedOption == l10n.rcOptionRelaxed) return 'Relaxed';
    if (localizedOption == l10n.rcOptionLong) return 'Long';

    // Neckline options
    if (localizedOption == l10n.rcOptionCrew) return 'Crew';
    if (localizedOption == l10n.rcOptionVNeck) return 'V-neck';
    if (localizedOption == l10n.rcOptionSquare) return 'Square';
    if (localizedOption == l10n.rcOptionHalfShoulder) return 'Half-shoulder';
    if (localizedOption == l10n.rcOptionScoop) return 'Scoop';
    if (localizedOption == l10n.rcOptionBoatNeck) return 'Boat neck';

    // Sleeve options
    if (localizedOption == l10n.rcOptionSleeveless) return 'Sleeveless';
    if (localizedOption == l10n.rcOptionShortThreeQuarter) return 'Short ¾';
    if (localizedOption == l10n.rcOptionPuff) return 'Puff';
    if (localizedOption == l10n.rcOptionRaglan) return 'Raglan';
    if (localizedOption == l10n.rcOptionCap) return 'Cap';

    // Closure options
    if (localizedOption == l10n.rcOptionZipper) return 'Zipper (metal/plastic/invisible)';
    if (localizedOption == l10n.rcOptionButtons) return 'Buttons';
    if (localizedOption == l10n.rcOptionHooks) return 'Hooks';
    if (localizedOption == l10n.rcOptionVelcro) return 'Velcro';
    if (localizedOption == l10n.rcOptionSnaps) return 'Snaps';

    // Pocket options
    if (localizedOption == l10n.rcOptionPatch) return 'Patch';
    if (localizedOption == l10n.rcOptionWelt) return 'Welt';
    if (localizedOption == l10n.rcOptionFlap) return 'Flap';
    if (localizedOption == l10n.rcOptionHidden) return 'Hidden';
    if (localizedOption == l10n.rcOptionCargo) return 'Cargo';

    // Waist options
    if (localizedOption == l10n.rcOptionElastic) return 'Elastic';
    if (localizedOption == l10n.rcOptionHighWaist) return 'High-waist';
    if (localizedOption == l10n.rcOptionLowRise) return 'Low-rise';
    if (localizedOption == l10n.rcOptionBelted) return 'Belted';
    if (localizedOption == l10n.rcOptionDrawstring) return 'Drawstring';

    // Leg options
    if (localizedOption == l10n.rcOptionStraightLeg) return 'Straight leg';
    if (localizedOption == l10n.rcOptionTapered) return 'Tapered';
    if (localizedOption == l10n.rcOptionWideLeg) return 'Wide leg';
    if (localizedOption == l10n.rcOptionBootcut) return 'Bootcut';
    if (localizedOption == l10n.rcOptionFlared) return 'Flared';

    // Finish options
    if (localizedOption == l10n.rcOptionLining) return 'Lining';
    if (localizedOption == l10n.rcOptionTopstitching) return 'Topstitching';
    if (localizedOption == l10n.rcOptionEmbroidery) return 'Embroidery';
    if (localizedOption == l10n.rcOptionLace) return 'Lace';
    if (localizedOption == l10n.rcOptionSequins) return 'Sequins';
    if (localizedOption == l10n.rcOptionAppliques) return 'Appliqués';

    // Seasonal options
    if (localizedOption == l10n.rcOptionSummer) return 'Summer';
    if (localizedOption == l10n.rcOptionMidSeason) return 'Mid-Season';
    if (localizedOption == l10n.rcOptionAllSeason) return 'All-Season';

    // Budget options
    if (localizedOption == l10n.rcOptionPriceRangeInEuro) return 'Price Range In €';
    if (localizedOption == l10n.rcOptionIndicationOfMarketLevel) return 'An Indication Of The Market Level';
    if (localizedOption == l10n.rcOptionEntry) return 'Entry';
    if (localizedOption == l10n.rcOptionMidRange) return 'Mid-Range';
    if (localizedOption == l10n.rcOptionPremium) return 'Premium';

    // Functionality/Values options
    if (localizedOption == l10n.rcOptionOrganicFabric) return 'Organic Fabric';
    if (localizedOption == l10n.rcOptionLocallyMade) return 'Locally Made';
    if (localizedOption == l10n.rcOptionUpcycled) return 'Upcycled';
    if (localizedOption == l10n.rcOptionUVProtection) return 'UV Protection';
    if (localizedOption == l10n.rcOptionQuickDry) return 'Quick-Dry';
    if (localizedOption == l10n.rcOptionWrinkleFree) return 'Wrinkle-Free';

    // Custom option
    if (localizedOption == l10n.rcOptionCustom) return 'Custom';

    return localizedOption; // Fallback
  }

  /// Get list of localized options from English options
  List<String> getLocalizedOptions(List<String> englishOptions) {
    return englishOptions.map((opt) => getLocalizedOption(opt)).toList();
  }

  /// Get localized categories map from English categories
  Map<String, List<String>> getLocalizedCategories(
    Map<String, List<String>> englishCategories,
  ) {
    Map<String, List<String>> localized = {};
    for (var entry in englishCategories.entries) {
      final localizedCategoryName = getLocalizedCategory(entry.key);
      final localizedOptions = getLocalizedOptions(entry.value);
      localized[localizedCategoryName] = localizedOptions;
    }
    return localized;
  }
}
