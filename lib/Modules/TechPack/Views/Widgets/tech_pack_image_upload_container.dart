import 'package:atella/core/themes/app_fonts.dart';
import 'package:dotted_border/dotted_border.dart';
import 'package:flutter/material.dart';
import 'dart:io';

import 'package:flutter_screenutil/flutter_screenutil.dart';

class TechPackImageUploadContainer extends StatelessWidget {
  final VoidCallback onTap;
  final String? imagePath;
  const TechPackImageUploadContainer({
    Key? key,
    required this.onTap,
    this.imagePath,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return DottedBorder(
      borderType: BorderType.RRect,
      color: const Color.fromRGBO(246, 121, 82, 1),
      dashPattern: [5, 5], // 5 is dash length, 5 is space length
      strokeWidth: 2,
      radius: Radius.circular(18.r),
      child: GestureDetector(
        onTap: onTap,
        child: Container(
          width: double.infinity,
          height: 120,
          margin: const EdgeInsets.symmetric(vertical: 10),
          decoration: BoxDecoration(
            color: Colors.transparent,
            borderRadius: BorderRadius.circular(18),
            border: Border.all(
              color: const Color(0xFFB6B6F6),
              width: 2,
              style: BorderStyle.solid,
            ),
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
                    const SizedBox(height: 8),
                    Text(
                      'Open Camera & Take Photo',
                      style: UITextTextStyle13500,
                    ),
                  ],
                )
              : ClipRRect(
                  borderRadius: BorderRadius.circular(16),
                  child: Image.file(
                    File(imagePath!),
                    fit: BoxFit.cover,
                    width: double.infinity,
                    height: 120,
                  ),
                ),
        ),
      ),
    );
  }
}
