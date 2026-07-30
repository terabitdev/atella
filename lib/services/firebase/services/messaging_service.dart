import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:atella/Data/Models/conversation_model.dart';
import 'package:atella/Data/Models/message_model.dart';

/// Direct messaging between a user and a supplier, anchored to a
/// [SupplierSubmissionModel]. Conversation summary fields (lastMessage,
/// unreadCountByUid) are kept in sync by the onMessageCreated Cloud
/// Function — this service only ever writes into the messages subcollection
/// plus the one-time conversation-creation doc.
class MessagingService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;

  String? get _uid => _auth.currentUser?.uid;

  /// Returns the existing conversation for this submission, or creates one.
  Future<String> getOrCreateConversation(String submissionId) async {
    final existing = await _firestore
        .collection('conversations')
        .where('submissionId', isEqualTo: submissionId)
        .limit(1)
        .get();
    if (existing.docs.isNotEmpty) {
      return existing.docs.first.id;
    }

    final submissionDoc = await _firestore.collection('supplierSubmissions').doc(submissionId).get();
    if (!submissionDoc.exists) throw Exception('Submission not found');
    final submission = submissionDoc.data()!;

    final supplierDoc = await _firestore.collection('suppliers').doc(submission['supplierId']).get();
    if (!supplierDoc.exists) throw Exception('Supplier not found');
    final supplier = supplierDoc.data()!;
    final supplierOwnerUid = supplier['ownerUid'] as String?;
    if (supplierOwnerUid == null) {
      throw Exception('This supplier has not finished setting up their account yet.');
    }

    final userUid = submission['userUid'] as String;
    final userDoc = await _firestore.collection('users').doc(userUid).get();
    final userName = userDoc.data()?['name'] as String? ?? 'Designer';

    final conversationRef = _firestore.collection('conversations').doc();
    await conversationRef.set({
      'submissionId': submissionId,
      'participantUids': [userUid, supplierOwnerUid],
      'userUid': userUid,
      'userName': userName,
      'supplierId': submission['supplierId'],
      'supplierCompanyName': supplier['companyName'] ?? 'Supplier',
      'supplierLogoUrl': supplier['logoUrl'],
      'techPackProjectName': submission['techPackProjectName'],
      'techPackImageUrl': submission['techPackImageUrl'],
      'lastMessage': null,
      'lastMessageAt': FieldValue.serverTimestamp(),
      'unreadCountByUid': {userUid: 0, supplierOwnerUid: 0},
      'createdAt': FieldValue.serverTimestamp(),
    });

    return conversationRef.id;
  }

  Stream<List<ConversationModel>> streamMyConversations() {
    final uid = _uid;
    if (uid == null) return const Stream.empty();
    return _firestore
        .collection('conversations')
        .where('participantUids', arrayContains: uid)
        .orderBy('lastMessageAt', descending: true)
        .snapshots()
        .map((snap) => snap.docs.map((d) => ConversationModel.fromFirestore(d)).toList());
  }

  Future<ConversationModel?> getConversation(String conversationId) async {
    final doc = await _firestore.collection('conversations').doc(conversationId).get();
    if (!doc.exists) return null;
    return ConversationModel.fromFirestore(doc);
  }

  Stream<List<MessageModel>> streamMessages(String conversationId) {
    return _firestore
        .collection('conversations')
        .doc(conversationId)
        .collection('messages')
        .orderBy('createdAt', descending: true)
        .snapshots()
        .map((snap) => snap.docs.map((d) => MessageModel.fromFirestore(d)).toList());
  }

  Future<void> sendMessage(String conversationId, String text) async {
    final uid = _uid;
    if (uid == null) throw Exception('Not signed in');
    if (text.trim().isEmpty) return;

    final message = MessageModel(id: '', senderUid: uid, text: text.trim());
    await _firestore
        .collection('conversations')
        .doc(conversationId)
        .collection('messages')
        .add(message.toFirestore(uid));
  }

  Future<void> markConversationRead(String conversationId) async {
    final uid = _uid;
    if (uid == null) return;
    await _firestore.collection('conversations').doc(conversationId).update({
      'unreadCountByUid.$uid': 0,
    });
  }
}
