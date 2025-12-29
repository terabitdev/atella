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
        return l10n.fdQuestionSeason;
      case 'target_budget':
        return l10n.fdQuestionBudget;
      case 'desired_features':
        return l10n.fdQuestionFeatures;
      case 'additional_details':
        return l10n.fdQuestionAdditional;
      default:
        return questionId;
    }
  }

  // OPTION LOCALIZATION - Maps English options to localized text
  String getLocalizedOption(String englishOption) {
    switch (englishOption) {
      // Season options
      case 'Summer (Lightweight, Short Or Roll-Up Sleeves)':
        return l10n.fdOptionSummer;
      case 'Mid-Season':
        return l10n.fdOptionMidSeason;
      case 'All-Season (Layer-Friendly)':
        return l10n.fdOptionAllSeason;

      // Budget options
      case 'Entry-Level (€15-30 Production / €35-60 Retail)':
        return l10n.fdOptionEntryLevel;
      case 'Mid-Range (€30-50 Production / €60-120 Retail)':
        return l10n.fdOptionMidRange;
      case 'Premium (€60+ Production / €120+ Retail)':
        return l10n.fdOptionPremium;

      // Feature options
      case 'Organic Fabric':
        return l10n.fdOptionOrganicFabric;
      case 'Upcycled Materials':
        return l10n.fdOptionUpcycled;
      case 'Locally Made (Europe)':
        return l10n.fdOptionLocallyMade;
      case 'UV Protection':
        return l10n.fdOptionUVProtection;
      case 'Quick-Dry':
        return l10n.fdOptionQuickDry;
      case 'Wrinkle-Free':
        return l10n.fdOptionWrinkleFree;
      case 'Other: ?':
        return l10n.fdOptionOther;

      default:
        return englishOption; // Fallback
    }
  }

  // REVERSE OPTION MAPPING - Maps localized options back to English for API
  // This is CRITICAL - ensures API always receives English values
  String getEnglishOption(String localizedOption) {
    // Season options
    if (localizedOption == l10n.fdOptionSummer) return 'Summer (Lightweight, Short Or Roll-Up Sleeves)';
    if (localizedOption == l10n.fdOptionMidSeason) return 'Mid-Season';
    if (localizedOption == l10n.fdOptionAllSeason) return 'All-Season (Layer-Friendly)';

    // Budget options
    if (localizedOption == l10n.fdOptionEntryLevel) return 'Entry-Level (€15-30 Production / €35-60 Retail)';
    if (localizedOption == l10n.fdOptionMidRange) return 'Mid-Range (€30-50 Production / €60-120 Retail)';
    if (localizedOption == l10n.fdOptionPremium) return 'Premium (€60+ Production / €120+ Retail)';

    // Feature options
    if (localizedOption == l10n.fdOptionOrganicFabric) return 'Organic Fabric';
    if (localizedOption == l10n.fdOptionUpcycled) return 'Upcycled Materials';
    if (localizedOption == l10n.fdOptionLocallyMade) return 'Locally Made (Europe)';
    if (localizedOption == l10n.fdOptionUVProtection) return 'UV Protection';
    if (localizedOption == l10n.fdOptionQuickDry) return 'Quick-Dry';
    if (localizedOption == l10n.fdOptionWrinkleFree) return 'Wrinkle-Free';
    if (localizedOption == l10n.fdOptionOther) return 'Other: ?';

    return localizedOption; // Fallback
  }

  // Helper method - converts list of English options to localized
  List<String> getLocalizedOptions(List<String> englishOptions) {
    return englishOptions.map((opt) => getLocalizedOption(opt)).toList();
  }
}
