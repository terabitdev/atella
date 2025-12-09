import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:atella/services/firebase/services/auth_service.dart';
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
      );
    } finally {
      isLoading.value = false;
    }
  }
  Future<void> updateProfile() async {
    if (validateForm()) {
      isLoading.value = true;
      
      try {
        final success = await _authService.updateUserProfile(
          name: fullNameController.text.trim(),
        );
        
        if (success) {
          Get.snackbar(
            'Success',
            'Profile updated successfully',
            snackPosition: SnackPosition.TOP,
            backgroundColor: Colors.black,
            colorText: Colors.white,
          );
        } else {
          Get.snackbar(
            'Error',
            'Failed to update profile. Please try again.',
            snackPosition: SnackPosition.TOP,
            backgroundColor: Colors.red.shade100,
            colorText: Colors.red.shade800,
          );
        }
      } catch (e) {
        print('Error updating profile: $e');
        Get.snackbar(
          'Error',
          'An error occurred while updating profile',
          snackPosition: SnackPosition.TOP,
          backgroundColor: Colors.red.shade100,
          colorText: Colors.red.shade800,
        );
      } finally {
        isLoading.value = false;
      }
    }
  }

  bool validateForm() {
    if (fullNameController.text.trim().isEmpty) {
      Get.snackbar('Error', 'Please enter your full name');
      return false;
    }

    return true;
  }

  Future<void> logout() async {
    // Track logout and reset PostHog session
    await PostHogAnalyticsService().trackUserLoggedOut();
    await _authService.signOut();
    Get.offAllNamed('/login');
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
