import 'package:atella/Routes/app_routes.dart';
import 'package:atella/Widgets/custom_roundbutton.dart';
import 'package:atella/core/constants/app_images.dart';
import 'package:atella/core/themes/app_colors.dart';
import 'package:atella/core/themes/app_fonts.dart';
import 'package:atella/l10n/generated/app_localizations.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';

class OnboardingBrandScreen extends StatelessWidget {
  const OnboardingBrandScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    return Scaffold(
      body: SingleChildScrollView(
        child: Column(
          children: [
            SizedBox(
              height: 420.h,
              width: double.infinity,
              child: Image.asset(onboardingHeroImage, fit: BoxFit.cover),
            ),
            Container(
              width: double.infinity,
              padding: EdgeInsets.symmetric(horizontal: 24.w),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.vertical(top: Radius.circular(60.r)),
              ),
              child: Column(
                children: [
                  SizedBox(height: 16.h),
                  Text(
                    l10n.onboardingBrandTitle,
                    textAlign: TextAlign.center,
                    style: osTextStyle18600,
                  ),
                  SizedBox(height: 12.h),
                  Text(
                    l10n.onboardingBrandSubtitle,
                    textAlign: TextAlign.center,
                    style: osTextStyle165002,
                  ),
                  SizedBox(height: 20.h),
                  IntrinsicHeight(
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        _StatCard(
                          iconAsset: onboardingIconBrands,
                          iconWidth: 16.w,
                          iconHeight: 14.h,
                          value: '500+',
                          label: l10n.onboardingBrandStatBrands,
                        ),
                        SizedBox(width: 9.w),
                        _StatCard(
                          iconAsset: onboardingIconCountries,
                          iconWidth: 18.w,
                          iconHeight: 18.h,
                          value: '30+',
                          label: l10n.onboardingBrandStatCountries,
                        ),
                        SizedBox(width: 9.w),
                        _StatCard(
                          iconAsset: onboardingIconRating,
                          iconWidth: 18.w,
                          iconHeight: 17.h,
                          value: '4.9/5',
                          label: l10n.onboardingBrandStatRating,
                        ),
                      ],
                    ),
                  ),
                  SizedBox(height: 24.h),
                  RoundButton(
                    title: l10n.onboardingBrandCta,
                    onTap: () => Get.toNamed(AppRoutes.onboardingGoals),
                    color: AppColors.buttonColor,
                  ),
                  SizedBox(height: 12.h),
                  InkWell(
                    onTap: () => Get.toNamed(AppRoutes.login),
                    borderRadius: BorderRadius.circular(10.r),
                    child: Container(
                      height: 50.h,
                      width: double.infinity,
                      decoration: BoxDecoration(
                        color: Colors.white,
                        border: Border.all(color: const Color(0xFF090A0C)),
                        borderRadius: BorderRadius.circular(10.r),
                      ),
                      child: Center(
                        child: Text(
                          l10n.login,
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
          ],
        ),
      ),
    );
  }
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
            Container(
              width: 32.w,
              height: 32.h,
              decoration: const BoxDecoration(
                color: Color(0xFFDBDDE1),
                shape: BoxShape.circle,
              ),
              child: Center(
                child: SvgPicture.asset(
                  iconAsset,
                  width: iconWidth,
                  height: iconHeight,
                  fit: BoxFit.contain,
                ),
              ),
            ),
            SizedBox(height: 8.h),
            Text(
              value,
              style: GoogleFonts.workSans(
                fontSize: 18.sp,
                fontWeight: FontWeight.w700,
                color: const Color(0xFF27272A),
                height: 20 / 18,
              ),
            ),
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
