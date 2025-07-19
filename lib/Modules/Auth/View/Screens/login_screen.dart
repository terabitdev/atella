import 'package:atella/Modules/Auth/View/Widgets/auth_header.dart';
import 'package:atella/Modules/Auth/View/Widgets/google_signin_button.dart';
import 'package:atella/Widgets/custom_roundbutton.dart';
import 'package:atella/core/themes/app_fonts.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import '../../controllers/login_controller.dart';
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
                SizedBox(height: 20.h),

                /// Password Field
                AuthTextField(
                  label: 'Password',
                  controller: controller.passwordController,
                  isPassword: true,
                ),
                SizedBox(height: 12.h),

                /// Forgot Password
                Align(
                  alignment: Alignment.centerRight,
                  child: TextButton(
                    onPressed: () {
                      Get.toNamed('/verification');
                    },
                    child: Text(
                      "Forgot Password?",
                      style: ForgotTextTextStyle16500,
                    ),
                  ),
                ),
                SizedBox(height: 10.h),

                /// Round Login Button (Global)
                RoundButton(
                  title: "Log in",
                  onTap: controller.login,
                  color: const Color(0xFF8C82FF),
                  isloading: false,
                ),
                const SizedBox(height: 30),

                /// Divider
                Row(
                  children: [
                    Expanded(child: Divider()),
                    Padding(
                      padding: EdgeInsets.symmetric(horizontal: 10),
                      child: Text(
                        "Or continue with",
                        style: ContinuewithTextTextStyle13400,
                      ),
                    ),
                    Expanded(child: Divider()),
                  ],
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
                    Text("Don’t have an account? ", style: LLastTextStyle14400),
                    GestureDetector(
                      onTap: () => Get.toNamed('/signup'),
                      child: Text("Sign Up", style: LLastTextStyle144002),
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
