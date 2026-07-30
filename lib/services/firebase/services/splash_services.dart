import 'dart:async';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:atella/core/utils/post_auth_router.dart';
import 'package:atella/services/firebase/services/auth_service.dart';

class SplashServices {
  void navigateToHome(BuildContext context) {
    Timer(const Duration(seconds: 4), () async {
      final authService = AuthService();
      if (authService.currentUser != null) {
        final route = await resolvePostAuthRoute();
        Get.offNamed(route);
      } else {
        Get.offNamed('/onboarding');
      }
    });
  }
}
