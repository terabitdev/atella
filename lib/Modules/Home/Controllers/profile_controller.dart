import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:atella/core/services/auth_service.dart';

class ProfileController extends GetxController {
  final TextEditingController fullNameController = TextEditingController();
  final TextEditingController emailController = TextEditingController();
  final TextEditingController passwordController = TextEditingController();
  final TextEditingController confirmPasswordController =
      TextEditingController();

  final RxString profileImageUrl = ''.obs;
  final RxBool isLoading = false.obs;
  final AuthService _authService = AuthService();

  @override
  void onInit() {
    super.onInit();
    // Initialize with default values
    fullNameController.text = 'John Weak';
    emailController.text = 'Abc@gmail.com';
    passwordController.text = '******';
    confirmPasswordController.text = '********';
  }

  void editProfilePicture() {
    // Handle profile picture editing
    // This could open image picker or camera
    print('Edit profile picture tapped');
    Get.toNamed("/subscribe");
  }

  void updateProfile() {
    if (validateForm()) {
      isLoading.value = true;

      // Simulate API call
      Future.delayed(const Duration(seconds: 2), () {
        isLoading.value = false;
        Get.snackbar(
          'Success',
          'Profile updated successfully',
          snackPosition: SnackPosition.BOTTOM,
        );
      });
    }
  }

  bool validateForm() {
    if (fullNameController.text.trim().isEmpty) {
      Get.snackbar('Error', 'Please enter your full name');
      return false;
    }

    if (emailController.text.trim().isEmpty) {
      Get.snackbar('Error', 'Please enter your email');
      return false;
    }

    if (!GetUtils.isEmail(emailController.text.trim())) {
      Get.snackbar('Error', 'Please enter a valid email');
      return false;
    }

    if (passwordController.text.trim().isEmpty) {
      Get.snackbar('Error', 'Please enter your password');
      return false;
    }

    if (confirmPasswordController.text.trim().isEmpty) {
      Get.snackbar('Error', 'Please confirm your password');
      return false;
    }

    if (passwordController.text != confirmPasswordController.text) {
      Get.snackbar('Error', 'Passwords do not match');
      return false;
    }

    return true;
  }

  Future<void> logout() async {
    await _authService.signOut();
    Get.offAllNamed('/login');
  }

  @override
  void onClose() {
    fullNameController.dispose();
    emailController.dispose();
    passwordController.dispose();
    confirmPasswordController.dispose();
    super.onClose();
  }
}
