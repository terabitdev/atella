import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:atella/Routes/app_routes.dart';
import 'package:atella/core/utils/app_snackbar.dart';
import 'package:atella/services/firebase/services/supplier_auth_service.dart';

class SupplierInviteSignupController extends GetxController {
  final SupplierAuthService _authService = SupplierAuthService();

  late final String token;

  final RxBool isValidating = true.obs;
  final RxString validationError = ''.obs;
  final RxString companyName = ''.obs;
  final RxString lockedEmail = ''.obs;

  final passwordController = TextEditingController();
  final confirmPasswordController = TextEditingController();
  final RxBool isSubmitting = false.obs;
  final RxString passwordError = ''.obs;
  final RxString confirmPasswordError = ''.obs;

  @override
  void onInit() {
    super.onInit();
    final args = Get.arguments;
    token = (args is Map && args['token'] is String) ? args['token'] as String : '';
    _validateToken();
  }

  Future<void> _validateToken() async {
    if (token.isEmpty) {
      isValidating.value = false;
      validationError.value = 'This invite link is missing or malformed.';
      return;
    }

    isValidating.value = true;
    try {
      final result = await _authService.validateInvite(token);
      companyName.value = result['companyName'] as String? ?? '';
      lockedEmail.value = result['email'] as String? ?? '';
    } catch (e) {
      validationError.value = _friendlyError(e);
    } finally {
      isValidating.value = false;
    }
  }

  Future<void> submit() async {
    passwordError.value = '';
    confirmPasswordError.value = '';

    if (passwordController.text.length < 6) {
      passwordError.value = 'Password must be at least 6 characters';
      return;
    }
    if (passwordController.text != confirmPasswordController.text) {
      confirmPasswordError.value = 'Passwords do not match';
      return;
    }

    isSubmitting.value = true;
    try {
      final error = await _authService.signUpAndAcceptInvite(
        email: lockedEmail.value,
        password: passwordController.text,
        token: token,
      );

      if (error == null) {
        showAppSnackbar(
          'Welcome to Atella',
          'Your supplier account is ready.',
          backgroundColor: Colors.black,
          colorText: Colors.white,
        );
        Get.offAllNamed(AppRoutes.supplierHome);
      } else {
        showAppSnackbar('Error', error, backgroundColor: Colors.red, colorText: Colors.white);
      }
    } finally {
      isSubmitting.value = false;
    }
  }

  String _friendlyError(Object e) {
    final message = e.toString();
    if (message.contains('expired')) return 'This invite link has expired.';
    if (message.contains('already been used') || message.contains('revoked')) {
      return 'This invite has already been used or revoked.';
    }
    if (message.contains('invalid')) return 'This invite link is invalid.';
    return 'Could not validate this invite. Please try again.';
  }

  @override
  void onClose() {
    passwordController.dispose();
    confirmPasswordController.dispose();
    super.onClose();
  }
}
