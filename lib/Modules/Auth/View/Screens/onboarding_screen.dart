import 'package:atella/Widgets/custom_roundbutton.dart';
import 'package:atella/core/constants/app_iamges.dart';
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
              decoration: const BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.vertical(top: Radius.circular(60)),
              ),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    "Welcome to StudioWear — Your\nFashion Brand Starts Here.\"",
                    textAlign: TextAlign.center,
                    style: OSTextStyle22700,
                  ),
                  SizedBox(height: 12.h),
                  Text(
                    "Turn your ideas into real clothing — with AI-powered design tools and manufacturer support.",
                    textAlign: TextAlign.center,
                    style: OSTextStyle165002,
                  ),
                  SizedBox(height: 50.h),
                  RoundButton(
                    title: "Join Now",
                    onTap: () {
                      Get.toNamed('/login');
                    },
                    color: const Color(0xFF8C82FF),
                    isloading: false,
                  ),
                  SizedBox(height: 33.h),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text("Already joined? ", style: OSTextStyle165003),
                      GestureDetector(
                        onTap: () {
                          // Navigate to sign-in
                        },
                        child: InkWell(
                          onTap: () {
                            Get.toNamed('/login');
                          },
                          child: Text("Sign In", style: OSTextStyle165004),
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
