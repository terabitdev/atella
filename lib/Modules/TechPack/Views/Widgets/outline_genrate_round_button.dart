import 'package:atella/core/themes/app_fonts.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

class OutlineGenerateRoundButton extends StatelessWidget {
  final String title;
  final VoidCallback onTap;
  final bool loading;
  final Color color;
  final String? imagePath;

  const OutlineGenerateRoundButton({
    Key? key,
    required this.title,
    required this.onTap,
    required this.color,
    this.loading = false,
    this.imagePath,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      child: Container(
        height: 50.h,
        width: 375.w,
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(10.r),
          border: Border.all(color: color),
        ),
        child: Center(
          child: loading
              ? SizedBox(
                  height: 24.h,
                  width: 24.h,
                  child: const CircularProgressIndicator(color: Colors.white),
                )
              : Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    if (imagePath != null)
                      Row(
                        children: [
                          Image.asset(imagePath!, height: 20.h, width: 20.w),
                          SizedBox(width: 10.w),
                        ],
                      ),
                    Text(title, style: GButtonTextStyle166001),
                  ],
                ),
        ),
      ),
    );
  }
}
