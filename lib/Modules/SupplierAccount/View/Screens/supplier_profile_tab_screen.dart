import 'dart:io';

import 'package:atella/Modules/Auth/View/Widgets/auth_textfield.dart';
import 'package:atella/Modules/SupplierAccount/Controllers/supplier_home_controller.dart';
import 'package:atella/Widgets/app_header.dart';
import 'package:atella/Widgets/custom_roundbutton.dart';
import 'package:atella/core/themes/app_colors.dart';
import 'package:atella/core/themes/app_fonts.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';

/// Supplier bottom-nav tab 4 of 4 — company profile editing + account actions.
class SupplierProfileTabScreen extends StatelessWidget {
  const SupplierProfileTabScreen({super.key});

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
            padding: EdgeInsets.symmetric(horizontal: 20.w, vertical: 20.h),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                GlobalHeader(
                  title: 'Company Profile',
                  showBackButton: false,
                  actions: [
                    GestureDetector(
                      onTap: controller.logout,
                      child: Text('Log out', style: gsTextStyle16400.copyWith(color: Colors.red)),
                    ),
                  ],
                ),
                SizedBox(height: 24.h),

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
