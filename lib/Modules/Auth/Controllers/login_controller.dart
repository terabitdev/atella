
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:atella/services/firebase/services/auth_service.dart';
import 'package:atella/services/analytics/posthog_analytics_service.dart';

class LoginController extends GetxController {
  final emailController = TextEditingController();
  final passwordController = TextEditingController();

  var isLoading = false.obs;
  var isGoogleLoading = false.obs;
  var emailError = ''.obs;
  var passwordError = ''.obs;

  final AuthService _authService = AuthService();

  String? validateEmail(String value) {
    if (value.trim().isEmpty) return 'Email is required';
    if (!GetUtils.isEmail(value.trim())) return 'Enter a valid email';
    return null;
  }

  String? validatePassword(String value) {
    if (value.isEmpty) return 'Password is required';
    if (value.length < 6) return 'Password must be at least 6 characters';
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

      Get.snackbar(
        'Success',
        'User successfully logged in',
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
        Get.snackbar(
          'Error',
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

      Get.snackbar(
        'Success',
        'Successfully signed in with Google',
        backgroundColor: Colors.black,
        colorText: Colors.white,
        snackPosition: SnackPosition.TOP,
        duration: const Duration(milliseconds: 1500),
      );
      Get.offAllNamed('/nav_bar');
    } else {
      Get.snackbar(
        'Error',
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
