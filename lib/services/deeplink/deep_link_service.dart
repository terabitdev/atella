import 'dart:async';

import 'package:app_links/app_links.dart';
import 'package:atella/Routes/app_routes.dart';
import 'package:flutter/foundation.dart';
import 'package:get/get.dart';

/// Listens for `atella://...` links (invite links today; extensible to
/// other links later) and routes to the matching screen. Custom-scheme
/// links, not universal/App Links — no web hosting/domain verification
/// required, which is why this is the v1 approach.
class DeepLinkService {
  static final DeepLinkService _instance = DeepLinkService._internal();
  factory DeepLinkService() => _instance;
  DeepLinkService._internal();

  final AppLinks _appLinks = AppLinks();
  StreamSubscription<Uri>? _subscription;

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

    if (uri.scheme != 'atella') return;

    if (uri.host == 'supplier-invite') {
      final token = uri.queryParameters['token'];
      if (token != null && token.isNotEmpty) {
        Get.toNamed(AppRoutes.supplierInviteSignup, arguments: {'token': token});
      }
    }
  }

  void dispose() {
    _subscription?.cancel();
  }
}
