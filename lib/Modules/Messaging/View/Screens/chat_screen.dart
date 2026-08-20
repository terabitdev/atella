import 'package:atella/Modules/Messaging/Controllers/chat_controller.dart';
import 'package:atella/Modules/Messaging/View/Widgets/chat_input_bar.dart';
import 'package:atella/Modules/Messaging/View/Widgets/message_bubble.dart';
import 'package:atella/Routes/app_routes.dart';
import 'package:atella/core/themes/app_fonts.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:image_picker/image_picker.dart';

class ChatScreen extends StatelessWidget {
  const ChatScreen({super.key});

  void _showAttachmentOptions(BuildContext context, ChatController controller) {
    showModalBottomSheet(
      context: context,
      builder: (_) => SafeArea(
        child: Wrap(
          children: [
            ListTile(
              leading: const Icon(Icons.photo_camera_outlined),
              title: const Text('Camera'),
              onTap: () {
                Navigator.pop(context);
                controller.pickAndSendImage(ImageSource.camera);
              },
            ),
            ListTile(
              leading: const Icon(Icons.photo_library_outlined),
              title: const Text('Gallery'),
              onTap: () {
                Navigator.pop(context);
                controller.pickAndSendImage(ImageSource.gallery);
              },
            ),
            ListTile(
              leading: const Icon(Icons.insert_drive_file_outlined),
              title: const Text('Document'),
              onTap: () {
                Navigator.pop(context);
                controller.pickAndSendDocument();
              },
            ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final controller = Get.find<ChatController>();

    return Scaffold(
      body: SafeArea(
        child: Obx(() {
          if (controller.isLoading.value) {
            return const Center(child: CircularProgressIndicator());
          }

          final conversation = controller.conversation.value;
          if (conversation == null) {
            return Center(
              child: Text("This conversation couldn't be found.", style: gsTextStyle16600),
            );
          }

          final otherPartyName = conversation.otherPartyName(controller.currentUid);

          return Column(
            children: [
              Padding(
                padding: EdgeInsets.symmetric(horizontal: 12.w, vertical: 12.h),
                child: Row(
                  children: [
                    GestureDetector(
                      onTap: () => Navigator.of(context).pop(),
                      child: Padding(
                        padding: EdgeInsets.all(4.w),
                        child: Icon(Icons.arrow_back_ios_new, size: 20.sp, color: Colors.black),
                      ),
                    ),
                    SizedBox(width: 8.w),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(otherPartyName, style: gsTextStyle16600),
                          if (conversation.techPackProjectName != null)
                            Text(
                              conversation.techPackProjectName!,
                              style: ssTitleTextTextStyle14400.copyWith(color: Colors.grey[500]),
                            ),
                        ],
                      ),
                    ),
                    if (conversation.userUid != controller.currentUid)
                      GestureDetector(
                        onTap: () => Get.toNamed(
                          AppRoutes.sampleOrderForm,
                          arguments: {'conversationId': controller.conversationId},
                        ),
                        child: Padding(
                          padding: EdgeInsets.all(4.w),
                          child: Icon(Icons.receipt_long_outlined, size: 22.sp, color: Colors.black),
                        ),
                      ),
                  ],
                ),
              ),
              const Divider(height: 1),
              Expanded(
                child: Obx(() {
                  if (controller.messages.isEmpty) {
                    return Center(
                      child: Text('Say hello 👋', style: ssTitleTextTextStyle14400),
                    );
                  }
                  return ListView.builder(
                    reverse: true,
                    padding: EdgeInsets.symmetric(horizontal: 14.w, vertical: 10.h),
                    itemCount: controller.messages.length,
                    itemBuilder: (context, index) {
                      final message = controller.messages[index];
                      return MessageBubble(
                        message: message,
                        isMe: message.senderUid == controller.currentUid,
                      );
                    },
                  );
                }),
              ),
              Obx(
                () => ChatInputBar(
                  controller: controller.textController,
                  isSending: controller.isSending.value,
                  isUploading: controller.isUploading.value,
                  onSend: controller.send,
                  onAttach: () => _showAttachmentOptions(context, controller),
                ),
              ),
            ],
          );
        }),
      ),
    );
  }
}
