import 'dart:io';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:cloud_functions/cloud_functions.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:atella/Data/Models/supplier_model.dart';

/// Admin-only actions: creating a supplier profile + invite, and managing
/// invites already sent. Every mutation goes through a callable Cloud
/// Function (Admin SDK) — this service never writes to `suppliers` or
/// `supplierInvites` directly.
class SupplierAdminService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseStorage _storage = FirebaseStorage.instance;
  final FirebaseFunctions _functions = FirebaseFunctions.instance;

  /// Uploads a locally-picked logo image and returns its download URL.
  /// Path is keyed by a client-generated id since the supplier doc doesn't
  /// exist yet at pick-time; Cloud Functions stores this URL on the doc.
  Future<String> uploadSupplierLogo(String localPath) async {
    final file = File(localPath);
    final fileName = 'logo_${DateTime.now().millisecondsSinceEpoch}.jpg';
    final tempId = DateTime.now().millisecondsSinceEpoch.toString();
    final ref = _storage.ref('supplier_logos/pending_$tempId/$fileName');
    final uploadTask = await ref.putFile(
      file,
      SettableMetadata(contentType: 'image/jpeg'),
    );
    return uploadTask.ref.getDownloadURL();
  }

  Future<Map<String, dynamic>> createSupplierInvite({
    required String companyName,
    required String email,
    String? specialty,
    String? originCountry,
    String? description,
    String? logoUrl,
  }) async {
    final callable = _functions.httpsCallable('createSupplierInvite');
    final result = await callable.call({
      'companyName': companyName,
      'email': email,
      'specialty': specialty,
      'originCountry': originCountry,
      'description': description,
      'logoUrl': logoUrl,
    });
    return Map<String, dynamic>.from(result.data as Map);
  }

  Future<void> revokeSupplierInvite(String inviteId) async {
    final callable = _functions.httpsCallable('revokeSupplierInvite');
    await callable.call({'inviteId': inviteId});
  }

  Stream<List<SupplierInviteModel>> streamInvites() {
    return _firestore
        .collection('supplierInvites')
        .orderBy('createdAt', descending: true)
        .limit(50)
        .snapshots()
        .map((snap) =>
            snap.docs.map((d) => SupplierInviteModel.fromFirestore(d)).toList());
  }

  Future<SupplierModel?> getSupplier(String supplierId) async {
    final doc = await _firestore.collection('suppliers').doc(supplierId).get();
    if (!doc.exists) return null;
    return SupplierModel.fromFirestore(doc);
  }
}
