import 'package:atella/core/constants/app_images.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:atella/core/themes/app_fonts.dart';

class AuthHeader extends StatelessWidget {
  final String title;

  const AuthHeader({super.key, required this.title});

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Image.asset(logo, height: 61.h, width: 63.w),
        SizedBox(height: 35.h),
        Text(title, style: loginTextTextStyle22700),
        SizedBox(height: 40.h),
      ],
    );
  }
}
