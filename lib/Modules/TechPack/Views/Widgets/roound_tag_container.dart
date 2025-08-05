import 'package:atella/core/themes/app_fonts.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

class RoundedTagContainer extends StatelessWidget {
  final String text;
  final TextStyle? textStyle;
  final Color backgroundColor;
  final EdgeInsetsGeometry padding;

  const RoundedTagContainer({
    Key? key,
    required this.text,
    this.textStyle,
    this.backgroundColor = Colors.black,
    this.padding = const EdgeInsets.all(12),
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 56.h,
      width: 356.w,
      decoration: BoxDecoration(
        color: backgroundColor,
        borderRadius: BorderRadius.only(
          topLeft: Radius.circular(4.r),
          topRight: Radius.circular(24.r),
          bottomLeft: Radius.circular(24.r),
          bottomRight: Radius.circular(24.r),
        ),
      ),
      child: Padding(
        padding: padding,
        child: Text(text, style: tpcTextStyle16400),
      ),
    );
  }
}
