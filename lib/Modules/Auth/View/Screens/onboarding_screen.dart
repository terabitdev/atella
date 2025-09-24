import 'package:atella/Widgets/custom_roundbutton.dart';
import 'package:atella/core/constants/app_images.dart';
import 'package:atella/core/themes/app_colors.dart';
import 'package:atella/core/themes/app_fonts.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';

class OnboardingScreen extends StatelessWidget {
  const OnboardingScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Column(
        children: [
          // Top Image Section
          SizedBox(
            height: 450.h,
            width: double.infinity,
            child: Image.asset(onboardingImage, fit: BoxFit.cover),
          ),

          // Bottom Curved Container
          Expanded(
            child: Container(
              width: double.infinity,
              padding: EdgeInsets.symmetric(horizontal: 24.w),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.vertical(top: Radius.circular(60.r)),
              ),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    "Welcome to AteliA — Your\nFashion Brand Starts Here.\"",
                    textAlign: TextAlign.center,
                    style: osTextStyle18600,
                  ),
                  SizedBox(height: 12.h),
                  Text(
                    "Turn your ideas into real clothing — with AI-powered design tools and manufacturer support.",
                    textAlign: TextAlign.center,
                    style: osTextStyle165002,
                  ),
                  SizedBox(height: 50.h),
                  RoundButton(
                    title: "Join Now",
                    onTap: () {
                      Get.toNamed('/signup');
                    },
                    color: AppColors.buttonColor,
                    isloading: false,
                  ),
                  SizedBox(height: 33.h),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text("Already joined? ", style: osTextStyle165003),
                      GestureDetector(
                        onTap: () {
                          // Navigate to sign-in
                        },
                        child: InkWell(
                          onTap: () {
                            Get.toNamed('/login');
                          },
                          child: Text("Sign In", style: osTextStyle167004),
                        ),
                      ),
                    ],
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
