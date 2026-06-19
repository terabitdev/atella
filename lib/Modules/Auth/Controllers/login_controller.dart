
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:atella/services/firebase/services/auth_service.dart';
import 'package:atella/services/analytics/posthog_analytics_service.dart';
import 'package:atella/l10n/generated/app_localizations.dart';

import 'package:atella/core/utils/app_snackbar.dart';
class LoginController extends GetxController {
  final emailController = TextEditingController();
  final passwordController = TextEditingController();

  var isLoading = false.obs;
  var isGoogleLoading = false.obs;
  var isAppleLoading = false.obs;
  var emailError = ''.obs;
  var passwordError = ''.obs;

  final AuthService _authService = AuthService();

  String? validateEmail(String value) {
    final l10n = AppLocalizations.of(Get.context!)!;
    if (value.trim().isEmpty) return l10n.emailIsRequired;
    if (!GetUtils.isEmail(value.trim())) return l10n.enterValidEmail;
    return null;
  }

  String? validatePassword(String value) {
    final l10n = AppLocalizations.of(Get.context!)!;
    if (value.isEmpty) return l10n.passwordIsRequired;
    if (value.length < 8) return l10n.passwordMinLength;
    return null;
  }

  void clearErrors() {
    emailError.value = '';
    passwordError.value = '';
  }

  Future<void> login() async {
    clearErrors();
    final email = emailController.text.trim();
    final password = passwordController.text;

    final emailErr = validateEmail(email);
    final passwordErr = validatePassword(password);

    if (emailErr != null) emailError.value = emailErr;
    if (passwordErr != null) passwordError.value = passwordErr;

    if (emailErr != null || passwordErr != null) return;

    isLoading.value = true;
    final result = await _authService.signIn(email: email, password: password);
    isLoading.value = false;
    if (result == null) {
      // Identify user for PostHog
      final user = _authService.currentUser;
      if (user != null) {
        PostHogAnalyticsService().identifyUser(
          userId: user.uid,
          email: user.email,
          name: user.displayName,
        );
      }
      // Track login event
      PostHogAnalyticsService().trackUserLoggedIn(method: 'email');

      final l10n = AppLocalizations.of(Get.context!)!;
      showAppSnackbar(
        l10n.success,
        l10n.userSuccessfullyLoggedIn,
        backgroundColor: Colors.black,
        colorText: Colors.white,
        duration: const Duration(milliseconds: 1500),
      );
      // Success
      Get.offAllNamed('/nav_bar');
    } else {
      final l10n = AppLocalizations.of(Get.context!)!;
      debugPrint('Login error code received: $result');
      final errorMessage = _getLocalizedError(result, l10n);
      debugPrint('Localized error message: $errorMessage');

      // Show error as snackbar for all authentication errors
      // This is a security best practice to not reveal which field is incorrect
      showAppSnackbar(
        l10n.error,
        errorMessage,
        backgroundColor: Colors.red,
        colorText: Colors.white,
        duration: const Duration(milliseconds: 1500),
      );
    }
  }

  Future<void> loginWithGoogle() async {
    isGoogleLoading.value = true;
    final result = await _authService.signInWithGoogle();
    isGoogleLoading.value = false;

    if (result == null) {
      // Identify user for PostHog
      final user = _authService.currentUser;
      if (user != null) {
        PostHogAnalyticsService().identifyUser(
          userId: user.uid,
          email: user.email,
          name: user.displayName,
        );
      }
      // Track Google login event
      PostHogAnalyticsService().trackUserLoggedIn(method: 'google');

      final l10n = AppLocalizations.of(Get.context!)!;
      showAppSnackbar(
        l10n.success,
        l10n.successfullySignedInWithGoogle,
        backgroundColor: Colors.black,
        colorText: Colors.white,
        snackPosition: SnackPosition.TOP,
        duration: const Duration(milliseconds: 1500),
      );
      Get.offAllNamed('/nav_bar');
    } else {
      final l10n = AppLocalizations.of(Get.context!)!;
      final errorMessage = _getLocalizedError(result, l10n);
      showAppSnackbar(
        l10n.error,
        errorMessage,
        backgroundColor: Colors.red,
        colorText: Colors.white,
        duration: const Duration(milliseconds: 1500),
      );
    }
  }

  Future<void> loginWithApple() async {
    isAppleLoading.value = true;
    final result = await _authService.signInWithApple();
    isAppleLoading.value = false;

    if (result == null) {
      // Identify user for PostHog
      final user = _authService.currentUser;
      if (user != null) {
        PostHogAnalyticsService().identifyUser(
          userId: user.uid,
          email: user.email,
          name: user.displayName,
        );
      }
      // Track Apple login event
      PostHogAnalyticsService().trackUserLoggedIn(method: 'apple');

      final l10n = AppLocalizations.of(Get.context!)!;
      showAppSnackbar(
        l10n.success,
        l10n.successfullySignedInWithApple,
        backgroundColor: Colors.black,
        colorText: Colors.white,
        snackPosition: SnackPosition.TOP,
        duration: const Duration(milliseconds: 1500),
      );
      Get.offAllNamed('/nav_bar');
    } else if (result != 'auth-apple-sign-in-cancelled') {
      final l10n = AppLocalizations.of(Get.context!)!;
      final errorMessage = _getLocalizedError(result, l10n);
      showAppSnackbar(
        l10n.error,
        errorMessage,
        backgroundColor: Colors.red,
        colorText: Colors.white,
        duration: const Duration(milliseconds: 1500),
      );
    }
  }

  String _getLocalizedError(String errorCode, AppLocalizations l10n) {
    switch (errorCode) {
      case 'auth-invalid-credentials':
        return l10n.authInvalidCredentials;
      case 'auth-user-not-found':
        return l10n.authUserNotFound;
      case 'auth-wrong-password':
        return l10n.authWrongPassword;
      case 'auth-invalid-email':
        return l10n.authInvalidEmail;
      case 'auth-user-disabled':
        return l10n.authUserDisabled;
      case 'auth-too-many-requests':
        return l10n.authTooManyRequests;
      case 'auth-network-error':
        return l10n.authNetworkError;
      case 'auth-google-sign-in-cancelled':
        return l10n.authGoogleSignInCancelled;
      case 'auth-google-sign-in-failed':
        return l10n.authGoogleSignInFailed;
      case 'auth-google-config-error':
        return l10n.authGoogleConfigError;
      case 'auth-google-generic-error':
        return l10n.authGoogleGenericError;
      case 'auth-apple-sign-in-cancelled':
        return l10n.authAppleSignInCancelled;
      case 'auth-apple-sign-in-failed':
        return l10n.authAppleSignInFailed;
      case 'auth-generic-error':
        return l10n.authGenericError;
      default:
        return l10n.authGenericError;
    }
  }

  @override
  void onClose() {
    // print('LoginController disposed');
    emailController.dispose();
    passwordController.dispose();
    super.onClose();
  }
}
