import 'dart:async';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';

/// Registers this device for push notifications and keeps the signed-in
/// user's Firestore doc in sync with its FCM token, so Cloud Functions can
/// target them (see functions/src/messaging/messages.ts and
/// functions/src/suppliers/submissions.ts). Also draws a local notification
/// for messages that arrive while the app is in the foreground — FCM only
/// auto-displays a system-tray notification when the app is backgrounded or
/// killed.
class PushNotificationService {
  static final PushNotificationService _instance = PushNotificationService._internal();
  factory PushNotificationService() => _instance;
  PushNotificationService._internal();

  static const _androidChannelId = 'chat_messages';
  static const _androidChannelName = 'Chat messages';

  final FirebaseMessaging _messaging = FirebaseMessaging.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FlutterLocalNotificationsPlugin _localNotifications = FlutterLocalNotificationsPlugin();

  StreamSubscription<String>? _tokenRefreshSubscription;
  StreamSubscription<RemoteMessage>? _foregroundMessageSubscription;

  /// Requests notification permission, prepares local-notification display
  /// for foreground messages, and starts listening for token refreshes.
  /// Call once at app startup, after Firebase.initializeApp.
  Future<void> initialize() async {
    try {
      await _messaging.requestPermission();
    } catch (e) {
      debugPrint('PushNotificationService: permission request failed - $e');
    }

    await _initializeLocalNotifications();

    await saveTokenForCurrentUser();

    _tokenRefreshSubscription?.cancel();
    _tokenRefreshSubscription = _messaging.onTokenRefresh.listen(_writeToken);

    _foregroundMessageSubscription?.cancel();
    _foregroundMessageSubscription = FirebaseMessaging.onMessage.listen(_showForegroundNotification);
  }

  Future<void> _initializeLocalNotifications() async {
    try {
      const androidSettings = AndroidInitializationSettings('@mipmap/launcher_icon');
      const iosSettings = DarwinInitializationSettings();
      await _localNotifications.initialize(
        const InitializationSettings(android: androidSettings, iOS: iosSettings),
      );

      await _localNotifications
          .resolvePlatformSpecificImplementation<AndroidFlutterLocalNotificationsPlugin>()
          ?.createNotificationChannel(
            const AndroidNotificationChannel(
              _androidChannelId,
              _androidChannelName,
              importance: Importance.high,
            ),
          );
    } catch (e) {
      debugPrint('PushNotificationService: local notifications init failed - $e');
    }
  }

  void _showForegroundNotification(RemoteMessage message) {
    final title = message.notification?.title;
    final body = message.notification?.body;
    if (title == null && body == null) return;

    _localNotifications.show(
      message.hashCode,
      title,
      body,
      const NotificationDetails(
        android: AndroidNotificationDetails(
          _androidChannelId,
          _androidChannelName,
          importance: Importance.high,
          priority: Priority.high,
        ),
        iOS: DarwinNotificationDetails(),
      ),
    );
  }

  /// Fetches the device's current FCM token and stores it on the signed-in
  /// user's Firestore doc. Call right after a successful sign-in/sign-up so
  /// a device that installed the app pre-login still gets registered.
  Future<void> saveTokenForCurrentUser() async {
    try {
      final token = await _messaging.getToken();
      if (token != null) {
        await _writeToken(token);
      }
    } catch (e) {
      debugPrint('PushNotificationService: failed to fetch token - $e');
    }
  }

  Future<void> _writeToken(String token) async {
    final uid = FirebaseAuth.instance.currentUser?.uid;
    if (uid == null) return;
    try {
      await _firestore.collection('users').doc(uid).update({
        'fcmTokens': FieldValue.arrayUnion([token]),
      });
    } catch (e) {
      debugPrint('PushNotificationService: failed to save token - $e');
    }
  }

  /// Removes this device's token from the signed-out user's doc so it stops
  /// receiving that account's notifications. Call before signing out.
  Future<void> removeTokenForCurrentUser() async {
    final uid = FirebaseAuth.instance.currentUser?.uid;
    if (uid == null) return;
    try {
      final token = await _messaging.getToken();
      if (token != null) {
        await _firestore.collection('users').doc(uid).update({
          'fcmTokens': FieldValue.arrayRemove([token]),
        });
      }
    } catch (e) {
      debugPrint('PushNotificationService: failed to remove token - $e');
    }
  }
}
