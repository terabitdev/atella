import 'package:atella/core/themes/app_fonts.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

class RoundButton extends StatelessWidget {
  final String title;
  final VoidCallback? onTap;
  final Color color;
  final bool isloading;
  const RoundButton({
    super.key,
    required this.title,
    required this.onTap,
    required this.color,
    this.isloading = false,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: isloading ? null : onTap,
      child: Container(
        height: 50.h,
        width: 375.w,
        decoration: BoxDecoration(
          color: isloading ? Colors.grey.shade400 : color,
          borderRadius: BorderRadius.circular(10.r),
        ),
        child: Center(
          child: isloading
              ? SizedBox(
                  height: 24.h,
                  width: 24.h,
                  child: const CircularProgressIndicator(color: Colors.white),
                )
              : Padding(
                  padding: EdgeInsets.symmetric(horizontal: 16.w),
                  child: Text(
                    title,
                    style: buttonTextStyle16600,
                    textAlign: TextAlign.center,
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
        ),
      ),
    );
  }
}
