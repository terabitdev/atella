import 'dart:io';

import 'package:appsflyer_sdk/appsflyer_sdk.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/foundation.dart';

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

  /// Links the logged-in Firebase user to their AppsFlyer install ID.
  ///
  /// Saves [appsflyerId] and [appsflyerPlatform] on the user's Firestore doc
  /// so backend S2S events (e.g. website subscriptions) can attribute revenue
  /// to the correct app install.
  Future<void> syncAppsFlyerIdToFirestore() async {
    final sdk = _sdk;
    if (sdk == null) {
      _debugLog('SDK not attached, skipping Firestore sync');
      return;
    }

    final user = FirebaseAuth.instance.currentUser;
    if (user == null) {
      _debugLog('No authenticated user, skipping Firestore sync');
      return;
    }

    try {
      sdk.setCustomerUserId(user.uid);

      final appsflyerId = await sdk.getAppsFlyerUID();
      if (appsflyerId == null || appsflyerId.isEmpty) {
        _debugLog('AppsFlyer UID not available yet, skipping Firestore sync');
        return;
      }

      final platform = Platform.isIOS ? 'ios' : 'android';

      await FirebaseFirestore.instance.collection('users').doc(user.uid).set({
        'appsflyerId': appsflyerId,
        'appsflyerPlatform': platform,
      }, SetOptions(merge: true));

      _debugLog('Synced appsflyerId to Firestore ($platform: $appsflyerId)');
    } catch (e) {
      _debugLog('Failed to sync appsflyerId to Firestore: $e');
    }
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

  Future<void> trackCreatedDesign() async {
    try {
      await _sdk?.logEvent('af_created_design', {});
      _debugLog('af_created_design sent');
    } catch (e) {
      _debugLog('Failed to send af_created_design: $e');
    }
  }

  Future<void> trackGeneratedTechPack() async {
    try {
      await _sdk?.logEvent('af_generated_tech_pack', {});
      _debugLog('af_generated_tech_pack sent');
    } catch (e) {
      _debugLog('Failed to send af_generated_tech_pack: $e');
    }
  }

  Future<void> trackContactedManufacturer() async {
    try {
      await _sdk?.logEvent('af_contacted_manufacturer', {});
      _debugLog('af_contacted_manufacturer sent');
    } catch (e) {
      _debugLog('Failed to send af_contacted_manufacturer: $e');
    }
  }

  void _debugLog(String message) {
    if (kDebugMode) {
      debugPrint('AppsFlyer: $message');
    }
  }
}
