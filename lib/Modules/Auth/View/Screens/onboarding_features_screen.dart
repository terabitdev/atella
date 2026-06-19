import 'package:atella/Routes/app_routes.dart';
import 'package:atella/core/constants/app_images.dart';
import 'package:atella/core/themes/app_colors.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';

class OnboardingFeaturesScreen extends StatelessWidget {
  const OnboardingFeaturesScreen({super.key});

  // Sprite is a 2×2 grid; each cell is ~51×51 within a 104×104 canvas.
  // (offsetX, offsetY) selects which cell to display.
  static const List<_FeatureItem> _features = [
    _FeatureItem('Turn an idea into a design', 0, 0),
    _FeatureItem('Create with an intelligent assistant', 53, 0),
    _FeatureItem('Auto-generate your tech packs', 0, 52),
    _FeatureItem('Find reliable factories fast', 53, 52),
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

              SizedBox(height: 28.h),

              Text(
                'Atelia takes care of everything',
                style: GoogleFonts.manrope(
                  fontSize: 22.sp,
                  fontWeight: FontWeight.w800,
                  color: const Color(0xFF333333),
                  height: 1.2,
                ),
              ),
              SizedBox(height: 12.h),

              Text(
                'We combine creativity, AI and trusted partners to bring your brand to life.',
                style: GoogleFonts.manrope(
                  fontSize: 16.sp,
                  fontWeight: FontWeight.w500,
                  color: const Color(0xFF6E6D6F),
                  height: 22 / 16,
                ),
              ),
              SizedBox(height: 24.h),

              // Feature cards
              ...List.generate(_features.length, (i) {
                final feature = _features[i];
                return Padding(
                  padding: EdgeInsets.only(
                    bottom: i < _features.length - 1 ? 12.h : 0,
                  ),
                  child: _FeatureCard(item: feature, isFirst: i == 0),
                );
              }),

              const Spacer(),

              // Buttons
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
                      label: 'Continue',
                      onTap: () => Get.toNamed(AppRoutes.onboardingBrandStart),
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

class _FeatureItem {
  final String label;
  final double offsetX;
  final double offsetY;
  const _FeatureItem(this.label, this.offsetX, this.offsetY);
}

class _FeatureCard extends StatelessWidget {
  final _FeatureItem item;
  final bool isFirst;

  const _FeatureCard({required this.item, required this.isFirst});

  @override
  Widget build(BuildContext context) {
    // Each sprite cell is ~51×51 within a 104×104 canvas
    const cellSize = 51.0;
    const canvasSize = 104.0;

    return Container(
      width: double.infinity,
      padding: EdgeInsets.all(16.r),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(10.r),
      ),
      child: Row(
        children: [
          ClipRRect(
            borderRadius: BorderRadius.circular(8.r),
            child: SizedBox(
              width: cellSize.w,
              height: cellSize.h,
              child: OverflowBox(
                maxWidth: canvasSize.w,
                maxHeight: canvasSize.h,
                alignment: Alignment.topLeft,
                child: Transform.translate(
                  offset: Offset(-item.offsetX.w, -item.offsetY.h),
                  child: Image.asset(
                    onboardingFeatureSprite,
                    width: canvasSize.w,
                    height: canvasSize.h,
                    fit: BoxFit.fill,
                  ),
                ),
              ),
            ),
          ),
          SizedBox(width: 8.w),
          Expanded(
            child: Text(
              item.label,
              style: GoogleFonts.workSans(
                fontSize: 15.sp,
                fontWeight: FontWeight.w600,
                color: isFirst
                    ? const Color(0xFF090A0C)
                    : const Color(0xFF27272A),
                letterSpacing: -0.105,
                height: 22 / 15,
              ),
            ),
          ),
        ],
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
