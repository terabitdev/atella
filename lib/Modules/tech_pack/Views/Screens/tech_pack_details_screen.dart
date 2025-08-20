import 'package:atella/modules/tech_pack/Views/Widgets/roound_tag_container.dart';
import 'package:atella/Widgets/app_header.dart';
import 'package:atella/core/constants/app_images.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import '../../controllers/tech_pack_details_controller.dart';
import '../Widgets/tech_pack_question_field.dart';
import '../Widgets/tech_pack_image_upload_container.dart';
import 'package:atella/modules/tech_pack/Views/Widgets/outline_genrate_round_button.dart';
import 'package:atella/core/themes/app_colors.dart';

class TechPackDetailsScreen extends StatelessWidget {
  TechPackDetailsScreen({super.key});
  final controller = Get.find<TechPackDetailsController>();

  void onContinue() {}

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFFDFDFD),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: EdgeInsets.symmetric(horizontal: 18.w, vertical: 8.h),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              SizedBox(height: 8.h),
              GlobalHeader(
                title: 'Final Design Validated',
                onBack: () => Get.back(),
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
                    RoundedTagContainer(text: 'Materials & Fabrics'),
                    SizedBox(height: 10.h),
                    TechPackQuestionField(
                      label: 'What is the main fabric used?',
                      hint: 'Main Fabric: Organic cotton twill',
                      controller: controller.mainFabricController,
                      onChanged: (_) =>
                          controller.checkMaterialsBlockComplete(),
                    ),
                    TechPackQuestionField(
                      label: 'Are there any secondary materials or linings?',
                      hint: 'Polyester mesh lining',
                      controller: controller.secondaryMaterialsController,
                      onChanged: (_) =>
                          controller.checkMaterialsBlockComplete(),
                    ),
                    TechPackQuestionField(
                      label:
                          'Does the fabric have any technical properties? (e.g. organic, stretch, water-repellent)',
                      hint: 'Breathable, stretchable, water-repellent',
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
                                const RoundedTagContainer(text: 'Colors'),
                                SizedBox(height: 10.h),
                                TechPackQuestionField(
                                  label:
                                      'What is the primary color of the garment?',
                                  hint: 'Sky blue',
                                  controller: controller.primaryColorController,
                                  onChanged: (_) =>
                                      controller.checkColorsBlockComplete(),
                                ),
                                TechPackQuestionField(
                                  label:
                                      'Are there any alternate colorways to produce?',
                                  hint: 'Sage green, off-white',
                                  controller:
                                      controller.alternateColorwaysController,
                                  onChanged: (_) =>
                                      controller.checkColorsBlockComplete(),
                                ),
                                TechPackQuestionField(
                                  label:
                                      'Do you have Pantone references or HEX codes for the colors?',
                                  hint: 'Pantone 290C, #C1DAD6',
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
                                const RoundedTagContainer(
                                  text: 'Sizes & Measurements',
                                ),
                                SizedBox(height: 10.h),
                                TechPackQuestionField(
                                  label:
                                      'What size range do you plan to produce? (e.g. XS–XL)',
                                  hint: '',
                                  controller: controller.sizeRangeController,
                                  onChanged: (_) =>
                                      controller.checkSizesBlockComplete(),
                                ),
                                TechPackQuestionField(
                                  label:
                                      'Will you provide a measurement chart by size?',
                                  hint: '',
                                  controller:
                                      controller.measurementChartController,
                                  onChanged: (_) =>
                                      controller.checkSizesBlockComplete(),
                                ),
                                SizedBox(height: 10.h),
                                Center(
                                  child: Text(
                                    'or',
                                    style: TextStyle(
                                      color: Colors.grey,
                                      fontSize: 15.sp,
                                    ),
                                  ),
                                ),
                                SizedBox(height: 10.h),
                                Obx(
                                  () => TechPackImageUploadContainer(
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
                                  ),
                                ),
                                SizedBox(height: 10.h),
                                TechPackQuestionField(
                                  label:
                                      'Or should the AI auto-generate one from the 3D model?',
                                  hint: '',
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
                                const RoundedTagContainer(
                                  text: 'Technical Details',
                                ),
                                SizedBox(height: 10.h),
                                TechPackQuestionField(
                                  label: 'Are there any accessories?',
                                  hint: 'Zipper, buttons, drawcord',
                                  controller: controller.accessoriesController,
                                  onChanged: (_) =>
                                      controller.checkTechnicalBlockComplete(),
                                ),
                                TechPackQuestionField(
                                  label:
                                      'Any specific assembly or stitching instructions?',
                                  hint: 'Reinforced double stitch',
                                  controller: controller.stitchingController,
                                  onChanged: (_) =>
                                      controller.checkTechnicalBlockComplete(),
                                ),
                                TechPackQuestionField(
                                  label:
                                      'Do you require visible, reinforced, or decorative stitching?',
                                  hint: 'Contrast topstitching sleeves',
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
                                const RoundedTagContainer(
                                  text: 'Labeling & Branding',
                                ),
                                SizedBox(height: 10.h),
                                TechPackQuestionField(
                                  label:
                                      'Where should the logo or brand name appear?',
                                  hint: 'Logo Placement: Chest & neck',
                                  controller:
                                      controller.logoPlacementController,
                                  onChanged: (_) =>
                                      controller.checkLabelingBlockComplete(),
                                ),
                                TechPackQuestionField(
                                  label: 'What types of labels are needed?',
                                  hint: 'Brand, care, size',
                                  controller: controller.labelsNeededController,
                                  onChanged: (_) =>
                                      controller.checkLabelingBlockComplete(),
                                ),
                                TechPackQuestionField(
                                  label:
                                      'Should a QR code, barcode, or NFC chip be included?',
                                  hint: 'Add QR code',
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
                                const RoundedTagContainer(
                                  text: 'Packaging & Shipping',
                                ),
                                SizedBox(height: 10.h),
                                TechPackQuestionField(
                                  label: 'What type of packaging is required?',
                                  hint: 'Kraft box + polybag',
                                  controller:
                                      controller.packagingTypeController,
                                  onChanged: (_) =>
                                      controller.checkPackagingBlockComplete(),
                                ),
                                TechPackQuestionField(
                                  label:
                                      'Any specific folding or packing instructions?',
                                  hint: 'Fold across chest',
                                  controller:
                                      controller.foldingInstructionsController,
                                  onChanged: (_) =>
                                      controller.checkPackagingBlockComplete(),
                                ),
                                TechPackQuestionField(
                                  label:
                                      'Would you like to include a product sheet or flyer?',
                                  hint: 'Inserts: Thank-you card, care sheet',
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
                                const RoundedTagContainer(
                                  text: 'Production Details',
                                ),
                                SizedBox(height: 10.h),
                                TechPackQuestionField(
                                  label: 'What is the target cost per piece?',
                                  hint: 'Cost per Piece: €3.8',
                                  controller: controller.costPerPieceController,
                                  onChanged: (_) =>
                                      controller.checkProductionBlockComplete(),
                                ),
                                TechPackQuestionField(
                                  label:
                                      'How many units do you plan to produce?',
                                  hint: 'Quantity: 1,000 units',
                                  controller: controller.quantityController,
                                  onChanged: (_) =>
                                      controller.checkProductionBlockComplete(),
                                ),
                                TechPackQuestionField(
                                  label: 'What is your desired delivery date?',
                                  hint: 'Delivery: 30 Sept 2025',
                                  controller: controller.deliveryDateController,
                                  onChanged: (_) =>
                                      controller.checkProductionBlockComplete(),
                                ),
                                SizedBox(height: 20.h),
                                OutlineGenerateRoundButton(
                                  title: 'Generate Tech Pack',
                                  onTap: () {
                                    controller.checkSubscriptionAndGenerate();
                                  },
                                  color: AppColors.buttonColor,
                                  loading: false,
                                  imagePath: generateTechPackIcon,
                                ),
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
    );
  }
}
