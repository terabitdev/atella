import 'package:get/get.dart';
import '../../Data/Models/manufacturer_model.dart';
import '../firebase/services/manufacturer_firebase_service.dart';

class ManufacturerService extends GetxService {
  static ManufacturerService get instance => Get.find();
  
  final RxBool isLoading = false.obs;
  final RxString error = ''.obs;
  
  // Firebase service instance
  final ManufacturerFirebaseService _firebaseService = ManufacturerFirebaseService();
  
  // Pagination
  static const int pageSize = 10;
  int currentPage = 0;
  bool hasMoreData = true;
  final RxList<Manufacturer> allManufacturers = <Manufacturer>[].obs;
  
  
  // Load initial manufacturers from Firebase with pagination
  Future<List<Manufacturer>> loadInitialManufacturers() async {
    try {
      isLoading.value = true;
      error.value = '';
      currentPage = 0;
      hasMoreData = true;
      
      // Get first page of manufacturers
      final manufacturers = await _firebaseService.getAllManufacturers();
      allManufacturers.value = manufacturers;
      
      // Return first page
      if (manufacturers.length > pageSize) {
        hasMoreData = true;
        return manufacturers.take(pageSize).toList();
      } else {
        hasMoreData = false;
        return manufacturers;
      }
    } catch (e) {
      // print('❌ Error loading manufacturers from Firebase: $e');
      error.value = 'Failed to load manufacturers: $e';
      return [];
    } finally {
      isLoading.value = false;
    }
  }
  
  // Load more manufacturers (for pagination)
  Future<List<Manufacturer>> loadMoreManufacturers() async {
    if (!hasMoreData || isLoading.value) return [];
    
    try {
      isLoading.value = true;
      currentPage++;
      
      final startIndex = currentPage * pageSize;
      
      if (startIndex >= allManufacturers.length) {
        hasMoreData = false;
        return [];
      }
      
      final nextBatch = allManufacturers.skip(startIndex).take(pageSize).toList();
      
      if (nextBatch.length < pageSize) {
        hasMoreData = false;
      }
      
      return nextBatch;
    } catch (e) {
      // print('❌ Error loading more manufacturers: $e');
      return [];
    } finally {
      isLoading.value = false;
    }
  }
  
  // Get manufacturers from Firebase with optional country filter
  Future<List<Manufacturer>> getManufacturersFromFirebase({String? country, int? limit}) async {
    try {
      List<Manufacturer> manufacturers;
      
      if (country != null && country != 'All' && country != 'All Countries') {
        manufacturers = await _firebaseService.getManufacturersByCountry(country);
      } else {
        manufacturers = await _firebaseService.getAllManufacturers();
      }
      
      // Apply limit if specified
      if (limit != null && manufacturers.length > limit) {
        return manufacturers.take(limit).toList();
      }
      
      return manufacturers;
    } catch (e) {
      // print('❌ Error getting manufacturers from Firebase: $e');
      return [];
    }
  }
  
  // Get available countries from Firebase data
  Future<List<String>> getAvailableCountries() async {
    try {
      final stats = await _firebaseService.getManufacturerCountByCountry();
      return stats.keys.toList()..sort();
    } catch (e) {
      // print('❌ Error getting available countries: $e');
      return [];
    }
  }
  
  // Get statistics about stored manufacturers
  Future<Map<String, int>> getManufacturerStatistics() async {
    try {
      return await _firebaseService.getManufacturerCountByCountry();
    } catch (e) {
      // print('❌ Error getting manufacturer statistics: $e');
      return {};
    }
  }
  
  // Get recommended manufacturers from Firebase
  Future<List<Manufacturer>> getRecommendedManufacturers() async {
    return await loadInitialManufacturers();
  }
  
  
  // Filter manufacturers by country from loaded data
  List<Manufacturer> getFilteredManufacturers({
    String? country, 
    required RxList<Manufacturer> sourceManufacturers,
  }) {
    // print('🔍 Filtering manufacturers by country: $country');
    
    if (sourceManufacturers.isEmpty) {
      return [];
    }
    
    if (country == null || country == 'All' || country == 'All Countries') {
      return sourceManufacturers.toList();
    }
    
    return sourceManufacturers.where((manufacturer) {
      return manufacturer.country.toLowerCase() == country.toLowerCase() ||
             manufacturer.country.toLowerCase().contains(country.toLowerCase());
    }).toList();
  }


}