import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/foundation.dart';
import 'package:google_sign_in/google_sign_in.dart';

class AuthService {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final GoogleSignIn _googleSignIn = GoogleSignIn();

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
        });
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
      await _auth.signInWithEmailAndPassword(email: email, password: password);
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
          if (message.contains('password') && (message.contains('wrong') || message.contains('incorrect') || message.contains('invalid'))) {
            return 'auth-invalid-credentials';
          } else if (message.contains('user') && message.contains('not found')) {
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

  Future<String?> signInWithGoogle() async {
    try {
      final GoogleSignInAccount? googleUser = await _googleSignIn.signIn();
      if (googleUser == null) {
        return 'auth-google-sign-in-cancelled';
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

        if (!userDoc.exists) {
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
          });
        }
        return null;
      } else {
        return 'auth-google-sign-in-failed';
      }
    } on FirebaseAuthException catch (e) {
      debugPrint('Firebase Auth Error: ${e.code} - ${e.message}');
      // Return Firebase error codes for localization
      switch (e.code) {
        case 'user-not-found':
          return 'auth-user-not-found';
        case 'user-disabled':
          return 'auth-user-disabled';
        case 'network-request-failed':
          return 'auth-network-error';
        default:
          return 'auth-generic-error';
      }
    } catch (e) {
      debugPrint('Error during Google sign-in: $e');
      if (e.toString().contains('sign_in_failed') || e.toString().contains('ApiException: 10')) {
        return 'auth-google-config-error';
      }
      return 'auth-google-generic-error';
    }
  }

  // Sign out the current user
  Future<void> signOut() async {
    await _auth.signOut();
    await _googleSignIn.signOut();
  }
}
