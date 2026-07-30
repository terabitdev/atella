import 'package:atella/Modules/Auth/View/Widgets/auth_header.dart';
import 'package:atella/Modules/Auth/View/Widgets/auth_textfield.dart';
import 'package:atella/Modules/SupplierAuth/Controllers/supplier_invite_signup_controller.dart';
import 'package:atella/Widgets/custom_roundbutton.dart';
import 'package:atella/core/themes/app_colors.dart';
import 'package:atella/core/themes/app_fonts.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';

class SupplierInviteSignupScreen extends StatelessWidget {
  const SupplierInviteSignupScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final controller = Get.find<SupplierInviteSignupController>();

    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: Padding(
          padding: EdgeInsets.symmetric(horizontal: 24.w),
          child: Obx(() {
            if (controller.isValidating.value) {
              return const Center(child: CircularProgressIndicator());
            }

            if (controller.validationError.value.isNotEmpty) {
              return Center(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(Icons.link_off, size: 48.sp, color: Colors.grey[500]),
                    SizedBox(height: 16.h),
                    Text(
                      controller.validationError.value,
                      textAlign: TextAlign.center,
                      style: gsTextStyle16600,
                    ),
                  ],
                ),
              );
            }

            return SingleChildScrollView(
              child: Column(
                children: [
                  SizedBox(height: 24.h),
                  AuthHeader(title: 'Join Atella as a Supplier'),
                  Text(
                    controller.companyName.value,
                    style: gsTextStyle16600,
                    textAlign: TextAlign.center,
                  ),
                  SizedBox(height: 24.h),

                  Align(
                    alignment: Alignment.centerLeft,
                    child: Text('Email', style: authLableTextTextStyle14400),
                  ),
                  SizedBox(height: 6.h),
                  Container(
                    width: double.infinity,
                    padding: EdgeInsets.symmetric(horizontal: 12.w, vertical: 16.h),
                    decoration: BoxDecoration(
                      color: const Color(0xFFF4F4F4),
                      borderRadius: BorderRadius.circular(6.r),
                      border: Border.all(color: const Color.fromRGBO(233, 233, 233, 1), width: 1.2),
                    ),
                    child: Text(controller.lockedEmail.value, style: authLableTextTextStyle144001),
                  ),
                  SizedBox(height: 16.h),
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
                                style: TextStyle(color: Colors.red, fontSize: 12.sp),
                              ),
                            ),
                          )
                        : const SizedBox.shrink(),
                  ),
                  SizedBox(height: 16.h),
                  AuthTextField(
                    label: 'Confirm password',
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
                                style: TextStyle(color: Colors.red, fontSize: 12.sp),
                              ),
                            ),
                          )
                        : const SizedBox.shrink(),
                  ),
                  SizedBox(height: 32.h),
                  Obx(
                    () => RoundButton(
                      title: controller.isSubmitting.value ? 'Creating account...' : 'Create account',
                      color: AppColors.buttonColor,
                      isloading: controller.isSubmitting.value,
                      onTap: controller.isSubmitting.value ? null : controller.submit,
                    ),
                  ),
                  SizedBox(height: 24.h),
                ],
              ),
            );
          }),
        ),
      ),
    );
  }
}
