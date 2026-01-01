import 'package:atella/core/themes/app_fonts.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:get/get.dart';
import 'package:flutter/material.dart';
import 'package:atella/Data/api/openai_service.dart';
import 'package:atella/Data/Models/tech_pack_model.dart';
import 'package:atella/Data/Models/user_subscription.dart';
import 'package:atella/services/designservices/design_data_service.dart';
import 'package:atella/services/designservices/designs_service.dart';
import 'package:atella/services/firebase/edit/edit_data_service.dart';
import 'package:atella/services/PaymentService/stripe_subscription_service.dart';
import 'package:atella/services/PaymentService/subscription_callback_service.dart';
import 'package:atella/services/analytics/posthog_analytics_service.dart';
import 'package:atella/Modules/final_details/Views/Widgets/usage_warning_dialog.dart';
import 'package:atella/l10n/generated/app_localizations.dart';

class TechPackController extends GetxController {
  final DesignDataService _dataService = DesignDataService.instance;
  final DesignsService _designsService = DesignsService();
  final EditDataService _editDataService = EditDataService();
  final StripeSubscriptionService _subscriptionService =
      StripeSubscriptionService();

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

  @override
  void onInit() {
    super.onInit();
    _checkForEditMode();
    _initializeApiKey();
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
      currentPrompt.value = await OpenAIService.generateVisualPrompt(
        creativeBrief: _dataService.getCreativeBriefData(),
        refinedConcept: _dataService.getRefinedConceptData(),
      );

      print('Generated Visual Prompt: ${currentPrompt.value}');

      print('Generating 3 design images with GPT-IMAGE-1...');

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
        numberOfImages: 3,
        inspirationImagePath: inspirationImagePath,
      );

      print('Generated ${base64Images.length} images:');
      for (int i = 0; i < base64Images.length; i++) {
        print(
          'Image  [33m${i + 1} [0m: [base64 string, length:  [32m${base64Images[i].length} [0m]',
        );
      }

      generatedImages.value = base64Images;
      print('=== DESIGN GENERATION COMPLETED SUCCESSFULLY ===');

      // Track successful generation
      PostHogAnalyticsService().trackDesignGenerationCompleted(
        numberOfDesigns: base64Images.length,
        generationTime: DateTime.now().difference(startTime),
      );

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
    // Check for 80% usage warning first
    final subscription = await _subscriptionService.getCurrentUserSubscription();
    if (subscription != null && subscription.isTechpackUsageAt80Percent) {
      _show80PercentTechpackWarningDialog(subscription, selectedIndex);
      return;
    }

    // Check subscription before allowing techpack generation (with monthly reset check)
    bool canGenerate = await _subscriptionService.canUsePremiumFeatureWithReset(
      'techpack',
    );

    if (!canGenerate) {
      // Show upgrade prompt
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

    // Check for 80% usage warning first
    final subscription = await _subscriptionService.getCurrentUserSubscription();
    if (subscription != null && subscription.isTechpackUsageAt80Percent) {
      _show80PercentTechpackWarningDialog(subscription, selectedDesignIndex.value);
      return;
    }

    // Check subscription before allowing techpack generation (with monthly reset check)
    bool canGenerate = await _subscriptionService.canUsePremiumFeatureWithReset(
      'techpack',
    );

    if (!canGenerate) {
      // Show upgrade prompt
      _showUpgradeDialog();
      return;
    }

    if (selectedDesignIndex.value >= 0 &&
        selectedDesignIndex.value < generatedImages.length) {

    if (selectedDesignIndex.value >= 0 && selectedDesignIndex.value < generatedImages.length) {
      // Track tech pack creation started
      PostHogAnalyticsService().trackTechPackStarted();

      // Navigate immediately - no waiting
      onContinueWithDesign(selectedDesignIndex.value);

      // Save in background
      _saveDesignsInBackground();
    }
  }
  }

  // Background save function - OPTIMIZED VERSION
  // Now saves all images to Storage but only selected design data to Firestore
  // Handles both new designs and edit mode updates
  Future<void> _saveDesignsInBackground() async {
    try {
      print('=== STARTING OPTIMIZED BACKGROUND SAVE ===');

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

        Get.snackbar(
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

        Get.snackbar(
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

      // Optional: Show error notification
      Get.snackbar(
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
    int remainingTechpacks = subscription?.remainingTechpacks ?? 0;

    // If Pro plan user has reached limit, show extra purchase dialog
    if (currentPlan.startsWith('PRO')) {
      _showProLimitDialog(subscription);
      return;
    }

    Get.dialog(
      AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
        title: Row(
          children: [
            Text(
              _l10n.tpUpgradeRequired,
              style: sfpsTitleTextTextStyle18600.copyWith(color: Colors.red),
            ),
          ],
        ),
        content: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Current plan info
              Container(
              width: double.infinity,
              padding: EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(8),
                border: Border.all(color: Colors.grey.shade300),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Expanded(
                        child: Text(
                          _l10n.tpDialogCurrentPlan(_getPlanDisplayName(currentPlan)),
                          style: ssTitleTextTextStyle14400.copyWith(
                            fontSize: 12,
                            color: Colors.black,
                            fontWeight: FontWeight.bold,
                          ),
                          textAlign: TextAlign.center,
                        ),
                      ),
                    ],
                  ),
                  if (remainingTechpacks > 0)
                    Padding(
                      padding: EdgeInsets.only(top: 4),
                      child: Text(
                        currentPlan.startsWith('PRO')
                            ? _l10n.tpDialogRemainingTechpacksPro(remainingTechpacks)
                            : _l10n.tpDialogRemainingTechpacksStarter(remainingTechpacks),
                        style: ssTitleTextTextStyle14400.copyWith(
                          fontSize: 12,
                          color: Colors.black,
                          fontWeight: FontWeight.bold,
                        ),
                        textAlign: TextAlign.center,
                      ),
                    ),
                ],
              ),
            ),
            SizedBox(height: 16),
            Text(
              currentPlan == 'FREE'
                  ? _l10n.tpTechpackFeaturePremium
                  : currentPlan.startsWith('PRO')
                  ? _l10n.tpProMonthlyLimitReached
                  : currentPlan == 'STARTER_YEARLY'
                  ? _l10n.tpStarterYearlyLimitReached
                  : _l10n.tpStarterMonthlyLimitReached,
              style: ssTitleTextTextStyle14400.copyWith(
                fontSize: 12,
                color: Colors.black,
              ),
              textAlign: TextAlign.center,
            ),
            SizedBox(height: 12),
            Container(
              padding: EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(8),
                border: Border.all(color: Colors.grey.shade300),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    currentPlan == 'FREE'
                        ? _l10n.tpDialogChoosePlan
                        : _l10n.tpDialogUpgradeToPro,
                    style: ssTitleTextTextStyle14400.copyWith(
                      color: Colors.black,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  SizedBox(height: 8),
                  if (currentPlan == 'FREE') ...[
                    _buildFeatureItem(
                      _l10n.tpDialogStarterPlanOption,
                    ),
                    _buildFeatureItem(
                      _l10n.tpDialogProPlanOption,
                    ),
                  ] else if (currentPlan.startsWith('STARTER')) ...[
                    _buildFeatureItem(_l10n.tpDialogProUpgradeOption),
                  ] else if (currentPlan.startsWith('PRO')) ...[
                    _buildFeatureItem(_l10n.tpDialogExtraTechpackOption),
                  ],
                  _buildFeatureItem(_l10n.tpDialogFeatureCustomPDFExport),
                  _buildFeatureItem(_l10n.tpDialogFeatureManufacturerAccess),
                  _buildFeatureItem(_l10n.tpDialogFeatureUnlimited3D),
                ],
              ),
            ),
          ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Get.back(),
            child: Text(
              _l10n.tpMaybeLater,
              style: ssTitleTextTextStyle14400.copyWith(color: Colors.black),
            ),
          ),
          ElevatedButton(
            onPressed: () {
              Get.back();

              // Set callback to refresh the UI state after subscription
              SubscriptionCallbackService().setOnSubscriptionSuccess(() {
                // Just refresh the UI, don't automatically navigate
                // User needs to manually click the button again
                print('Subscription upgraded, UI refreshed');
              });

              Get.toNamed(
                '/subscribe',
                arguments: {
                  'returnRoute': '/generate_tech_pack',
                  'showSuccessMessage': true,
                },
              );
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.black,
              padding: EdgeInsets.symmetric(horizontal: 16, vertical: 12),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(24),
              ),
            ),
            child: Text(
              _l10n.tpViewPlans,
              style: ssTitleTextTextStyle14400.copyWith(color: Colors.white),
              textAlign: TextAlign.center,
            ),
          ),
        ],
      ),
      barrierDismissible: false,
    );
  }

  String _getPlanDisplayName(String plan) {
    // CRITICAL: 'plan' parameter stays in English (FREE, STARTER, PRO, STUDIO) - only return value is localized
    switch (plan) {
      case 'FREE':
        return _l10n.tpPlanFree;
      case 'STARTER':
        return '${_l10n.tpPlanStarter} (€14.99/month)';
      case 'STARTER_YEARLY':
        return '${_l10n.tpPlanStarter} (€149.99/year)';
      case 'PRO':
        return '${_l10n.tpPlanPro} (€34.99/month)';
      case 'PRO_YEARLY':
        return '${_l10n.tpPlanPro} (€349.99/year)';
      case 'STUDIO':
        return 'Studio (€79.99/month)';
      case 'STUDIO_YEARLY':
        return 'Studio (€799.99/year)';
      default:
        return _l10n.tpPlanFree;
    }
  }

  Widget _buildFeatureItem(String text) {
    return Padding(
      padding: EdgeInsets.only(bottom: 4),
      child: Row(
        children: [
          Icon(Icons.check_circle, color: Colors.green, size: 16),
          SizedBox(width: 8),
          Expanded(child: Text(text, style: TextStyle(fontSize: 14))),
        ],
      ),
    );
  }

  void _showProLimitDialog(UserSubscription? subscription) {
    Get.dialog(
      AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
        title: Row(
          children: [
            Icon(Icons.warning_amber_rounded, color: Colors.red, size: 24),
            SizedBox(width: 8),
            Expanded(
              child: Text(
                _l10n.tpProLimitDialogTitle,
                style: sfpsTitleTextTextStyle18600.copyWith(color: Colors.red),
              ),
            ),
          ],
        ),
        content: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                width: double.infinity,
                padding: EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: Colors.purple.shade50,
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(color: Colors.purple.shade200),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Icon(Icons.star, color: Colors.black, size: 16),
                        SizedBox(width: 4),
                        Text(
                          _l10n.tpProLimitDialogProPlan,
                          style: ssTitleTextTextStyle14400.copyWith(
                            fontSize: 12,
                            color: Colors.black,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        Expanded(
                          child: Text(
                            _getPlanDisplayName(
                              subscription?.subscriptionPlan ?? 'PRO',
                            ),
                            style: ssTitleTextTextStyle14400.copyWith(
                              fontSize: 12,
                              fontWeight: FontWeight.bold,
                              color: Colors.black,
                            ),
                          ),
                        ),
                      ],
                    ),
                    Padding(
                      padding: EdgeInsets.only(top: 4),
                      child: Text(
                        _l10n.tpProLimitDialogMonthlyUsed(subscription?.techpacksUsedThisMonth ?? 0),
                        style: ssTitleTextTextStyle14400.copyWith(
                          fontSize: 12,
                          color: Colors.red.shade600,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              SizedBox(height: 16),
              Text(
                _l10n.tpProLimitDialogMessage,
                style: ssTitleTextTextStyle14400.copyWith(
                  fontSize: 14,
                  color: Colors.black,
                ),
                textAlign: TextAlign.center,
              ),
              SizedBox(height: 16),
              Container(
                padding: EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: Colors.white,
                  border: Border.all(color: Colors.grey.shade300),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Expanded(
                          child: Text(
                            _l10n.tpProLimitDialogTechpackPrice,
                            style: ssTitleTextTextStyle14400.copyWith(
                              fontSize: 14,
                              fontWeight: FontWeight.bold,
                              color: Colors.black,
                            ),
                          ),
                        ),
                      ],
                    ),
                    SizedBox(height: 4),
                    Text(
                      _l10n.tpProLimitDialogTechpackDescription,
                      style: ssTitleTextTextStyle14400.copyWith(
                        fontSize: 12,
                        color: Colors.black,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Get.back(),
            child: Text(
              _l10n.tpMaybeLater,
              style: ssTitleTextTextStyle14400.copyWith(
                color: Colors.grey,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
          TextButton(
            onPressed: () {
              Get.back();
              _purchaseExtraTechpacks(1, 5.99);
            },
            child: Text(
              _l10n.tpProLimitDialogPurchaseButton,
              style: ssTitleTextTextStyle14400.copyWith(
                color: Colors.black,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
        ],
      ),
      barrierDismissible: true,
    );
  }

  // Show 80% techpack usage warning dialog
  void _show80PercentTechpackWarningDialog(subscription, int selectedIndex) async {
    final int usedCount = subscription.techpacksUsedThisMonth;
    final int totalCount = subscription.totalAllowedTechpacks;
    // Check if user is on a paid plan (STARTER or PRO)
    final bool isPaidUser = subscription.subscriptionPlan.startsWith('STARTER') ||
                           subscription.subscriptionPlan.startsWith('PRO');

    Get.dialog(
      UsageWarningDialog(
        usedCount: usedCount,
        totalCount: totalCount,
        isDesign: false, // This is for techpacks
        isPaidUser: isPaidUser,
        onGetExtraDesigns: () {
          // Not used for techpacks, but required by widget
          Get.back();
        },
        onUpgradePlan: () {
          Get.back(); // Close dialog
          // Navigate to subscription screen
          Get.toNamed(
            '/subscribe',
            arguments: {
              'returnRoute': '/generate_tech_pack',
              'showSuccessMessage': true,
            },
          );
        },
        onContinue: () {
          Get.back(); // Close dialog and continue with techpack generation
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
      Get.snackbar(
        'Processing',
        'Processing your purchase...',
        backgroundColor: Colors.black,
        colorText: Colors.white,
        snackPosition: SnackPosition.TOP,
      );

      bool success = await _subscriptionService.purchaseExtraTechpacks(
        count,
        price,
      );

      if (success) {
        Get.snackbar(
          'Success!',
          'You now have $count additional techpacks for this month!',
          backgroundColor: Colors.black,
          colorText: Colors.white,
          snackPosition: SnackPosition.TOP,
          duration: const Duration(milliseconds: 1500),
        );

        // After successful purchase, allow user to continue
        // User should click the button again to proceed
      } else {
        Get.snackbar(
          'Purchase Failed',
          'Unable to process your purchase. Please try again.',
          backgroundColor: Colors.red,
          colorText: Colors.white,
          snackPosition: SnackPosition.TOP,
        );
      }
    } catch (e) {
      Get.snackbar(
        'Error',
        'An error occurred during purchase: ${e.toString()}',
        backgroundColor: Colors.red,
        colorText: Colors.white,
        snackPosition: SnackPosition.TOP,
      );
    }
  }
}
