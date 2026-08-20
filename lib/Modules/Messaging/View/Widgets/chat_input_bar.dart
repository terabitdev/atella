import 'package:atella/core/themes/app_colors.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

class ChatInputBar extends StatelessWidget {
  final TextEditingController controller;
  final bool isSending;
  final bool isUploading;
  final VoidCallback onSend;
  final VoidCallback onAttach;

  const ChatInputBar({
    super.key,
    required this.controller,
    required this.isSending,
    required this.isUploading,
    required this.onSend,
    required this.onAttach,
  });

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      top: false,
      child: Padding(
        padding: EdgeInsets.symmetric(horizontal: 12.w, vertical: 10.h),
        child: Row(
          children: [
            InkWell(
              onTap: isUploading ? null : onAttach,
              child: Padding(
                padding: EdgeInsets.all(8.w),
                child: isUploading
                    ? SizedBox(
                        width: 22.w,
                        height: 22.w,
                        child: const CircularProgressIndicator(strokeWidth: 2),
                      )
                    : Icon(Icons.attach_file, color: AppColors.buttonColor, size: 22.sp),
              ),
            ),
            Expanded(
              child: Container(
                decoration: BoxDecoration(
                  color: const Color(0xFFF4F4F4),
                  borderRadius: BorderRadius.circular(24.r),
                ),
                child: TextField(
                  controller: controller,
                  minLines: 1,
                  maxLines: 4,
                  textCapitalization: TextCapitalization.sentences,
                  decoration: InputDecoration(
                    hintText: 'Type a message...',
                    border: InputBorder.none,
                    contentPadding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 12.h),
                  ),
                  onSubmitted: (_) => onSend(),
                ),
              ),
            ),
            SizedBox(width: 8.w),
            InkWell(
              onTap: isSending ? null : onSend,
              child: Container(
                width: 44.w,
                height: 44.w,
                decoration: BoxDecoration(
                  color: AppColors.buttonColor,
                  shape: BoxShape.circle,
                ),
                child: isSending
                    ? Padding(
                        padding: EdgeInsets.all(12.w),
                        child: const CircularProgressIndicator(color: Colors.white, strokeWidth: 2),
                      )
                    : const Icon(Icons.arrow_upward, color: Colors.white, size: 20),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
