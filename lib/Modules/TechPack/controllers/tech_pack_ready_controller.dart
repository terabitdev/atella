import 'package:get/get.dart';
import 'tech_pack_details_controller.dart';
import '../../../services/firebase/techpack/tech_pack_service.dart';
import 'package:flutter/material.dart';

class TechPackReadyController extends GetxController {
  final TechPackDetailsController _detailsController = Get.find<TechPackDetailsController>();
  
  List<String> get generatedImages => _detailsController.generatedTechPackImages;
  
  String get selectedDesignImage => _detailsController.selectedDesignImagePath.value;
  
  bool get isGenerating => _detailsController.isGeneratingTechPack.value;
  
  RxInt selectedImageIndex = 0.obs;
  
  void selectImage(int index) {
    selectedImageIndex.value = index;
  }
  
  bool get hasGeneratedImages => generatedImages.isNotEmpty;
  
  String? get currentSelectedImage {
    if (hasGeneratedImages && selectedImageIndex.value < generatedImages.length) {
      return generatedImages[selectedImageIndex.value];
    }
    return null;
  }
  
  String get techPackSummary {
    return '''
Materials: ${_detailsController.mainFabricController.text}
Colors: ${_detailsController.primaryColorController.text}
Sizes: ${_detailsController.sizeRangeController.text}
Quantity: ${_detailsController.quantityController.text}
Target Cost: ${_detailsController.costPerPieceController.text}
Delivery: ${_detailsController.deliveryDateController.text}
    ''';
  }

  String _getProjectName() {
    // Extract garment type for project name
    String garmentType = 'Fashion';
    
    if (_detailsController.designData.isNotEmpty) {
      final creativeBrief = _detailsController.designData['creativeBrief'] as Map<String, dynamic>?;
      if (creativeBrief != null && creativeBrief['garmentType'] != null) {
        garmentType = creativeBrief['garmentType'].toString();
      }
    }
    
    return '$garmentType Tech Pack';
  }

  // Loading states
  RxBool isSaving = false.obs;
  RxBool isExporting = false.obs;

  // Save tech pack images to Firebase
  Future<void> saveTechPack() async {
    if (!hasGeneratedImages) {
      Get.snackbar(
        'No Images',
        'Please generate tech pack images first',
        backgroundColor: Colors.red,
        colorText: Colors.white,
      );
      return;
    }

    try {
      isSaving.value = true;
      
      // Generate unique tech pack ID
      final techPackId = DateTime.now().millisecondsSinceEpoch.toString();
      
      // Save images to Firebase Storage
      await TechPackService.saveTechPackImages(
        base64Images: generatedImages,
        techPackId: techPackId,
      );

      Get.snackbar(
        'Success',
        'Tech pack saved successfully!',
        backgroundColor: Colors.green,
        colorText: Colors.white,
        duration: const Duration(seconds: 2),
      );

      // Navigate to nav_bar after successful save
      Get.toNamed('/nav_bar');
    } catch (e) {
      Get.snackbar(
        'Error',
        'Failed to save tech pack: ${e.toString()}',
        backgroundColor: Colors.red,
        colorText: Colors.white,
        duration: const Duration(seconds: 3),
      );
      print('Error saving tech pack: ${e.toString()}');
    } finally {
      isSaving.value = false;
    }
  }

  // Export tech pack as PDF
  Future<void> exportTechPackPDF() async {
    if (!hasGeneratedImages) {
      Get.snackbar(
        'No Images',
        'Please generate tech pack images first',
        backgroundColor: Colors.red,
        colorText: Colors.white,
      );
      return;
    }

    try {
      isExporting.value = true;

      // Generate PDF with dynamic project name
      final projectName = _getProjectName();
      final pdfPath = await TechPackService.generateTechPackPDF(
        base64Images: generatedImages,
        techPackSummary: techPackSummary,
        projectName: projectName,
      );

      // Download PDF to Downloads folder
      final downloadPath = await TechPackService.downloadPDF(pdfPath);

      Get.snackbar(
        'Success',
        'Tech pack PDF saved successfully!',
        backgroundColor: Colors.green,
        colorText: Colors.white,
        duration: const Duration(seconds: 3),
      );
    } catch (e) {
      print('Error exporting PDF: ${e.toString()}');
      Get.snackbar(
        'Error',
        'Failed to export PDF: ${e.toString()}',
        backgroundColor: Colors.red,
        colorText: Colors.white,
        duration: const Duration(seconds: 3),
      );
    } finally {
      isExporting.value = false;
    }
  }
}