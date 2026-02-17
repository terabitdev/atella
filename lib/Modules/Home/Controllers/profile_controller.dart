import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:atella/services/firebase/services/auth_service.dart';
import 'package:atella/Modules/Home/Controllers/home_controller.dart';
import 'package:atella/services/analytics/posthog_analytics_service.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:atella/l10n/generated/app_localizations.dart';

class ProfileController extends GetxController {
  final TextEditingController fullNameController = TextEditingController();
  final TextEditingController emailController = TextEditingController();

  final RxString profileImageUrl = ''.obs;
  final RxBool isLoading = false.obs;
  final AuthService _authService = AuthService();
  final RxBool analyticsOptIn = true.obs;
  final RxBool isDeletingAccount = false.obs;

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
      final l10n = AppLocalizations.of(Get.context!)!;
      Get.snackbar(
        l10n.error,
        l10n.failedToLoadProfile,
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
        final l10n = AppLocalizations.of(Get.context!)!;

        if (success) {
          Get.snackbar(
            l10n.success,
            l10n.profileUpdatedSuccessfully,
            snackPosition: SnackPosition.TOP,
            backgroundColor: Colors.black,
            colorText: Colors.white,
            duration: const Duration(milliseconds: 1500),
          );
        } else {
          Get.snackbar(
            l10n.error,
            l10n.failedToUpdateProfile,
            snackPosition: SnackPosition.TOP,
            backgroundColor: Colors.red.shade100,
            colorText: Colors.red.shade800,
            duration: const Duration(milliseconds: 1500),
          );
        }
      } catch (e) {
        print('❌ Error updating profile: $e');
        final l10n = AppLocalizations.of(Get.context!)!;
        Get.snackbar(
          l10n.error,
          l10n.errorUpdatingProfile,
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
    final l10n = AppLocalizations.of(Get.context!)!;
    if (fullNameController.text.trim().isEmpty) {
      Get.snackbar(
        l10n.error,
        l10n.pleaseEnterFullName,
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
    final l10n = AppLocalizations.of(Get.context!)!;
    analyticsOptIn.value = enabled;
    await PostHogAnalyticsService().setAnalyticsOptIn(enabled);
    Get.snackbar(
      enabled ? l10n.analyticsEnabled : l10n.analyticsDisabled,
      enabled
          ? l10n.analyticsEnabledMessage
          : l10n.analyticsDisabledMessage,
      snackPosition: SnackPosition.TOP,
      backgroundColor: Colors.black,
      colorText: Colors.white,
      duration: const Duration(seconds: 3),
    );
  }

  // ========= Delete Account =========

  /// Delete account for email/password users
  Future<void> deleteAccountWithPassword(String password) async {
    try {
      isDeletingAccount.value = true;
      final l10n = AppLocalizations.of(Get.context!)!;

      print('🗑️ Starting account deletion with password...');

      // Call auth service to delete account
      final errorCode = await _authService.deleteAccountWithPassword(password);

      if (errorCode == null) {
        // Success
        print('✅ Account deleted successfully');

        // Clear all controllers
        Get.deleteAll(force: true);

        // Show success message
        Get.snackbar(
          l10n.accountDeleted,
          l10n.accountDeletedSuccess,
          snackPosition: SnackPosition.TOP,
          backgroundColor: Colors.black,
          colorText: Colors.white,
          duration: const Duration(seconds: 3),
        );

        // Navigate to login screen
        Get.offAllNamed('/login');
      } else {
        // Handle error
        print('❌ Account deletion failed: $errorCode');
        // Close the dialog before showing error
        if (Get.isDialogOpen ?? false) {
          Get.back();
        }
        _handleDeleteAccountError(errorCode);
      }
    } catch (e) {
      print('❌ Error during account deletion: $e');
      final l10n = AppLocalizations.of(Get.context!)!;
      // Close the dialog before showing error
      if (Get.isDialogOpen ?? false) {
        Get.back();
      }
      Get.snackbar(
        l10n.error,
        l10n.accountDeleteFailed,
        snackPosition: SnackPosition.TOP,
        backgroundColor: Colors.red,
        colorText: Colors.white,
        duration: const Duration(seconds: 3),
      );
    } finally {
      isDeletingAccount.value = false;
    }
  }

  /// Delete account for Google users
  Future<void> deleteAccountWithGoogle() async {
    try {
      isDeletingAccount.value = true;
      final l10n = AppLocalizations.of(Get.context!)!;

      print('🗑️ Starting account deletion with Google...');

      // Call auth service to delete account
      final errorCode = await _authService.deleteAccountWithGoogle();

      if (errorCode == null) {
        // Success
        print('✅ Account deleted successfully');

        // Clear all controllers
        Get.deleteAll(force: true);

        // Show success message
        Get.snackbar(
          l10n.accountDeleted,
          l10n.accountDeletedSuccess,
          snackPosition: SnackPosition.TOP,
          backgroundColor: Colors.black,
          colorText: Colors.white,
          duration: const Duration(seconds: 3),
        );

        // Navigate to login screen
        Get.offAllNamed('/login');
      } else {
        // Handle error
        print('❌ Account deletion failed: $errorCode');
        // Close the dialog before showing error
        if (Get.isDialogOpen ?? false) {
          Get.back();
        }
        _handleDeleteAccountError(errorCode);
      }
    } catch (e) {
      print('❌ Error during account deletion: $e');
      final l10n = AppLocalizations.of(Get.context!)!;
      // Close the dialog before showing error
      if (Get.isDialogOpen ?? false) {
        Get.back();
      }
      Get.snackbar(
        l10n.error,
        l10n.accountDeleteFailed,
        snackPosition: SnackPosition.TOP,
        backgroundColor: Colors.red,
        colorText: Colors.white,
        duration: const Duration(seconds: 3),
      );
    } finally {
      isDeletingAccount.value = false;
    }
  }

  /// Delete account for Apple users
  Future<void> deleteAccountWithApple() async {
    try {
      isDeletingAccount.value = true;
      final l10n = AppLocalizations.of(Get.context!)!;

      print('🗑️ Starting account deletion with Apple...');

      // Call auth service to delete account
      final errorCode = await _authService.deleteAccountWithApple();

      if (errorCode == null) {
        // Success
        print('✅ Account deleted successfully');

        // Clear all controllers
        Get.deleteAll(force: true);

        // Show success message
        Get.snackbar(
          l10n.accountDeleted,
          l10n.accountDeletedSuccess,
          snackPosition: SnackPosition.TOP,
          backgroundColor: Colors.black,
          colorText: Colors.white,
          duration: const Duration(seconds: 3),
        );

        // Navigate to login screen
        Get.offAllNamed('/login');
      } else {
        // Handle error
        print('❌ Account deletion failed: $errorCode');
        // Close the dialog before showing error
        if (Get.isDialogOpen ?? false) {
          Get.back();
        }
        _handleDeleteAccountError(errorCode);
      }
    } catch (e) {
      print('❌ Error during account deletion: $e');
      final l10n = AppLocalizations.of(Get.context!)!;
      // Close the dialog before showing error
      if (Get.isDialogOpen ?? false) {
        Get.back();
      }
      Get.snackbar(
        l10n.error,
        l10n.accountDeleteFailed,
        snackPosition: SnackPosition.TOP,
        backgroundColor: Colors.red,
        colorText: Colors.white,
        duration: const Duration(seconds: 3),
      );
    } finally {
      isDeletingAccount.value = false;
    }
  }

  /// Check if current user is a Google user
  bool isGoogleUser() {
    return _authService.isGoogleUser();
  }

  /// Check if current user is an Apple user
  bool isAppleUser() {
    return _authService.isAppleUser();
  }

  /// Handle delete account errors
  void _handleDeleteAccountError(String errorCode) {
    final l10n = AppLocalizations.of(Get.context!)!;
    String errorMessage;

    switch (errorCode) {
      case 'auth-wrong-password':
        errorMessage = l10n.wrongPassword;
        break;
      case 'auth-requires-recent-login':
        errorMessage = l10n.requiresRecentLogin;
        break;
      case 'auth-user-not-found':
        errorMessage = l10n.userNotFound;
        break;
      case 'auth-network-error':
        errorMessage = l10n.networkError;
        break;
      case 'auth-google-reauthentication-cancelled':
        errorMessage = l10n.googleReauthCancelled;
        break;
      case 'auth-apple-reauthentication-cancelled':
        errorMessage = l10n.appleReauthCancelled;
        break;
      case 'auth-delete-account-failed':
      default:
        errorMessage = l10n.accountDeleteFailed;
        break;
    }

    Get.snackbar(
      l10n.error,
      errorMessage,
      snackPosition: SnackPosition.TOP,
      backgroundColor: Colors.red,
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
