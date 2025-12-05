import 'package:atella/Modules/Home/View/Widgets/profile_textField.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import '../../../../core/themes/app_colors.dart';
import '../../../../Widgets/app_header.dart';
import '../../../../Widgets/custom_roundbutton.dart';
import '../../../auth/View/Widgets/auth_textfield.dart';
import '../../Controllers/profile_controller.dart';
import 'package:atella/core/themes/app_fonts.dart';

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({super.key});

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  final ProfileController controller = Get.put(ProfileController());

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Padding(
          padding: EdgeInsets.symmetric(horizontal: 24.w),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Header
              GlobalHeader(title: 'Edit Profile', onBack: () => Get.back()),

              SizedBox(height: 40.h),

              // Form Fields
              // Full Name
              AuthTextField(
                label: 'Full Name',
                controller: controller.fullNameController,
              ),

              SizedBox(height: 20.h),

              ProfileTextfield(label: 'Email', controller: controller.emailController, enabled: false),

              SizedBox(height: 24.h),

              Obx(() => Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Expanded(
                        child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'Allow analytics',
                              style: gsTextStyle16600,
                            ),
                            SizedBox(height: 6.h),
                            Text(
                                'We record sessions with text and images blurred (masked). Turn this off to stop all analytics and recordings.',
                                style: uiTextTextStyle13500.copyWith(
                                  color: Colors.grey[600],
                                ),
                              ),
                          ],
                          ),
                        ),
                        SizedBox(width: 28.w),
                      Switch(
                        activeColor: Colors.white,
                        activeTrackColor:
                            AppColors.buttonColor.withOpacity(0.25),
                        inactiveThumbColor: Colors.white,
                        inactiveTrackColor: Colors.grey.shade300,
                        thumbColor: MaterialStateProperty.resolveWith(
                          (states) =>
                              states.contains(MaterialState.selected)
                                  ? AppColors.buttonColor
                                  : Colors.white,
                        ),
                        value: controller.analyticsOptIn.value,
                        onChanged: controller.toggleAnalyticsOptIn,
                      ),
                    ],
                  )),

              Spacer(),
              Obx(
                () => RoundButton(
                  title: 'Update',
                  onTap: controller.updateProfile,
                  color: AppColors.buttonColor,
                  isloading: controller.isLoading.value,
                ),
              ),
              SizedBox(height: 40.h),
            ],
          ),
        ),
      ),
    );
  }
}
