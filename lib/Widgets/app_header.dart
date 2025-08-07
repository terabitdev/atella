// File: lib/widgets/global_header.dart
import 'package:atella/core/themes/app_fonts.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';

class GlobalHeader extends StatelessWidget {
  final String title;
  final VoidCallback? onBack;

  const GlobalHeader({super.key, required this.title, this.onBack});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.only(top: 20.h),
      child: Row(
        children: [
          GestureDetector(
            onTap: onBack ?? () => Get.back(),
            child: Icon(
              Icons.arrow_back_ios_new,
              size: 20.sp,
              color: Colors.black,
            ),
          ),
          SizedBox(width: 16.w),
          Text(title, style: vsTextStyle20800),
        ],
      ),
    );
  }
}
