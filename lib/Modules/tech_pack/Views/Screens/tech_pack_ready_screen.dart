import 'package:atella/Modules/tech_pack/Views/Screens/recommended_manufacture_screen.dart';
import 'package:atella/core/themes/app_fonts.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import '../Widgets/save_export_button_row.dart';
import '../Widgets/save_tech_pack_dialog.dart';
import '../Widgets/export_options_dialog.dart';
import '../Widgets/export_options_controller.dart';
import 'package:atella/Widgets/custom_roundbutton.dart';
import 'package:atella/core/themes/app_colors.dart';
import '../../controllers/tech_pack_ready_controller.dart';
import 'dart:convert';
import 'dart:io';
import 'package:atella/core/widgets/tap_tracking_wrapper.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:lottie/lottie.dart';
import 'package:atella/l10n/generated/app_localizations.dart';

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

  void _showImagePopup(BuildContext context, String base64Image, String title, {String? logoImagePath, String? logoPlacement}) {
    showDialog(
      context: context,
      barrierDismissible: true,
      builder: (context) {
        return Dialog(
          backgroundColor: Colors.transparent,
          insetPadding: EdgeInsets.symmetric(horizontal: 12.w, vertical: 60.h),
          child: ClipRRect(
            borderRadius: BorderRadius.circular(28.r),
            child: logoImagePath != null && logoImagePath.isNotEmpty
                ? Stack(
                    children: [
                      // Main image
                      Image.memory(
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
                      // Logo overlay (top-right)
                      Positioned(
                        top: 16.h,
                        right: 16.w,
                        child: Column(
                          mainAxisSize: MainAxisSize.min,
                          crossAxisAlignment: CrossAxisAlignment.end,
                          children: [
                            // Logo image
                            Image.file(
                              File(logoImagePath),
                              width: 30.w,
                              height: 30.w,
                              fit: BoxFit.contain,
                              errorBuilder: (context, error, stackTrace) {
                                return SizedBox.shrink();
                              },
                            ),
                            // Logo placement text
                            if (logoPlacement != null && logoPlacement.isNotEmpty) ...[
                              SizedBox(height: 4.h),
                              Text(
                                AppLocalizations.of(Get.context!)!.tprLogoPlacement(logoPlacement),
                                style: TextStyle(
                                  fontSize: 10.sp,
                                  color: Colors.black54,
                                  backgroundColor: Colors.white70,
                                ),
                              ),
                            ],
                          ],
                        ),
                      ),
                    ],
                  )
                : Image.memory(
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

  void _showSaveDialog(
    BuildContext context,
    TechPackReadyController controller,
  ) {
    Get.dialog(
      SaveTechPackDialog(
        onSave: (projectName, collectionName) async {
          await controller.saveTechPackWithDetails(
            projectName,
            collectionName,
          );
        },
      ),
      barrierDismissible: true, // Allow dismissing by clicking outside
    );
  }

  void _showExportDialog(
    BuildContext context,
    TechPackReadyController controller,
  ) {
    showDialog(
      context: context,
      barrierDismissible: true,
      builder: (context) {
        return ExportOptionsDialog(
          onExport: (exportType) async {
            // Close dialog first
            Navigator.of(context).pop();
            
            // Wait a moment for dialog to close
            await Future.delayed(const Duration(milliseconds: 300));
            
            // Then export and show share sheet
            switch (exportType) {
              case ExportType.pdfWithLogo:
                await controller.exportTechPackPDF(withLogo: true);
                break;
              case ExportType.neutralPdf:
                await controller.exportTechPackPDF(withLogo: false);
                break;
              case ExportType.word:
                await controller.exportTechPackWord();
                break;
            }
          },
        );
      },
    );
  }

  Widget _buildLoadingState(AppLocalizations l10n) {
    return Column(
      children: [
        Text(
          l10n.tprCreatingTechPack,
          style: GoogleFonts.inter(
            fontSize: 18.sp,
            fontWeight: FontWeight.w600,
            color: const Color(0xFF1A1A1A),
          ),
        ),
        SizedBox(height: 8.h),
        Text(
          l10n.tprPleaseWaitGenerating,
          textAlign: TextAlign.center,
          style: GoogleFonts.inter(
            fontSize: 14.sp,
            color: const Color(0xFF666666),
          ),
        ),
        SizedBox(height: 24.h),
        _buildDynamicLoadingCard(l10n.tprTechPackDetails),
        SizedBox(height: 16.h),
        _buildDynamicLoadingCard(l10n.tprTechnicalFlatDrawing),
      ],
    );
  }

  Widget _buildDynamicLoadingCard(String title) {
    return Container(
      width: double.infinity,
      height: 280.h,
      decoration: BoxDecoration(
        color: const Color.fromRGBO(236, 239, 246, 1),
        borderRadius: BorderRadius.circular(20.r),
      ),
      child: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            // Title
            Text(
              title,
              style: GoogleFonts.inter(
                fontSize: 16.sp,
                fontWeight: FontWeight.w600,
                color: const Color(0xFF1A1A1A),
              ),
            ),
            SizedBox(height: 16.h),

            // Lottie loading animation
            SizedBox(
              width: 150.w,
              height: 80.h,
              child: Lottie.asset(
                'assets/lottie/Loading_dots.json',
                width: 150.w,
                height: 80.h,
                fit: BoxFit.contain,
                repeat: true,
                animate: true,
              ),
            ),
            SizedBox(height: 16.h),

            // Generating text
            Text(
              AppLocalizations.of(Get.context!)!.tprGenerating,
              style: GoogleFonts.inter(
                fontSize: 14.sp,
                color: const Color(0xFF666666),
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
    final l10n = AppLocalizations.of(context)!;

    return Scaffold(
      backgroundColor: const Color(0xFFFDFDFD),
      body: TapTrackingWrapper(
        screenName: 'TechPackReadyScreen',
        child: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 26, vertical: 26),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Expanded(
                    child: Text(
                      l10n.tprYourTechPackReady,
                      style: tprtTextTextStyle28700,
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                  SizedBox(width: 12.w),
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
                  return _buildLoadingState(l10n);
                } else if (controller.hasGeneratedImages &&
                    controller.generatedImages.length >= 2) {
                  return Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        l10n.tprGeneratedTechPackImages,
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 18.sp,
                        ),
                      ),
                      SizedBox(height: 16.h),

                      GestureDetector(
                        onTap: () => _showImagePopup(
                          context,
                          controller.generatedImages[0],
                          l10n.tprTechPackDetails,
                        ),
                        child: Container(
                          width: double.infinity,
                          margin: const EdgeInsets.only(bottom: 16),
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(0),
                          ),
                          child: ClipRRect(
                            borderRadius: BorderRadius.circular(0),
                            child: _buildImageFromBase64(
                              controller.generatedImages[0],
                            ),
                          ),
                        ),
                      ),

                      // Second Image - Technical Flat Drawing with Logo Overlay
                      GestureDetector(
                        onTap: () => _showImagePopup(
                          context,
                          controller.generatedImages[1],
                          l10n.tprTechnicalFlatDrawing,
                          logoImagePath: controller.hasLabelImage ? controller.labelImagePath : null,
                          logoPlacement: controller.logoPlacement.isNotEmpty ? controller.logoPlacement : null,
                        ),
                        child: Container(
                          width: double.infinity,
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(0),
                          ),
                          child: Stack(
                            children: [
                              // Main Technical Flat Drawing
                              ClipRRect(
                                borderRadius: BorderRadius.circular(0),
                                child: _buildImageFromBase64(
                                  controller.generatedImages[1],
                                ),
                              ),

                              // Small Logo Reference Overlay (top-right)
                              if (controller.hasLabelImage)
                                Positioned(
                                  top: 8.h,
                                  right: 8.w,
                                  child: Row(
                                    children: [
                                      Text(
                                        l10n.tprLogoPlacement(controller.logoPlacement),
                                        style: TextStyle(
                                          fontSize: 10.sp,
                                          color: Colors.black54,
                                          backgroundColor:
                                              Colors.white70,
                                        ),
                                      ),
                                      SizedBox(width: 4.w),
                                      Image.file(
                                    File(controller.labelImagePath),
                                    width: 30.w,
                                    height: 30.w,
                                    fit: BoxFit.contain,
                                    errorBuilder: (context, error, stackTrace) {
                                      return SizedBox.shrink();
                                    },
                                  ),
                                    ],
                                  ),
                                ),
                            ],
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
                            l10n.tprNoTechPackImages,
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
                title: l10n.tprGetManufacturerSuggestions,
                onTap: ()  {
                  Get.to(
                    () => RecommendedManufactureScreen(),
                    arguments: {
                      'manufacturerCountry': controller.manufacturerCountry,
                    },
                  );
                },
                color: AppColors.buttonColor,
                isloading: false,
              ),
              SizedBox(height: 16.h),
              Obx(
                () => SaveExportButtonRow(
                  onSave: () => _showSaveDialog(context, controller),
                  onExport: () => _showExportDialog(context, controller),
                  isSaving: controller
                      .isSaving
                      .value, // Show loading on screen save button
                  isExporting: controller.isExporting.value,
                ),
              ),
              SizedBox(height: 30.h),
            ],
          ),
        ),
      ),
      ),
    );
  }
}
