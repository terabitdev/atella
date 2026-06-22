import 'package:atella/Routes/app_routes.dart';
import 'package:atella/core/constants/app_images.dart';
import 'package:atella/core/themes/app_colors.dart';
import 'package:atella/l10n/generated/app_localizations.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';

class OnboardingBrandStartScreen extends StatelessWidget {
  const OnboardingBrandStartScreen({super.key});

  List<_Step> _steps(AppLocalizations l10n) => [
    _Step('1', l10n.onboardingBrandStartStep1),
    _Step('2', l10n.onboardingBrandStartStep2),
    _Step('3', l10n.onboardingBrandStartStep3),
  ];

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final steps = _steps(l10n);
    return Scaffold(
      backgroundColor: AppColors.backgroundColor,
      body: SafeArea(
        child: Padding(
          padding: EdgeInsets.symmetric(horizontal: 16.w),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              SizedBox(height: 16.h),

              // Back button — matches GlobalHeader / personal information page style
              GestureDetector(
                onTap: () => Get.back(),
                behavior: HitTestBehavior.opaque,
                child: Padding(
                  padding: EdgeInsets.all(8.w),
                  child: Icon(
                    Icons.arrow_back_ios_new,
                    size: 20.sp,
                    color: Colors.black,
                  ),
                ),
              ),

              SizedBox(height: 20.h),

              // Logo — same asset & size as login page
              Center(
                child: Image.asset(
                  logo,
                  height: 61.h,
                  width: 63.w,
                  fit: BoxFit.contain,
                ),
              ),

              SizedBox(height: 20.h),

              // Title — centered, same sizes as other onboarding screens
              Center(
                child: Text(
                  l10n.onboardingBrandStartTitle,
                  textAlign: TextAlign.center,
                  style: GoogleFonts.manrope(
                    fontSize: 22.sp,
                    fontWeight: FontWeight.w800,
                    color: const Color(0xFF333333),
                    height: 1.2,
                  ),
                ),
              ),
              SizedBox(height: 8.h),

              // Subtitle
              Center(
                child: Text(
                  l10n.onboardingBrandStartSubtitle,
                  textAlign: TextAlign.center,
                  style: GoogleFonts.manrope(
                    fontSize: 16.sp,
                    fontWeight: FontWeight.w500,
                    color: const Color(0xFF6E6D6F),
                    height: 22 / 16,
                  ),
                ),
              ),

              SizedBox(height: 20.h),

              // Hero illustration
              Center(
                child: Image.asset(
                  onboardingBrandStartHero,
                  height: 200.h,
                  fit: BoxFit.contain,
                ),
              ),

              SizedBox(height: 16.h),

              // Step cards — same padding & tile size as features screen
              ...List.generate(steps.length, (i) {
                return Padding(
                  padding: EdgeInsets.only(
                    bottom: i < steps.length - 1 ? 12.h : 0,
                  ),
                  child: _StepCard(step: steps[i]),
                );
              }),

              const Spacer(),

              // Full-width CTA button
              SizedBox(
                width: double.infinity,
                height: 50.h,
                child: GestureDetector(
                  onTap: () => Get.toNamed(AppRoutes.signup),
                  child: Container(
                    decoration: BoxDecoration(
                      color: const Color(0xFF090A0C),
                      borderRadius: BorderRadius.circular(10.r),
                    ),
                    child: Center(
                      child: Text(
                        l10n.onboardingBrandStartCta,
                        style: GoogleFonts.outfit(
                          fontSize: 16.sp,
                          fontWeight: FontWeight.w600,
                          color: Colors.white,
                        ),
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
    );
  }
}

class _Step {
  final String number;
  final String label;
  const _Step(this.number, this.label);
}

class _StepCard extends StatelessWidget {
  final _Step step;

  const _StepCard({required this.step});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: EdgeInsets.symmetric(horizontal: 14.w, vertical: 12.h),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(10.r),
      ),
      child: Row(
        children: [
          Container(
            width: 34.w,
            height: 34.h,
            decoration: BoxDecoration(
              color: const Color(0xFFF4F4F4),
              borderRadius: BorderRadius.circular(100.r),
            ),
            child: Center(
              child: Text(
                step.number,
                style: GoogleFonts.workSans(
                  fontSize: 16.sp,
                  fontWeight: FontWeight.w600,
                  color: const Color(0xFF090A0C),
                  letterSpacing: -0.1,
                  height: 1,
                ),
              ),
            ),
          ),
          SizedBox(width: 12.w),
          Text(
            step.label,
            style: GoogleFonts.workSans(
              fontSize: 16.sp,
              fontWeight: FontWeight.w500,
              color: const Color(0xFF27272A),
              letterSpacing: -0.1,
              height: 1,
            ),
          ),
        ],
      ),
    );
  }
}
