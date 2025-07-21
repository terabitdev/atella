import 'package:get/get.dart';
import 'package:flutter/material.dart';

class TechPackDetailsController extends GetxController {
  // Materials & Fabrics
  final mainFabricController = TextEditingController();
  final secondaryMaterialsController = TextEditingController();
  final fabricPropertiesController = TextEditingController();

  // Colors
  final primaryColorController = TextEditingController();
  final alternateColorwaysController = TextEditingController();
  final pantoneController = TextEditingController();

  // Sizes & Measurements
  final sizeRangeController = TextEditingController();
  final measurementChartController = TextEditingController();
  final RxString measurementImagePath = ''.obs;

  // Technical Details
  final accessoriesController = TextEditingController();
  final stitchingController = TextEditingController();
  final decorativeStitchingController = TextEditingController();

  // Labeling & Branding
  final logoPlacementController = TextEditingController();
  final labelsNeededController = TextEditingController();
  final qrCodeController = TextEditingController();

  // Packaging & Shipping
  final packagingTypeController = TextEditingController();
  final foldingInstructionsController = TextEditingController();
  final insertsController = TextEditingController();

  // Production Details
  final costPerPieceController = TextEditingController();
  final quantityController = TextEditingController();
  final deliveryDateController = TextEditingController();

  // Block visibility
  final RxBool showColorsBlock = false.obs;
  final RxBool showSizesBlock = false.obs;
  final RxBool showTechnicalBlock = false.obs;
  final RxBool showLabelingBlock = false.obs;
  final RxBool showPackagingBlock = false.obs;
  final RxBool showProductionBlock = false.obs;

  void checkMaterialsBlockComplete() {
    if (mainFabricController.text.isNotEmpty &&
        secondaryMaterialsController.text.isNotEmpty &&
        fabricPropertiesController.text.isNotEmpty) {
      showColorsBlock.value = true;
    }
  }

  void checkColorsBlockComplete() {
    if (primaryColorController.text.isNotEmpty &&
        alternateColorwaysController.text.isNotEmpty &&
        pantoneController.text.isNotEmpty) {
      showSizesBlock.value = true;
    }
  }

  void checkSizesBlockComplete() {
    if (sizeRangeController.text.isNotEmpty &&
        measurementChartController.text.isNotEmpty) {
      showTechnicalBlock.value = true;
    }
  }

  void checkTechnicalBlockComplete() {
    if (accessoriesController.text.isNotEmpty &&
        stitchingController.text.isNotEmpty &&
        decorativeStitchingController.text.isNotEmpty) {
      showLabelingBlock.value = true;
    }
  }

  void checkLabelingBlockComplete() {
    if (logoPlacementController.text.isNotEmpty &&
        labelsNeededController.text.isNotEmpty &&
        qrCodeController.text.isNotEmpty) {
      showPackagingBlock.value = true;
    }
  }

  void checkPackagingBlockComplete() {
    if (packagingTypeController.text.isNotEmpty &&
        foldingInstructionsController.text.isNotEmpty &&
        insertsController.text.isNotEmpty) {
      showProductionBlock.value = true;
    }
  }

  void checkProductionBlockComplete() {
    // No further block, but could trigger a summary or enable submit
  }

  @override
  void onClose() {
    mainFabricController.dispose();
    secondaryMaterialsController.dispose();
    fabricPropertiesController.dispose();
    primaryColorController.dispose();
    alternateColorwaysController.dispose();
    pantoneController.dispose();
    sizeRangeController.dispose();
    measurementChartController.dispose();
    accessoriesController.dispose();
    stitchingController.dispose();
    decorativeStitchingController.dispose();
    logoPlacementController.dispose();
    labelsNeededController.dispose();
    qrCodeController.dispose();
    packagingTypeController.dispose();
    foldingInstructionsController.dispose();
    insertsController.dispose();
    costPerPieceController.dispose();
    quantityController.dispose();
    deliveryDateController.dispose();
    super.onClose();
  }
}
