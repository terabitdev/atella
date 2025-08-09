import 'package:atella/core/themes/app_fonts.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

class TechPackQuestionField extends StatelessWidget {
  final String label;
  final String hint;
  final TextEditingController controller;
  final ValueChanged<String>? onChanged;
  final bool enabled;
  const TechPackQuestionField({
    super.key,
    required this.label,
    required this.hint,
    required this.controller,
    this.onChanged,
    this.enabled = true,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label, style: tplTextStyle12400),
        SizedBox(height: 6.h),
        TextField(
          controller: controller,
          enabled: enabled,
          onChanged: onChanged,
          style: tplTextStyle124001,
          decoration: InputDecoration(
            hintText: hint,
            filled: true,
            fillColor: Color(0xFFE3E1FB),
            contentPadding: EdgeInsets.symmetric(
              vertical: 14.h,
              horizontal: 16.w,
            ),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12.r),
              borderSide: BorderSide.none,
            ),
          ),
        ),
        SizedBox(height: 14.h),
      ],
    );
  }
}
