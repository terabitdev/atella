// File: lib/widgets/global_header.dart
import 'package:atella/core/themes/app_fonts.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';

class GlobalHeader extends StatelessWidget {
  final String title;
  final VoidCallback? onBack;
  final List<Widget>? actions;

  const GlobalHeader({
    super.key,
    required this.title,
    this.onBack,
    this.actions,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.only(top: 20.h),
      child: Row(
        children: [
          GestureDetector(
            onTap: onBack ?? () => Get.back(),
            behavior: HitTestBehavior.opaque,
            child: Padding(
              padding: EdgeInsets.all(8.w),
              child: Icon(
                Icons.arrow_back_ios_new,
                size: 20.sp,
                color: Colors.black,
              ),
            ),
          ),
          SizedBox(width: 16.w),
          Expanded(child: Text(title, style: vsTextStyle20800)),
          if (actions != null) ...actions!,
        ],
      ),
    );
  }
}
