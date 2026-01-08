import 'package:atella/Modules/Home/Controllers/profile_controller.dart';
import 'package:atella/core/themes/app_fonts.dart';
import 'package:atella/core/themes/app_colors.dart';
import 'package:atella/l10n/generated/app_localizations.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';

class DeleteAccountPasswordScreen extends StatefulWidget {
  const DeleteAccountPasswordScreen({super.key});

  @override
  State<DeleteAccountPasswordScreen> createState() =>
      _DeleteAccountPasswordScreenState();
}

class _DeleteAccountPasswordScreenState
    extends State<DeleteAccountPasswordScreen> {
  final ProfileController controller = Get.find<ProfileController>();
  final TextEditingController passwordController = TextEditingController();
  final RxBool isPasswordVisible = false.obs;

  @override
  void dispose() {
    passwordController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;

    return Scaffold(
      backgroundColor: Colors.black,
      body: SafeArea(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header
            Padding(
              padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 12.h),
              child: Row(
                children: [
                  IconButton(
                    onPressed: () => Get.back(),
                    icon: Icon(
                      Icons.arrow_back_ios,
                      color: Colors.white,
                      size: 20.sp,
                    ),
                    padding: EdgeInsets.zero,
                    constraints: BoxConstraints(),
                  ),
                  SizedBox(width: 8.w),
                  Expanded(
                    child: Text(
                      l10n.deleteAccount,
                      style: ssTitleTextTextStyle208001,
                    ),
                  ),
                ],
              ),
            ),
            SizedBox(height: 34.h),

            // Content Container
            Expanded(
              child: Container(
                width: double.infinity,
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.only(
                    topLeft: Radius.circular(30.r),
                    topRight: Radius.circular(30.r),
                  ),
                ),
                child: SingleChildScrollView(
                  padding: EdgeInsets.symmetric(
                    horizontal: 24.w,
                    vertical: 30.h,
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      // Warning Icon
                      Icon(
                        Icons.warning_rounded,
                        color: Colors.red,
                        size: 80.sp,
                      ),
                      SizedBox(height: 24.h),

                      // Title
                      Text(
                        l10n.enterPassword,
                        style: TextStyle(
                          fontSize: 24.sp,
                          fontWeight: FontWeight.w700,
                          color: Colors.black,
                        ),
                      ),
                      SizedBox(height: 12.h),

                      // Message
                      Text(
                        l10n.enterPasswordToConfirm,
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          fontSize: 15.sp,
                          fontWeight: FontWeight.w500,
                          color: Colors.black87,
                          height: 1.5,
                        ),
                      ),
                      SizedBox(height: 40.h),

                      // Password Field
                      Obx(
                        () => TextField(
                          controller: passwordController,
                          obscureText: !isPasswordVisible.value,
                          style: TextStyle(
                            fontSize: 16.sp,
                            fontWeight: FontWeight.w500,
                          ),
                          decoration: InputDecoration(
                            labelText: l10n.password,
                            labelStyle: TextStyle(
                              fontSize: 14.sp,
                              color: Colors.grey.shade600,
                            ),
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(12.r),
                              borderSide: BorderSide(
                                color: Colors.grey.shade300,
                                width: 1.5,
                              ),
                            ),
                            enabledBorder: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(12.r),
                              borderSide: BorderSide(
                                color: Colors.grey.shade300,
                                width: 1.5,
                              ),
                            ),
                            focusedBorder: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(12.r),
                              borderSide: BorderSide(
                                color: AppColors.buttonColor,
                                width: 2,
                              ),
                            ),
                            contentPadding: EdgeInsets.symmetric(
                              horizontal: 16.w,
                              vertical: 16.h,
                            ),
                            suffixIcon: IconButton(
                              icon: Icon(
                                isPasswordVisible.value
                                    ? Icons.visibility
                                    : Icons.visibility_off,
                                color: Colors.grey.shade600,
                              ),
                              onPressed: () {
                                isPasswordVisible.value =
                                    !isPasswordVisible.value;
                              },
                            ),
                          ),
                        ),
                      ),
                      SizedBox(height: 40.h),

                      // Delete Button
                      SizedBox(
                        width: double.infinity,
                        child: Obx(
                          () => ElevatedButton(
                            style: ElevatedButton.styleFrom(
                              backgroundColor: Colors.red,
                              foregroundColor: Colors.white,
                              padding: EdgeInsets.symmetric(
                                vertical: 16.h,
                                horizontal: 20.w,
                              ),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(12.r),
                              ),
                              elevation: 0,
                            ),
                            onPressed: controller.isDeletingAccount.value
                                ? null
                                : () async {
                                    if (passwordController.text.isNotEmpty) {
                                      await controller
                                          .deleteAccountWithPassword(
                                        passwordController.text,
                                      );
                                    } else {
                                      Get.snackbar(
                                        'Error',
                                        'Please enter your password',
                                        backgroundColor: Colors.red,
                                        colorText: Colors.white,
                                        snackPosition: SnackPosition.BOTTOM,
                                        margin: EdgeInsets.all(16.w),
                                      );
                                    }
                                  },
                            child: controller.isDeletingAccount.value
                                ? SizedBox(
                                    width: 24.w,
                                    height: 24.h,
                                    child: CircularProgressIndicator(
                                      strokeWidth: 2.5,
                                      valueColor: AlwaysStoppedAnimation<Color>(
                                        Colors.white,
                                      ),
                                    ),
                                  )
                                : Text(
                                    l10n.deleteMyAccount,
                                    style: TextStyle(
                                      fontSize: 16.sp,
                                      fontWeight: FontWeight.w600,
                                    ),
                                  ),
                          ),
                        ),
                      ),
                      SizedBox(height: 16.h),

                      // Cancel Button
                      SizedBox(
                        width: double.infinity,
                        child: OutlinedButton(
                          style: OutlinedButton.styleFrom(
                            foregroundColor: Colors.black,
                            side: BorderSide(
                              color: Colors.grey.shade300,
                              width: 1.5,
                            ),
                            padding: EdgeInsets.symmetric(
                              vertical: 16.h,
                              horizontal: 20.w,
                            ),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12.r),
                            ),
                          ),
                          onPressed: () => Get.back(),
                          child: Text(
                            l10n.cancel,
                            style: TextStyle(
                              fontSize: 16.sp,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}