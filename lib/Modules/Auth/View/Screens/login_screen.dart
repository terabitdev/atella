import 'package:atella/modules/auth/Controllers/login_controller.dart';
import 'package:atella/modules/auth/View/Widgets/auth_header.dart';
import 'package:atella/modules/auth/View/Widgets/google_signin_button.dart';
import 'package:atella/Widgets/custom_roundbutton.dart';
import 'package:atella/core/themes/app_colors.dart';
import 'package:atella/core/themes/app_fonts.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import '../widgets/auth_textfield.dart';

class LoginScreen extends StatelessWidget {
  LoginScreen({super.key});

  final LoginController controller = Get.find<LoginController>();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Padding(
          padding: EdgeInsets.symmetric(horizontal: 20.w, vertical: 24.h),
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
                Align(
                  alignment: Alignment.centerRight,
                  child: TextButton(
                    onPressed: () {
                      Get.toNamed('/verification');
                    },
                    child: Text("Forgot Password?", style: lLastTextStyle16700),
                  ),
                ),
                SizedBox(height: 10.h),
                Obx(
                  () => RoundButton(
                    title: controller.isLoading.value ? "Logging In..." : "Log In",
                    onTap: controller.isLoading.value
                        ? null
                        : () {
                            controller.login();
                          },
                    color: AppColors.buttonColor,
                    isloading: controller.isLoading.value,
                  ),
                ),
                SizedBox(height: 30.h),
                Center(
                  child: Text(
                    "Or continue with",
                    style: continuewithTextTextStyle13400,
                  ),
                ),
                SizedBox(height: 20.h),
                Obx(
                  () => GoogleRoundButton(
                    title: "Continue with Google",
                    onTap: controller.isGoogleLoading.value
                        ? () {}
                        : () {
                            controller.loginWithGoogle();
                          },
                    color: const Color.fromRGBO(255, 255, 255, 1),
                    loading: controller.isGoogleLoading.value,
                  ),
                ),
                SizedBox(height: 80.h),
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text("Don't have an account? ", style: lLastTextStyle16500),
                    GestureDetector(
                      onTap: () => Get.offNamed('/signup'),
                      child: Text("Sign Up", style: lLastTextStyle16700),
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
