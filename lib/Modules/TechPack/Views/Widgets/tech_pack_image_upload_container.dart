import 'package:atella/core/themes/app_fonts.dart';
import 'package:dotted_border/dotted_border.dart';
import 'package:flutter/material.dart';
import 'dart:io';
import 'package:flutter_screenutil/flutter_screenutil.dart';

class TechPackImageUploadContainer extends StatelessWidget {
  final VoidCallback onTap;
  final String? imagePath;

  const TechPackImageUploadContainer({
    super.key,
    required this.onTap,
    this.imagePath,
  }) ;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: DottedBorder(
        color: Colors.black, // ✅ Set dotted border color to black
        strokeWidth: 1.5,
        borderType: BorderType.RRect,
        radius: Radius.circular(18.r),
        dashPattern: [6, 3], // ✅ Customizes the dot size and gap
        child: Container(
          width: double.infinity,
          height: 120.h,
          decoration: BoxDecoration(
            color: Colors.transparent,
            borderRadius: BorderRadius.circular(18.r),
          ),
          child: imagePath == null
              ? Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Image.asset(
                      'assets/images/upload.png',
                      height: 24.h,
                      width: 24.w,
                    ),
                    SizedBox(height: 8.h),
                    Text(
                      'Open Camera & Take Photo',
                      style: uiTextTextStyle13500,
                    ),
                  ],
                )
              : ClipRRect(
                  borderRadius: BorderRadius.circular(16.r),
                  child: Image.file(
                    File(imagePath!),
                    fit: BoxFit.cover,
                    width: double.infinity,
                    height: 120.h,
                  ),
                ),
        ),
      ),
    );
  }
}
