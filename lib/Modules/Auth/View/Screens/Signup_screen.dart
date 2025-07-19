import 'package:atella/Modules/Auth/View/Widgets/auth_textfield.dart';
import 'package:atella/Widgets/custom_roundbutton.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import '../widgets/auth_header.dart';
import '../widgets/add_profile_picture.dart';

class SignUpscreen extends StatelessWidget {
  final TextEditingController nameController = TextEditingController();
  final TextEditingController emailController = TextEditingController();
  final TextEditingController passwordController = TextEditingController();
  final TextEditingController confirmPasswordController =
      TextEditingController();

  SignUpscreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
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
                    // Implement image picker
                  },
                ),
                AuthTextField(label: "Full Name", controller: nameController),
                SizedBox(height: 16.h),
                AuthTextField(label: "Email", controller: emailController),
                SizedBox(height: 16.h),
                AuthTextField(
                  label: "Password",
                  controller: passwordController,
                  isPassword: true,
                ),
                SizedBox(height: 16.h),
                AuthTextField(
                  label: "Confirm Password",
                  controller: confirmPasswordController,
                  isPassword: true,
                ),
                SizedBox(height: 24.h),
                RoundButton(
                  title: "Sign Up",
                  onTap: () {
                    // Signup logic
                  },
                  color: const Color(0xFF8C82FF),
                  isloading: false,
                ),
                SizedBox(height: 20.h),
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      "Already have an account? ",
                      style: TextStyle(
                        color: Colors.grey.shade600,
                        fontSize: 14.sp,
                      ),
                    ),
                    GestureDetector(
                      onTap: () => Get.toNamed('/login'),
                      child: Text(
                        "Log In",
                        style: TextStyle(
                          color: const Color(0xFF8C82FF),
                          fontWeight: FontWeight.w600,
                          fontSize: 14.sp,
                        ),
                      ),
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
