
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:google_sign_in/google_sign_in.dart';

class AuthService {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

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
        return 'User creation failed';
      }
    } on FirebaseAuthException catch (e) {
      return e.message;
    } catch (e) {
      return 'An error occurred';
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
      if (e.code == 'user-not-found') {
        return 'No user found for that email.';
      } else if (e.code == 'wrong-password') {
        return 'Incorrect password.';
      }
      return e.message;
    } catch (e) {
      return 'An error occurred';
    }
  }

  // Sign in with Google
  Future<String?> signInWithGoogle() async {
    try {
      // Trigger the Google Sign-In flow
      final GoogleSignInAccount? googleUser = await GoogleSignIn().signIn();
      
      // User cancelled the sign-in
      if (googleUser == null) {
        return 'Google sign-in was cancelled';
      }

      final GoogleSignInAuthentication? googleAuth = await googleUser.authentication;

      if (googleAuth?.idToken != null && googleAuth?.accessToken != null) {
        // Create a new credential
        final credential = GoogleAuthProvider.credential(
          idToken: googleAuth?.idToken,
          accessToken: googleAuth?.accessToken,
        );

        // Sign in with the credential
        UserCredential userCredential = await _auth.signInWithCredential(credential);
        User? user = userCredential.user;
        
        if (user != null) {
          // Check if user already exists
          DocumentSnapshot userDoc = await _firestore.collection('users').doc(user.uid).get();
          
          if (!userDoc.exists) {
            // Create new user document with subscription info
            await _firestore.collection('users').doc(user.uid).set({
              'uid': user.uid,
              'name': user.displayName ?? '',
              'email': user.email ?? '',
              'createdAt': FieldValue.serverTimestamp(),
              'subscriptionPlan': 'FREE',
              'subscriptionStatus': 'active',
              'stripeCustomerId': null,
              'currentSubscriptionId': null,
              'techpacksUsedThisMonth': 0,
            });
          }
        }
        
        return null; // Success
      } else {
        return 'Failed to get Google authentication tokens';
      }
    } on FirebaseAuthException catch (e) {
      return 'Firebase Auth Error: ${e.message}';
    } catch (e) {
      return 'Google sign-in error: ${e.toString()}';
    }
  }

  // Get the current user (null if not signed in)
  User? get currentUser => _auth.currentUser;

  // Sign out the current user
  Future<void> signOut() async {
    await _auth.signOut();
  }
}
