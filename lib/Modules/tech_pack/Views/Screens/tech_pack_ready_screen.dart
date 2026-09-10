import 'package:atella/core/themes/app_fonts.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import '../Widgets/save_export_button_row.dart';
import '../Widgets/save_tech_pack_dialog.dart';
import '../Widgets/export_options_dialog.dart';
import '../Widgets/export_options_controller.dart';
import '../../controllers/tech_pack_ready_controller.dart';
import 'dart:convert';
import 'dart:io';
import 'package:atella/core/widgets/tap_tracking_wrapper.dart';
import 'package:atella/Widgets/animated_dots_text.dart';
import 'package:percent_indicator/percent_indicator.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:atella/l10n/generated/app_localizations.dart';
import '../../controllers/tech_pack_details_controller.dart';

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

  void _showImagesViewer(BuildContext context, List<String> images, int initialIndex) {
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (_) => _TechPackGalleryViewer(
          images: images,
          initialIndex: initialIndex,
        ),
      ),
    );
  }

  void _showSaveDialog(
    BuildContext context,
    TechPackReadyController controller,
  ) {
    Get.dialog(
      SaveTechPackDialog(
        projectNameController: controller.projectNameController,
        selectedCollection: controller.selectedCollection,
        collections: controller.collections,
        onAddCollection: controller.addNewCollection,
        onSelectCollection: controller.updateSelectedCollection,
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
    final detailsController = Get.find<TechPackDetailsController>();

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
        Container(
          width: double.infinity,
          height: 280.h,
          decoration: BoxDecoration(
            color: const Color.fromRGBO(236, 239, 246, 1),
            borderRadius: BorderRadius.circular(20.r),
          ),
          child: Center(
            child: Obx(() {
              final progress = detailsController.generationProgress.value;
              final step = detailsController.generationStep.value;
              final stepLabels = [l10n.tpgStepAnalyzing, l10n.tpgStepDesigning, l10n.tpgStepRendering, l10n.tpgStepFinishing];
              final stepLabel = step > 0 && step <= stepLabels.length
                  ? stepLabels[step - 1]
                  : stepLabels[0];
              final percent = (progress * 100).toInt();

              return Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  CircularPercentIndicator(
                    radius: 45.0,
                    lineWidth: 6.0,
                    percent: progress,
                    animation: true,
                    animateFromLastPercent: true,
                    animationDuration: 400,
                    circularStrokeCap: CircularStrokeCap.round,
                    progressColor: Colors.black,
                    backgroundColor: Colors.white,
                    center: Text(
                      '$percent%',
                      style: GoogleFonts.inter(
                        fontSize: 16.sp,
                        fontWeight: FontWeight.w700,
                        color: Colors.black,
                      ),
                    ),
                  ),
                  SizedBox(height: 20.h),
                  AnimatedDotsText(
                    text: stepLabel,
                    style: GoogleFonts.inter(
                      fontSize: 14.sp,
                      color: const Color(0xFF666666),
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ],
              );
            }),
          ),
        ),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    final controller = Get.put(TechPackReadyController());
    final detailsController = Get.find<TechPackDetailsController>();
    final l10n = AppLocalizations.of(context)!;

    return PopScope(
      canPop: false,
      onPopInvokedWithResult: (bool didPop, dynamic result) async {
        if (didPop) return;
        // Show warning dialog if generating, otherwise go back
        final canGoBack = await detailsController.handleBackNavigation();
        if (canGoBack && context.mounted) {
          Navigator.of(context).pop();
        }
      },
      child: Scaffold(
        backgroundColor: const Color(0xFFFDFDFD),
        body: TapTrackingWrapper(
          screenName: 'TechPackReadyScreen',
          child: SafeArea(
            child: SingleChildScrollView(
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 26),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
              // Header with back button, title, and edit icon
              Row(
                children: [
                  // Back button
                  GestureDetector(
                    onTap: () async {
                      final canGoBack = await detailsController.handleBackNavigation();
                      if (canGoBack && context.mounted) {
                        Navigator.of(context).pop();
                      }
                    },
                    child: Icon(
                      Icons.arrow_back_ios_new,
                      size: 20.sp,
                      color: Colors.black,
                    ),
                  ),
                  SizedBox(width: 16.w),
                  // Title
                  Expanded(
                    child: Text(
                      l10n.tprYourTechPackReady,
                      style: tprtTextTextStyle28700,
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                  SizedBox(width: 12.w),
                  // Edit icon
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
                        onTap: () => _showImagesViewer(
                          context,
                          controller.generatedImages,
                          0,
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
                        onTap: () => _showImagesViewer(
                          context,
                          controller.generatedImages,
                          1,
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

                              // Small Logo Reference Overlay (top-left)
                              if (controller.hasLabelImage)
                                Positioned(
                                  top: 8.h,
                                  left: 8.w,
                                  child: Image.file(
                                    File(controller.labelImagePath),
                                    width: 30.w,
                                    height: 30.w,
                                    fit: BoxFit.contain,
                                    errorBuilder: (context, error, stackTrace) {
                                      return SizedBox.shrink();
                                    },
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
              // Only show buttons after tech pack generation is complete
              Obx(() {
                if (controller.isGenerating) {
                  return const SizedBox.shrink(); // Hide buttons during generation
                }
                return Column(
                  children: [
                    SizedBox(
                      width: double.infinity,
                      child: OutlinedButton(
                        onPressed: controller.isSendingToPartner.value ||
                                controller.isSaving.value
                            ? null
                            : () => controller.sendToManufacturePartner(),
                        style: OutlinedButton.styleFrom(
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12.r),
                          ),
                          side: const BorderSide(color: Colors.black, width: 1),
                          padding: EdgeInsets.symmetric(vertical: 16.h),
                        ),
                        child: controller.isSendingToPartner.value
                            ? SizedBox(
                                width: 20.w,
                                height: 20.h,
                                child: const CircularProgressIndicator(
                                  strokeWidth: 2,
                                  valueColor: AlwaysStoppedAnimation<Color>(
                                    Color(0xFF222222),
                                  ),
                                ),
                              )
                            : Text(
                                'Send to manufacture partner',
                                style: TextStyle(
                                  fontWeight: FontWeight.w600,
                                  color: const Color(0xFF222222),
                                  fontSize: 16.sp,
                                ),
                              ),
                      ),
                    ),
                    SizedBox(height: 16.h),
                    SaveExportButtonRow(
                      onSave: controller.isSendingToPartner.value
                          ? null
                          : () => _showSaveDialog(context, controller),
                      onExport: controller.isSendingToPartner.value
                          ? null
                          : () => _showExportDialog(context, controller),
                      isSaving: controller.isSaving.value,
                      isExporting: controller.isExporting.value,
                    ),
                    SizedBox(height: 30.h),
                  ],
                );
              }),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}

// ─── Full-screen tech pack gallery with zoom + dot indicators ────────────────

class _TechPackGalleryViewer extends StatefulWidget {
  final List<String> images;
  final int initialIndex;

  const _TechPackGalleryViewer({
    required this.images,
    required this.initialIndex,
  });

  @override
  State<_TechPackGalleryViewer> createState() => _TechPackGalleryViewerState();
}

class _TechPackGalleryViewerState extends State<_TechPackGalleryViewer> {
  late PageController _pageController;
  late int _currentIndex;
  bool _isZoomed = false;

  @override
  void initState() {
    super.initState();
    _currentIndex = widget.initialIndex;
    _pageController = PageController(initialPage: widget.initialIndex);
  }

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      body: Stack(
        children: [
          // Swipeable + zoomable pages
          PageView.builder(
            controller: _pageController,
            physics: _isZoomed
                ? const NeverScrollableScrollPhysics()
                : const BouncingScrollPhysics(),
            onPageChanged: (i) => setState(() => _currentIndex = i),
            itemCount: widget.images.length,
            itemBuilder: (context, i) {
              return _ZoomableTechPackImage(
                base64Image: widget.images[i],
                onZoomChanged: (zoomed) {
                  if (_isZoomed != zoomed) {
                    setState(() => _isZoomed = zoomed);
                  }
                },
              );
            },
          ),

          // Close button — top right
          SafeArea(
            child: Align(
              alignment: Alignment.topRight,
              child: GestureDetector(
                onTap: () => Navigator.of(context).pop(),
                child: Container(
                  margin: const EdgeInsets.all(12),
                  padding: const EdgeInsets.all(6),
                  decoration: const BoxDecoration(
                    color: Colors.black54,
                    shape: BoxShape.circle,
                  ),
                  child: const Icon(Icons.close, color: Colors.white, size: 22),
                ),
              ),
            ),
          ),

          // Dot indicators — bottom centre
          if (widget.images.length > 1)
            Positioned(
              bottom: 36,
              left: 0,
              right: 0,
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: List.generate(widget.images.length, (i) {
                  final isActive = _currentIndex == i;
                  return AnimatedContainer(
                    duration: const Duration(milliseconds: 250),
                    width: isActive ? 20 : 8,
                    height: 8,
                    margin: const EdgeInsets.symmetric(horizontal: 3),
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(4),
                      color: isActive ? Colors.white : Colors.white38,
                    ),
                  );
                }),
              ),
            ),
        ],
      ),
    );
  }
}

class _ZoomableTechPackImage extends StatefulWidget {
  final String base64Image;
  final ValueChanged<bool> onZoomChanged;

  const _ZoomableTechPackImage({
    required this.base64Image,
    required this.onZoomChanged,
  });

  @override
  State<_ZoomableTechPackImage> createState() => _ZoomableTechPackImageState();
}

class _ZoomableTechPackImageState extends State<_ZoomableTechPackImage> {
  final _transformationController = TransformationController();

  @override
  void initState() {
    super.initState();
    _transformationController.addListener(_onTransform);
  }

  void _onTransform() {
    final scale = _transformationController.value.getMaxScaleOnAxis();
    widget.onZoomChanged(scale > 1.01);
  }

  @override
  void dispose() {
    _transformationController.removeListener(_onTransform);
    _transformationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return InteractiveViewer(
      transformationController: _transformationController,
      minScale: 1.0,
      maxScale: 5.0,
      child: Center(
        child: Image.memory(
          base64Decode(widget.base64Image),
          fit: BoxFit.contain,
          errorBuilder: (context, error, stackTrace) {
            return const Center(
              child: Icon(Icons.error_outline, color: Colors.white54, size: 48),
            );
          },
        ),
      ),
    );
  }
}
