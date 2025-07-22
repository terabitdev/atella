import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:atella/core/services/auth_service.dart';

class LoginController extends GetxController {
  final emailController = TextEditingController();
  final passwordController = TextEditingController();

  var isLoading = false.obs;
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
      Get.snackbar(
        'Success',
        'User successfully logged in',
        backgroundColor: Colors.black,
        colorText: Colors.white,
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
        );
      }
    }
  }

  void loginWithGoogle() {
    // handle Google Sign-In
  }

  @override
  void onClose() {
    emailController.dispose();
    passwordController.dispose();
    super.onClose();
  }
}
