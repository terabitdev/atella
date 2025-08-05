import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import '../../../../core/themes/app_colors.dart';
import '../../../../core/themes/app_fonts.dart';

class VerificationMethodWidget extends StatelessWidget {
  final String method;
  final String maskedValue;
  final IconData icon;
  final bool isSelected;
  final VoidCallback onTap;

  const VerificationMethodWidget({
    super.key,
    required this.method,
    required this.maskedValue,
    required this.icon,
    required this.isSelected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: double.infinity,
        padding: EdgeInsets.all(16.w),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16.r),
          border: Border.all(
            color: Color.fromRGBO(233, 233, 233, 1), // Light gray
            width: 1.5,
          ),
        ),
        child: Row(
          children: [
            // Icon
            Container(
              width: 40.w,
              height: 40.w,
              decoration: BoxDecoration(
                color: Colors.grey.shade100,
                shape: BoxShape.circle,
              ),
              child: Icon(icon, color: Colors.black, size: 20.sp),
            ),
            SizedBox(width: 12.w),
            // Text content
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(method, style: osTextStyle165003),
                  SizedBox(height: 2.h),
                  Text(maskedValue, style: osTextStyle165002),
                ],
              ),
            ),
            // Radio button
            Container(
              width: 20.w,
              height: 20.w,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                border: Border.all(
                  color: isSelected
                      ? AppColors.buttonColor
                      : Colors.grey.shade400,
                  width: 2,
                ),
              ),
              child: isSelected
                  ? Container(
                      margin: EdgeInsets.all(4.w),
                      decoration: BoxDecoration(
                        color: AppColors.buttonColor,
                        shape: BoxShape.circle,
                      ),
                    )
                  : null,
            ),
          ],
        ),
      ),
    );
  }
}
