import 'package:atella/Widgets/app_header.dart';
import 'package:atella/Widgets/custom_roundbutton.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import '../../../../core/themes/app_colors.dart';
import '../../../../core/themes/app_fonts.dart';
import '../Widgets/verification_method_widget.dart';
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
    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: Padding(
          padding: EdgeInsets.symmetric(horizontal: 24.w),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              GlobalHeader(title: 'Verification', onBack: () => Get.back()),

              SizedBox(height: 32.h),

              // Description text
              Text(
                'Select verification method and we will send verification link',
                style: VSTextStyle145002,
              ),

              SizedBox(height: 24.h),

              // Verification method selection
              Obx(
                () => VerificationMethodWidget(
                  method: 'Email',
                  maskedValue: controller.maskedEmail.value,
                  icon: Icons.email_outlined,
                  isSelected: controller.isEmailSelected,
                  onTap: () => controller.selectVerificationMethod('email'),
                ),
              ),

              const Spacer(),
              RoundButton(
                title: 'Send Verification Link',
                onTap: controller.sendVerificationLink,
                color: AppColors.splashcolor,
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
