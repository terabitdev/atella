import 'package:atella/Routes/app_routes.dart';
import 'package:atella/Widgets/custom_roundbutton.dart';
import 'package:atella/core/constants/app_images.dart';
import 'package:atella/core/themes/app_colors.dart';
import 'package:atella/core/themes/app_fonts.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';

class OnboardingBrandScreen extends StatelessWidget {
  const OnboardingBrandScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: Column(
        children: [
          // Hero image clipped with a full circular arc at the bottom
          ClipPath(
            clipper: _BottomCircleClipper(),
            child: SizedBox(
              height: 380.h,
              width: double.infinity,
              child: Stack(
                fit: StackFit.expand,
                children: [
                  Container(color: const Color(0xFFFFDBD0)),
                  Image.asset(onboardingHeroImage, fit: BoxFit.cover),
                ],
              ),
            ),
          ),

          // White content area below
          Expanded(
            child: Container(
              width: double.infinity,
              padding: EdgeInsets.symmetric(horizontal: 24.w),
              color: Colors.white,
              child: Column(
                children: [
                  SizedBox(height: 16.h),

                  // Title
                  Text(
                    'From your idea to a real brand',
                    textAlign: TextAlign.center,
                    style: osTextStyle18600,
                  ),
                  SizedBox(height: 12.h),

                  // Subtitle
                  Text(
                    'Design, production, suppliers — all in one place',
                    textAlign: TextAlign.center,
                    style: osTextStyle165002,
                  ),
                  SizedBox(height: 20.h),

                  // Stats row — IntrinsicHeight makes all cards the same height
                  IntrinsicHeight(
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                      _StatCard(
                        iconAsset: onboardingIconBrands,
                        iconWidth: 16.w,
                        iconHeight: 14.h,
                        value: '500+',
                        label: 'Brands created',
                      ),
                      SizedBox(width: 9.w),
                      _StatCard(
                        iconAsset: onboardingIconCountries,
                        iconWidth: 18.w,
                        iconHeight: 18.h,
                        value: '30+',
                        label: 'Countries',
                      ),
                      SizedBox(width: 9.w),
                      _StatCard(
                        iconAsset: onboardingIconRating,
                        iconWidth: 18.w,
                        iconHeight: 17.h,
                        value: '4.9/5',
                        label: 'User rating',
                      ),
                    ],
                    ),
                  ),

                  const Spacer(),

                  // Create my brand button
                  RoundButton(
                    title: 'Create my brand',
                    onTap: () => Get.toNamed(AppRoutes.onboardingGoals),
                    color: AppColors.buttonColor,
                  ),
                  SizedBox(height: 12.h),

                  // Login outline button
                  InkWell(
                    onTap: () => Get.toNamed(AppRoutes.login),
                    borderRadius: BorderRadius.circular(10.r),
                    child: Container(
                      height: 50.h,
                      width: double.infinity,
                      decoration: BoxDecoration(
                        color: Colors.white,
                        border: Border.all(
                          color: const Color(0xFF090A0C),
                        ),
                        borderRadius: BorderRadius.circular(10.r),
                      ),
                      child: Center(
                        child: Text(
                          'Login',
                          style: GoogleFonts.outfit(
                            fontSize: 16.sp,
                            fontWeight: FontWeight.w600,
                            color: const Color(0xFF090A0C),
                          ),
                        ),
                      ),
                    ),
                  ),
                  SizedBox(height: 24.h),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _BottomCircleClipper extends CustomClipper<Path> {
  @override
  Path getClip(Size size) {
    return Path()
      ..lineTo(0, size.height)
      ..arcToPoint(
        Offset(size.width, size.height),
        radius: Radius.circular(size.width * 0.85),
        clockwise: false,
      )
      ..lineTo(size.width, 0)
      ..close();
  }

  @override
  bool shouldReclip(covariant CustomClipper<Path> oldClipper) => false;
}

class _StatCard extends StatelessWidget {
  final String iconAsset;
  final double iconWidth;
  final double iconHeight;
  final String value;
  final String label;

  const _StatCard({
    required this.iconAsset,
    required this.iconWidth,
    required this.iconHeight,
    required this.value,
    required this.label,
  });

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: Container(
        padding: EdgeInsets.all(10.r),
        decoration: BoxDecoration(
          color: Colors.white,
          border: Border.all(color: const Color(0xFFE4E4E7)),
          borderRadius: BorderRadius.circular(10.r),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Icon with circle background
            SizedBox(
              width: 32.w,
              height: 32.h,
              child: Stack(
                children: [
                  SvgPicture.asset(
                    onboardingEllipse,
                    width: 32.w,
                    height: 32.h,
                    fit: BoxFit.fill,
                  ),
                  Positioned(
                    left: 7.w,
                    top: 7.h,
                    child: SvgPicture.asset(
                      iconAsset,
                      width: iconWidth,
                      height: iconHeight,
                      fit: BoxFit.contain,
                    ),
                  ),
                ],
              ),
            ),
            SizedBox(height: 8.h),

            // Value
            Text(
              value,
              style: GoogleFonts.workSans(
                fontSize: 18.sp,
                fontWeight: FontWeight.w700,
                color: const Color(0xFF27272A),
                height: 20 / 18,
              ),
            ),

            // Label
            Text(
              label,
              style: GoogleFonts.workSans(
                fontSize: 12.sp,
                fontWeight: FontWeight.w400,
                color: const Color(0xFF27272A),
                height: 20 / 12,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
