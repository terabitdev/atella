import 'dart:async';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:atella/core/utils/post_auth_router.dart';
import 'package:atella/services/firebase/services/auth_service.dart';
import 'package:atella/services/deeplink/deep_link_service.dart';

class SplashServices {
  void navigateToHome(BuildContext context) {
    Timer(const Duration(seconds: 4), () async {
      // A deep link (e.g. the supplier-invite screen) already took over
      // navigation — don't stomp over it with this unrelated redirect.
      if (DeepLinkService.isHandlingDeepLink) return;

      final authService = AuthService();
      if (authService.currentUser != null) {
        final route = await resolvePostAuthRoute();
        // Re-check after the network round-trip above, in case a deep link
        // arrived while this was in flight.
        if (DeepLinkService.isHandlingDeepLink) return;
        Get.offNamed(route);
      } else {
        Get.offNamed('/onboarding');
      }
    });
  }
}
