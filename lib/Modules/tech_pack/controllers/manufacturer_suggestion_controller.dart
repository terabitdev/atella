import 'package:atella/services/email/test_email_service.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:country_picker/country_picker.dart';
import 'package:atella/Data/Models/manufacturer_model.dart';
import 'package:atella/services/manufacture_services/manufacturer_service.dart';
import 'package:atella/modules/tech_pack/controllers/tech_pack_ready_controller.dart';
import 'package:atella/services/firebase/services/auth_service.dart';


class ManufacturerSuggestionController extends GetxController {
  // Tab index: 0 = Recommended, 1 = Custom
  final RxInt tabIndex = 0.obs;

  // Services
  final ManufacturerService _manufacturerService = Get.put(ManufacturerService());
  final AuthService _authService = AuthService();

  // Data
  final RxList<Manufacturer> recommendedManufacturers = <Manufacturer>[].obs;
  final RxList<Manufacturer> displayedManufacturers = <Manufacturer>[].obs;
  final RxList<Manufacturer> filteredManufacturers = <Manufacturer>[].obs;
  final RxList<Manufacturer> allManufacturersCache = <Manufacturer>[].obs;
  final RxBool isLoading = false.obs;
  final RxBool isLoadingMore = false.obs;
  final RxBool isLoadingCustomTab = false.obs;
  final RxString error = ''.obs;
  
  // Stream for custom tab data
  Stream<List<Manufacturer>>? _customTabStream;
  Stream<List<Manufacturer>> get customTabStream => _customTabStream ?? Stream.value([]);

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
    _initializeCustomTabStream();
  }
  
  void _initializeCustomTabStream() {
    _customTabStream = Stream.value(filteredManufacturers);
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
      
      // Update filtered manufacturers for custom tab immediately
      loadFilteredManufacturers();
      
      // Ensure custom tab never shows loading if data is ready
      if (allManufacturersCache.isNotEmpty) {
        isLoadingCustomTab.value = false;
      }
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
    
    // Update stream for custom tab
    _customTabStream = Stream.value(filtered);
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

  // Handle tab switching - instant, no loading delays
  void switchToTab(int index) {
    tabIndex.value = index;
    
    if (index == 1 && allManufacturersCache.isNotEmpty && filteredManufacturers.isEmpty) {
      // Load filtered data from cache instantly
      loadFilteredManufacturers();
    }
  }
  
  
  // Email functionality
  final RxBool isSendingEmail = false.obs;
  final RxSet<String> loadingManufacturers = <String>{}.obs;
  
  // Helper method to check if a specific manufacturer is loading
  bool isManufacturerLoading(String manufacturerId) {
    return loadingManufacturers.contains(manufacturerId);
  }
  
  // Send email to manufacturer
  Future<void> sendEmailToManufacturer(Manufacturer manufacturer) async {
    // Check if manufacturer has email
    if (manufacturer.email == null || manufacturer.email!.isEmpty) {
      Get.snackbar(
        'No Email Available',
        'This manufacturer does not have an email address on file.',
        backgroundColor: Colors.orange,
        colorText: Colors.white,
        duration: const Duration(seconds: 3),
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
          'mainFabric': _extractFromSummary(techPackController.techPackSummary, 'Materials: '),
          'primaryColor': _extractFromSummary(techPackController.techPackSummary, 'Colors: '),
          'sizeRange': _extractFromSummary(techPackController.techPackSummary, 'Sizes: '),
          'quantity': _extractFromSummary(techPackController.techPackSummary, 'Quantity: '),
          'costPerPiece': _extractFromSummary(techPackController.techPackSummary, 'Target Cost: '),
          'deliveryDate': _extractFromSummary(techPackController.techPackSummary, 'Delivery: '),
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
          'data:image/jpeg;base64,/9j/4AAQSkZJRgABAQAAAQABAAD/2wBDAAYEBQYFBAYGBQYHBwYIChAKCgkJChQODwwQFxQYGBcUFhYaHSUfGhsjHBYWICwgIyYnKSopGR8tMC0oMCUoKSj/2wBDAQcHBwoIChMKChMoGhYaKCgoKCgoKCgoKCgoKCgoKCgoKCgoKCgoKCgoKCgoKCgoKCgoKCgoKCgoKCgoKCgoKCj/wAARCAABAAEDASIAAhEBAxEB/8QAFQABAQAAAAAAAAAAAAAAAAAAAAv/xAAUEAEAAAAAAAAAAAAAAAAAAAAA/8QAFQEBAQAAAAAAAAAAAAAAAAAAAAX/xAAUEQEAAAAAAAAAAAAAAAAAAAAA/9oADAMBAAIRAxEAPwCdABmX/9k='
        ];
      }

      // Send AI-powered email with PDF attachment
      final success = await EmailJSDebugService.sendAIPoweredEmailWithPDF(
        toEmail: manufacturer.email!,
        manufacturerName: manufacturer.name,
        manufacturerLocation: manufacturer.location,
        techPackData: techPackData,
        userCompanyName: userName ?? 'Atelia Fashion',
        userEmail: userEmail,
        userName: userName,
        imagePaths: imagePaths,
      );

      // Show result
      if (success) {
        Get.snackbar(
          'Email Sent Successfully!',
          'Your tech pack has been sent to ${manufacturer.name} at ${manufacturer.email}',
          backgroundColor: Colors.black,
          colorText: Colors.white,
          duration: const Duration(seconds: 3),
          icon: const Icon(Icons.check_circle, color: Colors.white),
        );
      } else {
        Get.snackbar(
          'Email Failed',
          'Failed to send email to ${manufacturer.name}. Please try again.',
          backgroundColor: Colors.red,
          colorText: Colors.white,
          duration: const Duration(seconds: 5),
          icon: const Icon(Icons.error, color: Colors.white),
        );
      }
    } catch (e) {
      Get.snackbar(
        'Error',
        'An error occurred while sending email: $e',
        backgroundColor: Colors.red,
        colorText: Colors.white,
        duration: const Duration(seconds: 5),
        icon: const Icon(Icons.error, color: Colors.white),
      );
    } finally {
      // Clear screen-wide loading state
      isSendingEmail.value = false;
    }
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

