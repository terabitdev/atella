import 'package:atella/core/themes/app_colors.dart';
import 'package:atella/core/themes/app_fonts.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

class ProfileTextfield extends StatelessWidget {
  final String label;
  final TextEditingController controller;
  final bool isPassword;
  final bool enabled;

  const ProfileTextfield({
    super.key,
    required this.label,
    required this.controller,
    this.isPassword = false,
    this.enabled = true,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label, style: authLableTextTextStyle14400),
        SizedBox(height: 6.h),
        TextField(
          enabled: enabled,
          controller: controller,
          obscureText: isPassword,
          style: authLableTextTextStyle144002,
          decoration:  InputDecoration(
            filled: !enabled,
            fillColor: !enabled ? const Color(0xFFF5F5F5) : null,
            hintText: label,
            hintStyle: authLableTextTextStyle144002,
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(6.r),
              borderSide: const BorderSide(
                color: Color.fromRGBO(233, 233, 233, 1), // Light gray
                width: 1.2,
              ),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(6.r),
              borderSide: BorderSide(color: AppColors.buttonColor, width: 1.5),
            ),
             disabledBorder: OutlineInputBorder( // 👈 add this
      borderRadius: BorderRadius.circular(6.r),
      borderSide: const BorderSide(
        color: Color.fromRGBO(233, 233, 233, 1), 
        width: 1.2,
      ),
    ),
            contentPadding: EdgeInsets.symmetric(
              vertical: 16.h,
              horizontal: 12.w,
            ),
          ),
        ),
      ],
    );
  }
}
