import 'package:atella/core/themes/app_fonts.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:get/get.dart';
import 'package:flutter/material.dart';
import 'package:atella/firebase/api/openai_service.dart';
import 'package:atella/firebase/services/design_data_service.dart';
import 'package:atella/firebase/services/designs_service.dart';

class TechPackController extends GetxController {
  final DesignDataService _dataService = DesignDataService.instance;
  final DesignsService _designsService = DesignsService();
  
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
    _initializeApiKey();
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
  
  void onGoBackAndEdit() {
    // Show dialog to let user choose which stage to edit
    _showEditOptionsDialog();
  }
  
  void _showEditOptionsDialog() {
    Get.dialog(
      AlertDialog(
        backgroundColor: Colors.white,
        title: Text('Edit Your Answers', style: gtpadTitleTextTextStyle18),
        content: const Text('Which stage would you like to edit?'),
        actions: [
          TextButton(
            onPressed: () {
              Get.back(); // Close dialog
              Get.offNamedUntil('/creative_brief', (route) => route.isFirst);
            },
            child: Text('Creative Brief',style: gtpadTitleTextTextStyle14600),
          ),
          TextButton(
            onPressed: () {
              Get.back(); // Close dialog
              Get.offNamedUntil('/refining_concept', (route) => route.isFirst);
            },
            child: Text('Refine Concept',style: gtpadTitleTextTextStyle14600),
          ),
          TextButton(
            onPressed: () {
              Get.back(); // Close dialog
              Get.offNamedUntil('/final_details', (route) => route.isFirst);
            },
            child: Text('Final Details',style: gtpadTitleTextTextStyle14600),
          ),
          TextButton(
            onPressed: () => Get.back(),
            child: Text('Cancel',style: gtpadTitleTextTextStyle16800),
          ),
        ],
      ),
    );
  }
  
  void onContinueWithDesign(int selectedIndex) {
    // Continue with the selected design
    if (selectedIndex >= 0 && selectedIndex < generatedImages.length) {
      // Navigate to tech pack details with arguments
      Get.toNamed(
        '/tech_pack_details_screen',
        arguments: {
          'selectedDesignUrl': generatedImages[selectedIndex],
          'designPrompt': currentPrompt.value,
          'designData': _dataService.getAllDesignData(),
        },

      );
    }
  }
  
  void selectDesign(int index) {
    if (index >= 0 && index < generatedImages.length) {
      selectedDesignIndex.value = index;
    }
  }
  
  Future<void> onContinueWithSelectedDesign() async {
    if (selectedDesignIndex.value >= 0 && selectedDesignIndex.value < generatedImages.length) {
      try {
        // Show saving state (not loading state)
        isSaving.value = true;
        hasError.value = false;
        errorMessage.value = '';
        
        print('=== STARTING FIREBASE SAVE ===');
        print('Selected design index: ${selectedDesignIndex.value}');
        print('Total designs to save: ${generatedImages.length}');
        
        // Test storage connection first
        print('Testing Firebase Storage connection...');
        bool storageConnected = await _designsService.testStorageConnection();
        if (!storageConnected) {
          print('Warning: Firebase Storage connection failed, will use fallback');
        }
        
        // Get questionnaire data
        Map<String, dynamic> questionnaireData = {
          'creativeBrief': _dataService.getCreativeBriefData(),
          'refinedConcept': _dataService.getRefinedConceptData(),
          'finalDetails': _dataService.getFinalDetailsData(),
          'prompt': currentPrompt.value,
        };
        
        print('Questionnaire data prepared');

        // Save all designs to Firebase with selection status
        await _designsService.saveMultipleDesigns(
          base64Images: generatedImages,
          questionnaireData: questionnaireData,
          selectedIndex: selectedDesignIndex.value,
        );

        print('=== DESIGNS SAVED TO FIREBASE SUCCESSFULLY ===');
        
        // Continue with the selected design
        onContinueWithDesign(selectedDesignIndex.value);
        
      } catch (e) {
        print('=== ERROR SAVING DESIGNS TO FIREBASE ===');
        print('Error: $e');
        print('Error Type: ${e.runtimeType}');
        
        hasError.value = true;
        errorMessage.value = e.toString().length > 100 
          ? e.toString().substring(0, 100) + '...' 
          : e.toString();
      } finally {
        isSaving.value = false;
      }
    }
  }
  
  Future<void> regenerateDesigns() async {
    await generateDesigns();
  }
  
  void retryGeneration() {
    generateDesigns();
  }
}
