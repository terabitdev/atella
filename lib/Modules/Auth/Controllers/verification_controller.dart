import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

class VerificationController extends GetxController {
  final RxString selectedMethod = 'email'.obs;
  final RxString maskedEmail = '********@gmail.com'.obs;
  final TextEditingController emailController = TextEditingController();

  void selectVerificationMethod(String method) {
    selectedMethod.value = method;
  }

  bool get isEmailSelected => selectedMethod.value == 'email';

  Future<void> sendVerificationLink(String email) async {
    // Handle sending verification link logic
    if (email.isNotEmpty) {
      try {
        await FirebaseAuth.instance.sendPasswordResetEmail(email: email);
        // print('Sending email verification to: $email');
        Get.back(); // Close the verification screen
        Get.snackbar(
          'Verification Link Sent',
          'A password reset link has been sent to $email.',
          snackPosition: SnackPosition.TOP,
          backgroundColor: Colors.black,
          colorText: Colors.white,
        );
      } catch (e) {
        // print('Failed to send verification link: $e');
        Get.snackbar(
          'Error',
          'Failed to send verification link. Please try again.',
          snackPosition: SnackPosition.BOTTOM,
          backgroundColor: Colors.red,
          colorText: Colors.white,
        );
      }
    }
  }
}
