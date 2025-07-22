import 'dart:async';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

class SplashServices {
  void navigateToHome(BuildContext context) {
    Timer(const Duration(seconds: 4), () {
      Get.offNamed('/onboarding');
    });
  }
}
