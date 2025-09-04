import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:country_picker/country_picker.dart';
import 'package:atella/Data/Models/manufacturer_model.dart';
import 'package:atella/services/manufacture_services/manufacturer_service.dart';


class ManufacturerSuggestionController extends GetxController {
  // Tab index: 0 = Recommended, 1 = Custom
  final RxInt tabIndex = 0.obs;

  // Services
  final ManufacturerService _manufacturerService = Get.put(ManufacturerService());

  // Data
  final RxList<Manufacturer> recommendedManufacturers = <Manufacturer>[].obs;
  final RxList<Manufacturer> displayedManufacturers = <Manufacturer>[].obs;
  final RxList<Manufacturer> filteredManufacturers = <Manufacturer>[].obs;
  final RxList<Manufacturer> allManufacturersCache = <Manufacturer>[].obs;
  final RxBool isLoading = false.obs;
  final RxBool isLoadingMore = false.obs;
  final RxString error = ''.obs;

  // Pagination
  final ScrollController scrollController = ScrollController();
  bool hasMoreData = true;

  // Filters for custom tab
  final Rx<Country?> selectedCountry = Rx<Country?>(null);
  final RxString selectedCountryName = 'All Countries'.obs;

  @override
  void onInit() {
    super.onInit();
    loadRecommendedManufacturers();
    setupScrollListener();
  }

  @override
  void onClose() {
    scrollController.dispose();
    super.onClose();
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

  Future<void> loadRecommendedManufacturers() async {
    try {
      isLoading.value = true;
      error.value = '';
      
      // Load initial manufacturers from Firebase
      final manufacturers = await _manufacturerService.loadInitialManufacturers();
      recommendedManufacturers.value = manufacturers;
      displayedManufacturers.value = manufacturers;
      
      // Cache all manufacturers for filtering
      final allManufacturers = await _manufacturerService.getManufacturersFromFirebase();
      allManufacturersCache.value = allManufacturers;
      
      hasMoreData = _manufacturerService.hasMoreData;
      
      // Update filtered manufacturers for custom tab
      loadFilteredManufacturers();
    } catch (e) {
      error.value = 'Failed to load manufacturers: $e';
      print('Error loading manufacturers: $e');
    } finally {
      isLoading.value = false;
    }
  }

  Future<void> loadMoreManufacturers() async {
    if (!hasMoreData || isLoadingMore.value) return;
    
    try {
      isLoadingMore.value = true;
      
      final moreManufacturers = await _manufacturerService.loadMoreManufacturers();
      if (moreManufacturers.isNotEmpty) {
        displayedManufacturers.addAll(moreManufacturers);
        hasMoreData = _manufacturerService.hasMoreData;
      } else {
        hasMoreData = false;
      }
    } catch (e) {
      print('Error loading more manufacturers: $e');
    } finally {
      isLoadingMore.value = false;
    }
  }

  void loadFilteredManufacturers() {
    if (allManufacturersCache.isEmpty) {
      filteredManufacturers.value = [];
      return;
    }
    
    final filtered = _manufacturerService.getFilteredManufacturers(
      country: selectedCountryName.value,
      sourceManufacturers: allManufacturersCache,
    );
    filteredManufacturers.value = filtered;
  }

  void updateFilters() {
    loadFilteredManufacturers();
  }

  Future<void> refreshManufacturers() async {
    displayedManufacturers.clear();
    await loadRecommendedManufacturers();
  }

  void selectCountry(Country country) {
    selectedCountry.value = country;
    selectedCountryName.value = country.name;
    updateFilters();
  }

  void clearCountryFilter() {
    selectedCountry.value = null;
    selectedCountryName.value = 'All Countries';
    updateFilters();
  }
  
  
  // Email functionality
  final RxBool isSendingEmail = false.obs;
  final RxSet<String> loadingManufacturers = <String>{}.obs;
  
  // Helper method to check if a specific manufacturer is loading
  bool isManufacturerLoading(String manufacturerId) {
    return loadingManufacturers.contains(manufacturerId);
  }
  
  // Get database statistics
  Future<Map<String, dynamic>> getDatabaseStats() async {
    try {
      final stats = await _manufacturerService.getManufacturerStatistics();
      final totalManufacturers = stats.values.fold<int>(0, (sum, count) => sum + count);
      
      return {
        'totalManufacturers': totalManufacturers,
        'countByCountry': stats,
        'countriesCovered': stats.keys.length,
      };
    } catch (e) {
      print('❌ Error getting database stats: $e');
      return {};
    }
  }
}

