import 'package:atella/Modules/Auth/View/Widgets/auth_textfield.dart';
import 'package:atella/Widgets/custom_roundbutton.dart';
import 'package:atella/core/themes/app_colors.dart';
import 'package:atella/core/themes/app_fonts.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import '../widgets/auth_header.dart';
import '../widgets/add_profile_picture.dart';
import 'package:atella/Modules/Auth/Controllers/signup_controller.dart';

class SignUpscreen extends StatelessWidget {
  final SignupController controller = Get.put(SignupController());

  SignUpscreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: Padding(
          padding: EdgeInsets.symmetric(horizontal: 24.w),
          child: SingleChildScrollView(
            child: Column(
              children: [
                SizedBox(height: 24.h),
                const AuthHeader(title: "Create your account"),
                AddProfilePicture(
                  onTap: () {
                    // Implement image picker (not required for now)
                  },
                ),
                AuthTextField(
                  label: "Full Name",
                  controller: controller.nameController,
                ),
                Obx(
                  () => controller.nameError.value.isNotEmpty
                      ? Padding(
                          padding: EdgeInsets.only(left: 8.w, top: 2.h),
                          child: Align(
                            alignment: Alignment.centerLeft,
                            child: Text(
                              controller.nameError.value,
                              style: TextStyle(
                                color: Colors.red,
                                fontSize: 12.sp,
                              ),
                            ),
                          ),
                        )
                      : SizedBox.shrink(),
                ),
                SizedBox(height: 16.h),
                AuthTextField(
                  label: "Email",
                  controller: controller.emailController,
                ),
                Obx(
                  () => controller.emailError.value.isNotEmpty
                      ? Padding(
                          padding: EdgeInsets.only(left: 8.w, top: 2.h),
                          child: Align(
                            alignment: Alignment.centerLeft,
                            child: Text(
                              controller.emailError.value,
                              style: TextStyle(
                                color: Colors.red,
                                fontSize: 12.sp,
                              ),
                            ),
                          ),
                        )
                      : SizedBox.shrink(),
                ),
                SizedBox(height: 16.h),
                AuthTextField(
                  label: "Password",
                  controller: controller.passwordController,
                  isPassword: true,
                ),
                Obx(
                  () => controller.passwordError.value.isNotEmpty
                      ? Padding(
                          padding: EdgeInsets.only(left: 8.w, top: 2.h),
                          child: Align(
                            alignment: Alignment.centerLeft,
                            child: Text(
                              controller.passwordError.value,
                              style: TextStyle(
                                color: Colors.red,
                                fontSize: 12.sp,
                              ),
                            ),
                          ),
                        )
                      : SizedBox.shrink(),
                ),
                SizedBox(height: 16.h),
                AuthTextField(
                  label: "Confirm Password",
                  controller: controller.confirmPasswordController,
                  isPassword: true,
                ),
                Obx(
                  () => controller.confirmPasswordError.value.isNotEmpty
                      ? Padding(
                          padding: EdgeInsets.only(left: 8.w, top: 2.h),
                          child: Align(
                            alignment: Alignment.centerLeft,
                            child: Text(
                              controller.confirmPasswordError.value,
                              style: TextStyle(
                                color: Colors.red,
                                fontSize: 12.sp,
                              ),
                            ),
                          ),
                        )
                      : SizedBox.shrink(),
                ),
                SizedBox(height: 12.h),
                Obx(
                  () => RoundButton(
                    title: "Sign Up",
                    onTap: controller.isLoading.value
                        ? null
                        : () {
                            controller.signUp();
                          },
                    color: AppColors.buttonColor,
                    isloading: controller.isLoading.value,
                  ),
                ),
                SizedBox(height: 20.h),
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text("Already Joined? ", style: lLastTextStyle16500),
                    GestureDetector(
                      onTap: () => Get.toNamed('/login'),
                      child: Text("Sign In", style: lLastTextStyle16700),
                    ),
                  ],
                ),
                SizedBox(height: 24.h),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
