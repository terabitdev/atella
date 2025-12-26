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

      Get.snackbar(
        l10n.success,
        l10n.userRegisteredSuccessfully,
        backgroundColor: Colors.black,
        colorText: Colors.white,
        duration: const Duration(milliseconds: 1500),
      );
      FocusScope.of(Get.context!).unfocus(); // Unfocus text fields
      await Future.delayed(const Duration(milliseconds: 300)); // Let UI settle
      Get.offAllNamed('/login');
    } else {
      // Check for duplicate email error
      if (result.toLowerCase().contains('email') &&
          result.toLowerCase().contains('already')) {
        emailError.value = l10n.userAlreadyExistsWithEmail;
      } else {
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
