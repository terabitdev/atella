import 'package:atella/Modules/Auth/View/Widgets/auth_header.dart';
import 'package:atella/Modules/Auth/View/Widgets/google_signin_button.dart';
import 'package:atella/Widgets/custom_roundbutton.dart';
import 'package:atella/core/themes/app_colors.dart';
import 'package:atella/core/themes/app_fonts.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:atella/Modules/Auth/Controllers/login_controller.dart';
import '../widgets/auth_textfield.dart';

class LoginScreen extends StatelessWidget {
  final controller = Get.put(LoginController());

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 24),
          child: SingleChildScrollView(
            child: Column(
              children: [
                AuthHeader(title: 'Log in'),
                AuthTextField(
                  label: 'Email',
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
                SizedBox(height: 20.h),

                /// Password Field
                AuthTextField(
                  label: 'Password',
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
                SizedBox(height: 12.h),

                /// Forgot Password
                Align(
                  alignment: Alignment.centerRight,
                  child: TextButton(
                    onPressed: () {
                      Get.toNamed('/verification');
                    },
                    child: Text("Forgot Password?", style: LLastTextStyle16700),
                  ),
                ),
                SizedBox(height: 10.h),

                /// Round Login Button (Global)
                Obx(
                  () => RoundButton(
                    title: "Log in",
                    onTap: controller.isLoading.value
                        ? null
                        : () {
                            controller.login();
                          },
                    color: AppColors.buttonColor,
                    isloading: controller.isLoading.value,
                  ),
                ),
                const SizedBox(height: 30),

                /// Divider
                Center(
                  child: Text(
                    "Or continue with",
                    style: ContinuewithTextTextStyle13400,
                  ),
                ),
                const SizedBox(height: 20),

                /// Google Button (module widget)
                GoogleRoundButton(
                  title: "Continue with Google",
                  onTap: () {
                    // Handle Google Sign-In
                  },
                  color: const Color.fromRGBO(255, 255, 255, 1), // Google Blue
                ),
                SizedBox(height: 80.h),

                /// Sign up navigation
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text("Don’t have an account? ", style: LLastTextStyle16500),
                    GestureDetector(
                      onTap: () => Get.toNamed('/signup'),
                      child: Text("Sign Up", style: LLastTextStyle16700),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
