import 'package:cloud_functions/cloud_functions.dart';
import 'package:firebase_auth/firebase_auth.dart';

/// Handles the invite-only supplier signup flow: validating an invite token
/// before an account exists, then creating the Firebase Auth account and
/// claiming the invite once it does.
class SupplierAuthService {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFunctions _functions = FirebaseFunctions.instance;

  /// Returns {email, supplierId, companyName} for a valid, unexpired,
  /// still-pending invite. Throws a [FirebaseFunctionsException] otherwise.
  Future<Map<String, dynamic>> validateInvite(String token) async {
    final callable = _functions.httpsCallable('validateSupplierInvite');
    final result = await callable.call({'token': token});
    return Map<String, dynamic>.from(result.data as Map);
  }

  /// Creates the Firebase Auth account for the invited email, claims the
  /// invite (grants the `supplier` custom claim server-side), then forces a
  /// fresh ID token so the claim is active in this session immediately.
  Future<String?> signUpAndAcceptInvite({
    required String email,
    required String password,
    required String token,
  }) async {
    try {
      final credential = await _auth.createUserWithEmailAndPassword(
        email: email,
        password: password,
      );
      final user = credential.user;
      if (user == null) return 'auth-user-creation-failed';

      final callable = _functions.httpsCallable('acceptSupplierInvite');
      await callable.call({'token': token});

      // Custom claims only take effect on a freshly-issued token.
      await user.getIdTokenResult(true);

      return null; // Success
    } on FirebaseAuthException catch (e) {
      switch (e.code) {
        case 'email-already-in-use':
          return 'auth-email-already-in-use';
        case 'weak-password':
          return 'auth-weak-password';
        case 'invalid-email':
          return 'auth-invalid-email';
        default:
          return e.message ?? 'auth-unknown-error';
      }
    } on FirebaseFunctionsException catch (e) {
      // Roll back the just-created Auth account so the invite can be retried
      // cleanly instead of leaving an orphaned, claim-less account behind.
      await _auth.currentUser?.delete();
      return e.message ?? e.code;
    }
  }
}
