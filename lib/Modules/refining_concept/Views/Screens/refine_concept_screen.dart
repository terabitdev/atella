import 'package:atella/l10n/generated/app_localizations.dart';
import 'package:atella/Widgets/custom_roundbutton.dart';
import 'package:atella/core/constants/app_images.dart';
import 'package:atella/core/themes/app_colors.dart';
import 'package:atella/core/themes/app_fonts.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';

class RefineConceptScreen extends StatelessWidget {
  const RefineConceptScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    return Scaffold(
      body: Column(
        children: [
          // Top Image Section
          SizedBox(
            height: 450.h,
            width: double.infinity,
            child: Image.asset(refineIcon, fit: BoxFit.cover),
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
                    l10n.rcRefiningTheConcept,
                    textAlign: TextAlign.center,
                    style: osTextStyle18600,
                  ),
                  SizedBox(height: 12.h),
                  Text(
                    l10n.rcNowToHelpMeRefine,
                    textAlign: TextAlign.center,
                    style: osTextStyle165002,
                  ),
                  Text(
                    l10n.rcProposeThreeConceptOptions,
                    textAlign: TextAlign.center,
                    style: osTextStyle165002,
                  ),
                  SizedBox(height: 50.h),
                  RoundButton(
                    title: l10n.rcContinue,
                    onTap: () {
                      // Pass through any arguments (like edit mode data) to the next screen
                      final arguments = Get.arguments;
                      if (arguments != null) {
                        Get.toNamed('/refining_concept', arguments: arguments);
                      } else {
                        Get.toNamed('/refining_concept');
                      }
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
