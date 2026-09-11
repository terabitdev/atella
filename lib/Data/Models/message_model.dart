import 'package:cloud_firestore/cloud_firestore.dart';

class MessageModel {
  final String id;
  final String senderUid;
  final String text;
  final String? attachmentUrl;
  final String type; // text | system | sample_order_form | tech_pack_shared | image | file
  final String? fileName;
  final String? orderId;
  final DateTime? createdAt;
  final List<String> readBy;
  // Only set for type == 'tech_pack_shared'. A full snapshot of the tech
  // pack at the moment it was shared (TechPackModel.toMap()), so the
  // recipient can view/download/share every image — not just the one
  // thumbnail — without needing read access to the sender's own tech packs.
  final String? techPackId;
  final Map<String, dynamic>? techPackSnapshot;

  MessageModel({
    required this.id,
    required this.senderUid,
    required this.text,
    this.attachmentUrl,
    this.type = 'text',
    this.fileName,
    this.orderId,
    this.createdAt,
    this.readBy = const [],
    this.techPackId,
    this.techPackSnapshot,
  });

  factory MessageModel.fromFirestore(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>? ?? {};
    return MessageModel(
      id: doc.id,
      senderUid: data['senderUid'] ?? '',
      text: data['text'] ?? '',
      attachmentUrl: data['attachmentUrl'],
      type: data['type'] ?? 'text',
      fileName: data['fileName'],
      orderId: data['orderId'],
      createdAt: (data['createdAt'] as Timestamp?)?.toDate(),
      readBy: List<String>.from(data['readBy'] ?? []),
      techPackId: data['techPackId'],
      techPackSnapshot: data['techPackSnapshot'] != null
          ? Map<String, dynamic>.from(data['techPackSnapshot'])
          : null,
    );
  }

  Map<String, dynamic> toFirestore(String senderUid) {
    return {
      'senderUid': senderUid,
      'text': text,
      'attachmentUrl': attachmentUrl,
      'type': type,
      'fileName': fileName,
      'createdAt': FieldValue.serverTimestamp(),
      'readBy': [senderUid],
      'techPackId': techPackId,
      'techPackSnapshot': techPackSnapshot,
    };
  }
}
