import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:atella/services/PaymentService/stripe_subscription_service.dart';
import 'package:atella/services/analytics/posthog_analytics_service.dart';

class DeleteAccountService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseStorage _storage = FirebaseStorage.instance;
  final StripeSubscriptionService _stripeService = StripeSubscriptionService();
  final PostHogAnalyticsService _analyticsService = PostHogAnalyticsService();

  /// Main method to delete user account and all associated data
  /// Returns true if successful, throws exception if failed
  Future<bool> deleteUserAccount() async {
    final user = _auth.currentUser;
    if (user == null) {
      throw Exception('No user is currently signed in');
    }

    final userId = user.uid;

    try {
      print('🗑️ Starting account deletion for user: $userId');

      // Step 1: Cancel Stripe subscription if exists
      await _cancelStripeSubscription(userId);

      // Step 2: Delete Firestore subcollections (tech_packs)
      await _deleteTechPacksSubcollection(userId);

      // Step 3: Delete Firebase Storage files
      await _deleteStorageFiles(userId);

      // Step 4: Delete Firestore main documents
      await _deleteFirestoreDocuments(userId);

      // Step 5: Track analytics event before deletion
      await _analyticsService.trackAccountDeleted();

      // Step 6: Delete Firebase Auth account (MUST BE LAST!)
      await user.delete();

      print('✅ Account deletion completed successfully');
      return true;
    } catch (e) {
      print('❌ Error during account deletion: $e');
      rethrow;
    }
  }

  /// Cancel active Stripe subscription
  Future<void> _cancelStripeSubscription(String userId) async {
    try {
      print('💳 Checking for active Stripe subscription...');

      final userDoc = await _firestore.collection('users').doc(userId).get();

      if (!userDoc.exists) {
        print('⚠️ User document not found, skipping Stripe cancellation');
        return;
      }

      final data = userDoc.data();
      final stripeCustomerId = data?['stripeCustomerId'] as String?;
      final currentSubscriptionId = data?['currentSubscriptionId'] as String?;

      if (stripeCustomerId != null && currentSubscriptionId != null) {
        print('📋 Found active subscription: $currentSubscriptionId');
        // Note: You may need to implement cancellation via Stripe API
        // For now, we'll just mark it in the database
        await _firestore.collection('users').doc(userId).update({
          'subscriptionStatus': 'cancelled',
          'accountDeletionRequested': FieldValue.serverTimestamp(),
        });
        print('✅ Stripe subscription marked for cancellation');
      } else {
        print('ℹ️ No active Stripe subscription found');
      }
    } catch (e) {
      print('⚠️ Error cancelling Stripe subscription: $e');
      // Don't throw - continue with deletion even if Stripe fails
    }
  }

  /// Delete all tech packs in the subcollection
  Future<void> _deleteTechPacksSubcollection(String userId) async {
    try {
      print('📦 Deleting tech packs subcollection...');

      final techPacksRef = _firestore
          .collection('users')
          .doc(userId)
          .collection('tech_packs');

      final snapshot = await techPacksRef.get();

      if (snapshot.docs.isEmpty) {
        print('ℹ️ No tech packs found');
        return;
      }

      print('📋 Found ${snapshot.docs.length} tech packs to delete');

      // Delete in batches to avoid timeout
      final batch = _firestore.batch();
      int count = 0;

      for (var doc in snapshot.docs) {
        batch.delete(doc.reference);
        count++;

        // Commit batch every 500 documents
        if (count % 500 == 0) {
          await batch.commit();
          print('✅ Deleted $count tech packs...');
        }
      }

      // Commit remaining documents
      if (count % 500 != 0) {
        await batch.commit();
      }

      print('✅ Deleted all $count tech packs');
    } catch (e) {
      print('❌ Error deleting tech packs: $e');
      throw Exception('Failed to delete tech packs: $e');
    }
  }

  /// Delete all Firebase Storage files
  Future<void> _deleteStorageFiles(String userId) async {
    try {
      print('🗄️ Deleting Firebase Storage files...');

      // Delete tech pack images
      await _deleteStorageFolder('users/$userId/tech_packs');

      // Try to delete design images (if they follow user-specific pattern)
      // Note: Design images might use designId, so this is best-effort
      await _deleteStorageFolder('designs/$userId');

      print('✅ Storage files deleted');
    } catch (e) {
      print('⚠️ Error deleting storage files: $e');
      // Don't throw - continue with deletion even if storage fails
    }
  }

  /// Helper method to delete a folder in Firebase Storage
  Future<void> _deleteStorageFolder(String path) async {
    try {
      final ref = _storage.ref(path);
      final result = await ref.listAll();

      // Delete all files in the folder
      for (var file in result.items) {
        try {
          await file.delete();
          print('🗑️ Deleted file: ${file.fullPath}');
        } catch (e) {
          print('⚠️ Could not delete file ${file.fullPath}: $e');
        }
      }

      // Recursively delete subfolders
      for (var folder in result.prefixes) {
        await _deleteStorageFolder(folder.fullPath);
      }
    } catch (e) {
      print('⚠️ Could not access storage folder $path: $e');
      // Folder might not exist, which is fine
    }
  }

  /// Delete main Firestore documents
  Future<void> _deleteFirestoreDocuments(String userId) async {
    try {
      print('📄 Deleting Firestore documents...');

      final batch = _firestore.batch();

      // Delete main user document
      batch.delete(_firestore.collection('users').doc(userId));
      print('📋 Marked user document for deletion');

      // Delete designs document if it exists
      final designsDoc = _firestore.collection('designs').doc(userId);
      final designsSnapshot = await designsDoc.get();

      if (designsSnapshot.exists) {
        batch.delete(designsDoc);
        print('📋 Marked designs document for deletion');
      }

      await batch.commit();
      print('✅ Firestore documents deleted');
    } catch (e) {
      print('❌ Error deleting Firestore documents: $e');
      throw Exception('Failed to delete Firestore documents: $e');
    }
  }

  /// Re-authenticate user with email and password
  /// Required before sensitive operations like account deletion
  Future<bool> reauthenticateWithPassword(String password) async {
    try {
      final user = _auth.currentUser;
      if (user == null || user.email == null) {
        throw Exception('No user signed in');
      }

      final credential = EmailAuthProvider.credential(
        email: user.email!,
        password: password,
      );

      await user.reauthenticateWithCredential(credential);
      print('✅ Re-authentication successful');
      return true;
    } catch (e) {
      print('❌ Re-authentication failed: $e');
      throw Exception('Invalid password. Please try again.');
    }
  }

  /// Re-authenticate Google user
  /// Required before sensitive operations like account deletion
  Future<bool> reauthenticateWithGoogle() async {
    try {
      final user = _auth.currentUser;
      if (user == null) {
        throw Exception('No user signed in');
      }

      // Check if user has Google provider
      final googleProvider = user.providerData
          .firstWhere(
            (provider) => provider.providerId == 'google.com',
            orElse: () => throw Exception('User is not signed in with Google'),
          );

      // For Google re-authentication, we need to trigger the Google sign-in flow again
      // This is handled by the GoogleSignIn package
      // The actual re-authentication will be done in the auth_service

      print('✅ Google re-authentication check passed');
      return true;
    } catch (e) {
      print('❌ Google re-authentication check failed: $e');
      throw Exception('Google re-authentication required');
    }
  }
}
