import 'package:atella/Widgets/custom_roundbutton.dart';
import 'package:atella/core/constants/app_images.dart';
import 'package:atella/core/themes/app_colors.dart';
import 'package:atella/core/themes/app_fonts.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';

class CreateScreen extends StatelessWidget {
  const CreateScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Column(
        children: [
          // Top Image Section
          SizedBox(
            height: 450.h,
            width: double.infinity,
            child: Image.asset(chatbriefIcon, fit: BoxFit.cover),
          ),
          Expanded(
            child: Container(
              width: double.infinity,
              padding: EdgeInsets.symmetric(horizontal: 24.w),
              decoration: const BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.vertical(top: Radius.circular(60)),
              ),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    "Gathering the Creative Brief ",
                    textAlign: TextAlign.center,
                    style: OSTextStyle18600,
                  ),
                  SizedBox(height: 12.h),
                  Text(
                    "As your expert virtual fashion designer.",
                    textAlign: TextAlign.center,
                    style: GSTextStyle16600,
                  ),
                  SizedBox(height: 18.h),
                  Text(
                    "I’m here to help you create a custom garment or collection.",
                    textAlign: TextAlign.center,
                    style: OSTextStyle165002,
                  ),
                  SizedBox(height: 50.h),
                  RoundButton(
                    title: "Get Started",
                    onTap: () {
                      Get.toNamed('/creative_brief');
                    },
                    color: AppColors.buttonColor,
                    isloading: false,
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
