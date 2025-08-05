import 'package:atella/Widgets/custom_roundbutton.dart';
import 'package:atella/core/constants/app_images.dart';
import 'package:atella/core/themes/app_colors.dart';
import 'package:atella/core/themes/app_fonts.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';

class FinalDetailOnboard extends StatelessWidget {
  const FinalDetailOnboard({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Column(
        children: [
          // Top Image Section
          SizedBox(
            height: 450.h,
            width: double.infinity,
            child: Image.asset(finalimageIcon, fit: BoxFit.cover),
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
                    "Final Details to Provide ",
                    textAlign: TextAlign.center,
                    style: osTextStyle18600,
                  ),
                  SizedBox(height: 70.h),
                  RoundButton(
                    title: "Continue",
                    onTap: () {
                      Get.toNamed('/final_details');
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
