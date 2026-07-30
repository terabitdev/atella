import 'package:atella/Modules/Messaging/Controllers/chat_controller.dart';
import 'package:atella/Modules/Messaging/Controllers/conversation_list_controller.dart';
import 'package:get/get.dart';

class ConversationListBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut<ConversationListController>(() => ConversationListController());
  }
}

class ChatBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut<ChatController>(() => ChatController());
  }
}
