import 'package:flutter/foundation.dart';
import 'package:appsflyer_sdk/appsflyer_sdk.dart';

/// AppsFlyer Analytics Service
///
/// A singleton service for sending AppsFlyer in-app events.
/// Mirrors the pattern used by PostHogAnalyticsService.
class AppsFlyerAnalyticsService {
  static final AppsFlyerAnalyticsService _instance =
      AppsFlyerAnalyticsService._internal();
  factory AppsFlyerAnalyticsService() => _instance;
  AppsFlyerAnalyticsService._internal();

  AppsflyerSdk? _sdk;

  /// Called once from main.dart after the SDK finishes initializing.
  void attachSdk(AppsflyerSdk sdk) {
    _sdk = sdk;
  }

  /// Track a completed registration (new account created).
  /// [method] should be 'email', 'google', or 'apple'.
  Future<void> trackCompleteRegistration({required String method}) async {
    try {
      await _sdk?.logEvent('af_complete_registration', {
        'af_registration_method': method,
      });
      _debugLog('af_complete_registration sent ($method)');
    } catch (e) {
      _debugLog('Failed to send af_complete_registration: $e');
    }
  }

  void _debugLog(String message) {
    if (kDebugMode) {
      debugPrint('AppsFlyer: $message');
    }
  }
}
