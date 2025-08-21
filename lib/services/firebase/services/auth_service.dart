
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
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
  // Get the current user (null if not signed in)
  User? get currentUser => _auth.currentUser;

  Future<String?> signInWithGoogle() async {
    try {
      final GoogleSignInAccount? googleUser = await _googleSignIn.signIn();
      if (googleUser == null) {
        return 'Google sign-in was cancelled';
      }

      final GoogleSignInAuthentication googleAuth = await googleUser.authentication;
      final credential = GoogleAuthProvider.credential(
        accessToken: googleAuth.accessToken,
        idToken: googleAuth.idToken,
      );

      UserCredential userCredential = await _auth.signInWithCredential(credential);
      User? user = userCredential.user;

      if (user != null) {
        DocumentSnapshot userDoc = await _firestore.collection('users').doc(user.uid).get();
        
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
        return 'Google sign-in failed';
      }
    } on FirebaseAuthException catch (e) {
      return e.message;
    } catch (e) {
      return 'An error occurred during Google sign-in';
    }
  }

  // Sign out the current user
  Future<void> signOut() async {
    await _auth.signOut();
    await _googleSignIn.signOut();
  }
}
