import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:atella/firebase/services/auth_service.dart';

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
    if (value.trim().isEmpty) return 'Name is required';
    return null;
  }

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

  String? validateConfirmPassword(String value) {
    if (value.isEmpty) return 'Confirm your password';
    if (value != passwordController.text) return 'Passwords do not match';
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
    if (result == null) {
      // Success
      Get.snackbar(
        'Success',
        'User registered successfully',
        backgroundColor: Colors.black,
        colorText: Colors.white,
      );
      FocusScope.of(Get.context!).unfocus(); // Unfocus text fields
      await Future.delayed(const Duration(milliseconds: 300)); // Let UI settle
      Get.offAllNamed('/login');
    } else {
      // Check for duplicate email error
      if (result.toLowerCase().contains('email') &&
          result.toLowerCase().contains('already')) {
        emailError.value = 'User already exists with this email';
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
