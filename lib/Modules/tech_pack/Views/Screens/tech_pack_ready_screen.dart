import 'package:atella/modules/tech_pack/Views/Screens/recommended_manufacture_screen.dart';
import 'package:atella/core/themes/app_fonts.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import '../Widgets/save_export_button_row.dart';
import '../Widgets/save_tech_pack_dialog.dart';
import 'package:atella/Widgets/custom_roundbutton.dart';
import 'package:atella/core/themes/app_colors.dart';
import '../../controllers/tech_pack_ready_controller.dart';
import 'dart:convert';

class TechPackReadyScreen extends StatelessWidget {
  const TechPackReadyScreen({super.key});

  Widget _buildImageFromBase64(String base64String) {
    try {
      final bytes = base64Decode(base64String);
      return Image.memory(
        bytes,
        fit: BoxFit.contain,
        errorBuilder: (context, error, stackTrace) {
          return Container(
            color: Colors.grey[300],
            child: const Icon(Icons.error, color: Colors.red),
          );
        },
      );
    } catch (e) {
      return Container(
        color: Colors.grey[300],
        child: const Icon(Icons.error, color: Colors.red),
      );
    }
  }

  void _showImagePopup(BuildContext context, String base64Image, String title) {
    showDialog(
      context: context,
      barrierDismissible: true,
      builder: (context) {
        return Dialog(
          backgroundColor: Colors.transparent,
          insetPadding: EdgeInsets.symmetric(horizontal: 12.w, vertical: 60.h),
          child: ClipRRect(
            borderRadius: BorderRadius.circular(28.r),
            child: Image.memory(
              base64Decode(base64Image),
              fit: BoxFit.cover,
              errorBuilder: (context, error, stackTrace) {
                  return Container(
                    color: Colors.grey.shade200,
                    child: Center(
                      child: Icon(
                        Icons.error_outline,
                        size: 48.w,
                        color: Colors.grey.shade400,
                      ),
                    ),
                  );
                },
              ),
            ),
        );
      },
    );
  }

  void _showSaveDialog(BuildContext context, TechPackReadyController controller) {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) {
        return SaveTechPackDialog(
          onSave: (projectName, collectionName) async {
            await controller.saveTechPackWithDetails(projectName, collectionName);
          },
        );
      },
    );
  }

  Widget _buildLoadingState() {
    return Column(
      children: [
        Text(
          'Creating your tech pack...',
          style: TextStyle(
            fontSize: 18.sp,
            fontWeight: FontWeight.w600,
            color: Color(0xFF1A1A1A),
          ),
        ),
        SizedBox(height: 8.h),
        Text(
          'Please wait while we generate your tech pack images with all specifications.',
          textAlign: TextAlign.center,
          style: TextStyle(
            fontSize: 14.sp,
            color: Color(0xFF666666),
          ),
        ),
        SizedBox(height: 24.h),
        _buildLoadingCard('Tech Pack Details'),
        SizedBox(height: 16.h),
        _buildLoadingCard('Technical Flat Drawing'),
      ],
    );
  }

  Widget _buildLoadingCard(String title) {
    return Container(
      width: double.infinity,
      height: 200.h,
      decoration: BoxDecoration(
        color: const Color.fromRGBO(236, 239, 246, 1),
        borderRadius: BorderRadius.circular(12.r),
      ),
      child: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Image.asset(
              'assets/images/generate.png', 
              width: 60.w, 
              height: 64.h,
              errorBuilder: (context, error, stackTrace) {
                return Icon(
                  Icons.hourglass_empty,
                  size: 60.w,
                  color: Colors.grey,
                );
              },
            ),
            SizedBox(height: 16.h),
            Text(
              'Generating $title...',
              style: TextStyle(
                fontSize: 17.sp,
                fontWeight: FontWeight.w500,
              ),
            ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final controller = Get.put(TechPackReadyController());
    
    return Scaffold(
      backgroundColor: const Color(0xFFFDFDFD),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 26, vertical: 26),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    'Your Tech Pack Is \nReady',
                    style: tprtTextTextStyle28700,
                  ),
                  InkWell(
                    onTap: () => Get.toNamed('/tech_pack_details_screen'),
                    child: Image.asset(
                      'assets/images/edit.png',
                      width: 36.w,
                      height: 36.h,
                    ),
                  ),
                ],
              ),
              SizedBox(height: 30.h),
              // Generated Tech Pack Images in Column
              Obx(() {
                if (controller.isGenerating) {
                  return _buildLoadingState();
                } else if (controller.hasGeneratedImages && controller.generatedImages.length >= 2) {
                  return Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Generated Tech Pack Images',
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 18.sp,
                        ),
                      ),
                      SizedBox(height: 16.h),
                      
                      GestureDetector(
                        onTap: () => _showImagePopup(context, controller.generatedImages[0], 'Tech Pack Details'),
                        child: Container(
                          width: double.infinity,
                          margin: const EdgeInsets.only(bottom: 16),
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(0),
                          ),
                          child: ClipRRect(
                            borderRadius: BorderRadius.circular(0),
                            child: _buildImageFromBase64(controller.generatedImages[0]),
                          ),
                        ),
                      ),
                      
                      // Second Image - Technical Flat Drawing
                      GestureDetector(
                        onTap: () => _showImagePopup(context, controller.generatedImages[1], 'Technical Flat Drawing'),
                        child: Container(
                          width: double.infinity,
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(0),
                          ),
                          child: ClipRRect(
                            borderRadius: BorderRadius.circular(0),
                            child: _buildImageFromBase64(controller.generatedImages[1]),
                          ),
                        ),
                      ),
                    ],
                  );
                } else {
                  return Container(
                    width: double.infinity,
                    height: 200.h,
                    decoration: BoxDecoration(
                      color: Colors.grey[100],
                      borderRadius: BorderRadius.circular(12.r),
                      border: Border.all(color: Colors.grey[300]!),
                    ),
                    child: Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(
                            Icons.image_not_supported,
                            size: 48.w,
                            color: Colors.grey,
                          ),
                          SizedBox(height: 8.h),
                          Text(
                            'No tech pack images generated yet',
                            style: TextStyle(
                              color: Colors.grey,
                              fontSize: 14.sp,
                            ),
                          ),
                        ],
                      ),
                    ),
                  );
                }
              }),
              SizedBox(height: 30.h),
              RoundButton(
                title: 'Get Manufacturer Suggestions',
                onTap: () {
                  // Get.toNamed('/recommended_tech_pack');
                  Get.to(() => const RecommendedManufactureScreen());
                },
                color: AppColors.buttonColor,
                isloading: false,
              ),
              SizedBox(height: 16.h),
              Obx(() => SaveExportButtonRow(
                onSave: () => _showSaveDialog(context, controller),
                onExport: () => controller.exportTechPackPDF(),
                isSaving: controller.isSaving.value, // Show loading on screen save button
                isExporting: controller.isExporting.value,
              )),
              SizedBox(height: 30.h),
            ],
          ),
        ),
      ),
    );
  }
}
