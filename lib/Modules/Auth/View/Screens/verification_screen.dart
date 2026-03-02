import 'package:atella/Modules/Auth/View/Widgets/auth_textfield.dart';
import 'package:atella/Widgets/app_header.dart';
import 'package:atella/Widgets/custom_roundbutton.dart';
import 'package:atella/l10n/generated/app_localizations.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import '../../../../core/themes/app_colors.dart';
import '../../../../core/themes/app_fonts.dart';
import '../../Controllers/verification_controller.dart';

class VerificationScreen extends StatefulWidget {
  const VerificationScreen({super.key});

  @override
  State<VerificationScreen> createState() => _VerificationScreenState();
}

class _VerificationScreenState extends State<VerificationScreen> {
  final VerificationController controller = Get.put(VerificationController());

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: Padding(
          padding: EdgeInsets.symmetric(horizontal: 24.w),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              GlobalHeader(title: l10n.verification),
              SizedBox(height: 32.h),
              // Description text
              Text(
                l10n.verificationDescription,
                style: vsTextStyle145002,
              ),
              SizedBox(height: 24.h),
              AuthTextField(
                  label: l10n.email,
                  controller: controller.emailController,
                ),
              const Spacer(),
              RoundButton(
                title: l10n.sendVerificationLink,
                onTap: () => controller.sendVerificationLink(controller.emailController.text),
                color: AppColors.buttonColor,
                isloading: false,
              ),
              SizedBox(height: 90.h),
            ],
          ),
        ),
      ),
    );
  }
}
