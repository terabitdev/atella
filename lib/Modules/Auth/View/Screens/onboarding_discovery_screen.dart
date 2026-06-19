import 'package:atella/Modules/Auth/View/Widgets/onboarding_step_indicator.dart';
import 'package:atella/Routes/app_routes.dart';
import 'package:atella/core/constants/app_images.dart';
import 'package:atella/core/themes/app_colors.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';

class OnboardingDiscoveryScreen extends StatefulWidget {
  const OnboardingDiscoveryScreen({super.key});

  @override
  State<OnboardingDiscoveryScreen> createState() =>
      _OnboardingDiscoveryScreenState();
}

class _OnboardingDiscoveryScreenState extends State<OnboardingDiscoveryScreen> {
  int _selectedIndex = 0; // Instagram pre-selected

  static const List<List<String>> _options = [
    ['Instagram', onboardingDiscInstagram],
    ['TikTok', onboardingDiscTiktok],
    ['App Store', onboardingDiscAppStore],
    ['Recommendation', onboardingDiscRecommendation],
    ['Other', onboardingDiscOther],
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.backgroundColor,
      body: SafeArea(
        child: Padding(
          padding: EdgeInsets.symmetric(horizontal: 16.w),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              SizedBox(height: 16.h),

              OnboardingStepIndicator(currentStep: 2),
              SizedBox(height: 28.h),

              Text(
                'How did you discover Atelia?',
                style: GoogleFonts.manrope(
                  fontSize: 22.sp,
                  fontWeight: FontWeight.w800,
                  color: const Color(0xFF333333),
                  height: 1.2,
                ),
              ),
              SizedBox(height: 12.h),

              Text(
                'Help us improve by sharing how you found us.',
                style: GoogleFonts.manrope(
                  fontSize: 16.sp,
                  fontWeight: FontWeight.w500,
                  color: const Color(0xFF6E6D6F),
                  height: 22 / 16,
                ),
              ),
              SizedBox(height: 24.h),

              ...List.generate(_options.length, (i) {
                final isSelected = _selectedIndex == i;
                return Padding(
                  padding: EdgeInsets.only(
                    bottom: i < _options.length - 1 ? 12.h : 0,
                  ),
                  child: _OptionTile(
                    label: _options[i][0],
                    iconAsset: _options[i][1],
                    isSelected: isSelected,
                    onTap: () => setState(() => _selectedIndex = i),
                  ),
                );
              }),

              const Spacer(),

              Row(
                children: [
                  Expanded(
                    child: _OutlineButton(
                      label: 'Previous',
                      onTap: () => Get.back(),
                    ),
                  ),
                  SizedBox(width: 11.w),
                  Expanded(
                    child: _FilledButton(
                      label: 'Next',
                      onTap: () => Get.toNamed(AppRoutes.onboardingExperience),
                    ),
                  ),
                ],
              ),
              SizedBox(height: 24.h),
            ],
          ),
        ),
      ),
    );
  }
}

class _OptionTile extends StatelessWidget {
  final String label;
  final String iconAsset;
  final bool isSelected;
  final VoidCallback onTap;

  const _OptionTile({
    required this.label,
    required this.iconAsset,
    required this.isSelected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: double.infinity,
        padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 15.h),
        decoration: BoxDecoration(
          color: Colors.white,
          border: Border.all(
            color: isSelected
                ? const Color(0xFF090A0C)
                : const Color(0xFFE4E4E7),
            width: isSelected ? 2 : 1,
          ),
          borderRadius: BorderRadius.circular(10.r),
          boxShadow: isSelected
              ? [
                  BoxShadow(
                    color: const Color(0x050F172A),
                    offset: const Offset(0, 8),
                    blurRadius: 16,
                  ),
                  BoxShadow(
                    color: const Color(0x080F172A),
                    offset: const Offset(0, 4),
                    blurRadius: 8,
                  ),
                ]
              : null,
        ),
        child: Row(
          children: [
            SvgPicture.asset(
              iconAsset,
              width: 32.w,
              height: 32.h,
              fit: BoxFit.contain,
            ),
            SizedBox(width: 8.w),
            Expanded(
              child: Text(
                label,
                style: GoogleFonts.workSans(
                  fontSize: 16.sp,
                  fontWeight: FontWeight.w500,
                  color: isSelected
                      ? const Color(0xFF090A0C)
                      : const Color(0xFF27272A),
                  letterSpacing: -0.112,
                  height: 22 / 16,
                ),
              ),
            ),
            SizedBox(width: 16.w),
            Container(
              width: 20.w,
              height: 20.h,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: isSelected ? const Color(0xFF090A0C) : Colors.white,
                border: isSelected
                    ? null
                    : Border.all(color: const Color(0xFFD4D4D8)),
              ),
              child: isSelected
                  ? Icon(Icons.check, color: Colors.white, size: 12.sp)
                  : null,
            ),
          ],
        ),
      ),
    );
  }
}

class _OutlineButton extends StatelessWidget {
  final String label;
  final VoidCallback onTap;

  const _OutlineButton({required this.label, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        height: 50.h,
        decoration: BoxDecoration(
          color: Colors.white,
          border: Border.all(color: const Color(0xFF090A0C)),
          borderRadius: BorderRadius.circular(10.r),
        ),
        child: Center(
          child: Text(
            label,
            style: GoogleFonts.outfit(
              fontSize: 16.sp,
              fontWeight: FontWeight.w600,
              color: const Color(0xFF090A0C),
            ),
          ),
        ),
      ),
    );
  }
}

class _FilledButton extends StatelessWidget {
  final String label;
  final VoidCallback onTap;

  const _FilledButton({required this.label, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        height: 50.h,
        decoration: BoxDecoration(
          color: const Color(0xFF090A0C),
          borderRadius: BorderRadius.circular(10.r),
        ),
        child: Center(
          child: Text(
            label,
            style: GoogleFonts.outfit(
              fontSize: 16.sp,
              fontWeight: FontWeight.w600,
              color: Colors.white,
            ),
          ),
        ),
      ),
    );
  }
}
