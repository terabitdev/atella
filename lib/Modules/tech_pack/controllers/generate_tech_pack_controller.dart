import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:get/get.dart';
import 'package:flutter/material.dart';
import 'package:atella/Data/api/openai_service.dart';
import 'package:atella/services/firebase/techpack/tech_pack_service.dart';
import 'package:atella/services/PaymentService/design_credit_service.dart';
import 'package:atella/Data/Models/tech_pack_model.dart';
import 'package:atella/Data/Models/user_subscription.dart';
import 'package:atella/services/designservices/design_data_service.dart';
import 'package:atella/services/designservices/designs_service.dart';
import 'package:atella/services/firebase/edit/edit_data_service.dart';
import 'package:atella/services/firebase/collections/collections_service.dart';
import 'package:atella/services/PaymentService/stripe_subscription_service.dart';
import 'package:atella/services/PaymentService/revenuecat_service.dart';
import 'package:atella/services/PaymentService/subscription_callback_service.dart';
import 'package:atella/services/analytics/posthog_analytics_service.dart';
import 'package:atella/services/analytics/appsflyer_analytics_service.dart';
import 'package:atella/Modules/final_details/Views/Widgets/usage_warning_dialog.dart';
import 'package:atella/Modules/tech_pack/Views/Widgets/techpack_limit_dialog.dart';
import 'package:atella/l10n/generated/app_localizations.dart';

import 'package:atella/core/utils/app_snackbar.dart';
class TechPackController extends GetxController {
  final DesignDataService _dataService = DesignDataService.instance;
  final DesignsService _designsService = DesignsService();
  final EditDataService _editDataService = EditDataService();
  final StripeSubscriptionService _subscriptionService =
      StripeSubscriptionService();
  final RevenueCatService _revenueCatService = RevenueCatService();
  final CollectionsService _collectionsService = CollectionsService();

  // Live localized price string for the techpack add-on (iOS only).
  // Null on Android or if the RevenueCat fetch failed — dialogs fall back to localisation.
  String? _techpackPriceString;

  // Helper to get localization
  AppLocalizations get _l10n => AppLocalizations.of(Get.context!)!;

  // Edit mode tracking
  final RxBool _isEditMode = false.obs;
  bool get isEditMode => _isEditMode.value;
  TechPackModel? _editingTechPack;

  var isLoading = false.obs;
  var isSaving = false.obs; // Separate loading state for saving to Firebase
  var isInitialized = false.obs;
  // Stores generated images as base64 strings
  var generatedImages = <String>[].obs;
  var currentPrompt = ''.obs;
  var errorMessage = ''.obs;
  var hasError = false.obs;
  var selectedDesignIndex = (-1).obs; // Track selected design index

  // Progress tracking (step: 0=idle, 1=generating prompt, 2=generating images)
  var generationProgress = 0.0.obs;
  var generationStep = 0.obs;

  // Design save completion tracking
  final RxBool isDesignSaveComplete = false.obs;
  final RxString savedDesignUrl = ''.obs;
  final RxString designSaveError = ''.obs;

  // Save Design dialog state (name + collection), mirrors TechPackReadyController
  final TextEditingController projectNameController = TextEditingController();
  RxString selectedCollection = 'SUMMER COLLECTION'.obs;
  RxList<String> collections = <String>['SUMMER COLLECTION', 'WINTER COLLECTION'].obs;

  @override
  void onInit() {
    super.onInit();
    _checkForEditMode();
    _initializeApiKey();
    _fetchAddonPrices();
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

      if (collections.contains(upperCaseName)) {
        showAppSnackbar(
          _l10n.tprCollectionExists,
          _l10n.tprCollectionAlreadyExists,
          backgroundColor: Colors.black,
          colorText: Colors.white,
          snackPosition: SnackPosition.TOP,
          duration: const Duration(milliseconds: 1500),
        );
        return;
      }

      await _collectionsService.addCollection(upperCaseName);

      collections.add(upperCaseName);
      selectedCollection.value = upperCaseName;
    } catch (e) {
      print('Error adding collection: $e');
      showAppSnackbar(
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

  Future<void> _fetchAddonPrices() async {
    try {
      final prices = await _revenueCatService.fetchAddonPriceStrings();
      _techpackPriceString = prices.techpackPrice;
    } catch (e) {
      // _techpackPriceString stays null — dialogs fall back to localisation strings
    }
  }

  @override
  void onReady() {
    super.onReady();
    // Execute any pending subscription callbacks when screen is ready
    // Check if controllers are still valid before executing
    Future.delayed(Duration(milliseconds: 500), () {
      if (!Get.isRegistered<TechPackController>()) {
        print('TechPackController not registered, clearing callbacks');
        SubscriptionCallbackService().clearCallback();
        return;
      }

      SubscriptionCallbackService().executeSubscriptionSuccessCallback();
    });
  }

  void startLoadingSimulation() {
    isLoading.value = true;
    // Your actual image generation logic here
  }

  void onImagesGenerated(List<String> images) {
    generatedImages.assignAll(images);
    isLoading.value = false;
    hasError.value = false;
  }

  void _checkForEditMode() {
    final arguments = Get.arguments;
    print('TechPack Controller - Arguments received: $arguments');

    if (arguments != null && arguments is Map<String, dynamic>) {
      final isEditMode = arguments['editMode'] == true;
      final forceRegenerate = arguments['forceRegenerate'] == true;
      print('Edit mode detected: $isEditMode');
      print('Force regenerate: $forceRegenerate');

      if (isEditMode) {
        _isEditMode.value = true;
        _editingTechPack = arguments['techPackModel'] as TechPackModel?;
        print('Editing tech pack: ${_editingTechPack?.projectName}');
      }

      // Clear existing images if force regenerate is requested
      if (forceRegenerate) {
        generatedImages.clear();
        print('Cleared existing images for fresh generation');
      }
    }
  }

  Future<void> _initializeApiKey() async {
    // Set the API key
    await OpenAIService.setApiKey(dotenv.env['OPENAI_API_KEY'] ?? '');
    isInitialized.value = true;

    // Always generate designs if forceRegenerate was passed or if images are empty
    final arguments = Get.arguments;
    final forceRegenerate =
        arguments != null &&
        arguments is Map<String, dynamic> &&
        arguments['forceRegenerate'] == true;

    if (generatedImages.isEmpty || forceRegenerate) {
      generateDesigns();
    } else {
      print(
        'Skipping generation - already have ${generatedImages.length} images',
      );
    }
  }

  Future<void> generateDesigns() async {
    final startTime = DateTime.now(); // Track generation time
    PostHogAnalyticsService().trackDesignGenerationStarted();

    try {
      print('=== STARTING DESIGN GENERATION ===');
      isLoading.value = true;
      hasError.value = false;
      errorMessage.value = '';
      generatedImages.clear();
      generationProgress.value = 0.0;
      generationStep.value = 1;

      // Check if all questionnaire data is available
      if (!_dataService.isAllDataComplete()) {
        print('No questionnaire data found, using sample data...');
        // Use sample data for testing if no real data is available
        _setSampleData();
      } else {
        print('Using real questionnaire data...');
      }

      print('Creative Brief Data: ${_dataService.getCreativeBriefData()}');
      print('Refined Concept Data: ${_dataService.getRefinedConceptData()}');

      print('Generating visual prompt with OpenAI GPT-4...');
      // Generate visual prompt using OpenAI (without Final Details - skipped screen)
      generationStep.value = 1;
      generationProgress.value = 0.1;
      currentPrompt.value = await OpenAIService.generateVisualPrompt(
        creativeBrief: _dataService.getCreativeBriefData(),
        refinedConcept: _dataService.getRefinedConceptData(),
      );
      generationStep.value = 2;
      generationProgress.value = 0.5;

      print('Generated Visual Prompt: ${currentPrompt.value}');

      print('Generating design image with GPT-IMAGE-1...');

      // Get inspiration image path from creative brief data
      final creativeBriefData = _dataService.getCreativeBriefData();
      String? inspirationImagePath;

      if (creativeBriefData['inspirationType'] == 'image' &&
          creativeBriefData['inspiration'] != null &&
          creativeBriefData['inspiration'].isNotEmpty) {
        // Handle both List<String> (new format) and String (legacy format)
        final inspiration = creativeBriefData['inspiration'];
        if (inspiration is List) {
          // New format: array of image paths, use the first one
          inspirationImagePath = inspiration.isNotEmpty ? inspiration[0] : null;
          print(
            'Using first inspiration image from list: $inspirationImagePath',
          );
        } else if (inspiration is String) {
          // Legacy format: single image path
          inspirationImagePath = inspiration;
          print('Using inspiration image (legacy): $inspirationImagePath');
        }
      }

      // Generate design images (now returns base64-encoded images)
      final base64Images = await OpenAIService.generateDesignImages(
        prompt: currentPrompt.value,
        numberOfImages: 1,
        inspirationImagePath: inspirationImagePath,
      );

      print('Generated ${base64Images.length} images:');
      for (int i = 0; i < base64Images.length; i++) {
        print(
          'Image  [33m${i + 1} [0m: [base64 string, length:  [32m${base64Images[i].length} [0m]',
        );
      }

      generationStep.value = 3;
      generationProgress.value = 0.75;
      await Future.delayed(const Duration(milliseconds: 300));
      generationStep.value = 4;
      generationProgress.value = 1.0;
      await Future.delayed(const Duration(milliseconds: 600));
      generatedImages.value = base64Images;
      // Only one design is ever generated now, so it's selected automatically —
      // no need to make the user tap it before Continue/Save Design are enabled.
      if (generatedImages.isNotEmpty) {
        selectedDesignIndex.value = 0;
      }
      print('=== DESIGN GENERATION COMPLETED SUCCESSFULLY ===');

      // Track successful generation
      PostHogAnalyticsService().trackDesignGenerationCompleted(
        numberOfDesigns: base64Images.length,
        generationTime: DateTime.now().difference(startTime),
      );
      AppsFlyerAnalyticsService().trackCreatedDesign();
    } catch (e) {
      hasError.value = true;
      errorMessage.value = e.toString();
      print('=== ERROR GENERATING DESIGNS ===');
      print('Error: $e');
      print('Error Type: ${e.runtimeType}');

      // Track generation failure
      PostHogAnalyticsService().trackDesignGenerationFailed(
        errorMessage: e.toString(),
      );
    } finally {
      isLoading.value = false;
    }
  }

  void _setSampleData() {
    // Sample data for testing when no real questionnaire data exists
    _dataService.setCreativeBriefData({
      'garmentType': 'Casual T-shirt',
      'targetAudience': 'Young adults',
      'occasion': 'everyday wear',
      'brand': 'Modern casual',
    });

    _dataService.setRefinedConceptData({
      'style': 'minimalist',
      'colors': 'neutral tones',
      'materials': 'cotton blend',
      'silhouette': 'relaxed fit',
    });

    _dataService.setFinalDetailsData({
      'fit': 'comfortable',
      'details': 'subtle branding',
      'finishing': 'premium stitching',
      'size': 'unisex',
    });
  }

  void onContinueWithDesign(int selectedIndex) async {
    final subscription = await _subscriptionService
        .getCurrentUserSubscription();

    // FREE users — techpack access via purchased add-ons only
    if (subscription?.subscriptionPlan == 'FREE') {
      if (subscription!.hasFreeExtraTechpacks) {
        // Has free add-on techpacks — navigate directly; usage incremented on generation
        if (selectedIndex >= 0 && selectedIndex < generatedImages.length) {
          final arguments = <String, dynamic>{
            'selectedDesignUrl': generatedImages[selectedIndex],
            'designPrompt': currentPrompt.value,
            'designData': _dataService.getAllDesignData(),
          };
          if (_isEditMode.value && _editingTechPack != null) {
            arguments['editMode'] = true;
            arguments['techPackModel'] = _editingTechPack;
          }
          Get.toNamed('/tech_pack_details_screen', arguments: arguments);
        }
      } else {
        _showUpgradeDialog();
      }
      return;
    }

    // Paid user — check for 80% usage warning first
    if (subscription != null && subscription.isTechpackUsageAt80Percent) {
      _show80PercentTechpackWarningDialog(subscription, selectedIndex);
      return;
    }

    // Check subscription before allowing techpack generation (with monthly reset check)
    bool canGenerate = await _subscriptionService.canUsePremiumFeatureWithReset(
      'techpack',
    );

    if (!canGenerate) {
      _showUpgradeDialog();
      return;
    }

    // Continue with the selected design
    if (selectedIndex >= 0 && selectedIndex < generatedImages.length) {
      // Prepare arguments for tech pack details
      Map<String, dynamic> arguments = {
        'selectedDesignUrl': generatedImages[selectedIndex],
        'designPrompt': currentPrompt.value,
        'designData': _dataService.getAllDesignData(),
      };

      // Add edit mode data if applicable
      if (_isEditMode.value && _editingTechPack != null) {
        arguments['editMode'] = true;
        arguments['techPackModel'] = _editingTechPack;
      }

      // Navigate to tech pack details with arguments
      Get.toNamed('/tech_pack_details_screen', arguments: arguments);
    }
  }

  void selectDesign(int index) {
    if (index >= 0 && index < generatedImages.length) {
      selectedDesignIndex.value = index;
      // Track design selection
      PostHogAnalyticsService().trackDesignSelected(designIndex: index);
    }
  }

  Future<void> onContinueWithSelectedDesign() async {
    // Safety check - ensure controller is not disposed
    try {
      if (generatedImages.isEmpty) {
        print('GeneratedImages is empty, controller might be disposed');
        return;
      }
    } catch (e) {
      print('Controller might be disposed: $e');
      return;
    }

    final subscription = await _subscriptionService
        .getCurrentUserSubscription();

    // FREE users — delegate to onContinueWithDesign which handles the free path
    if (subscription?.subscriptionPlan == 'FREE') {
      onContinueWithDesign(selectedDesignIndex.value);
      return;
    }

    // Paid user — check for 80% usage warning first
    if (subscription != null && subscription.isTechpackUsageAt80Percent) {
      _show80PercentTechpackWarningDialog(
        subscription,
        selectedDesignIndex.value,
      );
      return;
    }

    // Check subscription before allowing techpack generation (with monthly reset check)
    bool canGenerate = await _subscriptionService.canUsePremiumFeatureWithReset(
      'techpack',
    );

    if (!canGenerate) {
      _showUpgradeDialog();
      return;
    }

    if (selectedDesignIndex.value >= 0 &&
        selectedDesignIndex.value < generatedImages.length) {
      // Track tech pack creation started
      PostHogAnalyticsService().trackTechPackStarted();

      // Navigate immediately - no waiting
      onContinueWithDesign(selectedDesignIndex.value);

      // Save in background
      _saveDesignsInBackground();
    }
  }

  // Save just the design (no tech pack) to the Dashboard.
  // Reuses the tech_packs collection so it shows up on the Dashboard immediately,
  // marked with hasTechPack: false so factory/export actions stay hidden for it.
  Future<void> onSaveDesignOnly(String projectName, String collectionName) async {
    if (selectedDesignIndex.value < 0 ||
        selectedDesignIndex.value >= generatedImages.length) {
      showAppSnackbar(
        _l10n.tpSnackbarNoDesignSelected,
        _l10n.tpSnackbarNoDesignSelectedMessage,
        snackPosition: SnackPosition.TOP,
        duration: const Duration(milliseconds: 1500),
        backgroundColor: Colors.black,
        colorText: Colors.white,
      );
      return;
    }

    isSaving.value = true;
    try {
      final techPackId = DateTime.now().millisecondsSinceEpoch.toString();
      final base64Image = generatedImages[selectedDesignIndex.value];

      await TechPackService.saveDesignOnly(
        base64Image: base64Image,
        techPackId: techPackId,
        projectName: projectName,
        collectionName: collectionName,
        designData: _dataService.getAllDesignData(),
      );

      // Spend the design credit here, unless this is an edit of an
      // already-existing (already-paid-for) design.
      if (!_isEditMode.value) {
        await DesignCreditService.spendDesignCredit();
      }

      PostHogAnalyticsService().trackEvent('design saved to dashboard');

      showAppSnackbar(
        _l10n.tpSnackbarDesignSavedToDashboard,
        _l10n.tpSnackbarDesignSavedToDashboardMessage,
        snackPosition: SnackPosition.TOP,
        duration: const Duration(milliseconds: 1500),
        backgroundColor: Colors.black,
        colorText: Colors.white,
        margin: const EdgeInsets.all(10),
      );

      // Delete controller so a fresh one is created next time this screen opens
      if (Get.isRegistered<TechPackController>()) {
        Get.delete<TechPackController>();
      }

      // Navigate to the Dashboard and force it to refresh so the new entry shows up
      Get.offNamedUntil('/nav_bar', (route) => false, arguments: {'refresh': true});
    } catch (e) {
      print('Failed to save design only: $e');
      showAppSnackbar(
        _l10n.tpSnackbarSaveDesignFailed,
        _l10n.tpSnackbarSaveDesignFailedMessage,
        snackPosition: SnackPosition.TOP,
        duration: const Duration(milliseconds: 1500),
        backgroundColor: Colors.black,
        colorText: Colors.white,
      );
    } finally {
      isSaving.value = false;
    }
  }

  // Background save function - OPTIMIZED VERSION
  // Now saves all images to Storage but only selected design data to Firestore
  // Handles both new designs and edit mode updates
  Future<void> _saveDesignsInBackground() async {
    try {
      print('=== STARTING OPTIMIZED BACKGROUND SAVE ===');

      // Reset completion flags
      isDesignSaveComplete.value = false;
      designSaveError.value = '';
      savedDesignUrl.value = '';

      // Get questionnaire data
      Map<String, dynamic> questionnaireData = {
        'creativeBrief': _dataService.getCreativeBriefData(),
        'refinedConcept': _dataService.getRefinedConceptData(),
        'finalDetails': _dataService.getFinalDetailsData(),
        'prompt': currentPrompt.value,
      };

      if (_isEditMode.value && _editingTechPack != null) {
        // EDIT MODE: Update existing design with new questionnaire data
        print('=== EDIT MODE: Updating existing design ===');

        // Update the designs collection with new questionnaire data
        await _editDataService.updateTechPackData(
          techPackId: _editingTechPack!.id,
          designQuestionnaireData: questionnaireData,
        );

        // Also save new designs if user selects one (for comparison)
        await _designsService.saveDesignsOptimized(
          base64Images: generatedImages,
          questionnaireData: questionnaireData,
          selectedIndex: selectedDesignIndex.value,
        );

        print('✅ Edit mode: Updated existing design and saved new options');

        // Mark design save as complete
        isDesignSaveComplete.value = true;
        savedDesignUrl.value = generatedImages[selectedDesignIndex.value];

        showAppSnackbar(
          _l10n.tpSnackbarDesignUpdated,
          _l10n.tpSnackbarDesignUpdatedMessage,
          snackPosition: SnackPosition.TOP,
          duration: const Duration(milliseconds: 1500),
          backgroundColor: Colors.black,
          colorText: Colors.white,
          margin: const EdgeInsets.all(10),
        );
      } else {
        // NEW DESIGN MODE: Save as new design
        print('=== NEW DESIGN MODE: Creating new design ===');

        await _designsService.saveDesignsOptimized(
          base64Images: generatedImages,
          questionnaireData: questionnaireData,
          selectedIndex: selectedDesignIndex.value,
        );

        print('✅ New design: Saved successfully');

        // Mark design save as complete
        isDesignSaveComplete.value = true;
        savedDesignUrl.value = generatedImages[selectedDesignIndex.value];

        showAppSnackbar(
          _l10n.tpSnackbarDesignSaved,
          _l10n.tpSnackbarDesignSavedMessage,
          snackPosition: SnackPosition.TOP,
          duration: const Duration(milliseconds: 1500),
          backgroundColor: Colors.black,
          colorText: Colors.white,
          margin: const EdgeInsets.all(10),
        );
      }

      print('=== OPTIMIZED BACKGROUND SAVE COMPLETED ===');
      print('✅ All 3 images saved to Storage');
      print('✅ Selected design data saved to Firestore');
    } catch (e) {
      print('=== OPTIMIZED BACKGROUND SAVE FAILED ===');
      print('Error: $e');

      // Mark save as failed
      isDesignSaveComplete.value = false;
      designSaveError.value = e.toString();

      // Optional: Show error notification
      showAppSnackbar(
        _l10n.tpSnackbarGenerationFailed,
        _l10n.tpSnackbarGenerationFailedMessage,
        snackPosition: SnackPosition.TOP,
        duration: const Duration(milliseconds: 1500),
        backgroundColor: Colors.black,
        colorText: Colors.white,
        margin: const EdgeInsets.all(10),
      );
    }
  }

  Future<void> regenerateDesigns() async {
    await generateDesigns();
  }

  void retryGeneration() {
    generateDesigns();
  }

  // Reset controller state and regenerate designs
  void resetAndRegenerate() {
    // Clear all existing data
    generatedImages.clear();
    selectedDesignIndex.value = -1;
    currentPrompt.value = '';
    errorMessage.value = '';
    hasError.value = false;
    isLoading.value = false;

    // Trigger new design generation
    generateDesigns();
  }

  void _showUpgradeDialog() async {
    // Get current subscription to show in dialog
    final subscription = await _subscriptionService
        .getCurrentUserSubscription();
    String currentPlan = subscription?.subscriptionPlan ?? 'FREE';

    // If Pro or Studio plan user has reached limit, show extra purchase dialog
    if (currentPlan.startsWith('PRO') || currentPlan.startsWith('STUDIO')) {
      _showProLimitDialog(subscription);
      return;
    }

    // FREE users — offer to buy free add-on techpacks
    if (currentPlan == 'FREE') {
      Get.dialog(
        TechpackLimitDialog(
          title: _l10n.tpProLimitDialogTitle,
          message: _l10n.tpFreeUserTechpackMessage,
          isPaidUser: false,
          techpackPriceString: _techpackPriceString,
          onGetExtraTechpacks: () async {
            bool success =
                await _revenueCatService.purchaseFreeExtraTechpacks(1, 5.99);
            if (success) {
              Navigator.of(Get.overlayContext!).pop();
              if (selectedDesignIndex.value >= 0 &&
                  selectedDesignIndex.value < generatedImages.length) {
                Get.toNamed('/tech_pack_details_screen', arguments: {
                  'selectedDesignUrl': generatedImages[selectedDesignIndex.value],
                  'designPrompt': currentPrompt.value,
                  'designData': _dataService.getAllDesignData(),
                });
              }
            }
          },
          onMaybeLater: () => Navigator.of(Get.overlayContext!).pop(),
        ),
        barrierDismissible: false,
      );
      return;
    }

    // STARTER users — offer paid add-on techpacks
    final bool isStarterYearly = currentPlan == 'STARTER_YEARLY';
    Get.dialog(
      TechpackLimitDialog(
        title: _l10n.tpProLimitDialogTitle,
        message: isStarterYearly
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

  // Show 80% techpack usage warning dialog
  void _show80PercentTechpackWarningDialog(
    subscription,
    int selectedIndex,
  ) async {
    final int usedCount = subscription.techpacksUsedThisMonth;
    final int totalCount = subscription.totalAllowedTechpacks;
    // Check if user is on a paid plan (STARTER, PRO, or STUDIO)
    final bool isPaidUser =
        subscription.subscriptionPlan.startsWith('STARTER') ||
        subscription.subscriptionPlan.startsWith('PRO') ||
        subscription.subscriptionPlan.startsWith('STUDIO');

    Get.dialog(
      UsageWarningDialog(
        usedCount: usedCount,
        totalCount: totalCount,
        isDesign: false, // This is for techpacks
        isPaidUser: isPaidUser,
        techpackPriceString: _techpackPriceString,
        onGetExtraDesigns: () async {
          // Not used for techpacks, but required by widget
        },
        onGetExtraTechpacks: isPaidUser
            ? () async {
                await _purchaseExtraTechpacks(1, 5.99);
              }
            : null,
        onContinue: () {
          Navigator.of(Get.overlayContext!).pop();
          // Continue with the selected design based on which method called this
          if (selectedIndex >= 0 && selectedIndex < generatedImages.length) {
            // Prepare arguments for tech pack details
            Map<String, dynamic> arguments = {
              'selectedDesignUrl': generatedImages[selectedIndex],
              'designPrompt': currentPrompt.value,
              'designData': _dataService.getAllDesignData(),
            };

            // Add edit mode data if applicable
            if (_isEditMode.value && _editingTechPack != null) {
              arguments['editMode'] = true;
              arguments['techPackModel'] = _editingTechPack;
            }

            // Navigate to tech pack details with arguments
            Get.toNamed('/tech_pack_details_screen', arguments: arguments);
          }
        },
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
        if (selectedDesignIndex.value >= 0 &&
            selectedDesignIndex.value < generatedImages.length) {
          final arguments = <String, dynamic>{
            'selectedDesignUrl': generatedImages[selectedDesignIndex.value],
            'designPrompt': currentPrompt.value,
            'designData': _dataService.getAllDesignData(),
          };

          if (_isEditMode.value && _editingTechPack != null) {
            arguments['editMode'] = true;
            arguments['techPackModel'] = _editingTechPack;
          }

          PostHogAnalyticsService().trackTechPackStarted();
          Navigator.of(Get.overlayContext!).pop(); // Close the dialog
          Get.toNamed('/tech_pack_details_screen', arguments: arguments);
          _saveDesignsInBackground();
        }
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
}
