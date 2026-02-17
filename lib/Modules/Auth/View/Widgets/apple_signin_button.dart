import 'package:atella/core/themes/app_fonts.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

class AppleRoundButton extends StatelessWidget {
  final String title;
  final VoidCallback onTap;
  final bool loading;

  const AppleRoundButton({
    super.key,
    required this.title,
    required this.onTap,
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
          borderRadius: BorderRadius.circular(6.r),
          border: Border.all(
            color: const Color.fromRGBO(233, 233, 233, 1),
            width: 1.2,
          ),
        ),
        child: Center(
          child: loading
              ? const CircularProgressIndicator(
                  strokeWidth: 3,
                  color: Colors.black,
                )
              : Row(
                  mainAxisSize: MainAxisSize.min,
                  mainAxisAlignment: MainAxisAlignment.spaceAround,
                  children: [
                    Icon(
                      Icons.apple,
                      size: 28.sp,
                      color: Colors.black,
                    ),
                    SizedBox(width: 10.w),
                    Text(title, style: googleButtonTextStyle16600),
                  ],
                ),
        ),
      ),
    );
  }
}
