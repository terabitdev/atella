import 'dart:async';
import 'dart:io';
import 'package:flutter/foundation.dart';

/// Simple internet connectivity checker for mobile platforms (Android/iOS)
/// Uses HTTP request to check actual internet connectivity
class InternetConnectivityChecker {
  /// Check if device has active internet connection
  /// Returns true if connected, false otherwise
  /// Only checks on mobile platforms (Android/iOS)
  /// Returns true on desktop platforms to avoid blocking
  static Future<bool> hasInternetConnection() async {
    // Skip check on desktop platforms (Windows, macOS, Linux)
    if (!kIsWeb && (Platform.isWindows || Platform.isMacOS || Platform.isLinux)) {
      print('🖥️ Desktop platform detected - skipping connectivity check');
      return true;
    }

    try {
      print('🌐 Checking internet connectivity...');

      // Try to lookup Google's DNS (reliable and fast)
      final result = await InternetAddress.lookup('google.com')
          .timeout(const Duration(seconds: 5));

      if (result.isNotEmpty && result[0].rawAddress.isNotEmpty) {
        print('✅ Internet connection available');
        return true;
      }

      print('❌ No internet connection');
      return false;
    } on SocketException catch (e) {
      print('❌ No internet connection (SocketException): $e');
      return false;
    } on TimeoutException catch (e) {
      print('❌ Internet check timeout: $e');
      return false;
    } catch (e) {
      print('⚠️ Error checking connectivity: $e');
      // On error, assume connection available to avoid blocking users
      return true;
    }
  }
}
