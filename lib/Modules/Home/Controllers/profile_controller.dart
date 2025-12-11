import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:atella/services/firebase/services/auth_service.dart';
import 'package:atella/Modules/Home/Controllers/home_controller.dart';
import 'package:atella/services/analytics/posthog_analytics_service.dart';
import 'package:shared_preferences/shared_preferences.dart';

class ProfileController extends GetxController {
  final TextEditingController fullNameController = TextEditingController();
  final TextEditingController emailController = TextEditingController();

  final RxString profileImageUrl = ''.obs;
  final RxBool isLoading = false.obs;
  final AuthService _authService = AuthService();
  final RxBool analyticsOptIn = true.obs;

  @override
  void onInit() {
    super.onInit();
    loadUserData();
    _loadAnalyticsOptIn();
  }

  Future<void> loadUserData() async {
    try {
      isLoading.value = true;
      final userData = await _authService.getUserData();
      
      if (userData != null) {
        fullNameController.text = userData['name'] ?? '';
        emailController.text = userData['email'] ?? '';
      } else {
        // Fallback to Firebase Auth user data
        final user = _authService.currentUser;
        if (user != null) {
          fullNameController.text = user.displayName ?? '';
          emailController.text = user.email ?? '';
        }
      }
    } catch (e) {
      print('Error loading user data: $e');
      Get.snackbar(
        'Error',
        'Failed to load profile data',
        snackPosition: SnackPosition.TOP,
        duration: const Duration(milliseconds: 1500),
      );
    } finally {
      isLoading.value = false;
    }
  }
  Future<void> updateProfile() async {
    if (validateForm()) {
      print('🔄 Starting profile update...');
      isLoading.value = true;
      print('✅ isLoading set to true: ${isLoading.value}');

      try {
        // Ensure UI has time to show "Updating..." state
        await Future.delayed(Duration(milliseconds: 300));

        print('📤 Calling updateUserProfile...');
        final success = await _authService.updateUserProfile(
          name: fullNameController.text.trim(),
        );
        print('📥 Update result: $success');

        if (success) {
          Get.snackbar(
            'Success',
            'Profile updated successfully',
            snackPosition: SnackPosition.TOP,
            backgroundColor: Colors.black,
            colorText: Colors.white,
            duration: const Duration(milliseconds: 1500),
          );
        } else {
          Get.snackbar(
            'Error',
            'Failed to update profile. Please try again.',
            snackPosition: SnackPosition.TOP,
            backgroundColor: Colors.red.shade100,
            colorText: Colors.red.shade800,
            duration: const Duration(milliseconds: 1500),
          );
        }
      } catch (e) {
        print('❌ Error updating profile: $e');
        Get.snackbar(
          'Error',
          'An error occurred while updating profile',
          snackPosition: SnackPosition.TOP,
          backgroundColor: Colors.red.shade100,
          colorText: Colors.red.shade800,
          duration: const Duration(milliseconds: 1500),
        );
      } finally {
        print('✅ isLoading set to false');
        isLoading.value = false;
      }
    } else {
      print('⚠️ Form validation failed');
    }
  }

  bool validateForm() {
    if (fullNameController.text.trim().isEmpty) {
      Get.snackbar(
        'Error',
        'Please enter your full name',
        duration: const Duration(milliseconds: 1500),
      );
      return false;
    }

    return true;
  }

  Future<void> logout() async {
    print('🔄 Starting logout process...');

    // Clear all cached data from controllers
    try {
      // Clear HomeController data if it exists
      if (Get.isRegistered<HomeController>()) {
        final homeController = Get.find<HomeController>();
        homeController.clearAllData();
        print('✅ HomeController data cleared');
      }

      // Delete all GetX controllers to ensure fresh state on next login
      Get.deleteAll(force: true);
      print('✅ All controllers deleted');

    } catch (e) {
      print('⚠️ Error clearing controllers: $e');
    }

    // Sign out from Firebase
    // Track logout and reset PostHog session
    await PostHogAnalyticsService().trackUserLoggedOut();
    await _authService.signOut();
    print('✅ Signed out from Firebase');

    // Navigate to login screen and clear all routes
    Get.offAllNamed('/login');
    print('✅ Navigated to login screen');
  }

  // ========= Analytics Opt-In =========
  Future<void> _loadAnalyticsOptIn() async {
    final prefs = await SharedPreferences.getInstance();
    analyticsOptIn.value = prefs.getBool('analytics_opt_in') ?? true;
  }

  Future<void> toggleAnalyticsOptIn(bool enabled) async {
    analyticsOptIn.value = enabled;
    await PostHogAnalyticsService().setAnalyticsOptIn(enabled);
    Get.snackbar(
      enabled ? 'Analytics enabled' : 'Analytics disabled',
      enabled
          ? 'Helps improve the app. Session replays remain sampled.'
          : 'We will stop sending analytics and session replays.',
      snackPosition: SnackPosition.TOP,
      backgroundColor: Colors.black,
      colorText: Colors.white,
      duration: const Duration(seconds: 3),
    );
  }

  @override
  void onClose() {
    fullNameController.dispose();
    emailController.dispose();
    super.onClose();
  }
}
