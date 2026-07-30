import 'package:cloud_firestore/cloud_firestore.dart';

/// A user↔supplier conversation, anchored to one [SupplierSubmissionModel].
/// Display fields (names/logo) are denormalized at creation time so the
/// conversation list never needs extra per-row lookups.
class ConversationModel {
  final String id;
  final String submissionId;
  final List<String> participantUids;
  final String userUid;
  final String userName;
  final String supplierId;
  final String supplierCompanyName;
  final String? supplierLogoUrl;
  final String? techPackProjectName;
  final String? techPackImageUrl;
  final String? lastMessage;
  final DateTime? lastMessageAt;
  final Map<String, int> unreadCountByUid;

  ConversationModel({
    required this.id,
    required this.submissionId,
    required this.participantUids,
    required this.userUid,
    required this.userName,
    required this.supplierId,
    required this.supplierCompanyName,
    this.supplierLogoUrl,
    this.techPackProjectName,
    this.techPackImageUrl,
    this.lastMessage,
    this.lastMessageAt,
    this.unreadCountByUid = const {},
  });

  factory ConversationModel.fromFirestore(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>? ?? {};
    return ConversationModel(
      id: doc.id,
      submissionId: data['submissionId'] ?? '',
      participantUids: List<String>.from(data['participantUids'] ?? []),
      userUid: data['userUid'] ?? '',
      userName: data['userName'] ?? 'Designer',
      supplierId: data['supplierId'] ?? '',
      supplierCompanyName: data['supplierCompanyName'] ?? 'Supplier',
      supplierLogoUrl: data['supplierLogoUrl'],
      techPackProjectName: data['techPackProjectName'],
      techPackImageUrl: data['techPackImageUrl'],
      lastMessage: data['lastMessage'],
      lastMessageAt: (data['lastMessageAt'] as Timestamp?)?.toDate(),
      unreadCountByUid: Map<String, int>.from(data['unreadCountByUid'] ?? {}),
    );
  }

  /// Display name/logo for the "other side" of the conversation, relative
  /// to [currentUid] — a supplier viewer sees the designer's name, a
  /// designer viewer sees the supplier's company name + logo.
  String otherPartyName(String currentUid) =>
      currentUid == userUid ? supplierCompanyName : userName;

  String? otherPartyLogoUrl(String currentUid) =>
      currentUid == userUid ? supplierLogoUrl : null;

  int unreadCountFor(String currentUid) => unreadCountByUid[currentUid] ?? 0;
}
