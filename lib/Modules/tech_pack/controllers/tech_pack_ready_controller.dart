import 'package:get/get.dart';
import 'tech_pack_details_controller.dart';
import '../../../services/firebase/techpack/tech_pack_service.dart';
import '../../../services/firebase/collections/collections_service.dart';
import 'package:flutter/material.dart';

class TechPackReadyController extends GetxController {
  final TechPackDetailsController _detailsController = Get.find<TechPackDetailsController>();
  final CollectionsService _collectionsService = CollectionsService();
  
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
  void onInit() {
    super.onInit();
    _loadCollections();
  }

  @override
  void onClose() {
    projectNameController.dispose();
    super.onClose();
  }

  // Load collections from Firebase
  Future<void> _loadCollections() async {
    try {
      final userCollections = await _collectionsService.getUserCollections();
      collections.value = userCollections;
      if (userCollections.isNotEmpty) {
        selectedCollection.value = userCollections.first;
      }
    } catch (e) {
      print('Error loading collections: $e');
    }
  }

  // Add new collection and save to Firebase
  Future<void> addNewCollection(String collectionName) async {
    try {
      final upperCaseName = collectionName.toUpperCase();
      
      // Check if collection already exists
      if (collections.contains(upperCaseName)) {
        Get.snackbar(
          'Collection Exists',
          'This collection already exists',
          backgroundColor: Colors.orange,
          colorText: Colors.white,
          duration: const Duration(seconds: 2),
        );
        return;
      }
      
      // Add to Firebase
      await _collectionsService.addCollection(upperCaseName);
      
      // Update local list
      collections.add(upperCaseName);
      selectedCollection.value = upperCaseName;
      
      print('Collection added successfully: $upperCaseName');
    } catch (e) {
      print('Error adding collection: $e');
      Get.snackbar(
        'Error',
        'Failed to add collection',
        backgroundColor: Colors.red,
        colorText: Colors.white,
      );
    }
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
      
      // Check if we're in edit mode
      final isEditMode = _detailsController.isEditMode;
      final editingTechPack = _detailsController.editingTechPack;

      // Use existing tech pack ID in edit mode, or generate new one
      final techPackId = isEditMode && editingTechPack != null 
          ? editingTechPack.id 
          : DateTime.now().millisecondsSinceEpoch.toString();
      
      // Get selected design image URL
      final selectedDesignImageUrl = await TechPackService.getSelectedDesignImageUrl();
      
      // Collect tech pack questionnaire data
      Map<String, dynamic> techPackQuestionnaireData = {
        'materials': {
          'mainFabric': _detailsController.mainFabricController.text,
          'secondaryMaterials': _detailsController.secondaryMaterialsController.text,
          'fabricProperties': _detailsController.fabricPropertiesController.text,
        },
        'colors': {
          'primaryColor': _detailsController.primaryColorController.text,
          'alternateColorways': _detailsController.alternateColorwaysController.text,
          'pantone': _detailsController.pantoneController.text,
        },
        'sizes': {
          'sizeRange': _detailsController.sizeRangeController.text,
          'measurementChart': _detailsController.measurementChartController.text,
          'measurementImage': _detailsController.measurementImagePath.value,
        },
        'technical': {
          'accessories': _detailsController.accessoriesController.text,
          'stitching': _detailsController.stitchingController.text,
          'decorativeStitching': _detailsController.decorativeStitchingController.text,
        },
        'labeling': {
          'logoPlacement': _detailsController.logoPlacementController.text,
          'labelsNeeded': _detailsController.labelsNeededController.text,
          'qrCode': _detailsController.qrCodeController.text,
        },
        'packaging': {
          'packagingType': _detailsController.packagingTypeController.text,
          'foldingInstructions': _detailsController.foldingInstructionsController.text,
          'inserts': _detailsController.insertsController.text,
        },
        'production': {
          'costPerPiece': _detailsController.costPerPieceController.text,
          'quantity': _detailsController.quantityController.text,
          'deliveryDate': _detailsController.deliveryDateController.text,
        },
      };
      
      if (isEditMode && editingTechPack != null) {
        // EDIT MODE: Update existing tech pack
        print('=== EDIT MODE: Updating existing tech pack ===');
        
        // Update tech pack details and questionnaire data
        await _collectionsService.addCollection(collectionName); // Ensure collection exists
        
        await TechPackService.saveTechPackImages(
          base64Images: generatedImages,
          techPackId: techPackId,
          projectName: projectName,
          collectionName: collectionName,
          selectedDesignImageUrl: selectedDesignImageUrl,
          techPackQuestionnaireData: techPackQuestionnaireData,
          designData: _detailsController.designData,
        );
        
        Get.snackbar(
          'Updated!',
          'Tech pack updated successfully!',
          backgroundColor: Colors.blue,
          colorText: Colors.white,
          duration: const Duration(seconds: 2),
        );
      } else {
        // NEW TECH PACK MODE: Create new tech pack
        print('=== NEW TECH PACK MODE ===');
        
        await TechPackService.saveTechPackImages(
          base64Images: generatedImages,
          techPackId: techPackId,
          projectName: projectName,
          collectionName: collectionName,
          selectedDesignImageUrl: selectedDesignImageUrl,
          techPackQuestionnaireData: techPackQuestionnaireData,
          designData: _detailsController.designData,
        );
        
        Get.snackbar(
          'Success',
          'Tech pack saved successfully!',
          backgroundColor: Colors.green,
          colorText: Colors.white,
          duration: const Duration(seconds: 2),
        );
      }

      // Clear any existing project controller to force refresh
      if (Get.isRegistered<dynamic>(tag: 'projectController')) {
        Get.delete(tag: 'projectController', force: true);
      }

      // Navigate to nav_bar with refresh flag
      Get.offNamedUntil('/nav_bar', (route) => false, arguments: {'refresh': true});
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