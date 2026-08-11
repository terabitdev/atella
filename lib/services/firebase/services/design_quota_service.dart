import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

/// Service to manage email-based design quota tracking
/// This collection persists even when user accounts are deleted
/// to prevent abuse of free design limits
class DesignQuotaService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;

  /// Collection name for quota tracking
  static const String _quotaCollection = 'design_quotas';

  /// Default monthly limit for free designs
  static const int _defaultMonthlyLimit = 1;

  /// Get or create quota document for an email
  /// Returns the quota data including:
  /// - designsUsed: number of designs generated this month
  /// - monthlyLimit: maximum allowed designs per month
  /// - resetDate: timestamp for next monthly reset
  Future<Map<String, dynamic>> getQuotaByEmail(String email) async {
    try {
      // Normalize email to lowercase for consistent lookup
      final normalizedEmail = email.toLowerCase().trim();
      print('🔍 Getting quota for: $normalizedEmail');

      final docRef = _firestore.collection(_quotaCollection).doc(normalizedEmail);
      final snapshot = await docRef.get();

      if (snapshot.exists) {
        print('✅ Found existing quota document');
        final data = snapshot.data()!;

        // Check if monthly reset is needed
        final resetDate = (data['resetDate'] as Timestamp).toDate();
        final now = DateTime.now();

        if (now.isAfter(resetDate)) {
          print('🔄 Monthly reset needed');
          // Reset needed - update document
          await _performMonthlyReset(normalizedEmail);
          // Fetch updated data
          final updatedSnapshot = await docRef.get();
          return updatedSnapshot.data()!;
        }

        return data;
      } else {
        print('📝 Creating new quota document for first-time user');
        // First time user - create new quota document
        final quotaData = await _createQuotaDocument(normalizedEmail);
        print('✅ New quota document created: $quotaData');
        return quotaData;
      }
    } catch (e) {
      print('❌ Error getting quota for email: $e');
      rethrow;
    }
  }

  /// Create a new quota document for a new email
  Future<Map<String, dynamic>> _createQuotaDocument(String email) async {
    final now = DateTime.now();
    final nextResetDate = DateTime(now.year, now.month + 1, 1); // First day of next month

    final quotaData = {
      'email': email,
      'designsUsed': 0,
      'monthlyLimit': _defaultMonthlyLimit,
      'resetDate': Timestamp.fromDate(nextResetDate),
      'createdAt': FieldValue.serverTimestamp(),
      'lastUpdated': FieldValue.serverTimestamp(),
    };

    await _firestore.collection(_quotaCollection).doc(email).set(quotaData);
    print('✅ Created new quota document for: $email');

    // Return with actual timestamp for resetDate
    return {
      ...quotaData,
      'resetDate': Timestamp.fromDate(nextResetDate),
      'createdAt': Timestamp.now(),
      'lastUpdated': Timestamp.now(),
    };
  }

  /// Perform monthly reset for a quota document
  Future<void> _performMonthlyReset(String email) async {
    final now = DateTime.now();
    final nextResetDate = DateTime(now.year, now.month + 1, 1);

    await _firestore.collection(_quotaCollection).doc(email).update({
      'designsUsed': 0,
      'resetDate': Timestamp.fromDate(nextResetDate),
      'lastUpdated': FieldValue.serverTimestamp(),
    });

    print('✅ Performed monthly reset for: $email');
  }

  /// Check if user has remaining quota
  /// Returns true if user can generate more designs
  Future<bool> hasRemainingQuota(String email) async {
    try {
      final quota = await getQuotaByEmail(email);
      final designsUsed = quota['designsUsed'] as int;
      final monthlyLimit = quota['monthlyLimit'] as int;

      return designsUsed < monthlyLimit;
    } catch (e) {
      print('❌ Error checking remaining quota: $e');
      return false;
    }
  }

  /// Get remaining designs count
  Future<int> getRemainingDesigns(String email) async {
    try {
      final quota = await getQuotaByEmail(email);
      final designsUsed = quota['designsUsed'] as int;
      final monthlyLimit = quota['monthlyLimit'] as int;

      final remaining = monthlyLimit - designsUsed;
      return remaining > 0 ? remaining : 0;
    } catch (e) {
      print('❌ Error getting remaining designs: $e');
      return 0;
    }
  }

  /// Increment the design usage counter
  /// Should be called after successful design generation
  Future<bool> incrementDesignUsage(String email) async {
    try {
      final normalizedEmail = email.toLowerCase().trim();
      print('🔄 Starting increment for: $normalizedEmail');

      // First ensure quota document exists and is up to date
      final quotaBefore = await getQuotaByEmail(normalizedEmail);
      print('📊 Quota before increment: ${quotaBefore['designsUsed']}/${quotaBefore['monthlyLimit']}');

      // Increment the counter
      await _firestore.collection(_quotaCollection).doc(normalizedEmail).update({
        'designsUsed': FieldValue.increment(1),
        'lastUpdated': FieldValue.serverTimestamp(),
      });

      print('✅ Incremented design usage for: $normalizedEmail');

      // Verify the increment worked
      final quotaAfter = await _firestore.collection(_quotaCollection).doc(normalizedEmail).get();
      if (quotaAfter.exists) {
        final data = quotaAfter.data()!;
        print('📊 Quota after increment: ${data['designsUsed']}/${data['monthlyLimit']}');
      }

      return true;
    } catch (e) {
      print('❌ Error incrementing design usage: $e');
      print('❌ Error stack trace: ${StackTrace.current}');
      rethrow; // Rethrow to see the error in the controller
    }
  }

  /// Live quota stream for the current authenticated user — used anywhere
  /// the UI displays remaining designs, so it can never show a stale
  /// snapshot from before a generation elsewhere incremented `designsUsed`.
  /// Ensures the quota document exists (and performs the monthly reset check
  /// `getQuotaByEmail` already does) before subscribing to live updates.
  Stream<Map<String, dynamic>?> streamCurrentUserQuota() async* {
    final user = _auth.currentUser;
    if (user == null || user.email == null) {
      yield null;
      return;
    }

    final normalizedEmail = user.email!.toLowerCase().trim();
    await getQuotaByEmail(normalizedEmail); // creates doc / performs reset if needed

    yield* _firestore
        .collection(_quotaCollection)
        .doc(normalizedEmail)
        .snapshots()
        .map((snap) => snap.data());
  }

  /// Get quota info for current authenticated user
  Future<Map<String, dynamic>?> getCurrentUserQuota() async {
    try {
      final user = _auth.currentUser;
      if (user == null || user.email == null) {
        print('⚠️ No authenticated user found');
        return null;
      }

      return await getQuotaByEmail(user.email!);
    } catch (e) {
      print('❌ Error getting current user quota: $e');
      return null;
    }
  }

  /// Check if current user can generate designs
  Future<bool> canCurrentUserGenerateDesign() async {
    try {
      final user = _auth.currentUser;
      if (user == null || user.email == null) {
        return false;
      }

      return await hasRemainingQuota(user.email!);
    } catch (e) {
      print('❌ Error checking if user can generate design: $e');
      return false;
    }
  }

  /// Get detailed quota status for display in UI
  Future<Map<String, dynamic>> getQuotaStatus(String email) async {
    try {
      final quota = await getQuotaByEmail(email);
      final designsUsed = quota['designsUsed'] as int;
      final monthlyLimit = quota['monthlyLimit'] as int;
      final resetDate = (quota['resetDate'] as Timestamp).toDate();

      final remaining = monthlyLimit - designsUsed;

      return {
        'designsUsed': designsUsed,
        'monthlyLimit': monthlyLimit,
        'remaining': remaining > 0 ? remaining : 0,
        'resetDate': resetDate,
        'hasQuota': remaining > 0,
      };
    } catch (e) {
      print('❌ Error getting quota status: $e');
      return {
        'designsUsed': 0,
        'monthlyLimit': _defaultMonthlyLimit,
        'remaining': _defaultMonthlyLimit,
        'resetDate': DateTime.now(),
        'hasQuota': true,
      };
    }
  }

  /// Manual reset (admin function - use with caution)
  Future<void> manualResetQuota(String email) async {
    try {
      final normalizedEmail = email.toLowerCase().trim();
      await _performMonthlyReset(normalizedEmail);
      print('✅ Manual reset completed for: $normalizedEmail');
    } catch (e) {
      print('❌ Error performing manual reset: $e');
      rethrow;
    }
  }

  /// Get all quota documents (admin function for debugging)
  Future<List<Map<String, dynamic>>> getAllQuotas() async {
    try {
      final snapshot = await _firestore.collection(_quotaCollection).get();
      return snapshot.docs.map((doc) => doc.data()).toList();
    } catch (e) {
      print('❌ Error getting all quotas: $e');
      return [];
    }
  }
}
