
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:atella/services/firebase/services/auth_service.dart';
import 'package:atella/services/analytics/posthog_analytics_service.dart';
import 'package:atella/l10n/generated/app_localizations.dart';

class LoginController extends GetxController {
  final emailController = TextEditingController();
  final passwordController = TextEditingController();

  var isLoading = false.obs;
  var isGoogleLoading = false.obs;
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
    if (value.length < 6) return l10n.passwordMinLength;
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
      Get.snackbar(
        l10n.success,
        l10n.userSuccessfullyLoggedIn,
        backgroundColor: Colors.black,
        colorText: Colors.white,
        duration: const Duration(milliseconds: 1500),
      );
      // Success
      Get.offAllNamed('/nav_bar');
    } else {
      // Show error below the relevant field
      if (result.toLowerCase().contains('email')) {
        emailError.value = result;
      } else if (result.toLowerCase().contains('password')) {
        passwordError.value = result;
      } else {
        final l10n = AppLocalizations.of(Get.context!)!;
        Get.snackbar(
          l10n.error,
          result,
          backgroundColor: Colors.red,
          colorText: Colors.white,
          duration: const Duration(milliseconds: 1500),
        );
      }
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
      Get.snackbar(
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
      Get.snackbar(
        l10n.error,
        result,
        backgroundColor: Colors.red,
        colorText: Colors.white,
        duration: const Duration(milliseconds: 1500),
      );
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
