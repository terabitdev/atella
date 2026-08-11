import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:atella/Data/Models/supplier_model.dart';
import 'package:atella/Data/Models/supplier_submission_model.dart';

/// User-facing actions: browsing active suppliers and sending a tech pack
/// to one of them.
class SupplierSubmissionService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;

  Stream<List<SupplierModel>> streamActiveSuppliers() {
    return _firestore
        .collection('suppliers')
        .where('status', isEqualTo: 'active')
        .orderBy('companyName')
        .snapshots()
        .map((snap) => snap.docs.map((d) => SupplierModel.fromFirestore(d)).toList());
  }

  Future<SupplierModel?> getSupplier(String supplierId) async {
    final doc = await _firestore.collection('suppliers').doc(supplierId).get();
    if (!doc.exists) return null;
    return SupplierModel.fromFirestore(doc);
  }

  Future<String> sendTechPackToSupplier({
    required String supplierId,
    required String techPackId,
    String? techPackProjectName,
    String? techPackImageUrl,
  }) async {
    final uid = _auth.currentUser?.uid;
    if (uid == null) throw Exception('Not signed in');

    final submission = SupplierSubmissionModel(
      id: '',
      techPackId: techPackId,
      techPackProjectName: techPackProjectName,
      techPackImageUrl: techPackImageUrl,
      userUid: uid,
      supplierId: supplierId,
      status: 'sent',
    );

    final doc = await _firestore.collection('supplierSubmissions').add(submission.toFirestore());
    return doc.id;
  }

  Stream<List<SupplierSubmissionModel>> streamSubmissionsForSupplier(String supplierId, {int limit = 5}) {
    return _firestore
        .collection('supplierSubmissions')
        .where('supplierId', isEqualTo: supplierId)
        .orderBy('createdAt', descending: true)
        .limit(limit)
        .snapshots()
        .map((snap) => snap.docs.map((d) => SupplierSubmissionModel.fromFirestore(d)).toList());
  }
}
