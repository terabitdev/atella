import 'package:atella/Modules/Home/View/Widgets/profile_textField.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import '../../../../core/themes/app_colors.dart';
import '../../../../Widgets/app_header.dart';
import '../../../auth/View/Widgets/auth_textfield.dart';
import '../../Controllers/profile_controller.dart';

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
              Spacer(),
              // Custom Update Button with Loading State
              Obx(
                () => InkWell(
                  onTap: controller.isLoading.value ? null : controller.updateProfile,
                  child: Container(
                    height: 50.h,
                    width: 375.w,
                    decoration: BoxDecoration(
                      color: controller.isLoading.value
                          ? AppColors.buttonColor.withOpacity(0.6)
                          : AppColors.buttonColor,
                      borderRadius: BorderRadius.circular(10.r),
                    ),
                    child: Center(
                      child: controller.isLoading.value
                          ? Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                SizedBox(
                                  height: 20.h,
                                  width: 20.w,
                                  child: CircularProgressIndicator(
                                    color: Colors.white,
                                    strokeWidth: 2,
                                  ),
                                ),
                                SizedBox(width: 12.w),
                                Text(
                                  'Updating...',
                                  style: TextStyle(
                                    color: Colors.white,
                                    fontSize: 16.sp,
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),
                              ],
                            )
                          : Text(
                              'Update',
                              style: TextStyle(
                                color: Colors.white,
                                fontSize: 16.sp,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                    ),
                  ),
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
