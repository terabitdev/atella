import 'package:atella/core/themes/app_fonts.dart';
import 'package:dotted_border/dotted_border.dart';
import 'package:flutter/material.dart';
import 'dart:io';
import 'package:flutter_screenutil/flutter_screenutil.dart';

class TechPackImageUploadContainer extends StatelessWidget {
  final VoidCallback onTap;
  final String? imagePath;
  final VoidCallback? onEdit;

  const TechPackImageUploadContainer({
    super.key,
    required this.onTap,
    this.imagePath,
    this.onEdit,
  }) ;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: DottedBorder(
        options: RoundedRectDottedBorderOptions(
          radius: Radius.circular(18.r),
          color: Colors.black, // ✅ Set dotted border color to black
          strokeWidth: 1.5,
          dashPattern: [6, 3], // ✅ Customizes the dot size and gap
        ),
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
                      'Select Image from Gallery',
                      style: uiTextTextStyle13500,
                    ),
                  ],
                )
              : Stack(
                  children: [
                    ClipRRect(
                      borderRadius: BorderRadius.circular(16.r),
                      child: Image.file(
                        File(imagePath!),
                        fit: BoxFit.cover,
                        width: double.infinity,
                        height: 120.h,
                      ),
                    ),
                    if (onEdit != null)
                      Positioned(
                        top: 8.h,
                        right: 8.w,
                        child: GestureDetector(
                          onTap: onEdit,
                          child: Container(
                            padding: EdgeInsets.all(6.w),
                            decoration: BoxDecoration(
                              color: Colors.black.withOpacity(0.7),
                              borderRadius: BorderRadius.circular(20.r),
                            ),
                            child: Icon(
                              Icons.edit,
                              color: Colors.white,
                              size: 16.sp,
                            ),
                          ),
                        ),
                      ),
                  ],
                ),
        ),
      ),
    );
  }
}
