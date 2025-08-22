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

class TechPackController extends GetxController {
  final DesignDataService _dataService = DesignDataService.instance;
  final DesignsService _designsService = DesignsService();
  final EditDataService _editDataService = EditDataService();
  final StripeSubscriptionService _subscriptionService = StripeSubscriptionService();
  
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
    final forceRegenerate = arguments != null && 
                           arguments is Map<String, dynamic> && 
                           arguments['forceRegenerate'] == true;
    
    if (generatedImages.isEmpty || forceRegenerate) {
      generateDesigns();
    } else {
      print('Skipping generation - already have ${generatedImages.length} images');
    }
  }
  
  Future<void> generateDesigns() async {
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
      print('Final Details Data: ${_dataService.getFinalDetailsData()}');
      
      print('Generating visual prompt with OpenAI GPT-4...');
      // Generate visual prompt using OpenAI
      currentPrompt.value = await OpenAIService.generateVisualPrompt(
        creativeBrief: _dataService.getCreativeBriefData(),
        refinedConcept: _dataService.getRefinedConceptData(),
        finalDetails: _dataService.getFinalDetailsData(),
      );
      
      print('Generated Visual Prompt: ${currentPrompt.value}');
      
      print('Generating 3 design images with GPT-IMAGE-1...');
      // Generate design images (now returns base64-encoded images)
      final base64Images = await OpenAIService.generateDesignImages(
        prompt: currentPrompt.value,
        numberOfImages: 3,
      );
      
      print('Generated ${base64Images.length} images:');
      for (int i = 0; i < base64Images.length; i++) {
        print('Image  [33m${i + 1} [0m: [base64 string, length:  [32m${base64Images[i].length} [0m]');
      }
      
      generatedImages.value = base64Images;
      print('=== DESIGN GENERATION COMPLETED SUCCESSFULLY ===');
      
    } catch (e) {
      hasError.value = true;
      errorMessage.value = e.toString();
      print('=== ERROR GENERATING DESIGNS ===');
      print('Error: $e');
      print('Error Type: ${e.runtimeType}');
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
    // Check subscription before allowing techpack generation (with monthly reset check)
    bool canGenerate = await _subscriptionService.canUsePremiumFeatureWithReset('techpack');
    
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
    
    // Check subscription before allowing techpack generation (with monthly reset check)
    bool canGenerate = await _subscriptionService.canUsePremiumFeatureWithReset('techpack');
    
    if (!canGenerate) {
      // Show upgrade prompt
      _showUpgradeDialog();
      return;
    }
    
    if (selectedDesignIndex.value >= 0 && selectedDesignIndex.value < generatedImages.length) {
      // Navigate immediately - no waiting
      onContinueWithDesign(selectedDesignIndex.value);
      
      // Save in background
      _saveDesignsInBackground();
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
        'Design Updated',
        'Your design has been updated with new preferences',
        snackPosition: SnackPosition.TOP,
        duration: const Duration(seconds: 2),
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
        'Design Saved',
        'Your selected design has been saved successfully',
        snackPosition: SnackPosition.TOP,
        duration: const Duration(seconds: 3),
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
      'Save Failed',
      'Failed to save design. It will be available during this session.',
      snackPosition: SnackPosition.TOP,
      duration: const Duration(seconds: 3),
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
    final subscription = await _subscriptionService.getCurrentUserSubscription();
    String currentPlan = subscription?.subscriptionPlan ?? 'FREE';
    int remainingTechpacks = subscription?.remainingTechpacks ?? 0;
    
    // If Pro plan user has reached limit, show extra purchase dialog
    if (currentPlan.startsWith('PRO')) {
      _showProLimitDialog(subscription);
      return;
    }
    
    Get.dialog(
      AlertDialog(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(15),
        ),
        title: Row(
          children: [
            Text('Upgrade Required',style:  sfpsTitleTextTextStyle18600.copyWith(color: Colors.red),),
          ],
        ),
        content: Column(
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
                      Text(
                        'Current Plan: ${_getPlanDisplayName(currentPlan)}',
                        style:  ssTitleTextTextStyle14400.copyWith(
                          fontSize: 12,
                          color: Colors.black,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
                  if (remainingTechpacks > 0)
                    Padding(
                      padding: EdgeInsets.only(top: 4),
                      child: Text(
                        currentPlan.startsWith('PRO')
                          ? 'Remaining: $remainingTechpacks/20 techpacks this month'
                          : currentPlan == 'STARTER_YEARLY' 
                            ? 'Remaining: $remainingTechpacks/3 this month'
                            : 'Remaining techpacks: $remainingTechpacks/3 this month',
                        style:  ssTitleTextTextStyle14400.copyWith(
                          fontSize: 12,
                          color: Colors.black,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                ],
              ),
            ),
            SizedBox(height: 16),
            Text(
              currentPlan == 'FREE' 
                ? 'Techpack generation is a premium feature.'
                : currentPlan.startsWith('PRO')
                  ? 'You\'ve reached your Pro plan monthly limit of 20 techpacks.'
                  : currentPlan == 'STARTER_YEARLY'
                    ? 'You\'ve reached your monthly limit of 3 techpacks (36/year total).'
                    : 'You\'ve reached your monthly limit of 3 techpacks.',
              style:  ssTitleTextTextStyle14400.copyWith(
                fontSize: 12,
                color: Colors.black,
              ),
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
                    currentPlan == 'FREE' ? 'Choose a plan:' : 'Upgrade to Pro:',
                    style:  ssTitleTextTextStyle14400.copyWith(
                      color: Colors.black,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  SizedBox(height: 8),
                  if (currentPlan == 'FREE') ...[
                    _buildFeatureItem('Starter: 3 techpacks/month (€9.99/mo or €99/yr)'),
                    _buildFeatureItem('Pro: 20 techpacks/month (€24.99/mo or €249/yr)'),
                  ] else if (currentPlan.startsWith('STARTER')) ...[
                    _buildFeatureItem('Pro: 20 techpacks/month'),
                  ] else if (currentPlan.startsWith('PRO')) ...[
                    _buildFeatureItem('Purchase extra techpacks: +5 for €4.99'),
                    _buildFeatureItem('Purchase extra techpacks: +10 for €8.99'),
                  ],
                  _buildFeatureItem('Custom PDF export with your logo'),
                  _buildFeatureItem('Access to manufacturers list'),
                  _buildFeatureItem('Unlimited 3D visualization'),
                ],
              ),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Get.back(),
            child: Text('Maybe Later', style: ssTitleTextTextStyle14400.copyWith(
              color: Colors.black,
            )),
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
              
              Get.toNamed('/subscribe', arguments: {
                'returnRoute': '/generate_tech_pack',
                'showSuccessMessage': true,
              });
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.black,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(24),
              ),
            ),
            child: Text('Upgrade Now', style: ssTitleTextTextStyle14400.copyWith(
              color: Colors.white,
            )),
          ),
        ],
      ),
      barrierDismissible: false,
    );
  }
  
  String _getPlanDisplayName(String plan) {
    switch (plan) {
      case 'FREE':
        return 'Free';
      case 'STARTER':
        return 'Starter (€9.99/month)';
      case 'STARTER_YEARLY':
        return 'Starter (€99/year)';
      case 'PRO':
        return 'Pro (€24.99/month)';
      case 'PRO_YEARLY':
        return 'Pro (€249/year)';
      default:
        return 'Free';
    }
  }
  
  Widget _buildFeatureItem(String text) {
    return Padding(
      padding: EdgeInsets.only(bottom: 4),
      child: Row(
        children: [
          Icon(Icons.check_circle, color: Colors.green, size: 16),
          SizedBox(width: 8),
          Expanded(
            child: Text(
              text,
              style: TextStyle(fontSize: 14),
            ),
          ),
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
            Icon(
              Icons.warning_amber_rounded,
              color: Colors.red,
              size: 24,
            ),
            SizedBox(width: 8),
            Text(
              'Monthly Limit Reached',
              style: sfpsTitleTextTextStyle18600.copyWith(color: Colors.red),
            ),
          ],
        ),
        content: Column(
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
                        'Pro Plan: ',
                        style: ssTitleTextTextStyle14400.copyWith(
                          fontSize: 12,
                          color: Colors.black,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      Text(
                        _getPlanDisplayName(subscription?.subscriptionPlan ?? 'PRO'),
                        style: ssTitleTextTextStyle14400.copyWith(
                          fontSize: 12,
                          fontWeight: FontWeight.bold,
                          color: Colors.black,
                        ),
                      ),
                    ],
                  ),
                  Padding(
                    padding: EdgeInsets.only(top: 4),
                    child: Text(
                      'Monthly limit reached: ${subscription?.techpacksUsedThisMonth ?? 0}/20 techpacks used',
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
              'You\'ve reached your Pro plan monthly limit of 20 techpacks. Purchase additional techpacks to continue:',
              style: ssTitleTextTextStyle14400.copyWith(
                fontSize: 14,
                color: Colors.black,
              ),
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
                      Text(
                        '+5 Techpacks: €4.99',
                        style: ssTitleTextTextStyle14400.copyWith(
                          fontSize: 14,
                          fontWeight: FontWeight.bold,
                          color: Colors.black,
                        ),
                      ),
                    ],
                  ),
                  SizedBox(height: 4),
                  Text(
                    'Get 5 additional techpacks for this month',
                    style: ssTitleTextTextStyle14400.copyWith(
                      fontSize: 12,
                      color: Colors.black,
                    ),
                  ),
                ],
              ),
            ),
            SizedBox(height: 8),
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
                      Text(
                        '+10 Techpacks: €8.99',
                        style: ssTitleTextTextStyle14400.copyWith(
                          fontSize: 14,
                          fontWeight: FontWeight.bold,
                          color: Colors.black,
                        ),
                      ),
                    ],
                  ),
                  SizedBox(height: 4),
                  Text(
                    'Get 10 additional techpacks for this month',
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
        actions: [
          TextButton(
            onPressed: () => Get.back(),
            child: Text(
              'Maybe Later',
              style: ssTitleTextTextStyle14400.copyWith(
                color: Colors.grey,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
          TextButton(
            onPressed: () {
              Get.back();
              _purchaseExtraTechpacks(5, 4.99);
            },
            child: Text(
              '+5 Techpacks',
              style: ssTitleTextTextStyle14400.copyWith(
                color: Colors.black,
                fontWeight: FontWeight.w600 ,
              ),
            ),
          ),
          TextButton(
            onPressed: () {
              Get.back();
              _purchaseExtraTechpacks(10, 8.99);
            },
            child: Text(
              '+10 Techpacks',
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

  Future<void> _purchaseExtraTechpacks(int count, double price) async {
    try {
      Get.snackbar(
        'Processing',
        'Processing your purchase...',
        backgroundColor: Colors.black,
        colorText: Colors.white,
        snackPosition: SnackPosition.TOP,
      );

      bool success = await _subscriptionService.purchaseExtraTechpacks(count, price);
      
      if (success) {
        Get.snackbar(
          'Success!',
          'You now have $count additional techpacks for this month!',
          backgroundColor: Colors.black,
          colorText: Colors.white,
          snackPosition: SnackPosition.TOP,
          duration: Duration(seconds: 4),
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
