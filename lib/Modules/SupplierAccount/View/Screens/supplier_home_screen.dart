import 'dart:io';

import 'package:atella/Modules/Auth/View/Widgets/auth_textfield.dart';
import 'package:atella/Modules/SupplierAccount/Controllers/supplier_home_controller.dart';
import 'package:atella/Routes/app_routes.dart';
import 'package:atella/Widgets/custom_roundbutton.dart';
import 'package:atella/core/themes/app_colors.dart';
import 'package:atella/core/themes/app_fonts.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';

class SupplierHomeScreen extends StatelessWidget {
  const SupplierHomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final controller = Get.find<SupplierHomeController>();

    return Scaffold(
      body: SafeArea(
        child: Obx(() {
          if (controller.isLoading.value) {
            return const Center(child: CircularProgressIndicator());
          }

          final supplier = controller.supplier.value;
          if (supplier == null) {
            return Center(
              child: Padding(
                padding: EdgeInsets.symmetric(horizontal: 24.w),
                child: Text(
                  "We couldn't find a supplier profile linked to this account.",
                  textAlign: TextAlign.center,
                  style: gsTextStyle16600,
                ),
              ),
            );
          }

          return SingleChildScrollView(
            padding: EdgeInsets.symmetric(horizontal: 20.w, vertical: 24.h),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text('Supplier Home', style: loginTextTextStyle22700),
                    GestureDetector(
                      onTap: controller.logout,
                      child: Text('Log out', style: forgotTextTextStyle16500),
                    ),
                  ],
                ),
                SizedBox(height: 20.h),
                InkWell(
                  onTap: () => Get.toNamed(AppRoutes.conversationList),
                  child: Container(
                    height: 50.h,
                    width: double.infinity,
                    decoration: BoxDecoration(
                      border: Border.all(color: AppColors.buttonColor),
                      borderRadius: BorderRadius.circular(10.r),
                    ),
                    child: Center(child: Text('Messages', style: gsTextStyle16600)),
                  ),
                ),
                SizedBox(height: 12.h),
                InkWell(
                  onTap: () => Get.toNamed(AppRoutes.orderList, arguments: {'asSupplier': true}),
                  child: Container(
                    height: 50.h,
                    width: double.infinity,
                    decoration: BoxDecoration(
                      border: Border.all(color: AppColors.buttonColor),
                      borderRadius: BorderRadius.circular(10.r),
                    ),
                    child: Center(child: Text('My Orders', style: gsTextStyle16600)),
                  ),
                ),
                SizedBox(height: 24.h),

                _OnboardingStatusCard(controller: controller),
                SizedBox(height: 32.h),

                Text('Company profile', style: gsTextStyle16600),
                SizedBox(height: 16.h),

                _LogoPicker(controller: controller, existingUrl: supplier.logoUrl),
                SizedBox(height: 20.h),

                AuthTextField(label: 'Company name', controller: controller.companyNameController),
                SizedBox(height: 16.h),
                AuthTextField(label: 'Specialty', controller: controller.specialtyController),
                SizedBox(height: 16.h),
                AuthTextField(label: 'Origin country', controller: controller.originCountryController),
                SizedBox(height: 16.h),
                AuthTextField(label: 'Description', controller: controller.descriptionController),
                SizedBox(height: 24.h),

                Obx(
                  () => RoundButton(
                    title: controller.isSaving.value ? 'Saving...' : 'Save profile',
                    color: AppColors.buttonColor,
                    isloading: controller.isSaving.value,
                    onTap: controller.isSaving.value ? null : controller.saveProfile,
                  ),
                ),
                SizedBox(height: 40.h),
              ],
            ),
          );
        }),
      ),
    );
  }
}

class _OnboardingStatusCard extends StatelessWidget {
  final SupplierHomeController controller;
  const _OnboardingStatusCard({required this.controller});

  @override
  Widget build(BuildContext context) {
    final supplier = controller.supplier.value!;
    final complete = supplier.payoutsEnabled;

    return Container(
      width: double.infinity,
      padding: EdgeInsets.all(16.w),
      decoration: BoxDecoration(
        color: complete ? const Color(0xFFEFFAF0) : const Color(0xFFFFF8E8),
        borderRadius: BorderRadius.circular(12.r),
        border: Border.all(color: complete ? Colors.green.shade200 : Colors.orange.shade200),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(
                complete ? Icons.check_circle : Icons.info_outline,
                color: complete ? Colors.green : Colors.orange,
                size: 20.sp,
              ),
              SizedBox(width: 8.w),
              Text(
                complete ? 'Payouts enabled' : 'Payout setup required',
                style: gsTextStyle16600,
              ),
            ],
          ),
          SizedBox(height: 8.h),
          Text(
            complete
                ? 'Stripe has verified your account — you can now receive payments through Atella.'
                : 'Complete Stripe onboarding so you can receive payments for sample and production orders.',
            style: ssTitleTextTextStyle14400,
          ),
          if (!complete) ...[
            SizedBox(height: 14.h),
            Obx(
              () => RoundButton(
                title: controller.isLaunchingOnboarding.value ? 'Opening...' : 'Complete Stripe Onboarding',
                color: AppColors.buttonColor,
                isloading: controller.isLaunchingOnboarding.value,
                onTap: controller.isLaunchingOnboarding.value ? null : controller.startStripeOnboarding,
              ),
            ),
          ],
        ],
      ),
    );
  }
}

class _LogoPicker extends StatelessWidget {
  final SupplierHomeController controller;
  final String? existingUrl;
  const _LogoPicker({required this.controller, this.existingUrl});

  @override
  Widget build(BuildContext context) {
    return Obx(() {
      final localPath = controller.logoLocalPath.value;
      return GestureDetector(
        onTap: controller.pickLogo,
        child: Container(
          height: 90.h,
          width: 90.h,
          decoration: BoxDecoration(
            color: const Color(0xFFF8F9FA),
            borderRadius: BorderRadius.circular(12.r),
            border: Border.all(color: const Color(0xFFE0E0E0)),
          ),
          child: ClipRRect(
            borderRadius: BorderRadius.circular(12.r),
            child: localPath.isNotEmpty
                ? Image.file(File(localPath), fit: BoxFit.cover)
                : (existingUrl != null && existingUrl!.isNotEmpty)
                    ? CachedNetworkImage(imageUrl: existingUrl!, fit: BoxFit.cover)
                    : Icon(Icons.cloud_upload_outlined, color: const Color(0xFF666666), size: 28.w),
          ),
        ),
      );
    });
  }
}
