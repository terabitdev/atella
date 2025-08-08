import 'dart:async';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:atella/services/firebase/services/auth_service.dart';

class SplashServices {
  void navigateToHome(BuildContext context) {
    Timer(const Duration(seconds: 4), () {
      final authService = AuthService();
      if (authService.currentUser != null) {
        Get.offNamed('/nav_bar');
      } else {
        Get.offNamed('/onboarding');
      }
    });
  }
}
