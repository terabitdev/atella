import 'package:atella/Modules/Auth/View/Widgets/onboarding_step_indicator.dart';
import 'package:atella/Routes/app_routes.dart';
import 'package:atella/core/themes/app_colors.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';

class OnboardingProductionScreen extends StatefulWidget {
  const OnboardingProductionScreen({super.key});

  @override
  State<OnboardingProductionScreen> createState() =>
      _OnboardingProductionScreenState();
}

class _OnboardingProductionScreenState
    extends State<OnboardingProductionScreen> {
  int _selectedIndex = 2; // "20–100 → Grow a brand" pre-selected

  static const List<String> _options = [
    '1–5 → Test an idea',
    '5–20 → Small launch',
    '20–100 → Grow a brand',
    '100+ → Scale up',
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

              OnboardingStepIndicator(currentStep: 1),
              SizedBox(height: 28.h),

              Text(
                'How many pieces do you want to launch?',
                style: GoogleFonts.manrope(
                  fontSize: 22.sp,
                  fontWeight: FontWeight.w800,
                  color: const Color(0xFF333333),
                  height: 1.2,
                ),
              ),
              SizedBox(height: 12.h),

              Text(
                'We\'ll adjust factories and recommendations accordingly.',
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
                    label: _options[i],
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
                      onTap: () => Get.toNamed(AppRoutes.onboardingDiscovery),
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
  final bool isSelected;
  final VoidCallback onTap;

  const _OptionTile({
    required this.label,
    required this.isSelected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: double.infinity,
        padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 20.h),
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
