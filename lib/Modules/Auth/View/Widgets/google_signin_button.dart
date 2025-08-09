import 'package:atella/core/constants/app_images.dart';
import 'package:atella/core/themes/app_fonts.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

class GoogleRoundButton extends StatelessWidget {
  final String title;
  final VoidCallback onTap;
  final bool loading;
  final Color color;

  const GoogleRoundButton({
    super.key,
    required this.title,
    required this.onTap,
    required this.color,
    this.loading = false,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      child: Container(
        height: 56.h,
        width: double.infinity,
        decoration: BoxDecoration(
          // color: Color.fromRGBO(233, 233, 233, 1),
          borderRadius: BorderRadius.circular(6.r),
          border: Border.all(
            color: Color.fromRGBO(233, 233, 233, 1),
            width: 1.2,
          ),
        ),
        child: Center(
          child: loading
              ? const CircularProgressIndicator(
                  strokeWidth: 3,
                  color: Colors.white,
                )
              : Row(
                  mainAxisSize: MainAxisSize.min,
                  mainAxisAlignment: MainAxisAlignment.spaceAround,
                  children: [
                    // Google Icon
                    Image.asset(
                      googleIcon,
                      height: 24.h, // Adjust the size of the Google icon
                      width: 24.w,
                    ),
                    SizedBox(width: 10.w),
                    // Button Text
                    Text(title, style: googleButtonTextStyle16600),
                  ],
                ),
        ),
      ),
    );
  }
}
