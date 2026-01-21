import 'dart:async';
import 'package:atella/services/email/test_email_service.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:atella/Data/Models/new_manufacturer_model.dart';
import 'package:atella/Data/Models/translated_manufacturer_model.dart';
import 'package:atella/services/manufacture_services/new_manufacturer_firebase_service.dart';
import 'package:atella/Modules/tech_pack/controllers/tech_pack_ready_controller.dart';
import 'package:atella/services/firebase/services/auth_service.dart';
import 'package:atella/l10n/generated/app_localizations.dart';
import 'package:atella/services/translation/ml_translation_service.dart';

class ManufacturerSuggestionController extends GetxController {
  // Tab index: 0 = Recommended, 1 = Custom
  final RxInt tabIndex = 0.obs;

  // Search functionality
  final TextEditingController searchController = TextEditingController();
  final RxString searchQuery = ''.obs;

  // Garment type to manufacturer product mapping
  // Maps creative brief garment types (both English and French) to manufacturer product categories
  static const Map<String, List<String>> _garmentTypeToProductMapping = {
    // T-Shirts & Tank Tops
    't-shirt': ['T-Shirts', 'Tops', 'Knitwear'],
    'tank top': ['Tank Tops', 'Tops', 'Activewear'],
    'crop top': ['Tops', 'Tank Tops', 'Activewear'],

    // Shirts & Blouses
    'shirt': ['Shirts', 'Tops', 'Blouses'],
    'blouse': ['Blouses', 'Shirts', 'Tops'],

    // Hoodies & Sweaters
    'hoodie': ['Hoodies', 'Sweatshirts', 'Activewear', 'Sportswear'],
    'sweater': ['Knitwear', 'Sweatshirts', 'Pullovers', 'Cardigans'],

    // Jackets & Coats
    'jacket': ['Jackets', 'Outwear', 'Outerwear'],
    'coat': ['Outwear', 'Outerwear', 'Jackets'],
    'vest': ['Outwear', 'Outerwear', 'Jackets'],
    'trench coat': ['Outwear', 'Outerwear', 'Jackets', 'Luxury'],
    'bomber jacket': ['Jackets', 'Outwear', 'Outerwear'],
    'blazer': ['Jackets', 'Outwear', 'Outerwear', 'Luxury'],
    'puffer jacket': ['Jackets', 'Outwear', 'Outerwear'],

    // Pants & Bottoms
    'pants': ['Trousers', 'Jeans', 'Denim', 'Bottoms'],
    'jeans': ['Jeans', 'Denim', 'Trousers'],
    'leggings': ['Leggings', 'Activewear', 'Sportswear', 'Trousers'],
    'culottes': ['Trousers', 'Bottoms'],
    'palazzo': ['Trousers', 'Bottoms'],
    'joggers': ['Sweatpants', 'Activewear', 'Sportswear', 'Trousers'],
    'shorts': ['Shorts', 'Activewear', 'Sportswear', 'Swimwear'],
    'skirts': ['Skirts', 'Bottoms', 'Dresses'],

    // Dresses
    'casual dress': ['Dresses', 'Tops'],
    'evening': ['Dresses', 'Luxury', 'Outwear'],
    'cocktail dress': ['Dresses', 'Luxury'],
    'gown': ['Dresses', 'Luxury'],
    'maxi dress': ['Dresses'],
    'midi dress': ['Dresses'],
    'mini dress': ['Dresses'],

    // Jumpsuits & Rompers
    'jumpsuit': ['Dresses', 'Tops', 'Trousers'],
    'romper': ['Dresses', 'Tops', 'Shorts'],
    'playsuit': ['Dresses', 'Tops'],
    'overalls': ['Denim', 'Trousers', 'Dresses'],

    // Activewear & Swimwear
    'tracksuit': ['Activewear', 'Sportswear', 'Sweatpants', 'Sweatshirts'],
    'activewear': ['Activewear', 'Sportswear', 'Leggings', 'Sports Bra', 'Tank Tops'],
    'swimwear': ['Swimwear', 'Activewear'],

    // Accessories
    'hat': ['Headwear', 'Caps', 'Accessories'],
    'bag': ['Bags', 'Accessories'],
    'scarf': ['Accessories'],
    'gloves': ['Gloves', 'Accessories'],

    // French translations
    'débardeur': ['Tank Tops', 'Tops', 'Activewear'],
    'haut court': ['Tops', 'Tank Tops', 'Activewear'],
    'chemise': ['Shirts', 'Tops', 'Blouses'],
    'chemisier': ['Blouses', 'Shirts', 'Tops'],
    'sweat à capuche': ['Hoodies', 'Sweatshirts', 'Activewear', 'Sportswear'],
    'pull': ['Knitwear', 'Sweatshirts', 'Pullovers', 'Cardigans'],
    'veste': ['Jackets', 'Outwear', 'Outerwear'],
    'manteau': ['Outwear', 'Outerwear', 'Jackets'],
    'gilet': ['Outwear', 'Outerwear', 'Jackets'],
    'trench': ['Outwear', 'Outerwear', 'Jackets', 'Luxury'],
    'blouson aviateur': ['Jackets', 'Outwear', 'Outerwear'],
    'doudoune': ['Jackets', 'Outwear', 'Outerwear'],
    'pantalon': ['Trousers', 'Jeans', 'Denim', 'Bottoms'],
    'jean': ['Jeans', 'Denim', 'Trousers'],
    'legging': ['Leggings', 'Activewear', 'Sportswear', 'Trousers'],
    'jogging': ['Sweatpants', 'Activewear', 'Sportswear', 'Trousers'],
    'short': ['Shorts', 'Activewear', 'Sportswear', 'Swimwear'],
    'jupe': ['Skirts', 'Bottoms', 'Dresses'],
    'robe décontractée': ['Dresses', 'Tops'],
    'soirée': ['Dresses', 'Luxury', 'Outwear'],
    'robe de cocktail': ['Dresses', 'Luxury'],
    'robe de soirée': ['Dresses', 'Luxury'],
    'robe longue': ['Dresses'],
    'robe midi': ['Dresses'],
    'robe courte': ['Dresses'],
    'combinaison': ['Dresses', 'Tops', 'Trousers'],
    'combi-short': ['Dresses', 'Tops', 'Shorts'],
    'salopette': ['Denim', 'Trousers', 'Dresses'],
    'survêtement': ['Activewear', 'Sportswear', 'Sweatpants', 'Sweatshirts'],
    'vêtements de sport': ['Activewear', 'Sportswear', 'Leggings', 'Sports Bra', 'Tank Tops'],
    'maillot de bain': ['Swimwear', 'Activewear'],
    'chapeau': ['Headwear', 'Caps', 'Accessories'],
    'sac': ['Bags', 'Accessories'],
    'écharpe': ['Accessories'],
    'gants': ['Gloves', 'Accessories'],
  };

  // Country name mappings for abbreviations and alternative spellings
  // Maps variations to a list of possible matches
  static const Map<String, List<String>> _countryNameMappings = {
    // USA variations
    'united states': ['usa', 'us', 'united states', 'united states of america', 'america'],
    'usa': ['usa', 'us', 'united states', 'united states of america', 'america'],
    'us': ['usa', 'us', 'united states', 'united states of america', 'america'],
    'united states of america': ['usa', 'us', 'united states', 'united states of america', 'america'],
    'america': ['usa', 'us', 'united states', 'united states of america', 'america'],

    // UK variations
    'united kingdom': ['uk', 'united kingdom', 'great britain', 'britain', 'england', 'gb'],
    'uk': ['uk', 'united kingdom', 'great britain', 'britain', 'england', 'gb'],
    'great britain': ['uk', 'united kingdom', 'great britain', 'britain', 'england', 'gb'],
    'britain': ['uk', 'united kingdom', 'great britain', 'britain', 'england', 'gb'],
    'england': ['uk', 'united kingdom', 'great britain', 'britain', 'england', 'gb'],
    'gb': ['uk', 'united kingdom', 'great britain', 'britain', 'england', 'gb'],

    // UAE variations
    'united arab emirates': ['uae', 'united arab emirates', 'emirates'],
    'uae': ['uae', 'united arab emirates', 'emirates'],
    'emirates': ['uae', 'united arab emirates', 'emirates'],

    // Turkey variations
    'turkey': ['turkey', 'türkiye', 'turkiye'],
    'türkiye': ['turkey', 'türkiye', 'turkiye'],
    'turkiye': ['turkey', 'türkiye', 'turkiye'],

    // China variations
    'china': ['china', 'prc', 'peoples republic of china', "people's republic of china"],
    'prc': ['china', 'prc', 'peoples republic of china', "people's republic of china"],

    // South Korea variations
    'south korea': ['south korea', 'korea', 'republic of korea', 'rok'],
    'korea': ['south korea', 'korea', 'republic of korea', 'rok'],
    'republic of korea': ['south korea', 'korea', 'republic of korea', 'rok'],

    // Germany variations
    'germany': ['germany', 'deutschland', 'de'],
    'deutschland': ['germany', 'deutschland', 'de'],

    // India variations
    'india': ['india', 'in', 'bharat'],
    'bharat': ['india', 'in', 'bharat'],

    // Bangladesh variations
    'bangladesh': ['bangladesh', 'bd'],
    'bd': ['bangladesh', 'bd'],

    // Vietnam variations
    'vietnam': ['vietnam', 'viet nam', 'vn'],
    'viet nam': ['vietnam', 'viet nam', 'vn'],
    'vn': ['vietnam', 'viet nam', 'vn'],

    // Pakistan variations
    'pakistan': ['pakistan', 'pk'],
    'pk': ['pakistan', 'pk'],

    // Indonesia variations
    'indonesia': ['indonesia', 'id'],

    // Thailand variations
    'thailand': ['thailand', 'th'],

    // Italy variations
    'italy': ['italy', 'italia', 'it'],
    'italia': ['italy', 'italia', 'it'],

    // France variations
    'france': ['france', 'fr'],

    // Spain variations
    'spain': ['spain', 'españa', 'espana', 'es'],
    'españa': ['spain', 'españa', 'espana', 'es'],
    'espana': ['spain', 'españa', 'espana', 'es'],

    // Portugal variations
    'portugal': ['portugal', 'pt'],

    // Mexico variations
    'mexico': ['mexico', 'méxico', 'mx'],
    'méxico': ['mexico', 'méxico', 'mx'],

    // Brazil variations
    'brazil': ['brazil', 'brasil', 'br'],
    'brasil': ['brazil', 'brasil', 'br'],

    // Sri Lanka variations
    'sri lanka': ['sri lanka', 'lk', 'ceylon'],
    'ceylon': ['sri lanka', 'lk', 'ceylon'],

    // Cambodia variations
    'cambodia': ['cambodia', 'kh', 'kampuchea'],
    'kampuchea': ['cambodia', 'kh', 'kampuchea'],

    // Myanmar variations
    'myanmar': ['myanmar', 'burma', 'mm'],
    'burma': ['myanmar', 'burma', 'mm'],

    // Philippines variations
    'philippines': ['philippines', 'ph', 'pilipinas'],
    'pilipinas': ['philippines', 'ph', 'pilipinas'],

    // Hong Kong variations
    'hong kong': ['hong kong', 'hk'],
    'hk': ['hong kong', 'hk'],

    // Taiwan variations
    'taiwan': ['taiwan', 'tw', 'republic of china', 'roc'],
    'republic of china': ['taiwan', 'tw', 'republic of china', 'roc'],
    'roc': ['taiwan', 'tw', 'republic of china', 'roc'],
  };

  /// Get all possible country name variations for matching
  List<String> _getCountryVariations(String countryName) {
    final lowerName = countryName.toLowerCase().trim();
    return _countryNameMappings[lowerName] ?? [lowerName];
  }

  /// Check if two country names match (including abbreviations and variations)
  bool _countriesMatch(String selectedCountry, String manufacturerCountry) {
    final selectedLower = selectedCountry.toLowerCase().trim();
    final manufacturerLower = manufacturerCountry.toLowerCase().trim();

    // Direct match
    if (selectedLower == manufacturerLower) return true;

    // Check if manufacturer country is in the variations of selected country
    final selectedVariations = _getCountryVariations(selectedLower);
    if (selectedVariations.contains(manufacturerLower)) return true;

    // Check if selected country is in the variations of manufacturer country
    final manufacturerVariations = _getCountryVariations(manufacturerLower);
    if (manufacturerVariations.contains(selectedLower)) return true;

    // Check for partial matches within variations
    for (final variation in selectedVariations) {
      if (manufacturerLower.contains(variation) || variation.contains(manufacturerLower)) {
        return true;
      }
    }

    return false;
  }

  // Services
  final NewManufacturerFirebaseService _manufacturerService =
      NewManufacturerFirebaseService();
  final AuthService _authService = AuthService();
  final MLTranslationService _translationService = MLTranslationService();

  // Helper to get localization
  AppLocalizations get _l10n => AppLocalizations.of(Get.context!)!;

  // Translation cache to avoid re-translating same text
  final Map<String, String> _translationCache = {};
  final Map<String, List<String>> _listTranslationCache = {};

  /// Translate manufacturer data (products and MOQ) based on locale
  Future<TranslatedManufacturer> translateManufacturer(
    NewManufacturer manufacturer,
    String locale,
  ) async {
    // If not French, return as-is
    if (locale != 'fr') {
      return TranslatedManufacturer.fromManufacturer(
        manufacturer,
        translatedMoq: manufacturer.moq,
        translatedProducts: manufacturer.products,
      );
    }

    // Translate MOQ
    final cacheKeyMoq = 'moq_${manufacturer.moq}';
    String translatedMoq;
    if (_translationCache.containsKey(cacheKeyMoq)) {
      translatedMoq = _translationCache[cacheKeyMoq]!;
    } else {
      translatedMoq = await _translationService.translateToFrench(
        manufacturer.moq,
        locale: locale,
      );
      _translationCache[cacheKeyMoq] = translatedMoq;
    }

    // Translate products list
    final cacheKeyProducts = 'products_${manufacturer.products.join('|')}';
    List<String> translatedProducts;
    if (_listTranslationCache.containsKey(cacheKeyProducts)) {
      translatedProducts = _listTranslationCache[cacheKeyProducts]!;
    } else {
      translatedProducts = await _translationService.translateList(
        manufacturer.products,
        locale: locale,
      );
      _listTranslationCache[cacheKeyProducts] = translatedProducts;
    }

    return TranslatedManufacturer.fromManufacturer(
      manufacturer,
      translatedMoq: translatedMoq,
      translatedProducts: translatedProducts,
    );
  }

  /// Translate all displayed manufacturers at once
  Future<void> translateAllManufacturers(String locale) async {
    if (locale != 'fr' || displayedManufacturers.isEmpty) {
      // If not French or no manufacturers, just convert to translated format
      translatedDisplayedManufacturers.value = displayedManufacturers
          .map((m) => TranslatedManufacturer.fromManufacturer(
                m,
                translatedMoq: m.moq,
                translatedProducts: m.products,
              ))
          .toList();
      return;
    }

    isTranslating.value = true;

    try {
      final List<TranslatedManufacturer> translated = [];

      for (final manufacturer in displayedManufacturers) {
        final translatedManufacturer = await translateManufacturer(manufacturer, locale);
        translated.add(translatedManufacturer);
      }

      translatedDisplayedManufacturers.value = translated;
    } catch (e) {
      debugPrint('Translation error: $e');
      // Fallback to untranslated
      translatedDisplayedManufacturers.value = displayedManufacturers
          .map((m) => TranslatedManufacturer.fromManufacturer(
                m,
                translatedMoq: m.moq,
                translatedProducts: m.products,
              ))
          .toList();
    } finally {
      isTranslating.value = false;
    }
  }

  // Data - Using NewManufacturer model
  final RxList<NewManufacturer> recommendedManufacturers = <NewManufacturer>[].obs;
  final RxList<NewManufacturer> displayedManufacturers = <NewManufacturer>[].obs;
  final RxList<NewManufacturer> filteredManufacturers = <NewManufacturer>[].obs;
  final RxList<NewManufacturer> allManufacturersCache = <NewManufacturer>[].obs;
  final RxBool isLoading = false.obs;
  final RxBool isLoadingMore = false.obs;
  final RxBool isLoadingCustomTab = false.obs;
  final RxBool isDataReady = false.obs;
  final RxBool isTranslating = false.obs;
  final RxString error = ''.obs;

  // Translated manufacturers cache
  final RxList<TranslatedManufacturer> translatedDisplayedManufacturers = <TranslatedManufacturer>[].obs;

  // Expanded card tracking
  final RxSet<String> expandedCards = <String>{}.obs;

  // Streams for real-time data updates
  final StreamController<List<NewManufacturer>> _recommendedStreamController =
      StreamController<List<NewManufacturer>>.broadcast();
  final StreamController<List<NewManufacturer>> _filteredStreamController =
      StreamController<List<NewManufacturer>>.broadcast();
  final StreamController<bool> _loadingStreamController =
      StreamController<bool>.broadcast();

  Stream<List<NewManufacturer>> get recommendedStream =>
      _recommendedStreamController.stream;
  Stream<List<NewManufacturer>> get filteredStream =>
      _filteredStreamController.stream;
  Stream<bool> get loadingStream => _loadingStreamController.stream;

  // Pagination
  final ScrollController scrollController = ScrollController();
  bool hasMoreData = true;
  int _currentPage = 0;
  final int _pageSize = 20;

  // Filters for custom tab
  final RxString selectedCountryName = 'All Countries'.obs;
  final RxList<String> availableCountries = <String>[].obs;

  // Product filter
  final RxString selectedProduct = 'All Products'.obs;
  final RxList<String> availableProducts = <String>[].obs;

  // Certification filter
  final RxString selectedCertification = 'All Certifications'.obs;
  final RxList<String> availableCertifications = <String>[].obs;

  // Product type filter for Recommended tab (automatic filtering based on garment type)
  final RxString productTypeFilter = ''.obs;
  final RxBool isProductTypeFiltered = false.obs;
  final RxInt totalFilteredCount = 0.obs; // Total count of filtered manufacturers (not paginated)

  @override
  void onInit() {
    super.onInit();
    _initializeStreams();
    _checkForPrefilter();
    loadRecommendedManufacturers();
    setupScrollListener();
    _setupSearchListener();
  }

  void _setupSearchListener() {
    searchController.addListener(() {
      searchQuery.value = searchController.text;
      _applySearch();
    });
  }

  void _checkForPrefilter() {
    final arguments = Get.arguments as Map<String, dynamic>?;

    debugPrint('🔧 _checkForPrefilter - Arguments: $arguments');

    // Check for product type filter (for Recommended tab - automatic filtering)
    if (arguments != null && arguments.containsKey('productType')) {
      final productType = arguments['productType'] as String?;
      debugPrint('🎯 Product type raw value: "$productType"');
      if (productType != null && productType.isNotEmpty) {
        productTypeFilter.value = productType;
        isProductTypeFiltered.value = true;
        debugPrint('✅ Product type filter activated: "$productType"');
      } else {
        debugPrint('⚠️ Product type is null or empty');
      }
    } else {
      debugPrint('⚠️ No productType in arguments');
    }

    // Check if manufacturer country was passed from tech pack details
    if (arguments != null && arguments.containsKey('manufacturerCountry')) {
      final countryName = arguments['manufacturerCountry'] as String?;
      if (countryName != null && countryName.isNotEmpty) {
        // Immediately switch to custom tab BEFORE data loads
        tabIndex.value = 1;
        _shouldSwitchToCustomTab = true;
        _prefilterCountryName = countryName;
        // Set country name immediately so UI shows it
        selectedCountryName.value = countryName;

        debugPrint('Pre-filter detected: $countryName, switching to Custom tab');
      }
    }
  }

  bool _shouldSwitchToCustomTab = false;
  String _prefilterCountryName = '';

  void _applyPrefilter() {
    // Tab is already switched in _checkForPrefilter
    // Just apply the actual filtering now that data is loaded
    loadFilteredManufacturers();

    print(
      'Pre-filter applied: $_prefilterCountryName, found ${filteredManufacturers.length} manufacturers',
    );
  }

  void _initializeStreams() {
    // Initialize with empty lists
    _recommendedStreamController.add([]);
    _filteredStreamController.add([]);
    _loadingStreamController.add(true);
  }

  @override
  void onClose() {
    searchController.dispose();
    scrollController.dispose();
    _recommendedStreamController.close();
    _filteredStreamController.close();
    _loadingStreamController.close();
    super.onClose();
  }

  // Search functionality
  void _applySearch() {
    if (tabIndex.value == 0) {
      // Recommended tab - filter displayed manufacturers
      _filterRecommendedManufacturers();
    } else {
      // Custom tab - apply search along with other filters
      loadFilteredManufacturers();
    }
  }

  void _filterRecommendedManufacturers() {
    final query = searchQuery.value.toLowerCase().trim();
    var sourceList = allManufacturersCache.toList();

    // Apply product type filter first if active
    if (isProductTypeFiltered.value && productTypeFilter.value.isNotEmpty) {
      sourceList = _filterByProductType(sourceList, productTypeFilter.value);
      // Store the total filtered count (before pagination)
      totalFilteredCount.value = sourceList.length;
    } else {
      // Reset count when filter is not active
      totalFilteredCount.value = 0;
    }

    if (query.isEmpty) {
      // Reset to paginated list (with product type filter applied if active)
      _currentPage = 0;
      final endIndex = (_currentPage + 1) * _pageSize;
      displayedManufacturers.value = sourceList.take(endIndex).toList();
      hasMoreData = endIndex < sourceList.length;
    } else {
      // Filter by search query
      final filtered = sourceList
          .where((m) => m.companyName.toLowerCase().contains(query))
          .toList();
      displayedManufacturers.value = filtered;
      hasMoreData = false; // Disable pagination when searching
    }
  }

  /// Get matching manufacturer product types for a given garment type
  /// Handles format "Category:GarmentType" and extracts only the garment type
  List<String> _getMatchingProductTypes(String garmentType) {
    // Extract garment type from "Category:GarmentType" format
    String extractedType = garmentType.trim();

    debugPrint('🎯 Raw garment type: "$garmentType"');

    // Check if the garment type contains a colon (Category:Type format)
    if (extractedType.contains(':')) {
      // Split by colon and take the part after the colon
      final parts = extractedType.split(':');
      if (parts.length > 1) {
        extractedType = parts[1].trim(); // Take the part after ":"
        debugPrint('✂️ Extracted type after colon: "$extractedType"');
      }
    }

    // Convert to lowercase for case-insensitive matching
    final lowerGarmentType = extractedType.toLowerCase();
    debugPrint('🔑 Looking up mapping for: "$lowerGarmentType"');

    final result = _garmentTypeToProductMapping[lowerGarmentType] ?? [];

    if (result.isEmpty) {
      debugPrint('❌ No mapping found! Available keys: ${_garmentTypeToProductMapping.keys.take(5).toList()}...');
    } else {
      debugPrint('✅ Found mapping: $result');
    }

    return result;
  }

  /// Filter manufacturers by product type using the mapping
  List<NewManufacturer> _filterByProductType(
    List<NewManufacturer> manufacturers,
    String garmentType,
  ) {
    final matchingProducts = _getMatchingProductTypes(garmentType);

    debugPrint('🔍 Filtering by garment type: "$garmentType"');
    debugPrint('📦 Matching products: $matchingProducts');

    if (matchingProducts.isEmpty) {
      // No mapping found - return all manufacturers
      debugPrint('⚠️ No mapping found for garment type: "$garmentType"');
      return manufacturers;
    }

    // Filter manufacturers whose products match any of the matching product types
    final filtered = manufacturers.where((manufacturer) {
      // Debug: Print first manufacturer's products to see the data
      if (manufacturer == manufacturers.first) {
        debugPrint('🏭 First manufacturer: ${manufacturer.companyName}');
        debugPrint('   Products: ${manufacturer.products}');
      }

      final hasMatch = manufacturer.products.any((manufacturerProduct) {
        final manufacturerProductLower = manufacturerProduct.toLowerCase().trim();

        // Check if any matching product type matches this manufacturer's product
        for (final matchingProduct in matchingProducts) {
          final matchingProductLower = matchingProduct.toLowerCase().trim();

          // Use partial/contains matching (case-insensitive)
          if (manufacturerProductLower.contains(matchingProductLower) ||
              matchingProductLower.contains(manufacturerProductLower)) {
            debugPrint('   ✓ Match found: "$manufacturerProduct" matches "$matchingProduct"');
            return true;
          }
        }
        return false;
      });

      return hasMatch;
    }).toList();

    debugPrint('✅ Filtered ${filtered.length} manufacturers out of ${manufacturers.length} total');

    // Show first few filtered manufacturers
    if (filtered.isNotEmpty) {
      debugPrint('📋 First filtered manufacturers:');
      for (var i = 0; i < filtered.length && i < 3; i++) {
        debugPrint('   - ${filtered[i].companyName}');
      }
    }

    return filtered;
  }

  void clearSearch() {
    searchController.clear();
    searchQuery.value = '';
    _applySearch();
  }

  void setupScrollListener() {
    scrollController.addListener(() {
      if (scrollController.position.pixels >=
              scrollController.position.maxScrollExtent - 200 &&
          !isLoadingMore.value &&
          hasMoreData &&
          tabIndex.value == 0) {
        loadMoreManufacturers();
      }
    });
  }

  // Toggle card expansion
  void toggleCardExpansion(String manufacturerId) {
    if (expandedCards.contains(manufacturerId)) {
      expandedCards.remove(manufacturerId);
    } else {
      expandedCards.add(manufacturerId);
    }
  }

  bool isCardExpanded(String manufacturerId) {
    return expandedCards.contains(manufacturerId);
  }

  Future<void> loadRecommendedManufacturers() async {
    try {
      isLoading.value = true;
      _loadingStreamController.add(true);
      error.value = '';

      // Load all manufacturers from new Firebase collection
      final manufacturers = await _manufacturerService.getAllManufacturers();

      // Cache all manufacturers
      allManufacturersCache.value = manufacturers;

      // Apply product type filter if active
      var displayList = manufacturers.toList();
      if (isProductTypeFiltered.value && productTypeFilter.value.isNotEmpty) {
        displayList = _filterByProductType(displayList, productTypeFilter.value);
        // Store the total filtered count (before pagination)
        totalFilteredCount.value = displayList.length;
      } else {
        totalFilteredCount.value = 0;
      }

      // Display first page
      _currentPage = 0;
      final endIndex = (_currentPage + 1) * _pageSize;
      displayedManufacturers.value = displayList.take(endIndex).toList();

      hasMoreData = endIndex < displayList.length;

      // Pre-load ALL manufacturers for instant custom tab switching
      filteredManufacturers.assignAll(manufacturers);

      // Load available countries, products and certifications for filters
      availableCountries.value = await _manufacturerService.getAllCountries();
      availableProducts.value = await _manufacturerService.getAllProducts();
      availableCertifications.value = await _manufacturerService.getAllCertifications();

      // Mark data as ready for instant tab switching
      isDataReady.value = true;

      // Update loading state
      _loadingStreamController.add(false);
      isLoadingCustomTab.value = false;

      // Apply pre-filter if specified
      if (_shouldSwitchToCustomTab && _prefilterCountryName.isNotEmpty) {
        _applyPrefilter();
      }
    } catch (e) {
      error.value = 'Failed to load manufacturers: $e';
      print('Error loading manufacturers: $e');
      _loadingStreamController.add(false);
    } finally {
      isLoading.value = false;
    }
  }

  Future<void> loadMoreManufacturers() async {
    if (!hasMoreData || isLoadingMore.value) return;

    try {
      isLoadingMore.value = true;

      _currentPage++;
      final startIndex = _currentPage * _pageSize;
      final endIndex = startIndex + _pageSize;

      // Apply product type filter to source list if active
      var sourceList = allManufacturersCache.toList();
      if (isProductTypeFiltered.value && productTypeFilter.value.isNotEmpty) {
        sourceList = _filterByProductType(sourceList, productTypeFilter.value);
      }

      if (startIndex < sourceList.length) {
        final moreManufacturers = sourceList
            .skip(startIndex)
            .take(_pageSize)
            .toList();

        if (moreManufacturers.isNotEmpty) {
          displayedManufacturers.addAll(moreManufacturers);
          hasMoreData = endIndex < sourceList.length;
        } else {
          hasMoreData = false;
        }
      } else {
        hasMoreData = false;
      }
    } catch (e) {
      debugPrint('Error loading more manufacturers: $e');
    } finally {
      isLoadingMore.value = false;
    }
  }

  void loadFilteredManufacturers() {
    if (allManufacturersCache.isEmpty) {
      filteredManufacturers.value = [];
      return;
    }

    var filtered = allManufacturersCache.toList();

    // Apply search filter first
    final query = searchQuery.value.toLowerCase().trim();
    if (query.isNotEmpty) {
      filtered = filtered
          .where((m) => m.companyName.toLowerCase().contains(query))
          .toList();
    }

    // Apply country filter with abbreviation and variation matching
    if (selectedCountryName.value != 'All Countries' &&
        selectedCountryName.value.isNotEmpty) {
      filtered = filtered
          .where((m) => _countriesMatch(selectedCountryName.value, m.country))
          .toList();
    }

    // Apply product filter
    if (selectedProduct.value != 'All Products') {
      filtered = filtered
          .where((m) => m.products.any((p) =>
              p.toLowerCase() == selectedProduct.value.toLowerCase()))
          .toList();
    }

    // Apply certification filter
    if (selectedCertification.value != 'All Certifications') {
      filtered = filtered
          .where((m) => m.certifications.any((c) =>
              c.toLowerCase() == selectedCertification.value.toLowerCase()))
          .toList();
    }

    filteredManufacturers.value = filtered;
  }

  void updateFilters() {
    loadFilteredManufacturers();
  }

  Future<void> refreshManufacturers() async {
    if (tabIndex.value == 0) {
      // For recommended tab, reload data
      displayedManufacturers.clear();
      await loadRecommendedManufacturers();
    } else {
      // For custom tab, data is already cached - just refresh if needed
      if (filteredManufacturers.isEmpty && allManufacturersCache.isNotEmpty) {
        filteredManufacturers.assignAll(allManufacturersCache);
      }
    }
  }

  void selectCountry(String country) {
    selectedCountryName.value = country;
    updateFilters();
  }

  void clearCountryFilter() {
    selectedCountryName.value = 'All Countries';
    updateFilters();
  }

  void selectProduct(String product) {
    selectedProduct.value = product;
    updateFilters();
  }

  void clearProductFilter() {
    selectedProduct.value = 'All Products';
    updateFilters();
  }

  void selectCertification(String certification) {
    selectedCertification.value = certification;
    updateFilters();
  }

  void clearCertificationFilter() {
    selectedCertification.value = 'All Certifications';
    updateFilters();
  }

  void clearAllFilters() {
    selectedCountryName.value = 'All Countries';
    selectedProduct.value = 'All Products';
    selectedCertification.value = 'All Certifications';
    updateFilters();
  }

  /// Clear product type filter for Recommended tab (Show All button)
  void clearProductTypeFilter() {
    productTypeFilter.value = '';
    isProductTypeFiltered.value = false;
    totalFilteredCount.value = 0; // Reset the filtered count
    _filterRecommendedManufacturers();
  }

  // Handle tab switching - instant, no processing
  void switchToTab(int index) {
    // Just switch the tab index - all data is pre-loaded
    tabIndex.value = index;
  }

  // Email functionality
  final RxBool isSendingEmail = false.obs;
  final RxSet<String> loadingManufacturers = <String>{}.obs;

  // Helper method to check if a specific manufacturer is loading
  bool isManufacturerLoading(String manufacturerId) {
    return loadingManufacturers.contains(manufacturerId);
  }

  // Send email to manufacturer
  Future<void> sendEmailToManufacturer(NewManufacturer manufacturer) async {
    // Check if manufacturer has email
    if (manufacturer.email == null || manufacturer.email!.isEmpty) {
      Get.snackbar(
        _l10n.mfNoEmailAvailable,
        _l10n.mfManufacturerNoEmail,
        backgroundColor: Colors.orange,
        colorText: Colors.white,
        duration: const Duration(milliseconds: 1500),
      );
      return;
    }

    // Set screen-wide loading state
    isSendingEmail.value = true;

    try {
      // Get current user information
      String? userEmail;
      String? userName;

      try {
        final userData = await _authService.getUserData();
        if (userData != null) {
          userEmail = userData['email'] as String?;
          userName = userData['name'] as String?;
        }

        // Fallback to Firebase Auth user if Firestore data is not available
        if (userEmail == null) {
          final currentUser = _authService.currentUser;
          if (currentUser != null) {
            userEmail = currentUser.email;
            userName = currentUser.displayName ?? userName;
          }
        }
      } catch (e) {
        print('Failed to get user data: $e');
      }

      // Get tech pack images and data
      List<String> imagePaths = [];
      Map<String, dynamic> techPackData = {};

      try {
        final techPackController = Get.find<TechPackReadyController>();

        // Get all three images: selected design + 2 tech pack images
        List<String> allImages = [];

        // 1. Add selected design image first
        if (techPackController.selectedDesignImage.isNotEmpty) {
          allImages.add(techPackController.selectedDesignImage);
        }

        // 2. Add generated tech pack images (limit to 2)
        if (techPackController.hasGeneratedImages) {
          final techPackImages = techPackController.generatedImages;
          for (int i = 0; i < techPackImages.length && i < 2; i++) {
            allImages.add(techPackImages[i]);
          }
        }

        imagePaths = allImages;

        // Extract tech pack data for AI generation
        techPackData = {
          'mainFabric': _extractFromSummary(
            techPackController.techPackSummary,
            'Materials: ',
          ),
          'primaryColor': _extractFromSummary(
            techPackController.techPackSummary,
            'Colors: ',
          ),
          'sizeRange': _extractFromSummary(
            techPackController.techPackSummary,
            'Sizes: ',
          ),
          'quantity': _extractFromSummary(
            techPackController.techPackSummary,
            'Quantity: ',
          ),
          'costPerPiece': _extractFromSummary(
            techPackController.techPackSummary,
            'Target Cost: ',
          ),
          'deliveryDate': _extractFromSummary(
            techPackController.techPackSummary,
            'Delivery: ',
          ),
        };
      } catch (e) {
        print('Could not find tech pack controller, using sample data: $e');
        // Use fallback sample data
        techPackData = {
          'mainFabric': 'Cotton blend',
          'primaryColor': 'Navy blue',
          'sizeRange': 'S-XL',
          'quantity': '500 pieces',
          'costPerPiece': '\$15-20',
          'deliveryDate': '30 days',
        };

        // Use sample images if no tech pack images
        imagePaths = [
          'data:image/jpeg;base64,/9j/4AAQSkZJRgABAQAAAQABAAD/2wBDAAYEBQYFBAYGBQYHBwYIChAKCgkJChQODwwQFxQYGBcUFhYaHSUfGhsjHBYWICwgIyYnKSopGR8tMC0oMCUoKSj/2wBDAQcHBwoIChMKChMoGhYaKCgoKCgoKCgoKCgoKCgoKCgoKCgoKCgoKCgoKCgoKCgoKCgoKCgoKCgoKCgoKCgoKCj/wAARCAABAAEDASIAAhEBAxEB/8QAFQABAQAAAAAAAAAAAAAAAAAAAAv/xAAUEAEAAAAAAAAAAAAAAAAAAAAA/8QAFQEBAQAAAAAAAAAAAAAAAAAAAAX/xAAUEQEAAAAAAAAAAAAAAAAAAAAA/9oADAMBAAIRAxEAPwCdABmX/9k=',
        ];
      }

      // Send AI-powered email with PDF attachment
      final success = await EmailJSDebugService.sendAIPoweredEmailWithPDF(
        toEmail: manufacturer.email!,
        manufacturerName: manufacturer.companyName,
        manufacturerLocation: manufacturer.country,
        techPackData: techPackData,
        userCompanyName: userName ?? 'Atelia Fashion',
        userEmail: userEmail,
        userName: userName,
        imagePaths: imagePaths,
      );

      // Show result
      if (success) {
        Get.snackbar(
          _l10n.mfEmailSentSuccessfully,
          _l10n.mfTechPackSentTo(manufacturer.companyName, manufacturer.email!),
          backgroundColor: Colors.black,
          colorText: Colors.white,
          duration: const Duration(milliseconds: 1500),
          icon: const Icon(Icons.check_circle, color: Colors.white),
        );
      } else {
        Get.snackbar(
          _l10n.mfEmailFailed,
          _l10n.mfFailedToSendEmail(manufacturer.companyName),
          backgroundColor: Colors.red,
          colorText: Colors.white,
          duration: const Duration(milliseconds: 1500),
          icon: const Icon(Icons.error, color: Colors.white),
        );
      }
    } catch (e) {
      Get.snackbar(
        _l10n.mfError,
        _l10n.mfErrorSendingEmail(e.toString()),
        backgroundColor: Colors.red,
        colorText: Colors.white,
        duration: const Duration(milliseconds: 1500),
        icon: const Icon(Icons.error, color: Colors.white),
      );
    } finally {
      // Clear screen-wide loading state
      isSendingEmail.value = false;
    }
  }

  // Preview email before sending
  Future<void> previewEmailToManufacturer(NewManufacturer manufacturer) async {
    // Check if manufacturer has email
    if (manufacturer.email == null || manufacturer.email!.isEmpty) {
      Get.snackbar(
        _l10n.mfNoEmailAvailable,
        _l10n.mfManufacturerNoEmail,
        backgroundColor: Colors.orange,
        colorText: Colors.white,
        duration: const Duration(milliseconds: 1500),
      );
      return;
    }

    String? userEmail;
    String? userName;
    List<String> imagePaths = [];
    Map<String, dynamic> techPackData = {};

    // Try to collect the same payload we will send
    try {
      try {
        final userData = await _authService.getUserData();
        if (userData != null) {
          userEmail = userData['email'] as String?;
          userName = userData['name'] as String?;
        }
        if (userEmail == null) {
          final currentUser = _authService.currentUser;
          if (currentUser != null) {
            userEmail = currentUser.email;
            userName = currentUser.displayName ?? userName;
          }
        }
      } catch (_) {}

      try {
        final techPackController = Get.find<TechPackReadyController>();
        final allImages = <String>[];
        if (techPackController.selectedDesignImage.isNotEmpty) {
          allImages.add(techPackController.selectedDesignImage);
        }
        if (techPackController.hasGeneratedImages) {
          final techPackImages = techPackController.generatedImages;
          for (int i = 0; i < techPackImages.length && i < 2; i++) {
            allImages.add(techPackImages[i]);
          }
        }
        imagePaths = allImages;
        techPackData = {
          'mainFabric': _extractFromSummary(
            techPackController.techPackSummary,
            'Materials: ',
          ),
          'primaryColor': _extractFromSummary(
            techPackController.techPackSummary,
            'Colors: ',
          ),
          'sizeRange': _extractFromSummary(
            techPackController.techPackSummary,
            'Sizes: ',
          ),
          'quantity': _extractFromSummary(
            techPackController.techPackSummary,
            'Quantity: ',
          ),
          'costPerPiece': _extractFromSummary(
            techPackController.techPackSummary,
            'Target Cost: ',
          ),
          'deliveryDate': _extractFromSummary(
            techPackController.techPackSummary,
            'Delivery: ',
          ),
        };
      } catch (e) {
        // Fallback sample if controller not available
        techPackData = {
          'mainFabric': 'Cotton blend',
          'primaryColor': 'Navy blue',
          'sizeRange': 'S-XL',
          'quantity': '500 pieces',
          'costPerPiece': '\$15-20',
          'deliveryDate': '30 days',
        };
        // Use sample images so preview reflects attachments similar to send flow
        imagePaths = [
          'data:image/jpeg;base64,/9j/4AAQSkZJRgABAQAAAQABAAD/2wBDAAYEBQYFBAYGBQYHBwYIChAKCgkJChQODwwQFxQYGBcUFhYaHSUfGhsjHBYWICwgIyYnKSopGR8tMC0oMCUoKSj/2wBDAQcHBwoIChMKChMoGhYaKCgoKCgoKCgoKCgoKCgoKCgoKCgoKCgoKCgoKCgoKCgoKCgoKCgoKCgoKCgoKCgoKCj/wAARCAABAAEDASIAAhEBAxEB/8QAFQABAQAAAAAAAAAAAAAAAAAAAAv/xAAUEAEAAAAAAAAAAAAAAAAAAAAA/8QAFQEBAQAAAAAAAAAAAAAAAAAAAAX/xAAUEQEAAAAAAAAAAAAAAAAAAAAA/9oADAMBAAIRAxEAPwCdABmX/9k=',
        ];
      }
    } catch (_) {}

    // Optionally build a PDF for preview (path + size)
    String? pdfPath;
    String? pdfName;
    String? pdfSizeKB;
    try {
      final preview = await EmailJSDebugService.previewEmailWithPDF(
        toEmail: manufacturer.email!,
        manufacturerName: manufacturer.companyName,
        manufacturerLocation: manufacturer.country,
        techPackData: techPackData,
        userCompanyName: userName ?? 'Atelia Fashion',
        imagePaths: imagePaths,
      );
      final pdf = preview['pdfPreview'] as Map<String, dynamic>?;
      if (pdf != null) {
        pdfPath = pdf['path'] as String?;
        pdfSizeKB = pdf['sizeKB']?.toString();
        if (pdfPath != null && pdfPath.isNotEmpty) {
          pdfName = pdfPath.split('/').last;
        }
      }
    } catch (_) {}

    // Build readable preview
    final previewLines = <Widget>[
      Text(
        'To: ${manufacturer.email}',
        style: const TextStyle(fontWeight: FontWeight.w600),
      ),
      const SizedBox(height: 6),
      Text(_l10n.tpManufacturerPrefix(manufacturer.companyName, manufacturer.country)),
      const SizedBox(height: 6),
      Text(
        'From: ${userName ?? 'Atelia Fashion'} ${userEmail != null ? "<$userEmail>" : ""}',
      ),
      const Divider(height: 16),
      Text(
        _l10n.mfTechPackSummary,
        style: const TextStyle(fontWeight: FontWeight.w600),
      ),
      const SizedBox(height: 6),
      Text('${_l10n.mfMaterial}: ${techPackData['mainFabric']}'),
      Text('${_l10n.mfPrimaryColor}: ${techPackData['primaryColor']}'),
      Text('${_l10n.mfSizeRange}: ${techPackData['sizeRange']}'),
      Text('${_l10n.mfQuantity}: ${techPackData['quantity']}'),
      Text('${_l10n.mfTargetCost}: ${techPackData['costPerPiece']}'),
      Text('${_l10n.mfDelivery}: ${techPackData['deliveryDate']}'),
      const SizedBox(height: 8),
      if (pdfName != null)
        Text(_l10n.mfPDFAttachment(pdfName, pdfSizeKB ?? '0'))
      else
        Text(_l10n.mfImagesAttached(imagePaths.length)),
    ];

    await Get.dialog(
      AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        title: Text(_l10n.mfPreviewEmail),
        content: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: previewLines,
          ),
        ),
        actions: [
          TextButton(onPressed: () => Get.back(), child: Text(_l10n.mfCancel)),
          ElevatedButton(
            onPressed: () {
              Get.back();
              sendEmailToManufacturer(manufacturer);
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.black,
              foregroundColor: Colors.white,
            ),
            child: Text(_l10n.mfSendEmail),
          ),
        ],
      ),
    );
  }

  // Helper method to extract data from tech pack summary
  String _extractFromSummary(String summary, String key) {
    try {
      final startIndex = summary.indexOf(key);
      if (startIndex == -1) return 'Not specified';

      final afterKey = summary.substring(startIndex + key.length);
      final endIndex = afterKey.indexOf('\n');

      if (endIndex == -1) {
        return afterKey.trim();
      } else {
        return afterKey.substring(0, endIndex).trim();
      }
    } catch (e) {
      return 'Not specified';
    }
  }

  // Get database statistics
  Future<Map<String, dynamic>> getDatabaseStats() async {
    try {
      final count = await _manufacturerService.getManufacturerCount();
      final countries = await _manufacturerService.getAllCountries();
      final products = await _manufacturerService.getAllProducts();

      return {
        'totalManufacturers': count,
        'countriesCovered': countries.length,
        'productsCovered': products.length,
      };
    } catch (e) {
      print('❌ Error getting database stats: $e');
      return {};
    }
  }
}
