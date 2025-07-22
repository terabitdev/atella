import 'package:atella/Modules/TechPack/Views/Widgets/roound_tag_container.dart';
import 'package:atella/Widgets/app_header.dart';
import 'package:atella/core/themes/app_fonts.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import '../../controllers/tech_pack_details_controller.dart';
import '../Widgets/tech_pack_question_field.dart';
import '../Widgets/tech_pack_image_upload_container.dart';
import 'package:atella/Modules/TechPack/Views/Widgets/outline_genrate_round_button.dart';
import 'package:atella/core/themes/app_colors.dart';
import 'package:atella/core/constants/app_iamges.dart';

class TechPackDetailsScreen extends StatelessWidget {
  TechPackDetailsScreen({Key? key}) : super(key: key);
  final controller = Get.put(TechPackDetailsController());

  void onContinue() {
    // TODO: Implement continue logic
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFFDFDFD),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 8),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const SizedBox(height: 8),
              GlobalHeader(
                title: 'Final Design Validated',
                onBack: () => Get.back(),
              ),
              const SizedBox(height: 18),
              // Materials & Fabrics Block
              Container(
                width: double.infinity,
                padding: const EdgeInsets.symmetric(
                  vertical: 18,
                  horizontal: 14,
                ),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(18),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    RoundedTagContainer(text: 'Materials & Fabrics'),
                    const SizedBox(height: 10),
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
                          const SizedBox(height: 18),
                          Container(
                            width: double.infinity,
                            padding: const EdgeInsets.symmetric(
                              vertical: 18,
                              horizontal: 14,
                            ),
                            decoration: BoxDecoration(
                              color: Colors.white,
                              borderRadius: BorderRadius.circular(18),
                            ),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                const RoundedTagContainer(text: 'Colors'),
                                const SizedBox(height: 10),
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
                          const SizedBox(height: 18),
                          Container(
                            width: double.infinity,
                            padding: const EdgeInsets.symmetric(
                              vertical: 18,
                              horizontal: 14,
                            ),
                            decoration: BoxDecoration(
                              color: Colors.white,
                              borderRadius: BorderRadius.circular(18),
                            ),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                const RoundedTagContainer(
                                  text: 'Sizes & Measurements',
                                ),
                                const SizedBox(height: 10),
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
                                const SizedBox(height: 10),
                                Center(
                                  child: Text(
                                    'or',
                                    style: TextStyle(
                                      color: Colors.grey,
                                      fontSize: 15,
                                    ),
                                  ),
                                ),
                                const SizedBox(height: 10),
                                TechPackImageUploadContainer(
                                  onTap: () {
                                    // TODO: Implement image picker/camera
                                  },
                                  imagePath:
                                      controller
                                          .measurementImagePath
                                          .value
                                          .isEmpty
                                      ? null
                                      : controller.measurementImagePath.value,
                                ),
                                const SizedBox(height: 10),
                                TechPackQuestionField(
                                  label:
                                      'Or should the AI auto-generate one from the 3D model?',
                                  hint: '',
                                  controller: TextEditingController(),
                                  enabled: false,
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
                          const SizedBox(height: 18),
                          Container(
                            width: double.infinity,
                            padding: const EdgeInsets.symmetric(
                              vertical: 18,
                              horizontal: 14,
                            ),
                            decoration: BoxDecoration(
                              color: Colors.white,
                              borderRadius: BorderRadius.circular(18),
                            ),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                const RoundedTagContainer(
                                  text: 'Technical Details',
                                ),
                                const SizedBox(height: 10),
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
                          const SizedBox(height: 18),
                          Container(
                            width: double.infinity,
                            padding: const EdgeInsets.symmetric(
                              vertical: 18,
                              horizontal: 14,
                            ),
                            decoration: BoxDecoration(
                              color: Colors.white,
                              borderRadius: BorderRadius.circular(18),
                            ),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                const RoundedTagContainer(
                                  text: 'Labeling & Branding',
                                ),
                                const SizedBox(height: 10),
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
                          const SizedBox(height: 18),
                          Container(
                            width: double.infinity,
                            padding: const EdgeInsets.symmetric(
                              vertical: 18,
                              horizontal: 14,
                            ),
                            decoration: BoxDecoration(
                              color: Colors.white,
                              borderRadius: BorderRadius.circular(18),
                            ),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                const RoundedTagContainer(
                                  text: 'Packaging & Shipping',
                                ),
                                const SizedBox(height: 10),
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
                          const SizedBox(height: 18),
                          Container(
                            width: double.infinity,
                            padding: const EdgeInsets.symmetric(
                              vertical: 18,
                              horizontal: 14,
                            ),
                            decoration: BoxDecoration(
                              color: Colors.white,
                              borderRadius: BorderRadius.circular(18),
                            ),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                const RoundedTagContainer(
                                  text: 'Production Details',
                                ),
                                const SizedBox(height: 10),
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
                                const SizedBox(height: 20),
                                OutlineGenerateRoundButton(
                                  title: 'Generate Tech Pack',
                                  onTap: () {
                                    Get.toNamed('/tech_pack_ready_screen');
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
              const SizedBox(height: 30),
            ],
          ),
        ),
      ),
    );
  }
}
