import 'dart:convert';
import 'dart:math';

import 'package:crypto/crypto.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/foundation.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:sign_in_with_apple/sign_in_with_apple.dart';
import 'package:atella/services/firebase/services/delete_account_service.dart';
import 'package:atella/services/firebase/services/design_quota_service.dart';
import 'package:atella/services/firebase/services/push_notification_service.dart';
import 'package:atella/services/onboarding/onboarding_storage_service.dart';

class AuthService {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final GoogleSignIn _googleSignIn = GoogleSignIn(
    // iOS client ID from GoogleService-Info.plist
    // This ensures proper OAuth redirect handling on iOS
  );
  final DesignQuotaService _quotaService = DesignQuotaService();

  Future<String?> signUp({
    required String name,
    required String email,
    required String password,
  }) async {
    try {
      UserCredential userCredential = await _auth
          .createUserWithEmailAndPassword(email: email, password: password);
      User? user = userCredential.user;
      if (user != null) {
        await _firestore.collection('users').doc(user.uid).set({
          'uid': user.uid,
          'name': name,
          'email': email,
          'createdAt': FieldValue.serverTimestamp(),
          'subscriptionPlan': 'FREE',
          'subscriptionStatus': 'active',
          'stripeCustomerId': null,
          'currentSubscriptionId': null,
          'techpacksUsedThisMonth': 0,
          'accountType': 'user',
          'supplierId': null,
        });

        // Initialize or fetch email-based quota (persists across account deletions)
        try {
          await _quotaService.getQuotaByEmail(email);
          debugPrint('✅ Email-based quota initialized for: $email');
        } catch (e) {
          debugPrint('⚠️ Error initializing quota: $e');
          // Don't fail signup if quota initialization fails
        }

        await _saveOnboardingToFirestore(user.uid);
        await PushNotificationService().saveTokenForCurrentUser();

        return null; // Success
      } else {
        return 'auth-user-creation-failed';
      }
    } on FirebaseAuthException catch (e) {
      debugPrint('SignUp FirebaseAuthException code: ${e.code}');
      debugPrint('SignUp FirebaseAuthException message: ${e.message}');

      // Return Firebase error codes for localization
      switch (e.code) {
        case 'email-already-in-use':
        case 'EMAIL_EXISTS':
          return 'auth-email-already-in-use';
        case 'weak-password':
        case 'WEAK_PASSWORD':
          return 'auth-weak-password';
        case 'invalid-email':
        case 'INVALID_EMAIL':
          return 'auth-invalid-email';
        case 'operation-not-allowed':
        case 'OPERATION_NOT_ALLOWED':
          return 'auth-operation-not-allowed';
        case 'network-request-failed':
          return 'auth-network-error';
        case 'unknown':
          // Firebase sometimes returns 'unknown' - check message to determine actual error
          final message = e.message?.toLowerCase() ?? '';
          if (message.contains('password')) {
            // Check for any password-related issues
            if (message.contains('weak') ||
                message.contains('strong') ||
                message.contains('6') ||
                message.contains('lower case') ||
                message.contains('upper case') ||
                message.contains('character') ||
                message.contains('must contain')) {
              return 'auth-weak-password';
            }
          } else if (message.contains('email') && message.contains('already')) {
            return 'auth-email-already-in-use';
          } else if (message.contains('email') && message.contains('invalid')) {
            return 'auth-invalid-email';
          }
          debugPrint('Unknown error with message: ${e.message}');
          return 'auth-generic-error';
        default:
          debugPrint('Unhandled SignUp Firebase error code: ${e.code}');
          return 'auth-generic-error';
      }
    } catch (e) {
      debugPrint('Non-Firebase SignUp error: $e');
      return 'auth-generic-error';
    }
  }

  Future<String?> signIn({
    required String email,
    required String password,
  }) async {
    try {
      final userCredential = await _auth.signInWithEmailAndPassword(email: email, password: password);

      // Check and initialize email-based quota (persists across account deletions)
      try {
        await _quotaService.getQuotaByEmail(email);
        debugPrint('✅ Email-based quota checked for: $email');
      } catch (e) {
        debugPrint('⚠️ Error checking quota: $e');
        // Don't fail signin if quota check fails
      }

      if (userCredential.user != null) {
        await _saveOnboardingToFirestore(userCredential.user!.uid);
        await PushNotificationService().saveTokenForCurrentUser();
      }

      return null; // Success
    } on FirebaseAuthException catch (e) {
      debugPrint('FirebaseAuthException code: ${e.code}');
      debugPrint('FirebaseAuthException message: ${e.message}');
      // Return Firebase error codes for localization
      // Handle both legacy and modern Firebase error codes
      switch (e.code) {
        case 'user-not-found':
        case 'USER_NOT_FOUND':
        case 'wrong-password':
        case 'INVALID_PASSWORD':
        case 'invalid-credential':
        case 'INVALID_LOGIN_CREDENTIALS':
        case 'channel-error':
          // Security best practice: Return same error for both user-not-found and wrong-password
          // This prevents attackers from determining which emails are registered
          return 'auth-invalid-credentials';
        case 'invalid-email':
        case 'INVALID_EMAIL':
          return 'auth-invalid-email';
        case 'user-disabled':
        case 'USER_DISABLED':
          return 'auth-user-disabled';
        case 'too-many-requests':
        case 'TOO_MANY_ATTEMPTS_TRY_LATER':
          return 'auth-too-many-requests';
        case 'network-request-failed':
          return 'auth-network-error';
        case 'unknown':
          // Firebase sometimes returns 'unknown' - check message to determine actual error
          final message = e.message?.toLowerCase() ?? '';
          if (message.contains('password') &&
              (message.contains('wrong') ||
                  message.contains('incorrect') ||
                  message.contains('invalid'))) {
            return 'auth-invalid-credentials';
          } else if (message.contains('user') &&
              message.contains('not found')) {
            return 'auth-invalid-credentials';
          } else if (message.contains('email') && message.contains('invalid')) {
            return 'auth-invalid-email';
          } else if (message.contains('disabled')) {
            return 'auth-user-disabled';
          }
          debugPrint('Unknown error with message: ${e.message}');
          return 'auth-generic-error';
        default:
          debugPrint('Unhandled Firebase error code: ${e.code}');
          debugPrint('Full error: $e');
          return 'auth-generic-error';
      }
    } catch (e) {
      debugPrint('Non-Firebase error: $e');
      return 'auth-generic-error';
    }
  }

  // Get the current user (null if not signed in)
  User? get currentUser => _auth.currentUser;

  // Get user data from Firestore
  Future<Map<String, dynamic>?> getUserData() async {
    try {
      User? user = currentUser;
      if (user != null) {
        DocumentSnapshot userDoc = await _firestore
            .collection('users')
            .doc(user.uid)
            .get();
        if (userDoc.exists) {
          return userDoc.data() as Map<String, dynamic>;
        }
      }
      return null;
    } catch (e) {
      print('Error getting user data: $e');
      return null;
    }
  }

  // Update user profile data
  Future<bool> updateUserProfile({required String name}) async {
    try {
      User? user = currentUser;
      if (user != null) {
        await _firestore.collection('users').doc(user.uid).update({
          'name': name,
          'updatedAt': FieldValue.serverTimestamp(),
        });

        // Also update the Firebase Auth display name
        await user.updateDisplayName(name);
        await user.reload();

        return true;
      }
      return false;
    } catch (e) {
      print('Error updating user profile: $e');
      return false;
    }
  }

  /// Returns the auth error code (null on success) plus whether this
  /// sign-in created a brand-new account, so callers can distinguish a
  /// first-time registration from a routine login.
  Future<({String? error, bool isNewUser})> signInWithGoogle() async {
    try {
      final GoogleSignInAccount? googleUser = await _googleSignIn.signIn();
      if (googleUser == null) {
        return (error: 'auth-google-sign-in-cancelled', isNewUser: false);
      }

      final GoogleSignInAuthentication googleAuth =
          await googleUser.authentication;
      final credential = GoogleAuthProvider.credential(
        accessToken: googleAuth.accessToken,
        idToken: googleAuth.idToken,
      );

      UserCredential userCredential = await _auth.signInWithCredential(
        credential,
      );
      User? user = userCredential.user;

      if (user != null) {
        DocumentSnapshot userDoc = await _firestore
            .collection('users')
            .doc(user.uid)
            .get();

        final isNewUser = !userDoc.exists;

        if (isNewUser) {
          await _firestore.collection('users').doc(user.uid).set({
            'uid': user.uid,
            'name': user.displayName ?? 'Google User',
            'email': user.email,
            'createdAt': FieldValue.serverTimestamp(),
            'subscriptionPlan': 'FREE',
            'subscriptionStatus': 'active',
            'stripeCustomerId': null,
            'currentSubscriptionId': null,
            'techpacksUsedThisMonth': 0,
            'accountType': 'user',
            'supplierId': null,
          });
        }

        // Check and initialize email-based quota (persists across account deletions)
        if (user.email != null) {
          try {
            await _quotaService.getQuotaByEmail(user.email!);
            debugPrint(
              '✅ Email-based quota checked for Google user: ${user.email}',
            );
          } catch (e) {
            debugPrint('⚠️ Error checking quota for Google user: $e');
            // Don't fail signin if quota check fails
          }
        }

        await _saveOnboardingToFirestore(user.uid);
        await PushNotificationService().saveTokenForCurrentUser();

        return (error: null, isNewUser: isNewUser);
      } else {
        return (error: 'auth-google-sign-in-failed', isNewUser: false);
      }
    } on FirebaseAuthException catch (e) {
      debugPrint('Firebase Auth Error: ${e.code} - ${e.message}');
      // Return Firebase error codes for localization
      switch (e.code) {
        case 'user-not-found':
          return (error: 'auth-user-not-found', isNewUser: false);
        case 'user-disabled':
          return (error: 'auth-user-disabled', isNewUser: false);
        case 'network-request-failed':
          return (error: 'auth-network-error', isNewUser: false);
        default:
          return (error: 'auth-generic-error', isNewUser: false);
      }
    } catch (e) {
      debugPrint('Error during Google sign-in: $e');
      if (e.toString().contains('sign_in_failed') ||
          e.toString().contains('ApiException: 10')) {
        return (error: 'auth-google-config-error', isNewUser: false);
      }
      return (error: 'auth-google-generic-error', isNewUser: false);
    }
  }

  /// Generates a cryptographically secure random nonce
  String _generateNonce([int length = 32]) {
    const charset =
        '0123456789ABCDEFGHIJKLMNOPQRSTUVXYZabcdefghijklmnopqrstuvwxyz-._';
    final random = Random.secure();
    return List.generate(length, (_) => charset[random.nextInt(charset.length)])
        .join();
  }

  /// Returns the SHA256 hash of [input] as a hex string
  String _sha256ofString(String input) {
    final bytes = utf8.encode(input);
    final digest = sha256.convert(bytes);
    return digest.toString();
  }

  /// Returns the auth error code (null on success) plus whether this
  /// sign-in created a brand-new account, so callers can distinguish a
  /// first-time registration from a routine login.
  Future<({String? error, bool isNewUser})> signInWithApple() async {
    try {
      final rawNonce = _generateNonce();
      final nonce = _sha256ofString(rawNonce);

      final appleCredential = await SignInWithApple.getAppleIDCredential(
  scopes: [
    AppleIDAuthorizationScopes.email,
    AppleIDAuthorizationScopes.fullName,
  ],
);

final oauthCredential = OAuthProvider("apple.com").credential(
  idToken: appleCredential.identityToken,
  accessToken: appleCredential.authorizationCode,
);


      UserCredential userCredential = await _auth.signInWithCredential(
        oauthCredential,
      );
      User? user = userCredential.user;

      if (user != null) {
        // Apple only provides name on first sign-in, so we must capture it
        String displayName = user.displayName ?? '';
        if (displayName.isEmpty &&
            (appleCredential.givenName != null ||
                appleCredential.familyName != null)) {
          displayName =
              '${appleCredential.givenName ?? ''} ${appleCredential.familyName ?? ''}'
                  .trim();
          await user.updateDisplayName(displayName);
          await user.reload();
        }

        DocumentSnapshot userDoc =
            await _firestore.collection('users').doc(user.uid).get();

        final isNewUser = !userDoc.exists;

        if (isNewUser) {
          await _firestore.collection('users').doc(user.uid).set({
            'uid': user.uid,
            'name': displayName.isNotEmpty ? displayName : 'Apple User',
            'email': user.email ?? appleCredential.email,
            'createdAt': FieldValue.serverTimestamp(),
            'subscriptionPlan': 'FREE',
            'subscriptionStatus': 'active',
            'stripeCustomerId': null,
            'currentSubscriptionId': null,
            'techpacksUsedThisMonth': 0,
            'accountType': 'user',
            'supplierId': null,
          });
        }

        // Check and initialize email-based quota
        final email = user.email ?? appleCredential.email;
        if (email != null) {
          try {
            await _quotaService.getQuotaByEmail(email);
            debugPrint(
              '✅ Email-based quota checked for Apple user: $email',
            );
          } catch (e) {
            debugPrint('⚠️ Error checking quota for Apple user: $e');
          }
        }

        await _saveOnboardingToFirestore(user.uid);
        await PushNotificationService().saveTokenForCurrentUser();

        return (error: null, isNewUser: isNewUser); // Success
      } else {
        return (error: 'auth-apple-sign-in-failed', isNewUser: false);
      }
    } on SignInWithAppleAuthorizationException catch (e) {
      debugPrint('Apple Sign In Authorization Error: ${e.code} - ${e.message}');
      if (e.code == AuthorizationErrorCode.canceled) {
        return (error: 'auth-apple-sign-in-cancelled', isNewUser: false);
      }
      return (error: 'auth-apple-sign-in-failed', isNewUser: false);
    } on FirebaseAuthException catch (e) {
      debugPrint('Firebase Auth Error: ${e.code} - ${e.message}');
      switch (e.code) {
        case 'user-disabled':
          return (error: 'auth-user-disabled', isNewUser: false);
        case 'network-request-failed':
          return (error: 'auth-network-error', isNewUser: false);
        default:
          return (error: 'auth-generic-error', isNewUser: false);
      }
    } catch (e) {
      debugPrint('Error during Apple sign-in: $e');
      return (error: 'auth-apple-sign-in-failed', isNewUser: false);
    }
  }

  // Sign out the current user
  Future<void> signOut() async {
    await _auth.signOut();
    await _googleSignIn.signOut();
  }

  // ==================== ACCOUNT DELETION ====================

  /// Delete user account with re-authentication
  /// For email/password users
  Future<String?> deleteAccountWithPassword(String password) async {
    try {
      final deleteService = DeleteAccountService();

      // Step 1: Re-authenticate user
      final reauthSuccess = await deleteService.reauthenticateWithPassword(
        password,
      );

      if (!reauthSuccess) {
        return 'auth-reauthentication-failed';
      }

      // Step 2: Delete all user data
      await deleteService.deleteUserAccount();

      // Step 3: Sign out from Google Sign-In if applicable
      await _googleSignIn.signOut();

      return null; // Success
    } on FirebaseAuthException catch (e) {
      debugPrint(
        'Firebase Auth Error during deletion: ${e.code} - ${e.message}',
      );

      switch (e.code) {
        case 'wrong-password':
        case 'invalid-credential':
          return 'auth-wrong-password';
        case 'requires-recent-login':
          return 'auth-requires-recent-login';
        case 'user-not-found':
          return 'auth-user-not-found';
        case 'network-request-failed':
          return 'auth-network-error';
        default:
          return 'auth-delete-account-failed';
      }
    } catch (e) {
      debugPrint('Error during account deletion: $e');
      return 'auth-delete-account-failed';
    }
  }

  /// Delete user account for Google sign-in users
  Future<String?> deleteAccountWithGoogle() async {
    try {
      final deleteService = DeleteAccountService();

      // Step 1: Re-authenticate with Google
      final GoogleSignInAccount? googleUser = await _googleSignIn.signIn();
      if (googleUser == null) {
        return 'auth-google-reauthentication-cancelled';
      }

      final GoogleSignInAuthentication googleAuth =
          await googleUser.authentication;
      final credential = GoogleAuthProvider.credential(
        accessToken: googleAuth.accessToken,
        idToken: googleAuth.idToken,
      );

      // Re-authenticate the user
      final user = _auth.currentUser;
      if (user == null) {
        return 'auth-user-not-found';
      }

      await user.reauthenticateWithCredential(credential);

      // Step 2: Delete all user data
      await deleteService.deleteUserAccount();

      // Step 3: Sign out from Google Sign-In
      await _googleSignIn.signOut();

      return null; // Success
    } on FirebaseAuthException catch (e) {
      debugPrint(
        'Firebase Auth Error during Google account deletion: ${e.code} - ${e.message}',
      );

      switch (e.code) {
        case 'requires-recent-login':
          return 'auth-requires-recent-login';
        case 'user-not-found':
          return 'auth-user-not-found';
        case 'network-request-failed':
          return 'auth-network-error';
        default:
          return 'auth-delete-account-failed';
      }
    } catch (e) {
      debugPrint('Error during Google account deletion: $e');
      return 'auth-delete-account-failed';
    }
  }

  /// Delete user account for Apple sign-in users
  Future<String?> deleteAccountWithApple() async {
    try {
      final deleteService = DeleteAccountService();

      // Step 1: Re-authenticate with Apple
      final rawNonce = _generateNonce();
      final nonce = _sha256ofString(rawNonce);

      final appleCredential = await SignInWithApple.getAppleIDCredential(
        scopes: [
          AppleIDAuthorizationScopes.email,
          AppleIDAuthorizationScopes.fullName,
        ],
        nonce: nonce,
      );

      final oauthCredential = OAuthProvider('apple.com').credential(
        idToken: appleCredential.identityToken,
        rawNonce: rawNonce,
      );

      // Re-authenticate the user
      final user = _auth.currentUser;
      if (user == null) {
        return 'auth-user-not-found';
      }

      await user.reauthenticateWithCredential(oauthCredential);

      // Step 2: Delete all user data
      await deleteService.deleteUserAccount();

      return null; // Success
    } on SignInWithAppleAuthorizationException catch (e) {
      debugPrint(
        'Apple re-auth error: ${e.code} - ${e.message}',
      );
      if (e.code == AuthorizationErrorCode.canceled) {
        return 'auth-apple-reauthentication-cancelled';
      }
      return 'auth-delete-account-failed';
    } on FirebaseAuthException catch (e) {
      debugPrint(
        'Firebase Auth Error during Apple account deletion: ${e.code} - ${e.message}',
      );

      switch (e.code) {
        case 'requires-recent-login':
          return 'auth-requires-recent-login';
        case 'user-not-found':
          return 'auth-user-not-found';
        case 'network-request-failed':
          return 'auth-network-error';
        default:
          return 'auth-delete-account-failed';
      }
    } catch (e) {
      debugPrint('Error during Apple account deletion: $e');
      return 'auth-delete-account-failed';
    }
  }

  // Reads onboarding selections from SharedPreferences and writes them to the
  // user's Firestore document. Always uses update() so it works for both new
  // and returning users (overwriting any previous onboarding data). Clears
  // SharedPreferences afterwards so stale data is never re-sent.
  Future<void> _saveOnboardingToFirestore(String uid) async {
    try {
      final onboardingData = await OnboardingStorageService().getOnboardingData();
      if (onboardingData == null) return;

      await _firestore.collection('users').doc(uid).update(onboardingData);
      await OnboardingStorageService().clearOnboardingData();
      debugPrint('✅ Onboarding data saved to Firestore for: $uid');
    } catch (e) {
      debugPrint('⚠️ Error saving onboarding data to Firestore: $e');
      // Never fail auth because of this
    }
  }

  /// Check if current user signed in with Google
  bool isGoogleUser() {
    final user = _auth.currentUser;
    if (user == null) return false;

    return user.providerData.any(
      (provider) => provider.providerId == 'google.com',
    );
  }

  /// Check if current user signed in with Apple
  bool isAppleUser() {
    final user = _auth.currentUser;
    if (user == null) return false;

    return user.providerData.any(
      (provider) => provider.providerId == 'apple.com',
    );
  }
}
