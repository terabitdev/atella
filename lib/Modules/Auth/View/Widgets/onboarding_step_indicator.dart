import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:google_fonts/google_fonts.dart';

class OnboardingStepIndicator extends StatelessWidget {
  final int currentStep; // 0-indexed

  const OnboardingStepIndicator({super.key, required this.currentStep});

  static const _labels = ['Goals', 'Production', 'Discovery', 'Experience'];

  @override
  Widget build(BuildContext context) {
    final circleDia = 25.w;

    return SizedBox(
      width: double.infinity,
      child: Padding(
        padding: EdgeInsets.symmetric(horizontal: 20.w),
        child: LayoutBuilder(builder: (context, constraints) {
          final w = constraints.maxWidth;
          final n = _labels.length;
          final centers = List.generate(
            n,
            (i) => circleDia / 2 + (w - circleDia) * i / (n - 1),
          );

          return SizedBox(
            height: circleDia + 7.h + 14.h,
            child: Stack(
              clipBehavior: Clip.none,
              children: [
                // Grey base line (full width)
                Positioned(
                  left: centers.first,
                  width: centers.last - centers.first,
                  top: circleDia / 2 - 1.85.h,
                  child: Container(
                    height: 3.7.h,
                    color: const Color(0xFFE0E0E0),
                  ),
                ),
                // Dark progress line overlay up to currentStep circle
                if (currentStep > 0)
                  Positioned(
                    left: centers.first,
                    width: centers[currentStep] - centers.first,
                    top: circleDia / 2 - 1.85.h,
                    child: Container(
                      height: 3.7.h,
                      decoration: BoxDecoration(
                        color: const Color(0xFF090A0C),
                        borderRadius: BorderRadius.circular(46.r),
                      ),
                    ),
                  ),
                // Circles + labels (drawn on top of lines)
                for (int i = 0; i < n; i++)
                  Positioned(
                    left: centers[i] - circleDia / 2,
                    top: 0,
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Container(
                          width: circleDia,
                          height: circleDia,
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            color: i <= currentStep
                                ? const Color(0xFF090A0C)
                                : const Color(0xFFD4D4D8),
                          ),
                          child: Center(
                            child: Text(
                              '${i + 1}',
                              style: GoogleFonts.workSans(
                                fontSize: 14.sp,
                                fontWeight: FontWeight.w500,
                                color: Colors.white,
                                height: 1,
                              ),
                            ),
                          ),
                        ),
                        SizedBox(height: 7.h),
                        Opacity(
                          opacity: i <= currentStep ? 1.0 : 0.31,
                          child: Text(
                            _labels[i],
                            style: GoogleFonts.workSans(
                              fontSize: 9.sp,
                              fontWeight: FontWeight.w500,
                              color: const Color(0xFF27272A),
                              letterSpacing: -0.065,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
              ],
            ),
          );
        }),
      ),
    );
  }
}
