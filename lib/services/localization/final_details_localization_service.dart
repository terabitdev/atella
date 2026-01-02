import 'package:flutter/material.dart';
import 'package:atella/l10n/generated/app_localizations.dart';

class FinalDetailsLocalizationService {
  final BuildContext context;
  late final AppLocalizations l10n;

  FinalDetailsLocalizationService(this.context) {
    l10n = AppLocalizations.of(context)!;
  }

  // QUESTION LOCALIZATION
  String getLocalizedQuestion(String questionId) {
    switch (questionId) {
      case 'target_season':
        return l10n.fdQuestionTargetSeason;
      case 'target_budget':
        return l10n.fdQuestionTargetBudget;
      case 'desired_features':
        return l10n.fdQuestionDesiredFeatures;
      case 'additional_details':
        return l10n.fdQuestionAdditionalDetails;
      default:
        return questionId;
    }
  }

  // OPTION LOCALIZATION - Maps English options to localized text
  String getLocalizedOption(String englishOption) {
    switch (englishOption) {
      // Season options
      case 'Summer (Lightweight, Short Or Roll-Up Sleeves)':
        return l10n.fdSeasonSummer;
      case 'Mid-Season':
        return l10n.fdSeasonMid;
      case 'All-Season (Layer-Friendly)':
        return l10n.fdSeasonAll;

      // Budget options
      case 'Entry-Level (€15-30 Production / €35-60 Retail)':
        return l10n.fdBudgetEntry;
      case 'Mid-Range (€30-50 Production / €60-120 Retail)':
        return l10n.fdBudgetMid;
      case 'Premium (€60+ Production / €120+ Retail)':
        return l10n.fdBudgetPremium;

      // Feature options
      case 'Organic Fabric':
        return l10n.fdFeatureOrganic;
      case 'Upcycled Materials':
        return l10n.fdFeatureUpcycled;
      case 'Locally Made (Europe)':
        return l10n.fdFeatureLocallyMade;
      case 'UV Protection':
        return l10n.fdFeatureUvProtection;
      case 'Quick-Dry':
        return l10n.fdFeatureQuickDry;
      case 'Wrinkle-Free':
        return l10n.fdFeatureWrinkleFree;
      case 'Other: ?':
        return l10n.fdFeatureOther;

      default:
        return englishOption; // Fallback
    }
  }

  // REVERSE OPTION MAPPING - Maps localized options back to English for API
  // This is CRITICAL - ensures API always receives English values
  String getEnglishOption(String localizedOption) {
    // Season options
    if (localizedOption == l10n.fdSeasonSummer) return 'Summer (Lightweight, Short Or Roll-Up Sleeves)';
    if (localizedOption == l10n.fdSeasonMid) return 'Mid-Season';
    if (localizedOption == l10n.fdSeasonAll) return 'All-Season (Layer-Friendly)';

    // Budget options
    if (localizedOption == l10n.fdBudgetEntry) return 'Entry-Level (€15-30 Production / €35-60 Retail)';
    if (localizedOption == l10n.fdBudgetMid) return 'Mid-Range (€30-50 Production / €60-120 Retail)';
    if (localizedOption == l10n.fdBudgetPremium) return 'Premium (€60+ Production / €120+ Retail)';

    // Feature options
    if (localizedOption == l10n.fdFeatureOrganic) return 'Organic Fabric';
    if (localizedOption == l10n.fdFeatureUpcycled) return 'Upcycled Materials';
    if (localizedOption == l10n.fdFeatureLocallyMade) return 'Locally Made (Europe)';
    if (localizedOption == l10n.fdFeatureUvProtection) return 'UV Protection';
    if (localizedOption == l10n.fdFeatureQuickDry) return 'Quick-Dry';
    if (localizedOption == l10n.fdFeatureWrinkleFree) return 'Wrinkle-Free';
    if (localizedOption == l10n.fdFeatureOther) return 'Other: ?';

    return localizedOption; // Fallback
  }

  // Helper method - converts list of English options to localized
  List<String> getLocalizedOptions(List<String> englishOptions) {
    return englishOptions.map((opt) => getLocalizedOption(opt)).toList();
  }
}
