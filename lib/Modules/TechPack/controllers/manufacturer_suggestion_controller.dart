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
  final RxList<Manufacturer> filteredManufacturers = <Manufacturer>[].obs;
  final RxBool isLoading = false.obs;
  final RxString error = ''.obs;

  // Filters for custom tab
  final Rx<Country?> selectedCountry = Rx<Country?>(null);
  final RxString selectedCountryName = 'All Countries'.obs;

  @override
  void onInit() {
    super.onInit();
    loadRecommendedManufacturers();
    loadFilteredManufacturers();
  }

  Future<void> loadRecommendedManufacturers() async {
    try {
      isLoading.value = true;
      error.value = '';
      final manufacturers = await _manufacturerService.getRecommendedManufacturers();
      recommendedManufacturers.value = manufacturers;
      
      // Update filtered manufacturers for custom tab with the new GPT data
      loadFilteredManufacturers();
    } catch (e) {
      error.value = 'Failed to load recommended manufacturers: $e';
    } finally {
      isLoading.value = false;
    }
  }

  void loadFilteredManufacturers() {
    final filtered = _manufacturerService.getFilteredManufacturers(
      country: selectedCountryName.value,
      sourceManufacturers: recommendedManufacturers, // Use Firebase manufacturers for filtering
    );
    filteredManufacturers.value = filtered;
  }

  void updateFilters() {
    loadFilteredManufacturers();
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
  
  // Method to manually expand the manufacturer database
  Future<void> expandManufacturerDatabase() async {
    try {
      isLoading.value = true;
      error.value = '';
      
      // This will trigger the smart strategy to add more countries
      final manufacturers = await _manufacturerService.getRecommendedManufacturers();
      recommendedManufacturers.value = manufacturers;
      
      // Update filtered manufacturers
      loadFilteredManufacturers();
      
      print('🌍 Manufacturer database expanded successfully');
    } catch (e) {
      error.value = 'Failed to expand manufacturer database: $e';
      print('❌ Error expanding manufacturer database: $e');
    } finally {
      isLoading.value = false;
    }
  }
  
  // Get database statistics
  Future<Map<String, dynamic>> getDatabaseStats() async {
    try {
      // We'll get stats from the current data since we can't directly access the private service
      final totalManufacturers = recommendedManufacturers.length;
      
      // Count by country from current data
      Map<String, int> countByCountry = {};
      for (var manufacturer in recommendedManufacturers) {
        countByCountry[manufacturer.country] = (countByCountry[manufacturer.country] ?? 0) + 1;
      }
      
      return {
        'totalManufacturers': totalManufacturers,
        'countByCountry': countByCountry,
        'countriesCovered': countByCountry.keys.length,
      };
    } catch (e) {
      print('❌ Error getting database stats: $e');
      return {};
    }
  }
}

