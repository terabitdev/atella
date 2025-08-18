import 'package:atella/core/themes/app_fonts.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:get/get.dart';
import 'package:flutter/material.dart';
import 'package:atella/Data/api/openai_service.dart';
import 'package:atella/Data/Models/tech_pack_model.dart';
import 'package:atella/services/designservices/design_data_service.dart';
import 'package:atella/services/designservices/designs_service.dart';
import 'package:atella/services/firebase/edit/edit_data_service.dart';
import 'package:atella/services/stripe_subscription_service.dart';

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
  
  void _checkForEditMode() {
    final arguments = Get.arguments;
    print('TechPack Controller - Arguments received: $arguments');
    
    if (arguments != null && arguments is Map<String, dynamic>) {
      final isEditMode = arguments['editMode'] == true;
      print('Edit mode detected: $isEditMode');
      
      if (isEditMode) {
        _isEditMode.value = true;
        _editingTechPack = arguments['techPackModel'] as TechPackModel?;
        print('Editing tech pack: ${_editingTechPack?.projectName}');
      }
    }
  }
  
  Future<void> _initializeApiKey() async {
    // Set the API key
    await OpenAIService.setApiKey(dotenv.env['OPENAI_API_KEY'] ?? '');
    isInitialized.value = true;
    
    // Start generating designs automatically
    generateDesigns();
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
    // Check subscription before allowing techpack generation
    bool canGenerate = await _subscriptionService.canUsePremiumFeature('techpack');
    
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
      
      // Increment techpack usage for STARTER plan users
      await _subscriptionService.incrementTechpackUsage();
      
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
    // Check subscription before allowing techpack generation
    bool canGenerate = await _subscriptionService.canUsePremiumFeature('techpack');
    
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
        snackPosition: SnackPosition.BOTTOM,
        duration: const Duration(seconds: 2),
        backgroundColor: Colors.blue.withOpacity(0.8),
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
        snackPosition: SnackPosition.BOTTOM,
        duration: const Duration(seconds: 2),
        backgroundColor: Colors.green.withOpacity(0.8),
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
      snackPosition: SnackPosition.BOTTOM,
      duration: const Duration(seconds: 3),
      backgroundColor: Colors.orange.withOpacity(0.8),
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
  
  void _showUpgradeDialog() {
    Get.dialog(
      AlertDialog(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(15),
        ),
        title: Row(
          children: [
            Icon(Icons.lock_outline, color: Colors.blue, size: 28),
            SizedBox(width: 10),
            Text('Premium Feature'),
          ],
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Techpack generation is a premium feature.',
              style: TextStyle(fontSize: 16),
            ),
            SizedBox(height: 12),
            Container(
              padding: EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: Colors.blue.shade50,
                borderRadius: BorderRadius.circular(8),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Upgrade to access:',
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      color: Colors.blue.shade900,
                    ),
                  ),
                  SizedBox(height: 8),
                  _buildFeatureItem('Generate professional techpacks'),
                  _buildFeatureItem('Custom PDF export with your logo'),
                  _buildFeatureItem('Access to manufacturers'),
                ],
              ),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Get.back(),
            child: Text('Maybe Later'),
          ),
          ElevatedButton(
            onPressed: () {
              Get.back();
              Get.toNamed('/subscribe');
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.blue,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(8),
              ),
            ),
            child: Text('View Plans'),
          ),
        ],
      ),
      barrierDismissible: false,
    );
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
}
