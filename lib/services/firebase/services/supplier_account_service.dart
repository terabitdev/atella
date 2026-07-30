import 'dart:io';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:cloud_functions/cloud_functions.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:atella/Data/Models/supplier_model.dart';

/// Actions available to a logged-in supplier: reading/editing their own
/// profile and driving Stripe Connect Express onboarding.
class SupplierAccountService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseStorage _storage = FirebaseStorage.instance;
  final FirebaseFunctions _functions = FirebaseFunctions.instance;

  Future<String?> get mySupplierId async {
    final uid = _auth.currentUser?.uid;
    if (uid == null) return null;
    final userDoc = await _firestore.collection('users').doc(uid).get();
    return userDoc.data()?['supplierId'] as String?;
  }

  Stream<SupplierModel?> streamSupplier(String supplierId) {
    return _firestore
        .collection('suppliers')
        .doc(supplierId)
        .snapshots()
        .map((doc) => doc.exists ? SupplierModel.fromFirestore(doc) : null);
  }

  Future<void> updateProfile(
    String supplierId, {
    String? companyName,
    String? specialty,
    String? originCountry,
    String? description,
    String? logoUrl,
  }) async {
    final updates = <String, dynamic>{};
    if (companyName != null) updates['companyName'] = companyName;
    if (specialty != null) updates['specialty'] = specialty;
    if (originCountry != null) updates['originCountry'] = originCountry;
    if (description != null) updates['description'] = description;
    if (logoUrl != null) updates['logoUrl'] = logoUrl;
    if (updates.isEmpty) return;

    await _firestore.collection('suppliers').doc(supplierId).update(updates);
  }

  Future<String> uploadLogo(String supplierId, String localPath) async {
    final file = File(localPath);
    final ref = _storage.ref('supplier_logos/$supplierId/logo.jpg');
    final uploadTask = await ref.putFile(
      file,
      SettableMetadata(contentType: 'image/jpeg'),
    );
    return uploadTask.ref.getDownloadURL();
  }

  Future<String> createConnectOnboardingLink() async {
    final callable = _functions.httpsCallable('createConnectOnboardingLink');
    final result = await callable.call();
    return (result.data as Map)['url'] as String;
  }
}
