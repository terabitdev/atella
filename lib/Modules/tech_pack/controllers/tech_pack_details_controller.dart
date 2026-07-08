import 'package:get/get.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:image_picker/image_picker.dart';
import 'package:atella/l10n/generated/app_localizations.dart';
import '../../../Data/api/openai_service.dart';
import '../../../Data/Models/tech_pack_model.dart';
import '../../../Data/Models/user_subscription.dart';
import '../../../services/firebase/edit/edit_data_service.dart';
import '../../../services/PaymentService/stripe_subscription_service.dart';
import '../../../services/PaymentService/revenuecat_service.dart';
import '../../../services/PaymentService/subscription_callback_service.dart';
import '../../../services/internet_connectivity_checker.dart';
import '../Views/Widgets/techpack_limit_dialog.dart';

import 'package:atella/core/utils/app_snackbar.dart';
class TechPackDetailsController extends GetxController {
  final EditDataService _editDataService = EditDataService();
  final StripeSubscriptionService _subscriptionService =
      StripeSubscriptionService();
  final RevenueCatService _revenueCatService = RevenueCatService();

  // Live localized price string for the techpack add-on (iOS only).
  // Null on Android or if the RevenueCat fetch failed — dialogs fall back to localisation.
  String? _techpackPriceString;

  // Helper to get localization
  AppLocalizations get _l10n => AppLocalizations.of(Get.context!)!;

  // Edit mode tracking
  final RxBool _isEditMode = false.obs;
  bool get isEditMode => _isEditMode.value;
  TechPackModel? _editingTechPack;
  // Materials & Fabrics
  final fabricCompositionController = TextEditingController();
  final fabricWeightController = TextEditingController();
  final secondaryMaterialsController = TextEditingController();
  final fabricPropertiesController = TextEditingController();

  // Industry standards checkboxes + validation errors
  final RxBool useIndustryStandardComposition = false.obs;
  final RxBool useIndustryStandardGSM = false.obs;
  final RxBool useIndustryStandardProperties = false.obs;
  final RxBool useIndustryStandardStitching = false.obs;
  final RxBool useIndustryStandardDecorativeStitching = false.obs;
  final RxString compositionError = ''.obs;
  final RxString weightError = ''.obs;

  // Sizes & Measurements
  // Changed from TextEditingController to RxList for checkbox multi-select
  final RxList<String> selectedSizes = <String>[].obs;
  final measurementChartController = TextEditingController();
  final RxString measurementImagePath = ''.obs;
  final RxBool providingOwnChart = false.obs;

  // Available size options
  static const List<String> availableSizes = [
    'XXS',
    'XS',
    'S',
    'M',
    'L',
    'XL',
    'XXL',
  ];

  // Technical Details
  final accessoriesController = TextEditingController();
  final stitchingController = TextEditingController();
  final decorativeStitchingController = TextEditingController();

  // Labeling & Branding
  final logoPlacementController = TextEditingController();
  final labelsNeededController = TextEditingController();
  final qrCodeController = TextEditingController();
  final RxString labelImagePath = ''.obs;
  final RxBool showLabelImage = true.obs;
  final RxBool showLabelText = true.obs;

  // Manufacturers
  final manufacturerCountryController = TextEditingController();
  final RxString selectedManufacturerCountry = ''.obs;

  // Block visibility
  final RxBool showSizesBlock = false.obs;
  final RxBool showTechnicalBlock = false.obs;
  final RxBool showLabelingBlock = false.obs;
  final RxBool showManufacturersBlock = false.obs;

  // Image picker instance
  final ImagePicker _picker = ImagePicker();

  // Tech pack generation state
  final RxBool isStartingGeneration = false.obs;
  final RxBool isGeneratingTechPack = false.obs;
  final RxBool generationCancelled = false.obs;
  final RxList<String> generatedTechPackImages = <String>[].obs;
  // Progress tracking (step: 0=idle, 1=generating prompts, 2=manufacturing image, 3=technical drawing)
  final RxDouble generationProgress = 0.0.obs;
  final RxInt generationStep = 0.obs;
  final RxString selectedDesignImagePath = ''.obs;
  final RxString selectedDesignPrompt = ''.obs;
  Map<String, dynamic> designData = {};

  // Generation ID + In-Flight Guard for preventing duplicate generations
  String? _activeGenerationId;
  bool _isGenerationInFlight = false;

  TechPackModel? get editingTechPack => _editingTechPack;

  @override
  void onInit() {
    super.onInit();
    _initializeWithArguments();
    _setupInputListeners();
    _fetchAddonPrices();
  }

  Future<void> _fetchAddonPrices() async {
    try {
      final prices = await _revenueCatService.fetchAddonPriceStrings();
      _techpackPriceString = prices.techpackPrice;
    } catch (e) {
      // _techpackPriceString stays null — dialogs fall back to localisation strings
    }
  }

  void _setupInputListeners() {
    measurementImagePath.listen((_) => checkSizesBlockComplete());

    // Listen to label text changes - hide image upload when text is filled
    labelsNeededController.addListener(() {
      if (labelsNeededController.text.trim().isNotEmpty) {
        showLabelImage.value = false;
      } else if (labelImagePath.value.isEmpty) {
        showLabelImage.value = true;
      }
    });

    // Listen to label image changes - hide text field when image is uploaded
    labelImagePath.listen((imagePath) {
      if (imagePath.isNotEmpty) {
        showLabelText.value = false;
      } else if (labelsNeededController.text.trim().isEmpty) {
        showLabelText.value = true;
      }
      checkLabelingBlockComplete();
    });
  }

  @override
  void onReady() {
    super.onReady();
    // Clear any pending callbacks to prevent disposed controller issues
    SubscriptionCallbackService().clearCallback();
  }

  void _initializeWithArguments() {
    // Get arguments passed from generate tech pack screen
    final arguments = Get.arguments as Map<String, dynamic>?;
    if (arguments != null) {
      selectedDesignImagePath.value = arguments['selectedDesignUrl'] ?? '';
      selectedDesignPrompt.value = arguments['designPrompt'] ?? '';
      designData = arguments['designData'] ?? {};

      // Check for edit mode
      final isEditMode = arguments['editMode'] == true;
      if (isEditMode) {
        _isEditMode.value = true;
        _editingTechPack = arguments['techPackModel'] as TechPackModel?;
        print('Tech Pack Details: Edit mode detected');
        _loadExistingTechPackData();
      }

      print('Tech Pack Details initialized with:');
      final imagePathPreview = selectedDesignImagePath.value.isNotEmpty
          ? selectedDesignImagePath.value.length > 50
                ? '${selectedDesignImagePath.value.substring(0, 50)}...'
                : selectedDesignImagePath.value
          : 'No image path';
      print('Design Image: $imagePathPreview');
      print('Design Prompt: ${selectedDesignPrompt.value}');
      print('Design Data: $designData');
      print('Edit Mode: $isEditMode');
    }
  }

  Future<void> _loadExistingTechPackData() async {
    if (_editingTechPack == null) return;

    try {
      print('Loading existing tech pack data for: ${_editingTechPack!.id}');

      // Get complete edit data from Firebase
      final editData = await _editDataService.getTechPackEditData(
        _editingTechPack!.id,
      );

      if (editData != null) {
        final techPackDetails =
            editData['techPackDetails'] as Map<String, dynamic>;
        if (techPackDetails.isNotEmpty) {
          final parsedDetails = _editDataService.parseTechPackDetailsForEdit(
            techPackDetails,
          );
          _populateTechPackFields(parsedDetails);

          // Show all blocks in edit mode
          _showAllBlocks();

          showAppSnackbar(
            _l10n.tpdEditMode,
            _l10n.tpdLoadingExistingTechPack,
            backgroundColor: Colors.black,
            colorText: Colors.white,
            snackPosition: SnackPosition.TOP,
            duration: const Duration(milliseconds: 1500),
          );
        }
      }
    } catch (e) {
      print('Error loading tech pack data: $e');
      showAppSnackbar(
        _l10n.tpdNotice,
        _l10n.tpdStartingWithEmptyForm,
        backgroundColor: Colors.black,
        snackPosition: SnackPosition.TOP,
        colorText: Colors.white,
        duration: const Duration(milliseconds: 1500),
      );
    }
  }

  void _populateTechPackFields(Map<String, dynamic> techPackDetails) {
    print('🔍 ===== POPULATING TECH PACK FIELDS =====');
    print('Full tech pack details structure:');
    print('  Materials: ${techPackDetails['materials']}');
    print('  Sizes: ${techPackDetails['sizes']}');
    print('  Labeling: ${techPackDetails['labeling']}');
    print('=========================================');

    // Materials & Fabrics
    final materials =
        techPackDetails['materials'] as Map<String, dynamic>? ?? {};
    fabricCompositionController.text = materials['fabricComposition'] ?? '';
    fabricWeightController.text = materials['fabricWeight'] ?? '';
    secondaryMaterialsController.text = materials['secondaryMaterials'] ?? '';
    fabricPropertiesController.text = materials['fabricProperties'] ?? '';

    // Sizes & Measurements
    final sizes = techPackDetails['sizes'] as Map<String, dynamic>? ?? {};
    // Load selected sizes from Firebase (stored as comma-separated string or list)
    final sizeRange = sizes['sizeRange'];
    if (sizeRange != null) {
      if (sizeRange is List) {
        selectedSizes.value = List<String>.from(sizeRange);
      } else if (sizeRange is String && sizeRange.isNotEmpty) {
        selectedSizes.value = sizeRange.split(',').map((s) => s.trim()).toList();
      }
    }
    measurementChartController.text = sizes['measurementChart'] ?? '';
    measurementImagePath.value = sizes['measurementImage'] ?? '';
    providingOwnChart.value = (sizes['providingOwnChart'] as bool?) ??
        (measurementImagePath.value.isNotEmpty || measurementChartController.text.isNotEmpty);

    print('📏 Measurement data from Firebase:');
    print(
      '   measurementImage field exists: ${sizes.containsKey('measurementImage')}',
    );
    print('   measurementImage value: ${sizes['measurementImage']}');

    // Technical Details
    final technical =
        techPackDetails['technical'] as Map<String, dynamic>? ?? {};
    accessoriesController.text = technical['accessories'] ?? '';
    stitchingController.text = technical['stitching'] ?? '';
    decorativeStitchingController.text = technical['decorativeStitching'] ?? '';

    // Labeling & Branding
    final labeling = techPackDetails['labeling'] as Map<String, dynamic>? ?? {};
    print('🏷️ Labeling data from Firebase:');
    print('   Raw labeling map: $labeling');
    print('   labelImage field exists: ${labeling.containsKey('labelImage')}');
    print('   labelImage value: ${labeling['labelImage']}');

    logoPlacementController.text = labeling['logoPlacement'] ?? '';
    labelsNeededController.text = labeling['labelsNeeded'] ?? '';
    labelImagePath.value = labeling['labelImage'] ?? '';
    qrCodeController.text = labeling['qrCode'] ?? '';

    print('🖼️ After loading - label image path: ${labelImagePath.value}');
    print('   Logo placement: ${logoPlacementController.text}');
    print('   Labels needed: ${labelsNeededController.text}');

    // Manufacturers
    final manufacturers =
        techPackDetails['manufacturers'] as Map<String, dynamic>? ?? {};
    manufacturerCountryController.text = manufacturers['country'] ?? '';
    selectedManufacturerCountry.value = manufacturers['country'] ?? '';

    update();
  }

  void _showAllBlocks() {
    // In edit mode, show all blocks
    showSizesBlock.value = true;
    showTechnicalBlock.value = true;
    showLabelingBlock.value = true;
    showManufacturersBlock.value = true;
  }

  String _creativeBriefFabricKey() {
    final raw = (designData['creativeBrief']?['fabrics'] ?? '').toString();
    final key = raw.contains(':') ? raw.split(':').last.trim().toLowerCase() : raw.toLowerCase().trim();
    return OpenAIService.fabricDefaults.containsKey(key) ? key : 'cotton';
  }

  void toggleIndustryStandardComposition(bool value) {
    useIndustryStandardComposition.value = value;
    if (value) {
      final defaults = OpenAIService.fabricDefaults[_creativeBriefFabricKey()]!;
      fabricCompositionController.text = defaults['composition']!;
      compositionError.value = '';
    } else {
      fabricCompositionController.clear();
    }
    checkMaterialsBlockComplete();
  }

  void toggleIndustryStandardGSM(bool value) {
    useIndustryStandardGSM.value = value;
    if (value) {
      final defaults = OpenAIService.fabricDefaults[_creativeBriefFabricKey()]!;
      fabricWeightController.text = defaults['gsm']!;
      weightError.value = '';
    } else {
      fabricWeightController.clear();
    }
    checkMaterialsBlockComplete();
  }

  String _creativeBriefGarmentTypeKey() {
    final raw = (designData['creativeBrief']?['garmentType'] ?? '').toString();
    return raw.contains(':') ? raw.split(':').last.trim().toLowerCase() : raw.toLowerCase().trim();
  }

  void toggleIndustryStandardProperties(bool value) {
    useIndustryStandardProperties.value = value;
    if (value) {
      fabricPropertiesController.text = OpenAIService.resolveByGarmentType(
        _creativeBriefGarmentTypeKey(),
        OpenAIService.technicalPropertiesDefaults,
        'Breathable, moisture-wicking',
      );
    } else {
      fabricPropertiesController.clear();
    }
    checkMaterialsBlockComplete();
  }

  void toggleIndustryStandardStitching(bool value) {
    useIndustryStandardStitching.value = value;
    if (value) {
      stitchingController.text = OpenAIService.resolveByGarmentType(
        _creativeBriefGarmentTypeKey(),
        OpenAIService.stitchTypeDefaults,
        'Overlock stitch (4-thread)',
      );
    } else {
      stitchingController.clear();
    }
    checkTechnicalBlockComplete();
  }

  void toggleIndustryStandardDecorativeStitching(bool value) {
    useIndustryStandardDecorativeStitching.value = value;
    if (value) {
      decorativeStitchingController.text = OpenAIService.resolveByGarmentType(
        _creativeBriefGarmentTypeKey(),
        OpenAIService.decorativeStitchingDefaults,
        'Single topstitch, 2 mm from seam',
      );
    } else {
      decorativeStitchingController.clear();
    }
    checkTechnicalBlockComplete();
  }

  void _validateComposition() {
    if (useIndustryStandardComposition.value) {
      compositionError.value = '';
      return;
    }
    final value = fabricCompositionController.text.trim();
    if (value.isEmpty) {
      compositionError.value = 'Fabric composition is required';
      return;
    }
    if (value.contains('%')) {
      final matches = RegExp(r'(\d+(?:\.\d+)?)\s*%').allMatches(value);
      final total = matches.fold<double>(0, (s, m) => s + double.parse(m.group(1)!));
      if ((total - 100).abs() > 2) {
        compositionError.value = 'Percentages must add up to 100%';
        return;
      }
    } else {
      final lv = value.toLowerCase();
      final known = OpenAIService.fabricDefaults.keys.any((k) => lv.contains(k) || k.contains(lv));
      if (!known) {
        compositionError.value = 'Enter a valid fabric or use % format (e.g. 80% Cotton 20% Polyester)';
        return;
      }
    }
    compositionError.value = '';
  }

  void _validateWeight() {
    if (useIndustryStandardGSM.value) {
      weightError.value = '';
      return;
    }
    final value = fabricWeightController.text.trim();
    if (value.isEmpty) {
      weightError.value = 'Fabric weight is required';
      return;
    }
    final num = double.tryParse(value.replaceAll(RegExp(r'[^0-9.]'), ''));
    if (num == null) {
      weightError.value = 'Enter a valid number (e.g. 180 or 180 GSM)';
      return;
    }
    if (num < 30 || num > 1000) {
      weightError.value = 'GSM must be between 30 and 1000';
      return;
    }
    weightError.value = '';
  }

  void checkMaterialsBlockComplete() {
    _validateComposition();
    _validateWeight();
    final compositionValid = compositionError.value.isEmpty &&
        fabricCompositionController.text.isNotEmpty;
    final weightValid = weightError.value.isEmpty &&
        fabricWeightController.text.isNotEmpty;
    if (compositionValid &&
        weightValid &&
        secondaryMaterialsController.text.isNotEmpty &&
        fabricPropertiesController.text.isNotEmpty) {
      showSizesBlock.value = true;
    }
  }

  void checkSizesBlockComplete() {
    // Sizes block is complete once at least one size is selected.
    // Chart is optional — AI auto-generates if not provided.
    if (selectedSizes.isNotEmpty) {
      showTechnicalBlock.value = true;
    }
  }

  void checkTechnicalBlockComplete() {
    // Only require essential fields - decorative stitching is optional
    if (accessoriesController.text.isNotEmpty &&
        stitchingController.text.isNotEmpty) {
      showLabelingBlock.value = true;
    }
  }

  void checkLabelingBlockComplete() {
    // Check if logo placement is filled AND either label text OR image is provided
    bool hasLabelInput =
        labelsNeededController.text.isNotEmpty ||
        labelImagePath.value.isNotEmpty;

    if (logoPlacementController.text.isNotEmpty && hasLabelInput) {
      showManufacturersBlock.value = true;
    }
  }

  void checkManufacturersBlockComplete() {
    // Optional field - no further block needed
    // User can proceed to generate even if this is empty
  }

  /// Set the selected manufacturer country from the country picker
  void setManufacturerCountry(String country) {
    selectedManufacturerCountry.value = country;
    manufacturerCountryController.text = country;
  }

  /// Toggle size selection (add or remove from selected sizes)
  void toggleSizeSelection(String size) {
    if (selectedSizes.contains(size)) {
      selectedSizes.remove(size);
    } else {
      selectedSizes.add(size);
    }
    checkSizesBlockComplete();
  }

  /// Check if a size is currently selected
  bool isSizeSelected(String size) {
    return selectedSizes.contains(size);
  }

  Map<String, String> _collectReferenceImages() {
    Map<String, String> images = {};

    // Add selected design image (main reference)
    if (selectedDesignImagePath.value.isNotEmpty) {
      images['selectedDesign'] = selectedDesignImagePath.value;
      print(
        'Added selected design image: ${selectedDesignImagePath.value.substring(0, 50)}...',
      );
    }

    // Add measurement chart image if uploaded
    if (measurementImagePath.value.isNotEmpty) {
      images['measurementChart'] = measurementImagePath.value;
      print(
        'Added measurement chart image: ${measurementImagePath.value.substring(0, 50)}...',
      );
    }

    // Add label reference image if uploaded
    if (labelImagePath.value.isNotEmpty) {
      images['labelReference'] = labelImagePath.value;
      print(
        'Added label reference image: ${labelImagePath.value.substring(0, 50)}...',
      );
    }

    print('Total reference images collected: ${images.length}');
    return images;
  }

  Future<void> generateTechPackImages(String generationId) async {
    // Subscription check is now handled by checkSubscriptionAndGenerate method
    // This method only handles the actual generation
    // Generation ID is passed to track and validate this specific generation

    try {
      print('=== STARTING DETAILED TECH PACK GENERATION ===');
      print('🆔 Generation ID: $generationId');

      // GENERATION ID CHECK: Verify this generation is still active
      if (generationId != _activeGenerationId) {
        print('⚠️ Generation outdated or cancelled (ID mismatch), aborting');
        print('   Expected: $_activeGenerationId, Got: $generationId');
        return;
      }

      isGeneratingTechPack.value = true;
      generatedTechPackImages.clear();
      // Progress and step are already set to 0.1/1 before navigation — do not reset here
      generationStep.value = 1;

      // Check if cancelled before starting expensive operations
      if (generationCancelled.value) {
        print('⚠️ Generation cancelled before starting');
        return;
      }

      final techPackDetails = _collectTechPackDetails();
      final referenceImages = _collectReferenceImages();

      print('Tech Pack Details: $techPackDetails');
      print('Design Data: $designData');
      print('Reference Images: $referenceImages');

      // Try different prompt approaches in order of preference
      Map<String, String> prompts;
      String approach = '';

      // Extract colors from the garment image via gpt-4o (non-blocking — null on failure)
      String? extractedColors;
      if (selectedDesignImagePath.value.isNotEmpty) {
        extractedColors = await OpenAIService.extractColorsFromGarmentImage(
          selectedDesignImagePath.value,
        );
      }

      try {
        // First attempt: Full detailed prompts with three views
        approach = 'Detailed Three Views';
        prompts = await OpenAIService.generateTechPackPrompts(
          creativeBrief: designData['creativeBrief'] ?? {},
          refinedConcept: designData['refinedConcept'] ?? {},
          finalDetails: designData['finalDetails'] ?? {},
          techPackDetails: techPackDetails,
          selectedDesignPrompt: selectedDesignPrompt.value,
          measurementChartImagePath: measurementImagePath.value.isNotEmpty
              ? measurementImagePath.value
              : null,
          colorPalette: extractedColors,
        );
      } catch (e) {
        try {
          // Second attempt: Advanced detailed with explicit positioning
          approach = 'Advanced Detailed Layout';
          print('Trying advanced detailed prompts...');
          prompts = OpenAIService.getAdvancedDetailedPrompts(
            techPackDetails,
            designData['creativeBrief'] ?? {},
          );
        } catch (e2) {
          try {
            // Third attempt: Detailed single view
            approach = 'Detailed Single View';
            print('Trying detailed single view prompts...');
            prompts = OpenAIService.getDetailedSingleViewPrompts(
              techPackDetails,
              designData['creativeBrief'] ?? {},
            );
          } catch (e3) {
            // Final fallback: Simplified but detailed
            approach = 'Simplified Detailed';
            print('Using simplified detailed prompts...');
            prompts = OpenAIService.getSimplifiedDetailedPrompts(
              techPackDetails,
              designData['creativeBrief'] ?? {},
            );
          }
        }
      }

      print('Using approach: $approach');
      print('Manufacturing Prompt: ${prompts['manufacturing_prompt']}');
      print('Technical Prompt: ${prompts['technical_flat_prompt']}');

      generationStep.value = 2;
      generationProgress.value = 0.5;

      // Generate manufacturing layout image with reference images
      print(
        'Generating manufacturing layout image with ${referenceImages.length} reference images...',
      );
      List<String> manufacturingImages = [];
      try {
        manufacturingImages = await OpenAIService.generateTechPackImages(
          prompt: prompts['manufacturing_prompt'] ?? '',
          referenceImages: referenceImages,
          numberOfImages: 1,
          size: '1024x1024',
        );
        print('✅ Manufacturing image generated successfully');
        print(
          '   Base64 preview: ${manufacturingImages.isNotEmpty ? manufacturingImages[0].substring(0, 50) : "EMPTY"}...',
        );
      } catch (e) {
        print('❌ Manufacturing image generation failed: $e');
        throw Exception('Failed to generate manufacturing image');
      }

      // GENERATION ID CHECK: Verify this generation is still active after manufacturing image
      if (generationId != _activeGenerationId) {
        print('⚠️ Generation cancelled after manufacturing image (ID mismatch)');
        print('   Discarding manufacturing image from outdated generation');
        return;
      }

      // Check if cancelled after first image generation
      if (generationCancelled.value) {
        print('⚠️ Generation cancelled after manufacturing image');
        return;
      }

      generationStep.value = 3;
      generationProgress.value = 0.75;

      // Generate technical flat drawing with detailed approach and reference images
      print(
        'Generating detailed technical flat drawing with ${referenceImages.length} reference images...',
      );
      List<String> technicalImages = [];
      try {
        technicalImages = await OpenAIService.generateTechPackImages(
          prompt: prompts['technical_flat_prompt'] ?? '',
          referenceImages: referenceImages,
          numberOfImages: 1,
          size: '1024x1024', // Try 1024x1792 for vertical if 1024x1024 cuts off
        );
        print('✅ Technical flat drawing generated successfully');
        print(
          '   Base64 preview: ${technicalImages.isNotEmpty ? technicalImages[0].substring(0, 50) : "EMPTY"}...',
        );
      } catch (e) {
        print('❌ Technical image generation failed, trying fallback: $e');

        // Fallback with even simpler prompt
        final fallbackPrompt =
            'Technical flat drawing of garment, front view, black lines on white background. Include measurement labels A, B, C, D and construction details. Complete drawing centered with margins.';
        technicalImages = await OpenAIService.generateDesignImages(
          prompt: fallbackPrompt,
          numberOfImages: 1,
          size: '1024x1024',
        );
        print(
          '   Fallback Base64 preview: ${technicalImages.isNotEmpty ? technicalImages[0].substring(0, 50) : "EMPTY"}...',
        );
      }

      // CRITICAL CHECK: Verify images are different before adding to list
      if (manufacturingImages.isNotEmpty && technicalImages.isNotEmpty) {
        final areIdentical = manufacturingImages[0] == technicalImages[0];
        print('⚠️ COMPARING GENERATED IMAGES:');
        print(
          '   Manufacturing: ${manufacturingImages[0].substring(0, 50)}...',
        );
        print('   Technical: ${technicalImages[0].substring(0, 50)}...');
        print('   Are identical: $areIdentical');

        if (areIdentical) {
          print(
            '❌ ERROR: AI generated IDENTICAL images for manufacturing and technical!',
          );
          print(
            'This is likely an OpenAI API issue or both prompts are too similar.',
          );
        }
      }

      // FINAL GENERATION ID CHECK: Verify before adding images to list
      if (generationId != _activeGenerationId) {
        print('⚠️ Generation cancelled before adding images (ID mismatch)');
        print('   Discarding all images from outdated generation');
        return;
      }

      generationStep.value = 4;
      generationProgress.value = 1.0;
      await Future.delayed(const Duration(milliseconds: 600));

      // Add images to the list
      generatedTechPackImages.addAll(manufacturingImages);
      generatedTechPackImages.addAll(technicalImages);

      print('📦 Final image list:');
      for (int i = 0; i < generatedTechPackImages.length; i++) {
        print(
          '   Image[$i]: ${generatedTechPackImages[i].substring(0, 50)}...',
        );
      }

      print('=== DETAILED TECH PACK GENERATION COMPLETED ===');
      print(
        'Generated ${generatedTechPackImages.length} tech pack images using: $approach',
      );

      // GENERATION ID CHECK: Only show success message if this generation is still active
      if (generationId != _activeGenerationId) {
        print('⚠️ Generation ID mismatch - skipping success notification');
        print('   Expected: $_activeGenerationId, Got: $generationId');
        return; // Don't show success message if this generation was cancelled
      }

      // Check if generation was cancelled during execution
      if (generationCancelled.value) {
        print('⚠️ Generation was cancelled - skipping success notification');
        return; // Don't show success message if cancelled
      }

      // Validate and provide feedback ONLY if not cancelled and generation is still active
      if (generatedTechPackImages.length >= 2) {
        print(
          '✅ Both manufacturing and detailed technical images generated successfully',
        );
        showAppSnackbar(
          _l10n.tpdSuccess,
          _l10n.tpdTechPackImagesGenerated,
          snackPosition: SnackPosition.TOP,
          backgroundColor: Colors.black,
          colorText: Colors.white,
          duration: const Duration(milliseconds: 1500),
        );
      } else {
        print(
          '⚠️ Warning: Only ${generatedTechPackImages.length} images generated',
        );
        showAppSnackbar(
          _l10n.tpdPartialSuccess,
          _l10n.tpdSomeTechPackImagesGenerated,
          snackPosition: SnackPosition.TOP,
          backgroundColor: Colors.black,
          colorText: Colors.white,
        );
      }
    } catch (e) {
      print('=== TECH PACK GENERATION ERROR ===');
      print('Error: $e');

      // Only show error snackbar if this generation is still active
      if (generationId == _activeGenerationId) {
        showAppSnackbar(
          _l10n.tpdError,
          _l10n.tpdFailedToGenerateTechPack(e.toString()),
          snackPosition: SnackPosition.TOP,
          backgroundColor: Colors.red,
          colorText: Colors.white,
        );
      } else {
        print('⚠️ Generation ID mismatch - skipping error notification');
        print('   Expected: $_activeGenerationId, Got: $generationId');
      }
    } finally {
      // CRITICAL: Only reset flags if this generation is still the active one
      // This prevents cancelled generations from interfering with new generations
      if (generationId == _activeGenerationId) {
        isGeneratingTechPack.value = false;
        _isGenerationInFlight = false;
        print('🏁 Generation $generationId completed, flags reset');
      } else {
        print('⚠️ Generation $generationId outdated, skipping flag reset');
        print('   Active generation is: $_activeGenerationId');
      }
    }
  }

  // Add this function to test different technical drawing approaches
  void testTechnicalDrawingPrompts() {
    final techPackDetails = _collectTechPackDetails();
    final creativeBrief = designData['creativeBrief'] ?? {};

    print('=== TESTING TECHNICAL DRAWING PROMPTS ===');

    // Test detailed three views
    final detailed = OpenAIService.getAdvancedDetailedPrompts(
      techPackDetails,
      creativeBrief,
    );
    print('Advanced Detailed: ${detailed['technical_flat_prompt']}');

    // Test single detailed view
    final singleView = OpenAIService.getDetailedSingleViewPrompts(
      techPackDetails,
      creativeBrief,
    );
    print('Single Detailed: ${singleView['technical_flat_prompt']}');

    // Test simplified detailed
    final simplified = OpenAIService.getSimplifiedDetailedPrompts(
      techPackDetails,
      creativeBrief,
    );
    print('Simplified Detailed: ${simplified['technical_flat_prompt']}');
  }

  // Gallery functionality for measurements
  Future<void> openCameraForMeasurement() async {
    try {
      final XFile? image = await _picker.pickImage(
        source: ImageSource.gallery,
        imageQuality: 80,
      );

      if (image != null) {
        measurementImagePath.value = image.path;
        checkSizesBlockComplete();
      }
    } catch (e) {
      showAppSnackbar(
        _l10n.tpdError,
        _l10n.tpdFailedToPickImage(e.toString()),
        snackPosition: SnackPosition.TOP,
        backgroundColor: Colors.red,
        colorText: Colors.white,
      );
    }
  }

  // Optional: Method to pick from gallery as alternative
  Future<void> pickImageFromGallery() async {
    try {
      final XFile? image = await _picker.pickImage(
        source: ImageSource.gallery,
        imageQuality: 80,
      );

      if (image != null) {
        measurementImagePath.value = image.path;
        checkSizesBlockComplete();
      }
    } catch (e) {
      showAppSnackbar(
        _l10n.tpdError,
        _l10n.tpdFailedToPickImage(e.toString()),
        snackPosition: SnackPosition.TOP,
        backgroundColor: Colors.red,
        colorText: Colors.white,
      );
    }
  }

  // Gallery functionality for labels
  Future<void> openCameraForLabels() async {
    try {
      final XFile? image = await _picker.pickImage(
        source: ImageSource.gallery,
        imageQuality: 80,
      );

      if (image != null) {
        labelImagePath.value = image.path;
        checkLabelingBlockComplete();
      }
    } catch (e) {
      showAppSnackbar(
        _l10n.tpdError,
        _l10n.tpdFailedToPickImage(e.toString()),
        snackPosition: SnackPosition.TOP,
        backgroundColor: Colors.red,
        colorText: Colors.white,
      );
    }
  }

  // Clear label image functionality
  void clearLabelImage() {
    labelImagePath.value = '';
    // Reset the label text visibility when image is removed
    if (labelsNeededController.text.trim().isEmpty) {
      showLabelText.value = true;
    }
    // Reset the image upload visibility when image is removed
    if (labelsNeededController.text.trim().isEmpty) {
      showLabelImage.value = true;
    } else {
      showLabelImage.value = false;
    }
    // Re-check if labeling block is still complete
    checkLabelingBlockComplete();
  }

  void clearMeasurementImage() {
    measurementImagePath.value = '';
    checkSizesBlockComplete();
  }

  Future<void> checkSubscriptionAndGenerate() async {
    isStartingGeneration.value = true;

    // INTERNET CHECK: Verify internet connection before generation (mobile only)
    final hasInternet = await InternetConnectivityChecker.hasInternetConnection();
    if (!hasInternet) {
      showAppSnackbar(
        _l10n.noInternetConnection,
        _l10n.noInternetConnectionMessage,
        backgroundColor: Colors.red,
        colorText: Colors.white,
        snackPosition: SnackPosition.TOP,
        duration: const Duration(seconds: 3),
        icon: Icon(
          Icons.wifi_off_rounded,
          color: Colors.white,
          size: 28.sp,
        ),
      );
      isStartingGeneration.value = false;
      return;
    }

    // IN-FLIGHT GUARD: Prevent multiple concurrent generations
    if (_isGenerationInFlight) {
      showAppSnackbar(
        _l10n.tpdProcessing,
        _l10n.tprGenerationInProgress,
        backgroundColor: Colors.orange,
        colorText: Colors.white,
        snackPosition: SnackPosition.TOP,
        duration: const Duration(milliseconds: 1500),
      );
      isStartingGeneration.value = false;
      return;
    }

    // Check subscription / quota before generating
    final subscription = await _subscriptionService.getCurrentUserSubscription();

    // FREE users — use free add-on techpacks
    if (subscription?.subscriptionPlan == 'FREE') {
      if (subscription!.hasFreeExtraTechpacks) {
        // Consume one free add-on techpack
        await _subscriptionService.incrementFreeExtraTechpackUsage();
      } else {
        _showUpgradeDialog();
        isStartingGeneration.value = false;
        return;
      }
    } else {
      // Paid users — standard quota check
      bool canGenerate = await _subscriptionService
          .canUsePremiumFeatureWithReset('techpack');
      if (!canGenerate) {
        _showUpgradeDialog();
        isStartingGeneration.value = false;
        return;
      }
      // CRITICAL: Increment counter IMMEDIATELY before generation starts
      await _subscriptionService.incrementTechpackUsage();
    }

    // Set in-flight flag to prevent concurrent generations
    _isGenerationInFlight = true;

    // Generate unique ID for this generation
    _activeGenerationId = DateTime.now().millisecondsSinceEpoch.toString();
    final currentGenerationId = _activeGenerationId!;

    // Reset cancellation flag
    generationCancelled.value = false;

    // Set initial progress before navigation so screen shows 10% immediately
    generationProgress.value = 0.1;
    generationStep.value = 1;

    // Start generation (don't await - runs in background)
    // Pass generation ID to track this specific generation
    generateTechPackImages(currentGenerationId);

    // Reset loading state before navigating so it's never stuck if user returns via push
    isStartingGeneration.value = false;
    Get.toNamed('/tech_pack_ready_screen');
  }

  void _showUpgradeDialog() async {
    // Get current subscription to show in dialog
    final subscription = await _subscriptionService
        .getCurrentUserSubscription();
    String currentPlan = subscription?.subscriptionPlan ?? 'FREE';

    // Show different dialogs based on plan
    if (currentPlan == 'FREE') {
      _showFreeUpgradeDialog(currentPlan);
    } else if (currentPlan == 'STARTER' || currentPlan == 'STARTER_YEARLY') {
      _showStarterLimitDialog(subscription);
    } else if (currentPlan == 'PRO' || currentPlan == 'PRO_YEARLY') {
      _showProLimitDialog(subscription);
    } else if (currentPlan == 'STUDIO' || currentPlan == 'STUDIO_YEARLY') {
      _showStudioLimitDialog(subscription);
    }
  }

  void _showFreeUpgradeDialog(String currentPlan) {
    Get.dialog(
      TechpackLimitDialog(
        title: _l10n.tpUpgradeRequired,
        message: _l10n.tpFreeUserTechpackMessage,
        isPaidUser: false,
        techpackPriceString: _techpackPriceString,
        onGetExtraTechpacks: () async {
          await _purchaseFreeExtraTechpacks(1, 5.99);
        },
        onMaybeLater: () => Navigator.of(Get.overlayContext!).pop(),
      ),
      barrierDismissible: false,
    );
  }

  Future<void> _purchaseFreeExtraTechpacks(int count, double price) async {
    try {
      bool success = await _revenueCatService.purchaseFreeExtraTechpacks(
        count,
        price,
      );
      if (success) {
        _isGenerationInFlight = true;
        _activeGenerationId = DateTime.now().millisecondsSinceEpoch.toString();
        final currentGenerationId = _activeGenerationId!;
        await _subscriptionService.incrementFreeExtraTechpackUsage();
        generationCancelled.value = false;
        generationProgress.value = 0.1;
        generationStep.value = 1;
        generateTechPackImages(currentGenerationId);
        Navigator.of(Get.overlayContext!).pop();
        Get.toNamed('/tech_pack_ready_screen');
      } else {
        showAppSnackbar(
          _l10n.tpdPurchaseFailed,
          _l10n.tpdUnableToProcessPurchase,
          backgroundColor: Colors.red,
          colorText: Colors.white,
          snackPosition: SnackPosition.TOP,
        );
      }
    } catch (e) {
      showAppSnackbar(
        _l10n.tpdError,
        _l10n.tpdPurchaseError(e.toString()),
        backgroundColor: Colors.red,
        colorText: Colors.white,
        snackPosition: SnackPosition.TOP,
      );
    }
  }

  void _showStarterLimitDialog(UserSubscription? subscription) {
    final plan = subscription?.subscriptionPlan ?? 'STARTER';
    final isYearly = plan.contains('YEARLY');

    Get.dialog(
      TechpackLimitDialog(
        title: _l10n.tpProLimitDialogTitle,
        message: isYearly
            ? _l10n.tpStarterYearlyLimitReached
            : _l10n.tpStarterMonthlyLimitReached,
        isPaidUser: true,
        techpackPriceString: _techpackPriceString,
        onGetExtraTechpacks: () async {
          await _purchaseExtraTechpacks(1, 5.99);
        },
        onMaybeLater: () => Navigator.of(Get.overlayContext!).pop(),
      ),
      barrierDismissible: false,
    );
  }

  void _showProLimitDialog(UserSubscription? subscription) {
    Get.dialog(
      TechpackLimitDialog(
        title: _l10n.tpProLimitDialogTitle,
        message: _l10n.tpProMonthlyLimitReached,
        isPaidUser: true,
        techpackPriceString: _techpackPriceString,
        onGetExtraTechpacks: () async {
          await _purchaseExtraTechpacks(1, 5.99);
        },
        onMaybeLater: () => Navigator.of(Get.overlayContext!).pop(),
      ),
      barrierDismissible: false,
    );
  }

  void _showStudioLimitDialog(UserSubscription? subscription) {
    // Studio users share the same generic monthly-limit copy for now.
    Get.dialog(
      TechpackLimitDialog(
        title: _l10n.tpProLimitDialogTitle,
        message: _l10n.tpProMonthlyLimitReached,
        isPaidUser: true,
        techpackPriceString: _techpackPriceString,
        onGetExtraTechpacks: () async {
          await _purchaseExtraTechpacks(1, 5.99);
        },
        onMaybeLater: () => Navigator.of(Get.overlayContext!).pop(),
      ),
      barrierDismissible: false,
    );
  }

  Future<void> _purchaseExtraTechpacks(int count, double price) async {
    try {
      // Use RevenueCat for add-on purchases (replaced Stripe)
      bool success = await _revenueCatService.purchaseExtraTechpacks(
        count,
        price,
      );

      if (success) {
        // After successful purchase, follow the same flow as manual generate
        // Set in-flight flag to prevent concurrent generations
        _isGenerationInFlight = true;

        // Generate unique ID for this generation
        _activeGenerationId = DateTime.now().millisecondsSinceEpoch.toString();
        final currentGenerationId = _activeGenerationId!;
        print('🆔 New generation started (add-on purchase) with ID: $currentGenerationId');

        // CRITICAL: Increment counter IMMEDIATELY before generation starts
        await _subscriptionService.incrementTechpackUsage();
        print('✅ Tech pack usage incremented BEFORE generation (after add-on purchase)');

        generationCancelled.value = false; // Reset cancellation flag
        generationProgress.value = 0.1;
        generationStep.value = 1;
        generateTechPackImages(currentGenerationId); // Start generation with ID
        Navigator.of(Get.overlayContext!).pop(); // Close the dialog
        Get.toNamed('/tech_pack_ready_screen'); // Navigate
      } else {
        showAppSnackbar(
          _l10n.tpdPurchaseFailed,
          _l10n.tpdUnableToProcessPurchase,
          backgroundColor: Colors.red,
          colorText: Colors.white,
          snackPosition: SnackPosition.TOP,
        );
      }
    } catch (e) {
      showAppSnackbar(
        _l10n.tpdError,
        _l10n.tpdPurchaseError(e.toString()),
        backgroundColor: Colors.red,
        colorText: Colors.white,
        snackPosition: SnackPosition.TOP,
      );
    }
  }

  // Cancel ongoing generation
  void cancelGeneration() {
    if (isGeneratingTechPack.value) {
      // Invalidate current generation ID to discard any in-flight results
      _activeGenerationId = null;
      print('🚫 Generation ID invalidated: $_activeGenerationId');

      // Reset flags and clear images
      generationCancelled.value = true;
      isGeneratingTechPack.value = false;
      _isGenerationInFlight = false;
      generatedTechPackImages.clear();
      print('🚫 Tech pack generation cancelled by user');
    }
  }

  // Check if user wants to navigate back during generation
  // shouldShowDialog: if false, allows navigation without showing confirmation dialog
  Future<bool> handleBackNavigation({bool shouldShowDialog = true}) async {
    if (!isGeneratingTechPack.value) {
      return true; // Allow navigation if not generating
    }

    // If shouldShowDialog is false, allow navigation without confirmation
    if (!shouldShowDialog) {
      return true;
    }

    // Show warning dialog with app design
    final l10n = AppLocalizations.of(Get.context!)!;
    final context = Get.context!;

    final result = await showDialog<bool?>(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext dialogContext) => Dialog(
        backgroundColor: Colors.white,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16.r),
        ),
        child: Padding(
          padding: EdgeInsets.all(24.w),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Warning icon and title
              Row(
                children: [
                  Container(
                    width: 40.w,
                    height: 40.h,
                    decoration: BoxDecoration(
                      color: const Color(0xFFFEF3E7),
                      borderRadius: BorderRadius.circular(8.r),
                    ),
                    child: Icon(
                      Icons.warning_amber_rounded,
                      color: const Color(0xFFFF9800),
                      size: 24.sp,
                    ),
                  ),
                  SizedBox(width: 12.w),
                  Expanded(
                    child: Text(
                      l10n.tprWarningTitle,
                      style: TextStyle(
                        fontSize: 20.sp,
                        fontWeight: FontWeight.w600,
                        color: const Color(0xFF1A1A1A),
                      ),
                    ),
                  ),
                ],
              ),
              SizedBox(height: 20.h),

              // Warning message
              Text(
                l10n.tprNavigationWarningMessage,
                style: TextStyle(
                  fontSize: 14.sp,
                  color: const Color(0xFF666666),
                  height: 1.5,
                ),
              ),
              SizedBox(height: 24.h),

              // Action buttons
              Row(
                children: [
                  Expanded(
                    child: OutlinedButton(
                      onPressed: () => Navigator.of(dialogContext).pop(false),
                      style: OutlinedButton.styleFrom(
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12.r),
                        ),
                        side: const BorderSide(color: Color(0xFF1A1A1A)),
                        padding: EdgeInsets.symmetric(vertical: 14.h),
                      ),
                      child: Text(
                        l10n.tprStayHere,
                        style: TextStyle(
                          fontSize: 16.sp,
                          fontWeight: FontWeight.w600,
                          color: const Color(0xFF1A1A1A),
                        ),
                      ),
                    ),
                  ),
                  SizedBox(width: 12.w),
                  Expanded(
                    child: ElevatedButton(
                      onPressed: () => Navigator.of(dialogContext).pop(true),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFFE53935),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12.r),
                        ),
                        padding: EdgeInsets.symmetric(vertical: 14.h),
                        elevation: 0,
                      ),
                      child: Text(
                        l10n.tprGoBack,
                        style: TextStyle(
                          fontSize: 16.sp,
                          fontWeight: FontWeight.w600,
                          color: Colors.white,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );

    if (result == true) {
      // User confirmed - cancel generation
      cancelGeneration();
      return true;
    }

    return false; // User chose to stay
  }

  // Collect all current tech pack details from form inputs
  Map<String, dynamic> _collectTechPackDetails() {
    return {
      'materials': {
        'fabricComposition': fabricCompositionController.text,
        'fabricWeight': fabricWeightController.text,
        'secondaryMaterials': secondaryMaterialsController.text,
        'fabricProperties': fabricPropertiesController.text,
        'isIndustryStandardComposition': useIndustryStandardComposition.value,
        'isIndustryStandardGSM': useIndustryStandardGSM.value,
        'isIndustryStandardProperties': useIndustryStandardProperties.value,
      },
      'sizes': {
        'sizeRange': selectedSizes.join(', '),
        'measurementChart': measurementChartController.text,
        'measurementImage': measurementImagePath.value,
        'providingOwnChart': providingOwnChart.value,
      },
      'technical': {
        'accessories': accessoriesController.text,
        'stitching': stitchingController.text,
        'decorativeStitching': decorativeStitchingController.text,
        'isIndustryStandardStitching': useIndustryStandardStitching.value,
        'isIndustryStandardDecorativeStitching': useIndustryStandardDecorativeStitching.value,
      },
      'labeling': {
        'logoPlacement': logoPlacementController.text,
        'labelsNeeded': labelsNeededController.text,
        'labelImage': labelImagePath.value,
        'qrCode': qrCodeController.text,
      },
      'manufacturers': {'country': manufacturerCountryController.text},
    };
  }

  @override
  void onClose() {
    fabricCompositionController.dispose();
    fabricWeightController.dispose();
    secondaryMaterialsController.dispose();
    fabricPropertiesController.dispose();
    // selectedSizes is RxList, no need to dispose
    measurementChartController.dispose();
    accessoriesController.dispose();
    stitchingController.dispose();
    decorativeStitchingController.dispose();
    logoPlacementController.dispose();
    labelsNeededController.dispose();
    qrCodeController.dispose();
    manufacturerCountryController.dispose();
    super.onClose();
  }
}
