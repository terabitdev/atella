import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import '../../../../core/themes/app_colors.dart';
import '../../../../Widgets/app_header.dart';
import '../../../../Widgets/custom_roundbutton.dart';
import '../../../Auth/View/Widgets/auth_textfield.dart';
import '../Widgets/profile_picture_widget.dart';
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
      backgroundColor: Colors.white,
      body: SafeArea(
        child: Padding(
          padding: EdgeInsets.symmetric(horizontal: 24.w),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Header
              GlobalHeader(title: 'Edit Profile', onBack: () => Get.back()),
              SizedBox(height: 32.h),
              // Profile Picture Section
              Center(
                child: ProfilePictureWidget(
                  imageUrl: controller.profileImageUrl.value.isNotEmpty
                      ? controller.profileImageUrl.value
                      : null,
                  onEditTap: controller.editProfilePicture,
                  size: 120,
                ),
              ),

              SizedBox(height: 40.h),

              // Form Fields
              Expanded(
                child: SingleChildScrollView(
                  child: Column(
                    children: [
                      // Full Name
                      AuthTextField(
                        label: 'Full Name',
                        controller: controller.fullNameController,
                      ),

                      SizedBox(height: 20.h),

                      // Email
                      AuthTextField(
                        label: 'Email',
                        controller: controller.emailController,
                      ),

                      SizedBox(height: 20.h),

                      // Password
                      AuthTextField(
                        label: 'Password',
                        controller: controller.passwordController,
                        isPassword: true,
                      ),

                      SizedBox(height: 20.h),

                      // Confirm Password
                      AuthTextField(
                        label: 'Confirm Password',
                        controller: controller.confirmPasswordController,
                        isPassword: true,
                      ),

                      SizedBox(height: 40.h),
                    ],
                  ),
                ),
              ),

              // Update Button
              Obx(
                () => RoundButton(
                  title: 'Update',
                  onTap: controller.updateProfile,
                  color: AppColors.buttonColor,
                  loading: controller.isLoading.value,
                  isloading: controller.isLoading.value,
                ),
              ),

              SizedBox(height: 20.h),
            ],
          ),
        ),
      ),
    );
  }
}
