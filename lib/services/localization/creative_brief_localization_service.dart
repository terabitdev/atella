import 'package:flutter/material.dart';
import 'package:atella/l10n/generated/app_localizations.dart';

/// Service for bidirectional mapping between English (API) and localized (Display) values
/// for Creative Brief questions, options, and categories.
///
/// CRITICAL: Internal storage and API calls ALWAYS use English keys.
/// This service ONLY converts for display purposes.
class CreativeBriefLocalizationService {
  final BuildContext context;
  late final AppLocalizations l10n;

  CreativeBriefLocalizationService(this.context) {
    l10n = AppLocalizations.of(context)!;
  }

  // ============================================================================
  // QUESTION LOCALIZATION
  // ============================================================================

  /// Get localized question text from English question ID
  String getLocalizedQuestion(String questionId) {
    switch (questionId) {
      case 'garment_type':
        return l10n.cbQuestionGarmentType;
      case 'style':
        return l10n.cbQuestionStyle;
      case 'target_audience':
        return l10n.cbQuestionTargetAudience;
      case 'occasion':
        return l10n.cbQuestionOccasion;
      case 'inspiration':
        return l10n.cbQuestionInspiration;
      case 'colors':
        return l10n.cbQuestionColors;
      case 'fabrics':
        return l10n.cbQuestionFabrics;
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
      // Garment categories
      case 'Tops':
        return l10n.cbCategoryTops;
      case 'Bottoms':
        return l10n.cbCategoryBottoms;
      case 'Dresses':
        return l10n.cbCategoryDresses;
      case 'Jumpsuits':
        return l10n.cbCategoryJumpsuits;
      case 'Outerwear':
        return l10n.cbCategoryOuterwear;
      case 'Sportswear':
        return l10n.cbCategorySportswear;
      case 'Accessories':
        return l10n.cbCategoryAccessories;

      // Fabric categories
      case 'Cotton':
        return l10n.cbCategoryCotton;
      case 'Wool':
        return l10n.cbCategoryWool;
      case 'Silk':
        return l10n.cbCategorySilk;
      case 'Linen':
        return l10n.cbCategoryLinen;
      case 'Synthetic':
        return l10n.cbCategorySynthetic;
      case 'Eco options':
        return l10n.cbCategoryEcoOptions;
      case 'Leather/Faux leather':
        return l10n.cbCategoryLeatherFauxLeather;
      case 'Knitwear':
        return l10n.cbCategoryKnitwear;

      // Color categories
      case 'Prints':
        return l10n.cbCategoryPrints;
      case 'Techniques':
        return l10n.cbCategoryTechniques;

      default:
        return categoryName; // Fallback to English
    }
  }

  /// Get English category name from localized category name
  String getEnglishCategory(String localizedCategory) {
    // Garment categories
    if (localizedCategory == l10n.cbCategoryTops) return 'Tops';
    if (localizedCategory == l10n.cbCategoryBottoms) return 'Bottoms';
    if (localizedCategory == l10n.cbCategoryDresses) return 'Dresses';
    if (localizedCategory == l10n.cbCategoryJumpsuits) return 'Jumpsuits';
    if (localizedCategory == l10n.cbCategoryOuterwear) return 'Outerwear';
    if (localizedCategory == l10n.cbCategorySportswear) return 'Sportswear';
    if (localizedCategory == l10n.cbCategoryAccessories) return 'Accessories';

    // Fabric categories
    if (localizedCategory == l10n.cbCategoryCotton) return 'Cotton';
    if (localizedCategory == l10n.cbCategoryWool) return 'Wool';
    if (localizedCategory == l10n.cbCategorySilk) return 'Silk';
    if (localizedCategory == l10n.cbCategoryLinen) return 'Linen';
    if (localizedCategory == l10n.cbCategorySynthetic) return 'Synthetic';
    if (localizedCategory == l10n.cbCategoryEcoOptions) return 'Eco options';
    if (localizedCategory == l10n.cbCategoryLeatherFauxLeather) return 'Leather/Faux leather';
    if (localizedCategory == l10n.cbCategoryKnitwear) return 'Knitwear';

    // Color categories
    if (localizedCategory == l10n.cbCategoryPrints) return 'Prints';
    if (localizedCategory == l10n.cbCategoryTechniques) return 'Techniques';

    return localizedCategory; // Fallback to input
  }

  // ============================================================================
  // OPTION LOCALIZATION
  // ============================================================================

  /// Get localized option from English option
  String getLocalizedOption(String englishOption) {
    switch (englishOption) {
      // Garment type options
      case 'T-shirt':
        return l10n.cbOptionTShirt;
      case 'Shirt':
        return l10n.cbOptionShirt;
      case 'Blouse':
        return l10n.cbOptionBlouse;
      case 'Hoodie':
        return l10n.cbOptionHoodie;
      case 'Jacket':
        return l10n.cbOptionJacket;
      case 'Coat':
        return l10n.cbOptionCoat;
      case 'Vest':
        return l10n.cbOptionVest;
      case 'Tank top':
        return l10n.cbOptionTankTop;
      case 'Crop top':
        return l10n.cbOptionCropTop;
      case 'Sweater':
        return l10n.cbOptionSweater;
      case 'Pants':
        return l10n.cbOptionPants;
      case 'Jeans':
        return l10n.cbOptionJeans;
      case 'Skirts':
        return l10n.cbOptionSkirts;
      case 'Shorts':
        return l10n.cbOptionShorts;
      case 'Leggings':
        return l10n.cbOptionLeggings;
      case 'Culottes':
        return l10n.cbOptionCulottes;
      case 'Palazzo':
        return l10n.cbOptionPalazzo;
      case 'Joggers':
        return l10n.cbOptionJoggers;
      case 'Casual dress':
        return l10n.cbOptionCasualDress;
      case 'Evening':
        return l10n.cbOptionEvening;
      case 'Cocktail dress':
        return l10n.cbOptionCocktailDress;
      case 'Gown':
        return l10n.cbOptionGown;
      case 'Maxi dress':
        return l10n.cbOptionMaxiDress;
      case 'Midi dress':
        return l10n.cbOptionMidiDress;
      case 'Mini dress':
        return l10n.cbOptionMiniDress;
      case 'Jumpsuit':
        return l10n.cbOptionJumpsuit;
      case 'Romper':
        return l10n.cbOptionRomper;
      case 'Playsuit':
        return l10n.cbOptionPlaysuit;
      case 'Overalls':
        return l10n.cbOptionOveralls;
      case 'Trench coat':
        return l10n.cbOptionTrenchCoat;
      case 'Bomber jacket':
        return l10n.cbOptionBomberJacket;
      case 'Blazer':
        return l10n.cbOptionBlazer;
      case 'Puffer jacket':
        return l10n.cbOptionPufferJacket;
      case 'Tracksuit':
        return l10n.cbOptionTracksuit;
      case 'Activewear':
        return l10n.cbOptionActivewear;
      case 'Swimwear':
        return l10n.cbOptionSwimwear;
      case 'Hat':
        return l10n.cbOptionHat;
      case 'Bag':
        return l10n.cbOptionBag;
      case 'Scarf':
        return l10n.cbOptionScarf;
      case 'Gloves':
        return l10n.cbOptionGloves;

      // Style options
      case 'Casual':
        return l10n.cbOptionCasual;
      case 'Chic':
        return l10n.cbOptionChic;
      case 'Sporty':
        return l10n.cbOptionSporty;
      case 'Streetwear':
        return l10n.cbOptionStreetwear;
      case 'Workwear':
        return l10n.cbOptionWorkwear;

      // Target audience options
      case 'Woman':
        return l10n.cbOptionWoman;
      case 'Man':
        return l10n.cbOptionMan;
      case 'Child':
        return l10n.cbOptionChild;
      case 'Unisex':
        return l10n.cbOptionUnisex;
      case 'Target Age':
        return l10n.cbOptionTargetAge;

      // Occasion options
      case 'Everyday wear':
        return l10n.cbOptionEverydayWear;
      case 'Special event':
        return l10n.cbOptionSpecialEvent;
      case 'Sports':
        return l10n.cbOptionSports;
      case 'Activity':
        return l10n.cbOptionActivity;

      // Print options
      case 'Floral':
        return l10n.cbOptionFloral;
      case 'Abstract':
        return l10n.cbOptionAbstract;
      case 'Camouflage':
        return l10n.cbOptionCamouflage;
      case 'Stripes':
        return l10n.cbOptionStripes;
      case 'Polka dots':
        return l10n.cbOptionPolkaDots;
      case 'Tie-dye':
        return l10n.cbOptionTieDye;

      // Technique options
      case 'Color blocking':
        return l10n.cbOptionColorBlocking;
      case 'Gradient/Ombré':
        return l10n.cbOptionGradientOmbre;
      case 'Embroidery':
        return l10n.cbOptionEmbroidery;
      case 'Jacquard':
        return l10n.cbOptionJacquard;

      // Fabric options
      case 'Lightweight (poplin, voile)':
        return l10n.cbOptionLightweight;
      case 'Medium (twill)':
        return l10n.cbOptionMedium;
      case 'Heavy (denim, canvas)':
        return l10n.cbOptionHeavy;
      case 'Merino':
        return l10n.cbOptionMerino;
      case 'Cashmere':
        return l10n.cbOptionCashmere;
      case 'Tweed':
        return l10n.cbOptionTweed;
      case 'Felt':
        return l10n.cbOptionFelt;
      case 'Satin':
        return l10n.cbOptionSatin;
      case 'Chiffon':
        return l10n.cbOptionChiffon;
      case 'Organza':
        return l10n.cbOptionOrganza;
      case 'Plain':
        return l10n.cbOptionPlain;
      case 'Textured':
        return l10n.cbOptionTextured;
      case 'Blended':
        return l10n.cbOptionBlended;
      case 'Polyester':
        return l10n.cbOptionPolyester;
      case 'Nylon':
        return l10n.cbOptionNylon;
      case 'Spandex':
        return l10n.cbOptionSpandex;
      case 'Neoprene':
        return l10n.cbOptionNeoprene;
      case 'Organic cotton':
        return l10n.cbOptionOrganicCotton;
      case 'Recycled polyester':
        return l10n.cbOptionRecycledPolyester;
      case 'Bamboo':
        return l10n.cbOptionBamboo;
      case 'Hemp':
        return l10n.cbOptionHemp;
      case 'Leather':
        return l10n.cbOptionLeather;
      case 'Faux leather':
        return l10n.cbOptionFauxLeather;
      case 'Jersey':
        return l10n.cbOptionJersey;
      case 'Rib knit':
        return l10n.cbOptionRibKnit;
      case 'Interlock':
        return l10n.cbOptionInterlock;

      // Special option
      case 'Custom':
        return l10n.cbOptionCustom;

      default:
        return englishOption; // Fallback to English
    }
  }

  /// Get English option from localized option
  String getEnglishOption(String localizedOption) {
    // Garment type options
    if (localizedOption == l10n.cbOptionTShirt) return 'T-shirt';
    if (localizedOption == l10n.cbOptionShirt) return 'Shirt';
    if (localizedOption == l10n.cbOptionBlouse) return 'Blouse';
    if (localizedOption == l10n.cbOptionHoodie) return 'Hoodie';
    if (localizedOption == l10n.cbOptionJacket) return 'Jacket';
    if (localizedOption == l10n.cbOptionCoat) return 'Coat';
    if (localizedOption == l10n.cbOptionVest) return 'Vest';
    if (localizedOption == l10n.cbOptionTankTop) return 'Tank top';
    if (localizedOption == l10n.cbOptionCropTop) return 'Crop top';
    if (localizedOption == l10n.cbOptionSweater) return 'Sweater';
    if (localizedOption == l10n.cbOptionPants) return 'Pants';
    if (localizedOption == l10n.cbOptionJeans) return 'Jeans';
    if (localizedOption == l10n.cbOptionSkirts) return 'Skirts';
    if (localizedOption == l10n.cbOptionShorts) return 'Shorts';
    if (localizedOption == l10n.cbOptionLeggings) return 'Leggings';
    if (localizedOption == l10n.cbOptionCulottes) return 'Culottes';
    if (localizedOption == l10n.cbOptionPalazzo) return 'Palazzo';
    if (localizedOption == l10n.cbOptionJoggers) return 'Joggers';
    if (localizedOption == l10n.cbOptionCasualDress) return 'Casual dress';
    if (localizedOption == l10n.cbOptionEvening) return 'Evening';
    if (localizedOption == l10n.cbOptionCocktailDress) return 'Cocktail dress';
    if (localizedOption == l10n.cbOptionGown) return 'Gown';
    if (localizedOption == l10n.cbOptionMaxiDress) return 'Maxi dress';
    if (localizedOption == l10n.cbOptionMidiDress) return 'Midi dress';
    if (localizedOption == l10n.cbOptionMiniDress) return 'Mini dress';
    if (localizedOption == l10n.cbOptionJumpsuit) return 'Jumpsuit';
    if (localizedOption == l10n.cbOptionRomper) return 'Romper';
    if (localizedOption == l10n.cbOptionPlaysuit) return 'Playsuit';
    if (localizedOption == l10n.cbOptionOveralls) return 'Overalls';
    if (localizedOption == l10n.cbOptionTrenchCoat) return 'Trench coat';
    if (localizedOption == l10n.cbOptionBomberJacket) return 'Bomber jacket';
    if (localizedOption == l10n.cbOptionBlazer) return 'Blazer';
    if (localizedOption == l10n.cbOptionPufferJacket) return 'Puffer jacket';
    if (localizedOption == l10n.cbOptionTracksuit) return 'Tracksuit';
    if (localizedOption == l10n.cbOptionActivewear) return 'Activewear';
    if (localizedOption == l10n.cbOptionSwimwear) return 'Swimwear';
    if (localizedOption == l10n.cbOptionHat) return 'Hat';
    if (localizedOption == l10n.cbOptionBag) return 'Bag';
    if (localizedOption == l10n.cbOptionScarf) return 'Scarf';
    if (localizedOption == l10n.cbOptionGloves) return 'Gloves';

    // Style options
    if (localizedOption == l10n.cbOptionCasual) return 'Casual';
    if (localizedOption == l10n.cbOptionChic) return 'Chic';
    if (localizedOption == l10n.cbOptionSporty) return 'Sporty';
    if (localizedOption == l10n.cbOptionStreetwear) return 'Streetwear';
    if (localizedOption == l10n.cbOptionWorkwear) return 'Workwear';

    // Target audience options
    if (localizedOption == l10n.cbOptionWoman) return 'Woman';
    if (localizedOption == l10n.cbOptionMan) return 'Man';
    if (localizedOption == l10n.cbOptionChild) return 'Child';
    if (localizedOption == l10n.cbOptionUnisex) return 'Unisex';
    if (localizedOption == l10n.cbOptionTargetAge) return 'Target Age';

    // Occasion options
    if (localizedOption == l10n.cbOptionEverydayWear) return 'Everyday wear';
    if (localizedOption == l10n.cbOptionSpecialEvent) return 'Special event';
    if (localizedOption == l10n.cbOptionSports) return 'Sports';
    if (localizedOption == l10n.cbOptionActivity) return 'Activity';

    // Print options
    if (localizedOption == l10n.cbOptionFloral) return 'Floral';
    if (localizedOption == l10n.cbOptionAbstract) return 'Abstract';
    if (localizedOption == l10n.cbOptionCamouflage) return 'Camouflage';
    if (localizedOption == l10n.cbOptionStripes) return 'Stripes';
    if (localizedOption == l10n.cbOptionPolkaDots) return 'Polka dots';
    if (localizedOption == l10n.cbOptionTieDye) return 'Tie-dye';

    // Technique options
    if (localizedOption == l10n.cbOptionColorBlocking) return 'Color blocking';
    if (localizedOption == l10n.cbOptionGradientOmbre) return 'Gradient/Ombré';
    if (localizedOption == l10n.cbOptionEmbroidery) return 'Embroidery';
    if (localizedOption == l10n.cbOptionJacquard) return 'Jacquard';

    // Fabric options
    if (localizedOption == l10n.cbOptionLightweight) return 'Lightweight (poplin, voile)';
    if (localizedOption == l10n.cbOptionMedium) return 'Medium (twill)';
    if (localizedOption == l10n.cbOptionHeavy) return 'Heavy (denim, canvas)';
    if (localizedOption == l10n.cbOptionMerino) return 'Merino';
    if (localizedOption == l10n.cbOptionCashmere) return 'Cashmere';
    if (localizedOption == l10n.cbOptionTweed) return 'Tweed';
    if (localizedOption == l10n.cbOptionFelt) return 'Felt';
    if (localizedOption == l10n.cbOptionSatin) return 'Satin';
    if (localizedOption == l10n.cbOptionChiffon) return 'Chiffon';
    if (localizedOption == l10n.cbOptionOrganza) return 'Organza';
    if (localizedOption == l10n.cbOptionPlain) return 'Plain';
    if (localizedOption == l10n.cbOptionTextured) return 'Textured';
    if (localizedOption == l10n.cbOptionBlended) return 'Blended';
    if (localizedOption == l10n.cbOptionPolyester) return 'Polyester';
    if (localizedOption == l10n.cbOptionNylon) return 'Nylon';
    if (localizedOption == l10n.cbOptionSpandex) return 'Spandex';
    if (localizedOption == l10n.cbOptionNeoprene) return 'Neoprene';
    if (localizedOption == l10n.cbOptionOrganicCotton) return 'Organic cotton';
    if (localizedOption == l10n.cbOptionRecycledPolyester) return 'Recycled polyester';
    if (localizedOption == l10n.cbOptionBamboo) return 'Bamboo';
    if (localizedOption == l10n.cbOptionHemp) return 'Hemp';
    if (localizedOption == l10n.cbOptionLeather) return 'Leather';
    if (localizedOption == l10n.cbOptionFauxLeather) return 'Faux leather';
    if (localizedOption == l10n.cbOptionJersey) return 'Jersey';
    if (localizedOption == l10n.cbOptionRibKnit) return 'Rib knit';
    if (localizedOption == l10n.cbOptionInterlock) return 'Interlock';

    // Special option
    if (localizedOption == l10n.cbOptionCustom) return 'Custom';

    return localizedOption; // Fallback to input
  }

  // ============================================================================
  // HELPER METHODS
  // ============================================================================

  /// Get localized list of options from English list
  List<String> getLocalizedOptions(List<String> englishOptions) {
    return englishOptions.map((option) => getLocalizedOption(option)).toList();
  }

  /// Get English list of options from localized list
  List<String> getEnglishOptions(List<String> localizedOptions) {
    return localizedOptions.map((option) => getEnglishOption(option)).toList();
  }

  /// Get localized category map (category name -> localized options)
  Map<String, List<String>> getLocalizedCategories(Map<String, List<String>> englishCategories) {
    final Map<String, List<String>> localizedMap = {};
    englishCategories.forEach((categoryName, options) {
      final localizedCategory = getLocalizedCategory(categoryName);
      final localizedOptions = getLocalizedOptions(options);
      localizedMap[localizedCategory] = localizedOptions;
    });
    return localizedMap;
  }
}
