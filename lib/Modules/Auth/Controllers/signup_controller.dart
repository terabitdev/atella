import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:atella/services/firebase/services/auth_service.dart';
import 'package:atella/services/analytics/posthog_analytics_service.dart';
import 'package:atella/l10n/generated/app_localizations.dart';

class SignupController extends GetxController {
  final nameController = TextEditingController();
  final emailController = TextEditingController();
  final passwordController = TextEditingController();
  final confirmPasswordController = TextEditingController();

  var isLoading = false.obs;

  // Field-specific error messages
  var nameError = ''.obs;
  var emailError = ''.obs;
  var passwordError = ''.obs;
  var confirmPasswordError = ''.obs;

  final AuthService _authService = AuthService();

  String? validateName(String value) {
    final l10n = AppLocalizations.of(Get.context!)!;
    if (value.trim().isEmpty) return l10n.nameIsRequired;
    return null;
  }

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

  String? validateConfirmPassword(String value) {
    final l10n = AppLocalizations.of(Get.context!)!;
    if (value.isEmpty) return l10n.confirmYourPassword;
    if (value != passwordController.text) return l10n.passwordsDoNotMatch;
    return null;
  }

  void clearErrors() {
    nameError.value = '';
    emailError.value = '';
    passwordError.value = '';
    confirmPasswordError.value = '';
  }

  Future<void> signUp() async {
    clearErrors();
    final name = nameController.text.trim();
    final email = emailController.text.trim();
    final password = passwordController.text;
    final confirmPassword = confirmPasswordController.text;

    final nameErr = validateName(name);
    final emailErr = validateEmail(email);
    final passwordErr = validatePassword(password);
    final confirmPasswordErr = validateConfirmPassword(confirmPassword);

    if (nameErr != null) nameError.value = nameErr;
    if (emailErr != null) emailError.value = emailErr;
    if (passwordErr != null) passwordError.value = passwordErr;
    if (confirmPasswordErr != null) {
      confirmPasswordError.value = confirmPasswordErr;
    }

    // If any error, don't proceed
    if ([
      nameErr,
      emailErr,
      passwordErr,
      confirmPasswordErr,
    ].any((e) => e != null)) {
      return;
    }

    isLoading.value = true;
    final result = await _authService.signUp(
      name: name,
      email: email,
      password: password,
    );
    isLoading.value = false;
    final l10n = AppLocalizations.of(Get.context!)!;

    if (result == null) {
      // Success - Track signup event
      PostHogAnalyticsService().trackUserSignedUp(method: 'email');

      // Identify user for PostHog
      final user = _authService.currentUser;
      if (user != null) {
        PostHogAnalyticsService().identifyUser(
          userId: user.uid,
          email: user.email,
          name: user.displayName,
        );
      }

      Get.snackbar(
        l10n.success,
        l10n.userRegisteredSuccessfully,
        backgroundColor: Colors.black,
        colorText: Colors.white,
        duration: const Duration(milliseconds: 1500),
      );
      FocusScope.of(Get.context!).unfocus();
      await Future.delayed(const Duration(milliseconds: 300));
      Get.offAllNamed('/nav_bar');
    } else {
      debugPrint('Signup error code received: $result');
      final errorMessage = _getLocalizedError(result, l10n);
      debugPrint('Localized error message: $errorMessage');

      // Show email-specific errors below the email field
      if (result == 'auth-email-already-in-use') {
        emailError.value = errorMessage;
      } else if (result == 'auth-weak-password') {
        passwordError.value = errorMessage;
      } else if (result == 'auth-invalid-email') {
        emailError.value = errorMessage;
      } else {
        Get.snackbar(
          l10n.error,
          errorMessage,
          backgroundColor: Colors.red,
          colorText: Colors.white,
          duration: const Duration(milliseconds: 1500),
        );
      }
    }
  }

  String _getLocalizedError(String errorCode, AppLocalizations l10n) {
    switch (errorCode) {
      case 'auth-email-already-in-use':
        return l10n.authEmailAlreadyInUse;
      case 'auth-weak-password':
        return l10n.authWeakPassword;
      case 'auth-invalid-email':
        return l10n.authInvalidEmail;
      case 'auth-operation-not-allowed':
        return l10n.authOperationNotAllowed;
      case 'auth-user-creation-failed':
        return l10n.authUserCreationFailed;
      case 'auth-network-error':
        return l10n.authNetworkError;
      case 'auth-generic-error':
        return l10n.authGenericError;
      default:
        return l10n.authGenericError;
    }
  }

  @override
  void onClose() {
    // print('SignupController disposed');
    nameController.dispose();
    emailController.dispose();
    passwordController.dispose();
    confirmPasswordController.dispose();
    super.onClose();
  }
}
