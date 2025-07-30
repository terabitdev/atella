import 'package:atella/core/themes/app_colors.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

// import your styles/colors
// import 'package:your_app/theme/app_colors.dart';
// import 'package:your_app/theme/text_styles.dart';

class AppHeader extends StatelessWidget {
  /// Title shown in the center
  final String title;

  /// Getter that returns the current time text (e.g. () => controller.currentTime)
  final String Function() timeTextGetter;

  /// Back action (defaults to Get.back)
  final VoidCallback? onBack;

  /// Optional customizations
  final EdgeInsetsGeometry padding;
  final TextStyle? titleStyle;
  final Color underlineColor;
  final Color backIconColor;

  const AppHeader({
    super.key,
    required this.title,
    required this.timeTextGetter,
    this.onBack,
    this.padding = const EdgeInsets.symmetric(horizontal: 20, vertical: 54),
    this.titleStyle,
    this.underlineColor = AppColors.buttonColor,
    this.backIconColor = Colors.black,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: padding,
      child: Column(
        children: [
          Row(
            children: [
              GestureDetector(
                onTap: onBack ?? Get.back,
                child: Icon(
                  Icons.arrow_back_ios_new,
                  size: 20.sp,
                  color: backIconColor,
                ),
              ),
              const Spacer(),
              Column(
                children: [
                  Text(
                    title,
                    // replace with your QTextStyle14600 if needed
                    style: titleStyle ??
                        const TextStyle(fontSize: 14, fontWeight: FontWeight.w600),
                  ),
                  const SizedBox(height: 4),
                  Container(
                    width: 40,
                    height: 3,
                    decoration: BoxDecoration(
                      color: underlineColor,
                      borderRadius: BorderRadius.circular(2),
                    ),
                  ),
                ],
              ),
              const Spacer(),
              // keeps the center column perfectly centered like your original
              const SizedBox(width: 40),
            ],
          ),
          const SizedBox(height: 24),
          // Rebuilds when the getter reads an Rx inside the controller
          Obx(() => Text(
                timeTextGetter(),
                style: const TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w400,
                  color: Color(0xFF999999),
                ),
              )),
        ],
      ),
    );
  }
}
