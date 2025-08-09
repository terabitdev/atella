import 'package:atella/core/constants/app_images.dart';
import 'package:atella/core/themes/app_fonts.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

class TechPackImageCard extends StatelessWidget {
  final bool isLoading;
  final String? imagePath;
  final VoidCallback? onTap;
  const TechPackImageCard({
    super.key,
    this.isLoading = false,
    this.imagePath,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    Widget card = Container(
      margin: EdgeInsets.symmetric(vertical: 12.h),
      decoration: BoxDecoration(
        color: const Color(0xFFE3E1FB),
        borderRadius: BorderRadius.circular(24.r),
      ),
      width: double.infinity,
      height: 180.h,
      child: isLoading
          ? Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Image.asset(generateIcon, height: 50.h, width: 50.w),
                SizedBox(height: 12.h),
                Text('Generating..', style: gsTextStyle17400),
              ],
            )
          : imagePath != null
          ? ClipRRect(
              borderRadius: BorderRadius.circular(24.r),
              child: Image.asset(
                imagePath!,
                fit: BoxFit.cover,
                width: double.infinity,
                height: 180.h,
              ),
            )
          : SizedBox.shrink(),
    );
    if (onTap != null && !isLoading && imagePath != null) {
      return GestureDetector(onTap: onTap, child: card);
    }
    return card;
  }
}
