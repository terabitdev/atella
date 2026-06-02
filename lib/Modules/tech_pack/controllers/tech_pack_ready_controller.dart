import 'package:get/get.dart';
import 'tech_pack_details_controller.dart';
import 'generate_tech_pack_controller.dart';
import '../../../services/firebase/techpack/tech_pack_service.dart';
import '../../../services/firebase/collections/collections_service.dart';
import 'package:flutter/material.dart';
import 'package:share_plus/share_plus.dart';
import 'package:atella/services/analytics/posthog_analytics_service.dart';
import 'package:atella/l10n/generated/app_localizations.dart';

class TechPackReadyController extends GetxController {
  final TechPackDetailsController _detailsController = Get.find<TechPackDetailsController>();
  final CollectionsService _collectionsService = CollectionsService();

  // Helper to get localization
  AppLocalizations get _l10n => AppLocalizations.of(Get.context!)!;

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
Materials: ${_detailsController.fabricCompositionController.text} ${_detailsController.fabricWeightController.text.isNotEmpty ? '/ ${_detailsController.fabricWeightController.text} GSM' : ''}
Sizes: ${_detailsController.selectedSizes.join(', ')}
    ''';
  }

  // Get manufacturer country preference
  String get manufacturerCountry => _detailsController.manufacturerCountryController.text;

  // Get garment type from creative brief for product filtering
  String get garmentType {
    if (_detailsController.designData.isNotEmpty) {
      final creativeBrief = _detailsController.designData['creativeBrief'] as Map<String, dynamic>?;
      if (creativeBrief != null && creativeBrief['garmentType'] != null) {
        final raw = creativeBrief['garmentType'].toString();
        // Strip category prefix: "Dresses:Cocktail dress" → "Cocktail dress"
        return raw.contains(':') ? raw.split(':').last.trim() : raw;
      }
    }
    return '';
  }

  // Get logo/label reference image data
  String get labelImagePath => _detailsController.labelImagePath.value;
  String get logoPlacement => _detailsController.logoPlacementController.text;
  String get labelsNeededText => _detailsController.labelsNeededController.text;

  bool get hasLabelImage => _detailsController.labelImagePath.value.isNotEmpty;

  String _getProjectName() {
    // Extract garment type for project name
    String garmentType = 'Fashion';

    if (_detailsController.designData.isNotEmpty) {
      final creativeBrief = _detailsController.designData['creativeBrief'] as Map<String, dynamic>?;
      if (creativeBrief != null && creativeBrief['garmentType'] != null) {
        final raw = creativeBrief['garmentType'].toString();
        // Strip category prefix: "Dresses:Cocktail dress" → "Cocktail dress"
        garmentType = raw.contains(':') ? raw.split(':').last.trim() : raw;
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
          _l10n.tprCollectionExists,
          _l10n.tprCollectionAlreadyExists,
          backgroundColor: Colors.black,
          colorText: Colors.white,
          snackPosition: SnackPosition.TOP,
          duration: const Duration(milliseconds: 1500),
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
        _l10n.tprError,
        _l10n.tprFailedToAddCollection,
        backgroundColor: Colors.red,
        colorText: Colors.white,
      );
    }
  }

  // Update selected collection
  void updateSelectedCollection(String collection) {
    selectedCollection.value = collection;
  }

  // CHECKPOINT: Wait for design save to complete before saving tech pack
  Future<bool> _waitForDesignSaveCompletion() async {
    // Check if TechPackController is registered
    if (!Get.isRegistered<TechPackController>()) {
      print('⚠️ TechPackController not registered, skipping design save check');
      return true; // Allow to proceed if controller doesn't exist
    }

    final techPackController = Get.find<TechPackController>();

    // If design is already saved, proceed immediately
    if (techPackController.isDesignSaveComplete.value) {
      print('✅ Design already saved, proceeding with tech pack save');
      return true;
    }

    print('⏳ Design save in progress, waiting...');

    // Show waiting snackbar
    Get.snackbar(
      _l10n.tprSavingDesign,
      _l10n.tprSavingDesignMessage,
      backgroundColor: Colors.black,
      colorText: Colors.white,
      snackPosition: SnackPosition.TOP,
      duration: const Duration(seconds: 10), // Will be dismissed when complete
      showProgressIndicator: true,
    );

    // Poll for completion with 10-second timeout
    const checkInterval = Duration(milliseconds: 500);
    const timeout = Duration(seconds: 10);
    final startTime = DateTime.now();

    while (DateTime.now().difference(startTime) < timeout) {
      // Check if save completed successfully
      if (techPackController.isDesignSaveComplete.value) {
        print('✅ Design save completed, proceeding with tech pack save');
        Get.closeAllSnackbars(); // Dismiss waiting snackbar
        return true;
      }

      // Check if save failed
      if (techPackController.designSaveError.value.isNotEmpty) {
        print('❌ Design save failed: ${techPackController.designSaveError.value}');
        Get.closeAllSnackbars();

        Get.snackbar(
          _l10n.tprSaveFailed,
          _l10n.tprDesignSaveFailedMessage,
          backgroundColor: Colors.red,
          colorText: Colors.white,
          snackPosition: SnackPosition.TOP,
          duration: const Duration(seconds: 3),
        );
        return false;
      }

      // Wait before next check
      await Future.delayed(checkInterval);
    }

    // Timeout reached
    print('⏱️ Design save timeout reached');
    Get.closeAllSnackbars();

    Get.snackbar(
      _l10n.tprSaveFailed,
      _l10n.tprDesignSaveTimeoutMessage,
      backgroundColor: Colors.red,
      colorText: Colors.white,
      snackPosition: SnackPosition.TOP,
      duration: const Duration(seconds: 3),
    );

    return false;
  }

  // Save tech pack images to Firebase with project and collection info
  Future<void> saveTechPackWithDetails(String projectName, String collectionName) async {
    if (!hasGeneratedImages) {
      Get.snackbar(
        _l10n.tprNoImages,
        _l10n.tprGenerateImagesFirst,
        backgroundColor: Colors.red,
        colorText: Colors.white,
      );
      return;
    }

    try {
      isSaving.value = true;

      // CHECKPOINT: Wait for design save to complete before proceeding
      final designSaveComplete = await _waitForDesignSaveCompletion();
      if (!designSaveComplete) {
        print('❌ Tech pack save aborted - design save incomplete');
        return;
      }

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
          'fabricComposition': _detailsController.fabricCompositionController.text,
          'fabricWeight': _detailsController.fabricWeightController.text,
          'secondaryMaterials': _detailsController.secondaryMaterialsController.text,
          'fabricProperties': _detailsController.fabricPropertiesController.text,
        },
        'sizes': {
          'sizeRange': _detailsController.selectedSizes.join(', '),
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
          'labelImage': _detailsController.labelImagePath.value,
          'qrCode': _detailsController.qrCodeController.text,
        },
        'manufacturers': {
          'country': _detailsController.manufacturerCountryController.text,
        },
      };

      print('💾 Saving tech pack with labelImage: ${_detailsController.labelImagePath.value}');
      print('   Logo placement: ${_detailsController.logoPlacementController.text}');
      print('   Measurement image: ${_detailsController.measurementImagePath.value}');

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
          _l10n.tprUpdated,
          _l10n.tprTechPackUpdatedSuccessfully,
          backgroundColor: Colors.black,
          colorText: Colors.white,
          snackPosition: SnackPosition.TOP,
          duration: const Duration(milliseconds: 1500),
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
          _l10n.tprSuccess,
          _l10n.tprTechPackSavedSuccessfully,
          backgroundColor: Colors.black,
          colorText: Colors.white,
          snackPosition: SnackPosition.TOP,
          duration: const Duration(milliseconds: 1500),
        );
      }

      // Track tech pack completed
      String garmentType = 'Fashion';
      if (_detailsController.designData.isNotEmpty) {
        final creativeBrief = _detailsController.designData['creativeBrief'] as Map<String, dynamic>?;
        if (creativeBrief != null && creativeBrief['garmentType'] != null) {
          garmentType = creativeBrief['garmentType'].toString();
        }
      }
      PostHogAnalyticsService().trackTechPackCompleted(garmentType: garmentType);

      // Clear any existing project controller to force refresh
      if (Get.isRegistered<dynamic>(tag: 'projectController')) {
        Get.delete(tag: 'projectController', force: true);
      }

      // Navigate to nav_bar with refresh flag
      Get.offNamedUntil('/nav_bar', (route) => false, arguments: {'refresh': true});
    } catch (e) {
      Get.snackbar(
        _l10n.tprError,
        _l10n.tprFailedToSaveTechPack(e.toString()),
        backgroundColor: Colors.red,
        colorText: Colors.white,
        snackPosition: SnackPosition.TOP,
        duration: const Duration(milliseconds: 1500),
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

  // Export tech pack as PDF with logo option
  Future<void> exportTechPackPDF({bool withLogo = true}) async {
    if (!hasGeneratedImages) {
      Get.snackbar(
        _l10n.tprNoImages,
        _l10n.tprGenerateImagesFirst,
        backgroundColor: Colors.red,
        colorText: Colors.white,
        snackPosition: SnackPosition.TOP,
      );
      return;
    }

    try {
      isExporting.value = true;

      // Generate PDF with dynamic project name and logo option
      final projectName = _getProjectName();
      final pdfPath = await TechPackService.generateTechPackPDF(
        base64Images: generatedImages,
        techPackSummary: techPackSummary,
        projectName: projectName,
        withLogo: withLogo,
        labelImagePath: labelImagePath.isNotEmpty ? labelImagePath : null,
        logoPlacement: logoPlacement.isNotEmpty ? logoPlacement : null,
      );

      // Open share sheet instead of downloading
      await _shareFile(pdfPath);
      
      // Download PDF to Downloads folder
      await TechPackService.downloadPDF(pdfPath);

      Get.snackbar(
        _l10n.tprSuccess,
        _l10n.tprPdfSavedSuccessfully,
        backgroundColor: Colors.black,
        colorText: Colors.white,
        snackPosition: SnackPosition.TOP,
        duration: const Duration(seconds: 3),
      );

      // Track tech pack downloaded
      PostHogAnalyticsService().trackTechPackDownloaded(format: 'pdf');
    } catch (e) {
      print('Error exporting PDF: ${e.toString()}');
      Get.snackbar(
        _l10n.tprError,
        _l10n.tprFailedToExportPdf(e.toString()),
        backgroundColor: Colors.red,
        colorText: Colors.white,
        snackPosition: SnackPosition.TOP,
        duration: const Duration(milliseconds: 1500),
      );
    } finally {
      isExporting.value = false;
    }
  }

  // Export tech pack as Word document
  Future<void> exportTechPackWord() async {
    if (!hasGeneratedImages) {
      Get.snackbar(
        _l10n.tprNoImages,
        _l10n.tprGenerateImagesFirst,
        backgroundColor: Colors.red,
        colorText: Colors.white,
        snackPosition: SnackPosition.TOP,
      );
      return;
    }

    try {
      isExporting.value = true;

      // Generate Word document with dynamic project name
      final projectName = _getProjectName();
      final wordPath = await TechPackService.generateTechPackWord(
        base64Images: generatedImages,
        techPackSummary: techPackSummary,
        projectName: projectName,
      );

      // Open share sheet instead of downloading
      await _shareFile(wordPath);

    } catch (e) {
      print('Error exporting Word: ${e.toString()}');
      Get.snackbar(
        _l10n.tprError,
        _l10n.tprFailedToExportWord(e.toString()),
        backgroundColor: Colors.red,
        colorText: Colors.white,
        snackPosition: SnackPosition.TOP,
        duration: const Duration(milliseconds: 1500),
      );
    } finally {
      isExporting.value = false;
    }
  }

  // Share file using share_plus
  Future<void> _shareFile(String filePath) async {
    try {
      final file = XFile(filePath);
      await Share.shareXFiles(
        [file],
        text: _l10n.tprTechPackDocument,
      );
    } catch (e) {
      print('Error sharing file: ${e.toString()}');
      Get.snackbar(
        _l10n.tprError,
        _l10n.tprFailedToShareFile(e.toString()),
        backgroundColor: Colors.red,
        colorText: Colors.white,
        snackPosition: SnackPosition.TOP,
      );
    }
  }
}