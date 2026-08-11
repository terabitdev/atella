import 'package:atella/Data/Models/conversation_model.dart';
import 'package:atella/Modules/Messaging/Controllers/conversation_list_controller.dart';
import 'package:atella/Routes/app_routes.dart';
import 'package:atella/Widgets/app_header.dart';
import 'package:atella/core/themes/app_colors.dart';
import 'package:atella/core/themes/app_fonts.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';

class ConversationListScreen extends StatelessWidget {
  final bool showBackButton;

  const ConversationListScreen({super.key, this.showBackButton = true});

  @override
  Widget build(BuildContext context) {
    final controller = Get.find<ConversationListController>();

    return Scaffold(
      body: SafeArea(
        child: Padding(
          padding: EdgeInsets.symmetric(horizontal: 20.w, vertical: 20.h),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              GlobalHeader(title: 'Messages', showBackButton: showBackButton),
              SizedBox(height: 16.h),
              Expanded(
                child: Obx(() {
                  if (controller.isLoading.value) {
                    return const Center(child: CircularProgressIndicator());
                  }
                  if (controller.conversations.isEmpty) {
                    return Center(
                      child: Text('No conversations yet.', style: ssTitleTextTextStyle14400),
                    );
                  }
                  return ListView.separated(
                    itemCount: controller.conversations.length,
                    separatorBuilder: (_, __) => SizedBox(height: 10.h),
                    itemBuilder: (context, index) {
                      final conversation = controller.conversations[index];
                      return _ConversationTile(
                        conversation: conversation,
                        currentUid: controller.currentUid,
                        onTap: () => Get.toNamed(
                          AppRoutes.chat,
                          arguments: {'conversationId': conversation.id},
                        ),
                      );
                    },
                  );
                }),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _ConversationTile extends StatelessWidget {
  final ConversationModel conversation;
  final String currentUid;
  final VoidCallback onTap;

  const _ConversationTile({
    required this.conversation,
    required this.currentUid,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final unread = conversation.unreadCountFor(currentUid);
    final logoUrl = conversation.otherPartyLogoUrl(currentUid);

    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: EdgeInsets.all(12.w),
        decoration: BoxDecoration(
          border: Border.all(color: const Color(0xFFE9E9E9)),
          borderRadius: BorderRadius.circular(12.r),
        ),
        child: Row(
          children: [
            ClipRRect(
              borderRadius: BorderRadius.circular(10.r),
              child: (logoUrl != null && logoUrl.isNotEmpty)
                  ? CachedNetworkImage(imageUrl: logoUrl, width: 48.w, height: 48.w, fit: BoxFit.cover)
                  : Container(
                      width: 48.w,
                      height: 48.w,
                      color: const Color(0xFFF4F4F4),
                      child: Icon(Icons.person_outline, color: Colors.grey[500]),
                    ),
            ),
            SizedBox(width: 12.w),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(conversation.otherPartyName(currentUid), style: gsTextStyle16600),
                  SizedBox(height: 4.h),
                  Text(
                    conversation.lastMessage ?? 'No messages yet',
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: ssTitleTextTextStyle14400,
                  ),
                ],
              ),
            ),
            Column(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                if (conversation.lastMessageAt != null)
                  Text(
                    DateFormat('MMM d').format(conversation.lastMessageAt!),
                    style: TextStyle(fontSize: 11.sp, color: Colors.grey[500]),
                  ),
                if (unread > 0) ...[
                  SizedBox(height: 6.h),
                  Container(
                    padding: EdgeInsets.symmetric(horizontal: 7.w, vertical: 2.h),
                    decoration: BoxDecoration(
                      color: AppColors.buttonColor,
                      borderRadius: BorderRadius.circular(10.r),
                    ),
                    child: Text(
                      '$unread',
                      style: const TextStyle(color: Colors.white, fontSize: 11),
                    ),
                  ),
                ],
              ],
            ),
          ],
        ),
      ),
    );
  }
}
