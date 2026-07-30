import 'package:firebase_auth/firebase_auth.dart';
import 'package:get/get.dart';
import 'package:atella/Data/Models/conversation_model.dart';
import 'package:atella/services/firebase/services/messaging_service.dart';

class ConversationListController extends GetxController {
  final MessagingService _service = MessagingService();

  final RxList<ConversationModel> conversations = <ConversationModel>[].obs;
  final RxBool isLoading = true.obs;

  String get currentUid => FirebaseAuth.instance.currentUser?.uid ?? '';

  @override
  void onInit() {
    super.onInit();
    _service.streamMyConversations().listen((list) {
      conversations.assignAll(list);
      isLoading.value = false;
    });
  }
}
