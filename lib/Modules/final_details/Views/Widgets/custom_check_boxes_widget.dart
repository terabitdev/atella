import 'package:atella/core/themes/app_colors.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

class CustomCheckboxWidget extends StatelessWidget {
  final String text;
  final bool isSelected;
  final VoidCallback onTap;
  final bool allowMultiple;

  const CustomCheckboxWidget({
    Key? key,
    required this.text,
    required this.isSelected,
    required this.onTap,
    this.allowMultiple = true,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        margin: EdgeInsets.only(bottom: 8.h),
        padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 12.h),
        decoration: BoxDecoration(
          color: const Color(0xFFF5F5F5),
          borderRadius: BorderRadius.circular(20.r),
          border: Border.all(
            color: isSelected
                ? AppColors.buttonColor
                : const Color(0xFFE0E0E0),
            width: 1,
          ),
        ),
        child: Row(
          children: [
            // Checkbox icon
            Container(
              width: 20.w,
              height: 20.w,
              decoration: BoxDecoration(
                color: isSelected ? AppColors.buttonColor : Colors.transparent,
                border: Border.all(
                  color: isSelected ? AppColors.buttonColor : const Color(0xFFCCCCCC),
                  width: 1.5,
                ),
                borderRadius: BorderRadius.circular(4.r),
              ),
              child: isSelected
                  ? Icon(Icons.check, color: Colors.white, size: 14.sp)
                  : null,
            ),

            SizedBox(width: 12.w),

            // Text
            Expanded(
              child: Text(
                text,
                style: TextStyle(
                  fontSize: 13.sp,
                  fontWeight: isSelected ? FontWeight.w500 : FontWeight.w400,
                  color: Colors.black87,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
