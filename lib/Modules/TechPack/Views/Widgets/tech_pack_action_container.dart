import 'package:atella/Modules/TechPack/Views/Widgets/outline_genrate_round_button.dart';
import 'package:atella/core/constants/app_images.dart';
import 'package:atella/core/themes/app_fonts.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:atella/Widgets/custom_roundbutton.dart';
import 'package:atella/core/themes/app_colors.dart';

class TechPackActionContainer extends StatelessWidget {
  final VoidCallback onMakeChanges;
  final VoidCallback onContinue;
  final bool isLoading;
  const TechPackActionContainer({
    super.key,
    required this.onMakeChanges,
    required this.onContinue,
    this.isLoading = false,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Container(
          margin: EdgeInsets.symmetric(vertical: 18.h),
          padding: EdgeInsets.symmetric(vertical: 18.h, horizontal: 16.w),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(16.r),
            color: Color.fromRGBO(211, 213, 223, 1),
          ),
          child: Text(
            'Would you like to make any changes before I create the final tech pack?',
            textAlign: TextAlign.center,
            style: gsTextStyle16400,
          ),
        ),
        RoundButton(
          title: "Yes, I'd like to make changes",
          onTap: onMakeChanges,
          color: AppColors.buttonColor,
          isloading: isLoading,
        ),
        SizedBox(height: 12.h),
        OutlineGenerateRoundButton(
          title: 'No, continue as is',
          onTap: onContinue,
          color: AppColors.buttonColor,
          loading: isLoading,
          imagePath: generateTechPackIcon,
        ),
        SizedBox(height: 23.h),
      ],
    );
  }
}
