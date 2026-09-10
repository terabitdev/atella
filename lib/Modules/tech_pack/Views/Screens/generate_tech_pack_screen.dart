import 'package:atella/Modules/tech_pack/Views/Widgets/outline_genrate_round_button.dart';
import 'package:atella/Modules/tech_pack/Views/Widgets/save_tech_pack_dialog.dart';
import 'package:atella/Widgets/animated_dots_text.dart';
import 'package:percent_indicator/percent_indicator.dart';
import 'package:atella/Modules/tech_pack/controllers/generate_tech_pack_controller.dart';
import 'package:atella/Widgets/custom_roundbutton.dart';
import 'package:atella/core/themes/app_fonts.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:atella/Widgets/app_header.dart';
import 'package:google_fonts/google_fonts.dart';
import 'dart:convert';
import 'package:atella/core/widgets/tap_tracking_wrapper.dart';
import 'package:atella/l10n/generated/app_localizations.dart';

class GenerateTechPackScreen extends StatelessWidget {
  GenerateTechPackScreen({super.key});

  final controller = Get.put(TechPackController(), permanent: true);


  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;

    return Scaffold(
      body: TapTrackingWrapper(
        screenName: 'GenerateTechPackScreen',
        child: Stack(
          children: [
            Column(
              children: [
                Padding(
                  padding: const EdgeInsets.fromLTRB(24.0, 35.0, 24.0, 24.0),
                  child: GlobalHeader(
                    title: l10n.tpDesignAssistant,
                    onBack: () => Navigator.of(context).pop(),
                  ),
                ),
                const SizedBox(height: 12),
                Obx(() {
                  if (controller.isLoading.value) {
                    return _buildLoadingState(l10n);
                  } else if (controller.hasError.value) {
                    return _buildErrorState(l10n);
                  } else {
                    return Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 24.0),
                      child: Text(
                        l10n.tpChooseFavoriteDesign,
                        style: GoogleFonts.inter(
                          fontSize: 18,
                          fontWeight: FontWeight.w600,
                          color: const Color(0xFF1A1A1A),
                        ),
                      ),
                    );
                  }
                }),
                const SizedBox(height: 20),
                Expanded(
                  child: SingleChildScrollView(
                    padding: const EdgeInsets.symmetric(horizontal: 16),
                    child: Obx(() {
                      return Column(
                        children: [
                          ...List.generate(1, (index) {
                            if (controller.isLoading.value) {
                              return _buildDynamicLoadingCard(index, l10n);
                            } else if (controller.hasError.value) {
                              return _buildErrorCard(index, l10n);
                            } else if (controller.generatedImages.isNotEmpty &&
                                index < controller.generatedImages.length) {
                              return _buildDesignImageCard(
                                controller.generatedImages[index],
                                index,
                                context,
                                l10n,
                              );
                            } else {
                              return _buildEmptyCard(index, l10n);
                            }
                          }),
                          const SizedBox(height: 20),
                          if (!controller.isLoading.value &&
                              !controller.hasError.value)
                            _buildActionButtons(l10n),
                        ],
                      );
                    }),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildLoadingState(AppLocalizations l10n) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 24.0),
      child: Column(
        children: [
          Text(
            l10n.tpCreatingDesigns,
            style: GoogleFonts.inter(
              fontSize: 18,
              fontWeight: FontWeight.w600,
              color: const Color(0xFF1A1A1A),
            ),
          ),
          const SizedBox(height: 8),
          Text(
            l10n.tpPleaseWaitGenerating,
            textAlign: TextAlign.center,
            style: GoogleFonts.inter(
              fontSize: 14,
              color: const Color(0xFF666666),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildErrorState(AppLocalizations l10n) {
    return Padding(
      padding: EdgeInsets.symmetric(horizontal: 24.w),
      child: Container(
        padding: EdgeInsets.all(16.r),
        decoration: BoxDecoration(
          color: Colors.red.shade50,
          borderRadius: BorderRadius.circular(12.r),
          border: Border.all(color: Colors.red.shade200),
        ),
        child: Column(
          children: [
            Icon(Icons.error_outline, color: Colors.red.shade600, size: 32.w),
            SizedBox(height: 8.h),
            Text(
              l10n.tpSomethingWentWrong,
              style: GoogleFonts.inter(
                fontSize: 16.sp,
                fontWeight: FontWeight.w600,
                color: Colors.red.shade700,
              ),
            ),
            SizedBox(height: 4.h),
            Text(
              controller.errorMessage.value,
              textAlign: TextAlign.center,
              style: GoogleFonts.inter(
                fontSize: 14.sp,
                color: Colors.red.shade600,
              ),
            ),
            const SizedBox(height: 12),
            ElevatedButton(
              onPressed: controller.retryGeneration,
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.red.shade600,
                foregroundColor: Colors.white,
              ),
              child: Text(l10n.tpRetry),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildDynamicLoadingCard(int index, AppLocalizations l10n) {
    if (index != 0) return const SizedBox.shrink();

    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      height: 280.h,
      decoration: BoxDecoration(
        color: const Color.fromRGBO(236, 239, 246, 1),
        borderRadius: BorderRadius.circular(20.r),
      ),
      child: Center(
        child: Obx(() {
          final progress = controller.generationProgress.value;
          final step = controller.generationStep.value;
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
    );
  }

  Widget _buildErrorCard(int index, AppLocalizations l10n) {
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      height: 280,
      decoration: BoxDecoration(
        color: Colors.grey.shade100,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: Colors.grey.shade300),
      ),
      child: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.image_not_supported_outlined,
              size: 48,
              color: Colors.grey.shade400,
            ),
            const SizedBox(height: 8),
            Text(
              l10n.tpgDesignNumber((index + 1).toString()),
              style: GoogleFonts.inter(
                fontSize: 16,
                color: Colors.grey.shade600,
              ),
            ),
            Text(
              l10n.tpgFailedToGenerate,
              style: GoogleFonts.inter(
                fontSize: 12,
                color: Colors.grey.shade500,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildEmptyCard(int index, AppLocalizations l10n) {
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      height: 280,
      decoration: BoxDecoration(
        color: Colors.grey.shade50,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: Colors.grey.shade200),
      ),
      child: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.image_outlined, size: 48, color: Colors.grey.shade300),
            const SizedBox(height: 8),
            Text(
              l10n.tpgDesignNumber((index + 1).toString()),
              style: GoogleFonts.inter(
                fontSize: 16,
                color: Colors.grey.shade400,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildDesignImageCard(
    String base64Image,
    int index,
    BuildContext context,
    AppLocalizations l10n,
  ) {
    return Obx(() {
      final isSelected = controller.selectedDesignIndex.value == index;
      return GestureDetector(
        onTap: () {
          Navigator.of(context).push(
            MaterialPageRoute(
              builder: (_) => _DesignGalleryViewer(
                images: controller.generatedImages,
                initialIndex: index,
                onSelect: (selectedIndex) {
                  controller.selectDesign(selectedIndex);
                },
              ),
            ),
          );
        },
        child: Container(
          margin: const EdgeInsets.only(bottom: 16),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(22),
            border: Border.all(
              color: isSelected ? const Color(0xFF1A1A1A) : Colors.transparent,
              width: 2,
            ),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.05),
                blurRadius: 8,
                offset: const Offset(0, 4),
              ),
            ],
          ),
          child: ClipRRect(
            borderRadius: BorderRadius.circular(20),
            child: Stack(
              children: [
                // Image that determines the card height
                Image.memory(
                  base64Decode(base64Image),
                  width: double.infinity,
                  // REMOVE fixed height - let image determine height
                  fit: BoxFit.contain, // Show full image without cropping
                  errorBuilder: (context, error, stackTrace) {
                    return Container(
                      height: 200, // Fallback height if image fails
                      color: Colors.grey.shade200,
                      child: Center(
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(
                              Icons.image_not_supported_outlined,
                              size: 48,
                              color: Colors.grey.shade400,
                            ),
                            const SizedBox(height: 8),
                            Text(
                              l10n.tpgFailedToLoadImage,
                              style: GoogleFonts.inter(
                                fontSize: 12,
                                color: Colors.grey.shade500,
                              ),
                            ),
                          ],
                        ),
                      ),
                    );
                  },
                ),

                if (isSelected)
                  Positioned(
                    top: 12,
                    right: 12,
                    child: Container(
                      padding: const EdgeInsets.all(6),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        shape: BoxShape.circle,
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withOpacity(0.2),
                            blurRadius: 4,
                            offset: const Offset(0, 2),
                          ),
                        ],
                      ),
                      child: Image.asset(
                        'assets/images/tick.png',
                        width: 20,
                        height: 20,
                        color: Colors.black,
                      ),
                    ),
                  ),

                // Design number overlay
                Positioned(
                  top: 12,
                  left: 12,
                  child: Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 8,
                      vertical: 4,
                    ),
                    decoration: BoxDecoration(
                      color: Colors.black.withOpacity(0.7),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Text(
                      l10n.tpgDesignNumber((index + 1).toString()),
                      style: GoogleFonts.inter(
                        fontSize: 12,
                        color: Colors.white,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      );
    });
  }

  void _showSaveDesignDialog() {
    Get.dialog(
      SaveTechPackDialog(
        projectNameController: controller.projectNameController,
        selectedCollection: controller.selectedCollection,
        collections: controller.collections,
        onAddCollection: controller.addNewCollection,
        onSelectCollection: controller.updateSelectedCollection,
        onSave: (projectName, collectionName) async {
          await controller.onSaveDesignOnly(projectName, collectionName);
        },
      ),
      barrierDismissible: true,
    );
  }

  Widget _buildActionButtons(AppLocalizations l10n) {
    return Column(
      children: [
        Container(
          height: 68.h,
          decoration: BoxDecoration(
            color: const Color.fromRGBO(211, 213, 223, 1),
            borderRadius: BorderRadius.circular(12.r),
          ),
          child: Center(
            child: Padding(
              padding: EdgeInsets.symmetric(horizontal: 16.w),
              child: Text(
                l10n.tpWouldYouLikeChanges,
                textAlign: TextAlign.center,
                style: tpcTextStyle16400.copyWith(color: Colors.black),
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
              ),
            ),
          ),
        ),
        SizedBox(height: 44.h),
        RoundButton(
          title: l10n.tpYesChanges,
          onTap: () {
            // DON'T reset - keep the current answers for editing
            // Instead, navigate to creative_brief in "edit current session" mode
            print('🔄 User wants to make changes - preserving current answers');

            // Delete the TechPackController so it will be recreated fresh next time
            if (Get.isRegistered<TechPackController>()) {
              Get.delete<TechPackController>();
            }

            // Navigate back to creative brief with flag to preserve current session data
            Get.toNamed(
              '/creative_brief',
              arguments: {
                'editCurrentSession':
                    true, // New flag to indicate editing current session
                'preserveAnswers': true,
              },
            );
          },
          color: const Color(0xFF1A1A1A),
          isloading: false,
        ),
        SizedBox(height: 12.h),
        Obx(() {
          final isDesignSelected = controller.selectedDesignIndex.value >= 0;

          return OutlineGenerateRoundButton(
            title: isDesignSelected
                ? l10n.tpContinueWithSelected
                : l10n.tpSnackbarNoDesignSelectedMessage,
            onTap: isDesignSelected
                ? controller.onContinueWithSelectedDesign
                : () {},
            color: isDesignSelected ? const Color(0xFF1A1A1A) : Colors.grey,
            imagePath: 'assets/images/techpackgenerate.png',
          );
        }),
        SizedBox(height: 12.h),
        Obx(() {
          final isDesignSelected = controller.selectedDesignIndex.value >= 0;

          return OutlineGenerateRoundButton(
            title: l10n.tpSaveDesignButton,
            onTap: isDesignSelected ? _showSaveDesignDialog : () {},
            loading: controller.isSaving.value,
            color: isDesignSelected ? const Color(0xFF1A1A1A) : Colors.grey,
          );
        }),
        SizedBox(height: 24.h),
      ],
    );
  }
}

// ─── Full-screen design gallery with zoom, dots, and Select button ───────────

class _DesignGalleryViewer extends StatefulWidget {
  final List<String> images;
  final int initialIndex;
  final void Function(int selectedIndex) onSelect;

  const _DesignGalleryViewer({
    required this.images,
    required this.initialIndex,
    required this.onSelect,
  });

  @override
  State<_DesignGalleryViewer> createState() => _DesignGalleryViewerState();
}

class _DesignGalleryViewerState extends State<_DesignGalleryViewer> {
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
              return _ZoomableDesignImage(
                base64Image: widget.images[i],
                onZoomChanged: (zoomed) {
                  if (_isZoomed != zoomed) {
                    setState(() => _isZoomed = zoomed);
                  }
                },
              );
            },
          ),

          // Top bar: close (left) + Select (right)
          SafeArea(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  // Close button
                  GestureDetector(
                    onTap: () => Navigator.of(context).pop(),
                    child: Container(
                      padding: const EdgeInsets.all(6),
                      decoration: const BoxDecoration(
                        color: Colors.black54,
                        shape: BoxShape.circle,
                      ),
                      child: const Icon(
                        Icons.close,
                        color: Colors.white,
                        size: 22,
                      ),
                    ),
                  ),

                  // Select button
                  GestureDetector(
                    onTap: () {
                      widget.onSelect(_currentIndex);
                      Navigator.of(context).pop();
                    },
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 18,
                        vertical: 8,
                      ),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: const Text(
                        'Select',
                        style: TextStyle(
                          color: Colors.black,
                          fontWeight: FontWeight.w600,
                          fontSize: 14,
                        ),
                      ),
                    ),
                  ),
                ],
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

class _ZoomableDesignImage extends StatefulWidget {
  final String base64Image;
  final ValueChanged<bool> onZoomChanged;

  const _ZoomableDesignImage({
    required this.base64Image,
    required this.onZoomChanged,
  });

  @override
  State<_ZoomableDesignImage> createState() => _ZoomableDesignImageState();
}

class _ZoomableDesignImageState extends State<_ZoomableDesignImage> {
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
