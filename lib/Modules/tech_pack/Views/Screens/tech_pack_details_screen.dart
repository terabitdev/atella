import 'package:atella/Modules/tech_pack/Views/Widgets/roound_tag_container.dart';
import 'package:atella/Widgets/app_header.dart';
import 'package:atella/core/constants/app_images.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:country_picker/country_picker.dart';
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
                    TechPackQuestionField(
                      label: l10n.tpdMainFabricLabel,
                      hint: l10n.tpdMainFabricHint,
                      controller: controller.mainFabricController,
                      onChanged: (_) =>
                          controller.checkMaterialsBlockComplete(),
                    ),
                    TechPackQuestionField(
                      label: l10n.tpdSecondaryMaterialsLabel,
                      hint: l10n.tpdSecondaryMaterialsHint,
                      controller: controller.secondaryMaterialsController,
                      onChanged: (_) =>
                          controller.checkMaterialsBlockComplete(),
                    ),
                    TechPackQuestionField(
                      label: l10n.tpdFabricPropertiesLabel,
                      hint: l10n.tpdFabricPropertiesHint,
                      controller: controller.fabricPropertiesController,
                      onChanged: (_) =>
                          controller.checkMaterialsBlockComplete(),
                    ),
                  ],
                ),
              ),
              // Colors Block
              Obx(
                () => controller.showColorsBlock.value
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
                                RoundedTagContainer(text: l10n.tpdColors),
                                SizedBox(height: 10.h),
                                TechPackQuestionField(
                                  label: l10n.tpdPrimaryColorLabel,
                                  hint: l10n.tpdPrimaryColorHint,
                                  controller: controller.primaryColorController,
                                  onChanged: (_) =>
                                      controller.checkColorsBlockComplete(),
                                ),
                                TechPackQuestionField(
                                  label: l10n.tpdAlternateColorwaysLabel,
                                  hint: l10n.tpdAlternateColorwaysHint,
                                  controller:
                                      controller.alternateColorwaysController,
                                  onChanged: (_) =>
                                      controller.checkColorsBlockComplete(),
                                ),
                                TechPackQuestionField(
                                  label: l10n.tpdPantoneLabel,
                                  hint: l10n.tpdPantoneHint,
                                  controller: controller.pantoneController,
                                  onChanged: (_) =>
                                      controller.checkColorsBlockComplete(),
                                ),
                              ],
                            ),
                          ),
                        ],
                      )
                    : const SizedBox.shrink(),
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
                                Obx(() => controller.showMeasurementText.value
                                    ? TechPackQuestionField(
                                        label: l10n.tpdMeasurementChartLabel,
                                        hint: l10n.tpdMeasurementChartHint,
                                        controller:
                                            controller.measurementChartController,
                                        onChanged: (_) =>
                                            controller.checkSizesBlockComplete(),
                                      )
                                    : const SizedBox.shrink()),
                                Obx(() => (controller.showMeasurementText.value && controller.showMeasurementImage.value) ||
                                           (!controller.showMeasurementText.value && !controller.showMeasurementImage.value)
                                    ? Column(
                                        children: [
                                          SizedBox(height: 10.h),
                                          Center(
                                            child: Text(
                                              l10n.tpdOr,
                                              style: TextStyle(
                                                color: Colors.grey,
                                                fontSize: 15.sp,
                                              ),
                                            ),
                                          ),
                                          SizedBox(height: 10.h),
                                        ],
                                      )
                                    : const SizedBox.shrink()),
                                Obx(() => controller.showMeasurementImage.value
                                    ? TechPackImageUploadContainer(
                                        onTap: () {
                                          controller.openCameraForMeasurement();
                                        },
                                        imagePath:
                                            controller
                                                .measurementImagePath
                                                .value
                                                .isEmpty
                                            ? null
                                            : controller.measurementImagePath.value,
                                        onEdit: controller.measurementImagePath.value.isNotEmpty
                                            ? () => controller.openCameraForMeasurement()
                                            : null,
                                        onDelete: controller.measurementImagePath.value.isNotEmpty
                                            ? () => controller.clearMeasurementImage()
                                            : null,
                                      )
                                    : const SizedBox.shrink()),
                                SizedBox(height: 10.h),
                                TechPackQuestionField(
                                  label: l10n.tpdAutogeneratedLabel,
                                  hint: l10n.tpdAutogeneratedHint,
                                  controller: controller.autogeneratedController,

                                ),
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
                                TechPackQuestionField(
                                  label: l10n.tpdStitchingLabel,
                                  hint: l10n.tpdStitchingHint,
                                  controller: controller.stitchingController,
                                  onChanged: (_) =>
                                      controller.checkTechnicalBlockComplete(),
                                ),
                                TechPackQuestionField(
                                  label: l10n.tpdDecorativeStitchingLabel,
                                  hint: l10n.tpdDecorativeStitchingHint,
                                  controller:
                                      controller.decorativeStitchingController,
                                  onChanged: (_) =>
                                      controller.checkTechnicalBlockComplete(),
                                ),
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
              // Packaging & Shipping Block
              Obx(
                () => controller.showPackagingBlock.value
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
                                  text: l10n.tpdPackagingShipping,
                                ),
                                SizedBox(height: 10.h),
                                TechPackQuestionField(
                                  label: l10n.tpdPackagingTypeLabel,
                                  hint: l10n.tpdPackagingTypeHint,
                                  controller:
                                      controller.packagingTypeController,
                                  onChanged: (_) =>
                                      controller.checkPackagingBlockComplete(),
                                ),
                                TechPackQuestionField(
                                  label: l10n.tpdFoldingInstructionsLabel,
                                  hint: l10n.tpdFoldingInstructionsHint,
                                  controller:
                                      controller.foldingInstructionsController,
                                  onChanged: (_) =>
                                      controller.checkPackagingBlockComplete(),
                                ),
                                TechPackQuestionField(
                                  label: l10n.tpdInsertsLabel,
                                  hint: l10n.tpdInsertsHint,
                                  controller: controller.insertsController,
                                  onChanged: (_) =>
                                      controller.checkPackagingBlockComplete(),
                                ),
                              ],
                            ),
                          ),
                        ],
                      )
                    : const SizedBox.shrink(),
              ),
              // Production Details Block
              Obx(
                () => controller.showProductionBlock.value
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
                                  text: l10n.tpdProductionDetails,
                                ),
                                SizedBox(height: 10.h),
                                TechPackQuestionField(
                                  label: l10n.tpdCostPerPieceLabel,
                                  hint: l10n.tpdCostPerPieceHint,
                                  controller: controller.costPerPieceController,
                                  onChanged: (_) =>
                                      controller.checkProductionBlockComplete(),
                                ),
                                TechPackQuestionField(
                                  label: l10n.tpdQuantityLabel,
                                  hint: l10n.tpdQuantityHint,
                                  controller: controller.quantityController,
                                  onChanged: (_) =>
                                      controller.checkProductionBlockComplete(),
                                ),
                                TechPackQuestionField(
                                  label: l10n.tpdDeliveryDateLabel,
                                  hint: l10n.tpdDeliveryDateHint,
                                  controller: controller.deliveryDateController,
                                  onChanged: (_) =>
                                      controller.checkProductionBlockComplete(),
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
                                SizedBox(height: 10.h),
                                Text(
                                  l10n.tpdSelectCountryForManufacturers,
                                  style: TextStyle(
                                    fontSize: 14.sp,
                                    fontWeight: FontWeight.w500,
                                    color: const Color(0xFF2C2C2C),
                                  ),
                                ),
                                SizedBox(height: 8.h),
                                Builder(
                                  builder: (ctx) => InkWell(
                                    onTap: () {
                                      showCountryPicker(
                                        context: ctx,
                                        showPhoneCode: false,
                                        onSelect: (Country country) {
                                          controller.setManufacturerCountry(country.name);
                                        },
                                        countryListTheme: CountryListThemeData(
                                          backgroundColor: Colors.white,
                                          textStyle: TextStyle(fontSize: 16.sp),
                                          searchTextStyle: TextStyle(fontSize: 16.sp),
                                          inputDecoration: InputDecoration(
                                            labelText: l10n.tpdSearchCountry,
                                            hintText: l10n.tpdSearchCountryHint,
                                            prefixIcon: const Icon(Icons.search),
                                            border: OutlineInputBorder(
                                              borderSide: BorderSide(
                                                color: const Color(0xFF8C98A8).withValues(alpha: 0.2),
                                              ),
                                            ),
                                          ),
                                        ),
                                      );
                                    },
                                    borderRadius: BorderRadius.circular(12.r),
                                    child: Container(
                                      width: double.infinity,
                                      padding: EdgeInsets.symmetric(vertical: 14.h, horizontal: 16.w),
                                      decoration: BoxDecoration(
                                        color: const Color(0xFFE3E1FB),
                                        borderRadius: BorderRadius.circular(12.r),
                                      ),
                                      child: Row(
                                        children: [
                                          Expanded(
                                            child: Obx(() => Text(
                                              controller.selectedManufacturerCountry.value.isEmpty
                                                  ? l10n.tpdSelectACountry
                                                  : controller.selectedManufacturerCountry.value,
                                              style: TextStyle(
                                                fontSize: 16.sp,
                                                color: controller.selectedManufacturerCountry.value.isEmpty
                                                    ? Colors.grey[600]
                                                    : Colors.black,
                                              ),
                                            )),
                                          ),
                                          Icon(Icons.arrow_drop_down, color: Colors.grey[700]),
                                        ],
                                      ),
                                    ),
                                  ),
                                ),
                                SizedBox(height: 20.h),
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
