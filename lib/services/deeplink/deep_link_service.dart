import 'dart:async';

import 'package:app_links/app_links.dart';
import 'package:atella/Routes/app_routes.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/widgets.dart';
import 'package:get/get.dart';

/// Listens for supplier-invite links — verified Android App Links / iOS
/// Universal Links (`https://atelia-123.web.app/supplier-invite?token=...`,
/// see `public/.well-known/`), plus the legacy `atella://` custom scheme
/// kept for backward compatibility — and routes to the matching screen.
class DeepLinkService {
  static final DeepLinkService _instance = DeepLinkService._internal();
  factory DeepLinkService() => _instance;
  DeepLinkService._internal();

  final AppLinks _appLinks = AppLinks();
  StreamSubscription<Uri>? _subscription;

  // Set right before navigating to a deep-link screen so other startup logic
  // (see SplashServices.navigateToHome) can avoid stomping over it once its
  // own, unrelated redirect finishes later.
  static bool isHandlingDeepLink = false;

  Future<void> initialize() async {
    try {
      final initialUri = await _appLinks.getInitialLink();
      if (initialUri != null) {
        _handleUri(initialUri);
      }
    } catch (e) {
      if (kDebugMode) debugPrint('DeepLink: error reading initial link - $e');
    }

    _subscription = _appLinks.uriLinkStream.listen(
      _handleUri,
      onError: (e) {
        if (kDebugMode) debugPrint('DeepLink: stream error - $e');
      },
    );
  }

  void _handleUri(Uri uri) {
    if (kDebugMode) debugPrint('DeepLink: received $uri');

    // Verified Android App Link / iOS Universal Link — the real, tappable
    // link format (see public/.well-known/ for the verification files).
    final isVerifiedInviteLink = uri.scheme == 'https' &&
        uri.host == 'atelia-123.web.app' &&
        uri.path.startsWith('/supplier-invite');

    // Legacy custom scheme — kept so any already-sent atella:// links
    // (from before this app-links setup) still work.
    final isLegacySchemeInviteLink =
        uri.scheme == 'atella' && uri.host == 'supplier-invite';

    if (!isVerifiedInviteLink && !isLegacySchemeInviteLink) return;

    final token = uri.queryParameters['token'];
    if (token == null || token.isEmpty) return;

    // A link can arrive (via getInitialLink) before the widget tree has
    // produced a stable first frame — especially on a cold start, which is
    // exactly what tapping this link does when the app wasn't already
    // running. Navigating immediately in that case throws "Looking up a
    // deactivated widget's ancestor is unsafe" and silently fails, leaving
    // a blank screen.
    //
    // A post-frame callback alone isn't enough either: it still runs during
    // the frame's synchronous callback phase, which is exactly when the
    // Navigator can be mid-transition and locked (`_debugLocked` assertion)
    // handling the app's own initial route push. Nesting a zero-duration
    // `Future.delayed` inside the post-frame callback pushes the actual
    // navigation into a later event-loop turn, after that lock is released,
    // while the post-frame callback still guarantees the tree exists first.
    isHandlingDeepLink = true;
    WidgetsBinding.instance.addPostFrameCallback((_) {
      Future.delayed(Duration.zero, () {
        Get.toNamed(AppRoutes.supplierInviteSignup, arguments: {'token': token});
      });
    });
  }

  void dispose() {
    _subscription?.cancel();
  }
}
