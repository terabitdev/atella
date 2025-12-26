import 'package:atella/l10n/generated/app_localizations.dart';
import 'package:atella/Widgets/custom_roundbutton.dart';
import 'package:atella/core/constants/app_images.dart';
import 'package:atella/core/themes/app_colors.dart';
import 'package:atella/core/themes/app_fonts.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';

class GatheringBriefScreen extends StatelessWidget {
  const GatheringBriefScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    return Scaffold(
      body: SingleChildScrollView(
        child: Column(
          children: [
            SizedBox(
              height: 400.h,
              width: double.infinity,
              child: Image.asset(chatbriefIcon, fit: BoxFit.cover),
            ),
            Container(
              width: double.infinity,
              constraints: BoxConstraints(
                minHeight: MediaQuery.of(context).size.height * 0.5,
              ),
              padding: EdgeInsets.only(
                left: 24.w,
                right: 24.w,
                top: 40.h,
                bottom: 60.h,
              ),
              decoration: const BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.vertical(top: Radius.circular(60)),
              ),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Column(
                    children: [
                      Text(
                        l10n.gatheringTheCreativeBrief,
                        textAlign: TextAlign.center,
                        style: osTextStyle18600,
                      ),
                      SizedBox(height: 12.h),
                      Text(
                        l10n.asYourExpertVirtualFashionDesigner,
                        textAlign: TextAlign.center,
                        style: gsTextStyle16600,
                      ),
                      SizedBox(height: 18.h),
                      Padding(
                        padding: EdgeInsets.symmetric(horizontal: 8.w),
                        child: Text(
                          l10n.imHereToHelpCreateCustomGarment,
                          textAlign: TextAlign.center,
                          style: osTextStyle165002,
                        ),
                      ),
                    ],
                  ),
                  SizedBox(height: 40.h),
                  RoundButton(
                    title: l10n.getStarted,
                    onTap: () {
                      Get.toNamed('/creative_brief');
                    },
                    color: AppColors.buttonColor,
                    isloading: false,
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
