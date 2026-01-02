import 'package:atella/Modules/tech_pack/Views/Widgets/outline_genrate_round_button.dart';
import 'package:atella/core/constants/app_images.dart';
import 'package:atella/core/themes/app_fonts.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:atella/Widgets/custom_roundbutton.dart';
import 'package:atella/core/themes/app_colors.dart';
import 'package:atella/l10n/generated/app_localizations.dart';

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
    final l10n = AppLocalizations.of(context)!;
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
            l10n.tpWouldYouLikeChanges,
            textAlign: TextAlign.center,
            style: gsTextStyle16400,
          ),
        ),
        RoundButton(
          title: l10n.tpYesChanges,
          onTap: onMakeChanges,
          color: AppColors.buttonColor,
          isloading: isLoading,
        ),
        SizedBox(height: 12.h),
        OutlineGenerateRoundButton(
          title: l10n.tpContinueAsIs,
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
