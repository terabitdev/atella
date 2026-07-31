import 'package:atella/Data/Models/message_model.dart';
import 'package:atella/Routes/app_routes.dart';
import 'package:atella/Widgets/custom_roundbutton.dart';
import 'package:atella/core/themes/app_colors.dart';
import 'package:atella/core/themes/app_fonts.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';

class MessageBubble extends StatelessWidget {
  final MessageModel message;
  final bool isMe;

  const MessageBubble({super.key, required this.message, required this.isMe});

  @override
  Widget build(BuildContext context) {
    if (message.type == 'system') {
      return Center(
        child: Padding(
          padding: EdgeInsets.symmetric(vertical: 8.h),
          child: Text(
            message.text,
            style: ssTitleTextTextStyle14400.copyWith(color: Colors.grey[500]),
            textAlign: TextAlign.center,
          ),
        ),
      );
    }

    if (message.type == 'tech_pack_shared') {
      return Align(
        alignment: isMe ? Alignment.centerRight : Alignment.centerLeft,
        child: Container(
          constraints: BoxConstraints(maxWidth: 240.w),
          margin: EdgeInsets.symmetric(vertical: 6.h),
          padding: EdgeInsets.all(10.w),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(14.r),
            border: Border.all(color: const Color(0xFFE0E0E0)),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              if (message.attachmentUrl != null && message.attachmentUrl!.isNotEmpty)
                ClipRRect(
                  borderRadius: BorderRadius.circular(10.r),
                  child: CachedNetworkImage(
                    imageUrl: message.attachmentUrl!,
                    width: double.infinity,
                    height: 160.h,
                    fit: BoxFit.cover,
                    placeholder: (context, url) => Container(
                      height: 160.h,
                      color: const Color(0xFFF4F4F4),
                    ),
                    errorWidget: (context, url, error) => Container(
                      height: 160.h,
                      color: const Color(0xFFF4F4F4),
                      child: const Icon(Icons.broken_image_outlined),
                    ),
                  ),
                ),
              Padding(
                padding: EdgeInsets.only(top: 8.h, left: 4.w, right: 4.w),
                child: Row(
                  children: [
                    Icon(Icons.description_outlined, size: 16.sp, color: AppColors.buttonColor),
                    SizedBox(width: 6.w),
                    Expanded(
                      child: Text(
                        message.text,
                        style: gsTextStyle16600,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                  ],
                ),
              ),
              Padding(
                padding: EdgeInsets.only(left: 4.w, top: 2.h),
                child: Text('Tech pack shared', style: ssTitleTextTextStyle14400.copyWith(color: Colors.grey[500])),
              ),
            ],
          ),
        ),
      );
    }

    if (message.type == 'sample_order_form' && message.orderId != null) {
      return Align(
        alignment: isMe ? Alignment.centerRight : Alignment.centerLeft,
        child: Container(
          constraints: BoxConstraints(maxWidth: 280.w),
          margin: EdgeInsets.symmetric(vertical: 6.h),
          padding: EdgeInsets.all(14.w),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(14.r),
            border: Border.all(color: const Color(0xFFE0E0E0)),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Icon(Icons.receipt_long_outlined, size: 18.sp, color: AppColors.buttonColor),
                  SizedBox(width: 6.w),
                  Text('Sample Order Form', style: gsTextStyle16600),
                ],
              ),
              if (message.text.isNotEmpty) ...[
                SizedBox(height: 8.h),
                Text(message.text, style: gsTextStyle16400),
              ],
              SizedBox(height: 12.h),
              if (!isMe)
                RoundButton(
                  title: 'Review & Pay',
                  color: AppColors.buttonColor,
                  isloading: false,
                  onTap: () => Get.toNamed(AppRoutes.orderCheckout, arguments: {'orderId': message.orderId}),
                )
              else
                RoundButton(
                  title: 'View Order',
                  color: Colors.grey,
                  isloading: false,
                  onTap: () => Get.toNamed(AppRoutes.orderTracking, arguments: {'orderId': message.orderId}),
                ),
            ],
          ),
        ),
      );
    }

    return Align(
      alignment: isMe ? Alignment.centerRight : Alignment.centerLeft,
      child: Container(
        constraints: BoxConstraints(maxWidth: 280.w),
        margin: EdgeInsets.symmetric(vertical: 4.h),
        padding: EdgeInsets.symmetric(horizontal: 14.w, vertical: 10.h),
        decoration: BoxDecoration(
          color: isMe ? AppColors.buttonColor : const Color(0xFFF1F1F1),
          borderRadius: BorderRadius.only(
            topLeft: Radius.circular(14.r),
            topRight: Radius.circular(14.r),
            bottomLeft: Radius.circular(isMe ? 14.r : 2.r),
            bottomRight: Radius.circular(isMe ? 2.r : 14.r),
          ),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              message.text,
              style: gsTextStyle16400.copyWith(color: isMe ? Colors.white : Colors.black),
            ),
            if (message.createdAt != null) ...[
              SizedBox(height: 4.h),
              Text(
                DateFormat('HH:mm').format(message.createdAt!),
                style: TextStyle(
                  fontSize: 10.sp,
                  color: isMe ? Colors.white70 : Colors.grey[500],
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }
}
