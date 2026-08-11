import 'package:atella/Modules/tech_pack/Views/Widgets/roound_tag_container.dart';
import 'package:atella/Widgets/app_header.dart';
import 'package:atella/core/constants/app_images.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import '../../controllers/tech_pack_details_controller.dart';
import '../Widgets/tech_pack_question_field.dart';
import '../Widgets/tech_pack_image_upload_container.dart';
import '../Widgets/size_checkbox_selector.dart';
import 'package:atella/Modules/tech_pack/Views/Widgets/outline_genrate_round_button.dart';
import 'package:atella/core/themes/app_colors.dart';
import 'package:atella/core/themes/app_fonts.dart';
import 'package:atella/l10n/generated/app_localizations.dart';

class TechPackDetailsScreen extends StatelessWidget {
  TechPackDetailsScreen({super.key});
  final controller = Get.find<TechPackDetailsController>();

  void onContinue() {}

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;

    return PopScope(
      canPop: false,
      onPopInvokedWithResult: (bool didPop, dynamic result) async {
        if (didPop) return;
        // Allow back navigation without dialog on tech pack details screen
        final canGoBack = await controller.handleBackNavigation(shouldShowDialog: false);
        if (canGoBack && context.mounted) {
          Navigator.of(context).pop();
        }
      },
      child: Scaffold(
        backgroundColor: const Color(0xFFFDFDFD),
        body: SafeArea(
          child: SingleChildScrollView(
            padding: EdgeInsets.symmetric(horizontal: 18.w, vertical: 8.h),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                SizedBox(height: 8.h),
                GlobalHeader(
                  title: l10n.tpdFinalDesignValidated,
                  onBack: () async {
                    // Allow back navigation without dialog on tech pack details screen
                    final canGoBack = await controller.handleBackNavigation(shouldShowDialog: false);
                    if (canGoBack && context.mounted) {
                      Navigator.of(context).pop();
                    }
                  },
                ),
              SizedBox(height: 18.h),
              // Materials & Fabrics Block
              Container(
                width: double.infinity,
                padding: EdgeInsets.symmetric(
                  vertical: 18.h,
                  horizontal: 14.w,
                ),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(18.r),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    RoundedTagContainer(text: l10n.tpdMaterialsFabrics),
                    SizedBox(height: 10.h),
                    Obx(() => TechPackQuestionField(
                      label: l10n.tpdFabricCompositionLabel,
                      hint: l10n.tpdFabricCompositionHint,
                      controller: controller.fabricCompositionController,
                      enabled: !controller.useIndustryStandardComposition.value,
                      errorText: controller.compositionError.value.isEmpty
                          ? null
                          : controller.compositionError.value,
                      onChanged: (_) => controller.checkMaterialsBlockComplete(),
                    )),
                    Obx(() => Row(
                      children: [
                        Checkbox(
                          value: controller.useIndustryStandardComposition.value,
                          activeColor: AppColors.splashcolor,
                          materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
                          visualDensity: VisualDensity.compact,
                          onChanged: (v) => controller.toggleIndustryStandardComposition(v ?? false),
                        ),
                        Text(
                          'Use industry standard',
                          style: TextStyle(fontSize: 12.sp, color: Colors.grey[700]),
                        ),
                      ],
                    )),
                    SizedBox(height: 6.h),
                    Obx(() => TechPackQuestionField(
                      label: l10n.tpdFabricWeightLabel,
                      hint: l10n.tpdFabricWeightHint,
                      controller: controller.fabricWeightController,
                      enabled: !controller.useIndustryStandardGSM.value,
                      errorText: controller.weightError.value.isEmpty
                          ? null
                          : controller.weightError.value,
                      onChanged: (_) => controller.checkMaterialsBlockComplete(),
                    )),
                    Obx(() => Row(
                      children: [
                        Checkbox(
                          value: controller.useIndustryStandardGSM.value,
                          activeColor: AppColors.splashcolor,
                          materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
                          visualDensity: VisualDensity.compact,
                          onChanged: (v) => controller.toggleIndustryStandardGSM(v ?? false),
                        ),
                        Text(
                          'Use industry standard',
                          style: TextStyle(fontSize: 12.sp, color: Colors.grey[700]),
                        ),
                      ],
                    )),
                    SizedBox(height: 6.h),
                    TechPackQuestionField(
                      label: l10n.tpdSecondaryMaterialsLabel,
                      hint: l10n.tpdSecondaryMaterialsHint,
                      controller: controller.secondaryMaterialsController,
                      onChanged: (_) =>
                          controller.checkMaterialsBlockComplete(),
                    ),
                    Obx(() => TechPackQuestionField(
                      label: l10n.tpdFabricPropertiesLabel,
                      hint: l10n.tpdFabricPropertiesHint,
                      controller: controller.fabricPropertiesController,
                      enabled: !controller.useIndustryStandardProperties.value,
                      onChanged: (_) => controller.checkMaterialsBlockComplete(),
                    )),
                    Obx(() => Row(
                      children: [
                        Checkbox(
                          value: controller.useIndustryStandardProperties.value,
                          activeColor: AppColors.splashcolor,
                          materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
                          visualDensity: VisualDensity.compact,
                          onChanged: (v) => controller.toggleIndustryStandardProperties(v ?? false),
                        ),
                        Text(
                          'Use industry standard',
                          style: TextStyle(fontSize: 12.sp, color: Colors.grey[700]),
                        ),
                      ],
                    )),
                  ],
                ),
              ),
              // Sizes & Measurements Block
              Obx(
                () => controller.showSizesBlock.value
                    ? Column(
                        children: [
                          SizedBox(height: 18.h),
                          Container(
                            width: double.infinity,
                            padding: const EdgeInsets.symmetric(
                              vertical: 18,
                              horizontal: 14,
                            ),
                            decoration: BoxDecoration(
                              color: Colors.white,
                              borderRadius: BorderRadius.circular(18.r),
                            ),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                RoundedTagContainer(
                                  text: l10n.tpdSizesMeasurements,
                                ),
                                SizedBox(height: 10.h),
                                // Size Range - Checkbox Multi-Select
                                Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      l10n.tpdSizeRangeLabel,
                                      style: tplTextStyle12400,
                                    ),
                                    SizedBox(height: 6.h),
                                    SizeCheckboxSelector(
                                      sizes: TechPackDetailsController.availableSizes,
                                      selectedSizes: controller.selectedSizes,
                                      onSizeToggle: controller.toggleSizeSelection,
                                    ),
                                  ],
                                ),
                                SizedBox(height: 10.h),
                                Text(
                                  l10n.tpdMeasurementChartLabel,
                                  style: tplTextStyle12400,
                                ),
                                SizedBox(height: 8.h),
                                Obx(() => Row(
                                  children: [
                                    _ToggleButton(
                                      label: 'Yes',
                                      selected: controller.providingOwnChart.value,
                                      onTap: () {
                                        controller.providingOwnChart.value = true;
                                      },
                                    ),
                                    SizedBox(width: 10.w),
                                    _ToggleButton(
                                      label: 'No',
                                      selected: !controller.providingOwnChart.value,
                                      onTap: () {
                                        controller.providingOwnChart.value = false;
                                        controller.clearMeasurementImage();
                                        controller.measurementChartController.clear();
                                      },
                                    ),
                                  ],
                                )),
                                Obx(() => controller.providingOwnChart.value
                                    ? Column(
                                        crossAxisAlignment: CrossAxisAlignment.start,
                                        children: [
                                          SizedBox(height: 12.h),
                                          TechPackImageUploadContainer(
                                            onTap: controller.openCameraForMeasurement,
                                            imagePath: controller.measurementImagePath.value.isEmpty
                                                ? null
                                                : controller.measurementImagePath.value,
                                            onEdit: controller.measurementImagePath.value.isNotEmpty
                                                ? () => controller.openCameraForMeasurement()
                                                : null,
                                            onDelete: controller.measurementImagePath.value.isNotEmpty
                                                ? () => controller.clearMeasurementImage()
                                                : null,
                                          ),
                                          SizedBox(height: 10.h),
                                          TechPackQuestionField(
                                            label: 'Additional notes (optional)',
                                            hint: 'e.g. sizes are in inches',
                                            controller: controller.measurementChartController,
                                            onChanged: (_) => controller.checkSizesBlockComplete(),
                                          ),
                                        ],
                                      )
                                    : Padding(
                                        padding: EdgeInsets.only(top: 8.h),
                                        child: Text(
                                          'AI will auto-generate standard measurements',
                                          style: TextStyle(
                                            fontSize: 12.sp,
                                            color: Colors.grey,
                                          ),
                                        ),
                                      )),
                              ],
                            ),
                          ),
                        ],
                      )
                    : const SizedBox.shrink(),
              ),
              // Technical Details Block
              Obx(
                () => controller.showTechnicalBlock.value
                    ? Column(
                        children: [
                          SizedBox(height: 18.h),
                          Container(
                            width: double.infinity,
                            padding: const EdgeInsets.symmetric(
                              vertical: 18,
                              horizontal: 14,
                            ),
                            decoration: BoxDecoration(
                              color: Colors.white,
                              borderRadius: BorderRadius.circular(18.r),
                            ),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                RoundedTagContainer(
                                  text: l10n.tpdTechnicalDetails,
                                ),
                                SizedBox(height: 10.h),
                                TechPackQuestionField(
                                  label: l10n.tpdAccessoriesLabel,
                                  hint: l10n.tpdAccessoriesHint,
                                  controller: controller.accessoriesController,
                                  onChanged: (_) =>
                                      controller.checkTechnicalBlockComplete(),
                                ),
                                Obx(() => TechPackQuestionField(
                                  label: l10n.tpdStitchingLabel,
                                  hint: l10n.tpdStitchingHint,
                                  controller: controller.stitchingController,
                                  enabled: !controller.useIndustryStandardStitching.value,
                                  onChanged: (_) => controller.checkTechnicalBlockComplete(),
                                )),
                                Obx(() => Row(
                                  children: [
                                    Checkbox(
                                      value: controller.useIndustryStandardStitching.value,
                                      activeColor: AppColors.splashcolor,
                                      materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
                                      visualDensity: VisualDensity.compact,
                                      onChanged: (v) => controller.toggleIndustryStandardStitching(v ?? false),
                                    ),
                                    Text(
                                      'Use industry standard',
                                      style: TextStyle(fontSize: 12.sp, color: Colors.grey[700]),
                                    ),
                                  ],
                                )),
                                Obx(() => TechPackQuestionField(
                                  label: l10n.tpdDecorativeStitchingLabel,
                                  hint: l10n.tpdDecorativeStitchingHint,
                                  controller: controller.decorativeStitchingController,
                                  enabled: !controller.useIndustryStandardDecorativeStitching.value,
                                  onChanged: (_) => controller.checkTechnicalBlockComplete(),
                                )),
                                Obx(() => Row(
                                  children: [
                                    Checkbox(
                                      value: controller.useIndustryStandardDecorativeStitching.value,
                                      activeColor: AppColors.splashcolor,
                                      materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
                                      visualDensity: VisualDensity.compact,
                                      onChanged: (v) => controller.toggleIndustryStandardDecorativeStitching(v ?? false),
                                    ),
                                    Text(
                                      'Use industry standard',
                                      style: TextStyle(fontSize: 12.sp, color: Colors.grey[700]),
                                    ),
                                  ],
                                )),
                              ],
                            ),
                          ),
                        ],
                      )
                    : const SizedBox.shrink(),
              ),
              // Labeling & Branding Block
              Obx(
                () => controller.showLabelingBlock.value
                    ? Column(
                        children: [
                          SizedBox(height: 18.h),
                          Container(
                            width: double.infinity,
                            padding: const EdgeInsets.symmetric(
                              vertical: 18,
                              horizontal: 14,
                            ),
                            decoration: BoxDecoration(
                              color: Colors.white,
                              borderRadius: BorderRadius.circular(18.r),
                            ),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                RoundedTagContainer(
                                  text: l10n.tpdLabelingBranding,
                                ),
                                SizedBox(height: 10.h),
                                TechPackQuestionField(
                                  label: l10n.tpdLogoPlacementLabel,
                                  hint: l10n.tpdLogoPlacementHint,
                                  controller:
                                      controller.logoPlacementController,
                                  onChanged: (_) =>
                                      controller.checkLabelingBlockComplete(),
                                ),
                                Obx(() => controller.showLabelText.value
                                    ? TechPackQuestionField(
                                        label: l10n.tpdLabelsNeededLabel,
                                        hint: l10n.tpdLabelsNeededHint,
                                        controller: controller.labelsNeededController,
                                        onChanged: (_) =>
                                            controller.checkLabelingBlockComplete(),
                                      )
                                    : const SizedBox.shrink()),
                                SizedBox(height: 10.h),
                                Center(
                                  child: Text(
                                    l10n.tpdUploadReferenceImage,
                                    style: TextStyle(
                                      color: Colors.grey,
                                      fontSize: 13.sp,
                                    ),
                                  ),
                                ),
                                SizedBox(height: 10.h),
                                Obx(() => TechPackImageUploadContainer(
                                  onTap: () {
                                    controller.openCameraForLabels();
                                  },
                                  imagePath:
                                      controller.labelImagePath.value.isEmpty
                                      ? null
                                      : controller.labelImagePath.value,
                                  onEdit: controller.labelImagePath.value.isNotEmpty
                                      ? () => controller.openCameraForLabels()
                                      : null,
                                  onDelete: controller.labelImagePath.value.isNotEmpty
                                      ? () => controller.clearLabelImage()
                                      : null,
                                )),
                                SizedBox(height: 10.h),
                                TechPackQuestionField(
                                  label: l10n.tpdQrCodeLabel,
                                  hint: l10n.tpdQrCodeHint,
                                  controller: controller.qrCodeController,
                                  onChanged: (_) =>
                                      controller.checkLabelingBlockComplete(),
                                ),
                              ],
                            ),
                          ),
                        ],
                      )
                    : const SizedBox.shrink(),
              ),
              // Manufacturers Block
              Obx(
                () => controller.showManufacturersBlock.value
                    ? Column(
                        children: [
                          SizedBox(height: 18.h),
                          Container(
                            width: double.infinity,
                            padding: const EdgeInsets.symmetric(
                              vertical: 18,
                              horizontal: 14,
                            ),
                            decoration: BoxDecoration(
                              color: Colors.white,
                              borderRadius: BorderRadius.circular(18.r),
                            ),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                RoundedTagContainer(
                                  text: l10n.tpdManufacturers,
                                ),
                                SizedBox(height: 18.h),
                                Obx(() => OutlineGenerateRoundButton(
                                  title: l10n.tpdGenerateTechPack,
                                  onTap: () {
                                    controller.checkSubscriptionAndGenerate();
                                  },
                                  color: AppColors.buttonColor,
                                  loading: controller.isStartingGeneration.value,
                                  imagePath: generateTechPackIcon,
                                )),
                              ],
                            ),
                          ),
                        ],
                      )
                    : const SizedBox.shrink(),
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

class _ToggleButton extends StatelessWidget {
  final String label;
  final bool selected;
  final VoidCallback onTap;

  const _ToggleButton({
    required this.label,
    required this.selected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: EdgeInsets.symmetric(horizontal: 24.w, vertical: 8.h),
        decoration: BoxDecoration(
          color: selected ? Colors.black : Colors.transparent,
          borderRadius: BorderRadius.circular(8.r),
          border: Border.all(
            color: selected ? Colors.black : Colors.grey.shade400,
          ),
        ),
        child: Text(
          label,
          style: TextStyle(
            fontSize: 13.sp,
            fontWeight: FontWeight.w600,
            color: selected ? Colors.white : Colors.grey.shade600,
          ),
        ),
      ),
    );
  }
}
