import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:atella/l10n/generated/app_localizations.dart';

import 'package:atella/core/utils/app_snackbar.dart';
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
      final l10n = AppLocalizations.of(Get.context!)!;
      try {
        await FirebaseAuth.instance.sendPasswordResetEmail(email: email);
        // print('Sending email verification to: $email');
        Get.back(); // Close the verification screen
        showAppSnackbar(
          l10n.verificationLinkSent,
          l10n.passwordResetLinkSent(email),
          snackPosition: SnackPosition.TOP,
          backgroundColor: Colors.black,
          colorText: Colors.white,
          duration: const Duration(milliseconds: 1500),
        );
      } catch (e) {
        // print('Failed to send verification link: $e');
        showAppSnackbar(
          l10n.error,
          l10n.failedToSendVerificationLink,
          snackPosition: SnackPosition.BOTTOM,
          backgroundColor: Colors.red,
          colorText: Colors.white,
          duration: const Duration(milliseconds: 1500),
        );
      }
    }
  }
}
