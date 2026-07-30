import 'package:cloud_firestore/cloud_firestore.dart';

/// A user sending a tech pack to a supplier — the anchor record that later
/// messaging (Section 5) and orders (Section 6/7) attach to.
class SupplierSubmissionModel {
  final String id;
  final String techPackId;
  final String? techPackProjectName;
  final String? techPackImageUrl;
  final String userUid;
  final String supplierId;
  final String status; // sent | viewed | in_discussion | sample_order_created | closed
  final DateTime? createdAt;

  SupplierSubmissionModel({
    required this.id,
    required this.techPackId,
    this.techPackProjectName,
    this.techPackImageUrl,
    required this.userUid,
    required this.supplierId,
    required this.status,
    this.createdAt,
  });

  factory SupplierSubmissionModel.fromFirestore(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>? ?? {};
    return SupplierSubmissionModel(
      id: doc.id,
      techPackId: data['techPackId'] ?? '',
      techPackProjectName: data['techPackProjectName'],
      techPackImageUrl: data['techPackImageUrl'],
      userUid: data['userUid'] ?? '',
      supplierId: data['supplierId'] ?? '',
      status: data['status'] ?? 'sent',
      createdAt: (data['createdAt'] as Timestamp?)?.toDate(),
    );
  }

  Map<String, dynamic> toFirestore() {
    return {
      'techPackId': techPackId,
      'techPackProjectName': techPackProjectName,
      'techPackImageUrl': techPackImageUrl,
      'userUid': userUid,
      'supplierId': supplierId,
      'status': status,
      'createdAt': FieldValue.serverTimestamp(),
    };
  }
}
