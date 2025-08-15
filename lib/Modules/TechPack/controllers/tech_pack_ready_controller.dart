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

  // Dialog state management
  final TextEditingController projectNameController = TextEditingController();
  RxString selectedCollection = 'SUMMER COLLECTION'.obs;
  RxList<String> collections = <String>['SUMMER COLLECTION', 'WINTER COLLECTION'].obs;

  @override
  void onClose() {
    projectNameController.dispose();
    super.onClose();
  }

  // Add new collection
  void addNewCollection(String collectionName) {
    collections.add(collectionName.toUpperCase());
    selectedCollection.value = collectionName.toUpperCase();
  }

  // Update selected collection
  void updateSelectedCollection(String collection) {
    selectedCollection.value = collection;
  }

  // Save tech pack images to Firebase with project and collection info
  Future<void> saveTechPackWithDetails(String projectName, String collectionName) async {
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
      
      // Get selected design image URL
      final selectedDesignImageUrl = await TechPackService.getSelectedDesignImageUrl();
      
      // Save images to Firebase Storage with project and collection details
      await TechPackService.saveTechPackImages(
        base64Images: generatedImages,
        techPackId: techPackId,
        projectName: projectName,
        collectionName: collectionName,
        selectedDesignImageUrl: selectedDesignImageUrl,
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

  // Legacy save method (kept for compatibility)
  Future<void> saveTechPack() async {
    // Use default values for legacy calls
    await saveTechPackWithDetails(_getProjectName(), 'GENERAL COLLECTION');
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