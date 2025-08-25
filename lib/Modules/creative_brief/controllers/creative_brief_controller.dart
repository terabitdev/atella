import 'dart:async';
import 'package:atella/Data/Models/brief_questions_model.dart';import 'package:atella/Data/Models/tech_pack_model.dart';
import 'package:atella/services/designservices/design_data_service.dart';
import 'package:atella/services/firebase/edit/edit_data_service.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

class CreativeBriefController extends GetxController {
  final DesignDataService _dataService = Get.find<DesignDataService>();
  final EditDataService _editDataService = EditDataService();
  
  // Edit mode tracking
  final RxBool _isEditMode = false.obs;
  bool get isEditMode => _isEditMode.value;
  TechPackModel? _editingTechPack;
  
  // Current question index
  final RxInt _currentQuestionIndex = 0.obs;
  int get currentQuestionIndex => _currentQuestionIndex.value;

  // Show last two questions together flag
  final RxBool _showLastTwoQuestions = false.obs;
  bool get showLastTwoQuestions => _showLastTwoQuestions.value;

  // Real-time timestamp
  final RxString _currentTime = ''.obs;
  String get currentTime => _currentTime.value;
  Timer? _timeTimer;

  // Answers storage - make it properly observable
  final RxMap<String, BriefAnswer> _answers = <String, BriefAnswer>{}.obs;
  Map<String, BriefAnswer> get answers => _answers;

  // Text controllers for text input questions
  final colorController = TextEditingController();
  final fabricController = TextEditingController();
  final customController = TextEditingController(); // For custom answers

  // Loading state for text input
  final RxBool _isTextLoading = false.obs;
  bool get isTextLoading => _isTextLoading.value;

  // Image storage for inspiration question
  final RxString _inspirationImage = ''.obs;
  String get inspirationImage => _inspirationImage.value;

  // Track which question has custom selected - FIXED: Now properly observable
  final RxString _customSelectedForQuestion = ''.obs;
  String get customSelectedForQuestion => _customSelectedForQuestion.value;

  // Track temporary selections before they are confirmed
  final RxMap<String, String> _tempSelections = <String, String>{}.obs;
  Map<String, String> get tempSelections => _tempSelections;

  // Editing state for text questions
  final RxSet<String> _editingQuestions = <String>{}.obs;
  Set<String> get editingQuestions => _editingQuestions;

  // Questions data
  final List<BriefQuestion> questions = [
    BriefQuestion(
      id: 'garment_type',
      question: 'What type of garment would you like to create?',
      type: 'chips',
      options: ['Jacket', 'Dress', 'Pants', 'Set', 'Custom'],
    ),
    BriefQuestion(
      id: 'style',
      question: 'What is the overall desired style?',
      type: 'chips',
      options: ['Casual', 'Chic', 'Sporty', 'Streetwear', 'Workwear', 'Custom'],
    ),
    BriefQuestion(
      id: 'target_audience',
      question: 'Who is this garment intended for?',
      type: 'chips',
      options: ['Woman', 'Man', 'Child', 'Unisex', 'Target Age', 'Custom'],
    ),
    BriefQuestion(
      id: 'occasion',
      question: 'What is the intended occasion or use?',
      type: 'chips',
      options: [
        'Everyday wear',
        'Special event',
        'Sports',
        'Activity',
        'Custom',
      ],
    ),
    BriefQuestion(
      id: 'inspiration',
      question: 'Do you have any visual inspirations or references?',
      type: 'image',
      options: [],
    ),
    BriefQuestion(
      id: 'colors',
      question: 'Are there any dominant colors or a preferred color palette?',
      type: 'text',
      options: [],
    ),
    BriefQuestion(
      id: 'fabrics',
      question: 'Are there any fabrics you prefer or absolutely want to avoid?',
      type: 'text',
      options: [],
    ),
  ];

  @override
  void onInit() {
    super.onInit();
    _startTimeUpdater();
    _updateCurrentTime();
    
    // Check if we're in edit mode and pre-fill data
    _checkForEditMode();
  }
  
  void _checkForEditMode() {
    final arguments = Get.arguments;
    print('=== CREATIVE BRIEF EDIT MODE CHECK ===');
    print('Arguments received: $arguments');
    print('Arguments type: ${arguments.runtimeType}');
    
    if (arguments != null && arguments is Map<String, dynamic>) {
      print('Arguments keys: ${arguments.keys}');
      final isEditMode = arguments['editMode'] == true;
      final techPackModel = arguments['techPackModel'] as TechPackModel?;
      
      print('Edit mode flag: ${arguments['editMode']}');
      print('Edit mode detected: $isEditMode');
      print('TechPack model: ${techPackModel?.toString()}');
      
      if (isEditMode) {
        print('🟢 ENTERING EDIT MODE');
        _isEditMode.value = true;
        _editingTechPack = techPackModel;
        print('Stored TechPack: ${_editingTechPack?.projectName}');
        _loadExistingDataFromFirebase();
      } else {
        print('🔴 EDIT MODE FLAG IS FALSE');
      }
    } else {
      print('🔴 NO ARGUMENTS OR WRONG FORMAT RECEIVED');
      print('Arguments is null: ${arguments == null}');
      print('Arguments is Map: ${arguments is Map<String, dynamic>}');
    }
  }
  
  // Load existing data from Firebase for edit mode
  Future<void> _loadExistingDataFromFirebase() async {
    if (_editingTechPack == null) {
      print('No tech pack model available for editing');
      return;
    }

    try {
      print('Loading data from Firebase for tech pack: ${_editingTechPack!.id}');
      
      // Show loading indicator
      Get.snackbar(
        'Loading',
        'Loading existing design data...',
        backgroundColor: Colors.black,
        colorText: Colors.white,
        snackPosition: SnackPosition.TOP,
        duration: Duration(seconds: 2),
      );

      // Get complete edit data from Firebase
      final editData = await _editDataService.getTechPackEditData(_editingTechPack!.id);
      
      if (editData != null) {
        final questionnaireData = editData['designQuestionnaire'] as Map<String, dynamic>;
        final parsedData = _editDataService.parseQuestionnaireForEdit(questionnaireData);
        
        // Load creative brief data if available
        if (parsedData.containsKey('creativeBrief')) {
          _loadCreativeBriefAnswers(parsedData['creativeBrief'] as Map<String, dynamic>);
        }
        
        // Store all questionnaire data for later use
        if (parsedData.containsKey('refinedConcept')) {
          _dataService.setRefinedConceptData(parsedData['refinedConcept'] as Map<String, dynamic>);
        }
        if (parsedData.containsKey('finalDetails')) {
          _dataService.setFinalDetailsData(parsedData['finalDetails'] as Map<String, dynamic>);
        }
        
        Get.snackbar(
          'Edit Mode',
          'Editing design: ${_editingTechPack!.projectName}',
          backgroundColor: Colors.black,
          colorText: Colors.white,
          snackPosition: SnackPosition.TOP,
          duration: Duration(seconds: 2),
        );
      } else {
        print('No edit data found, using default values');
        _prefillDemoAnswers(_editingTechPack);
      }
    } catch (e) {
      print('Error loading edit data: $e');
      Get.snackbar(
        'Error',
        'Failed to load existing data. Using defaults.',
        backgroundColor: Colors.black,
        colorText: Colors.white,
        duration: Duration(seconds: 2),
        snackPosition: SnackPosition.TOP,
      );
      _prefillDemoAnswers(_editingTechPack);
    }
  }
  
  // Load creative brief answers from Firebase data
  void _loadCreativeBriefAnswers(Map<String, dynamic> creativeBriefData) {
    print('Loading creative brief answers: $creativeBriefData');
    
    // Load chip-based answers
    final garmentType = creativeBriefData['garment_type'] as String? ?? '';
    if (garmentType.isNotEmpty) {
      _answers['garment_type'] = BriefAnswer(
        questionId: 'garment_type',
        selectedOptions: [garmentType],
      );
    }
    
    final style = creativeBriefData['style'] as String? ?? '';
    if (style.isNotEmpty) {
      _answers['style'] = BriefAnswer(
        questionId: 'style',
        selectedOptions: [style],
      );
    }
    
    final targetAudience = creativeBriefData['target_audience'] as String? ?? '';
    if (targetAudience.isNotEmpty) {
      _answers['target_audience'] = BriefAnswer(
        questionId: 'target_audience',
        selectedOptions: [targetAudience],
      );
    }
    
    final occasion = creativeBriefData['occasion'] as String? ?? '';
    if (occasion.isNotEmpty) {
      _answers['occasion'] = BriefAnswer(
        questionId: 'occasion',
        selectedOptions: [occasion],
      );
    }
    
    // Load image-based inspiration
    final inspiration = creativeBriefData['inspiration'] as String? ?? '';
    if (inspiration.isNotEmpty) {
      // Check if it's an image path or regular text
      if (inspiration.contains('/') || inspiration.contains('\\')) {
        // It's an image path
        _inspirationImage.value = inspiration;
        _answers['inspiration'] = BriefAnswer(
          questionId: 'inspiration',
          selectedOptions: ['Image'],
          textInput: inspiration,
        );
      } else {
        // It's regular text (legacy data)
        _answers['inspiration'] = BriefAnswer(
          questionId: 'inspiration',
          selectedOptions: [inspiration],
        );
      }
    }
    
    // Load text-based answers
    final colors = creativeBriefData['colors'] as String? ?? '';
    if (colors.isNotEmpty) {
      colorController.text = colors;
      _answers['colors'] = BriefAnswer(
        questionId: 'colors',
        textInput: colors,
      );
    }
    
    final fabrics = creativeBriefData['fabrics'] as String? ?? '';
    if (fabrics.isNotEmpty) {
      fabricController.text = fabrics;
      _answers['fabrics'] = BriefAnswer(
        questionId: 'fabrics',
        textInput: fabrics,
      );
    }
    
    // In edit mode, show all questions
    _showLastTwoQuestions.value = true;
    _currentQuestionIndex.value = questions.length - 1;
    
    // Force reactive update
    _answers.refresh();
    update();
    
    print('Loaded ${_answers.length} answers for creative brief');
  }
  
  void _prefillDemoAnswers(TechPackModel? techPack) {
    print('Pre-filling demo answers...');
    
    // Pre-fill some answers to demonstrate edit mode functionality
    // In a real application, you would load these from stored data
    
    // Example: Pre-fill garment type (this would come from stored questionnaire data)
    _answers['garment_type'] = BriefAnswer(
      questionId: 'garment_type',
      selectedOptions: ['Shirt'], // This would be the stored selection
      textInput: null,
    );
    print('Pre-filled garment_type: ${_answers['garment_type']}');
    
    // Example: Pre-fill style preference
    _answers['style'] = BriefAnswer(
      questionId: 'style',
      selectedOptions: ['Casual'], // This would be the stored selection
      textInput: null,
    );
    print('Pre-filled style: ${_answers['style']}');
    
    // Example: Pre-fill colors (using project name as example)
    if (techPack?.projectName.toLowerCase().contains('blue') == true) {
      colorController.text = 'Blue, Navy';
      _answers['colors'] = BriefAnswer(
        questionId: 'colors',
        selectedOptions: [],
        textInput: 'Blue, Navy',
      );
    } else {
      // Default colors for edit mode
      colorController.text = 'Black, White';
      _answers['colors'] = BriefAnswer(
        questionId: 'colors',
        selectedOptions: [],
        textInput: 'Black, White',
      );
    }
    print('Pre-filled colors: ${_answers['colors']}');
    
    // Example: Pre-fill fabrics based on collection name
    if (techPack?.collectionName.toLowerCase().contains('summer') == true) {
      fabricController.text = 'Cotton, Linen';
      _answers['fabrics'] = BriefAnswer(
        questionId: 'fabrics',
        selectedOptions: [],
        textInput: 'Cotton, Linen',
      );
    } else {
      // Default fabrics for edit mode
      fabricController.text = 'Cotton, Polyester';
      _answers['fabrics'] = BriefAnswer(
        questionId: 'fabrics',
        selectedOptions: [],
        textInput: 'Cotton, Polyester',
      );
    }
    print('Pre-filled fabrics: ${_answers['fabrics']}');
    
    // Force trigger reactive update for the _answers map
    _answers.refresh();
    
    // Also trigger general update
    update();
    
    print('All answers after pre-filling: ${_answers.keys.toList()}');
    print('Is garment_type answered: ${isQuestionAnswered('garment_type')}');
    print('Is style answered: ${isQuestionAnswered('style')}');
    
    // Show success message
    Future.delayed(Duration(seconds: 2), () {
      Get.snackbar(
        'Data Loaded',
        'Previous answers have been loaded for editing',
        backgroundColor: Colors.green,
        colorText: Colors.white,
      );
    });
  }

  @override
  void onClose() {
    _timeTimer?.cancel();
    colorController.dispose();
    fabricController.dispose();
    customController.dispose();
    super.onClose();
  }

  void _startTimeUpdater() {
    _timeTimer = Timer.periodic(const Duration(seconds: 30), (timer) {
      _updateCurrentTime();
    });
  }

  void _updateCurrentTime() {
    final now = DateTime.now();
    final timeString =
        '${now.hour.toString().padLeft(2, '0')}:${now.minute.toString().padLeft(2, '0')}';
    _currentTime.value = 'Today, $timeString';
  }

  BriefQuestion get currentQuestion => questions[currentQuestionIndex];

  // FIXED: Check if option is selected including custom selection and temporary selections
  bool isOptionSelected(String option) {
    // Special handling for Custom option
    if (option == 'Custom') {
      // Check if custom is currently selected for this question (not answered yet)
      if (_customSelectedForQuestion.value == currentQuestion.id) {
        return true;
      }
      // Check if custom answer is already submitted
      final answer = _answers[currentQuestion.id];
      return answer?.selectedOptions.contains(option) ?? false;
    }
    
    // Check temporary selection first (for current question)
    if (!isQuestionAnswered(currentQuestion.id)) {
      return _tempSelections[currentQuestion.id] == option;
    }
    
    // For answered questions, check final answer
    final answer = _answers[currentQuestion.id];
    return answer?.selectedOptions.contains(option) ?? false;
  }

  // Check if custom is selected for current question
  bool isCustomSelectedForCurrentQuestion() {
    return _customSelectedForQuestion.value == currentQuestion.id;
  }

  void selectOption(String option) async {
    print('Selecting option: $option'); // Debug
    
    // If "Custom" is selected, show text field
    if (option == 'Custom') {
      print('Custom selected for question: ${currentQuestion.id}'); // Debug
      _customSelectedForQuestion.value = currentQuestion.id;
      
      // Clear any temporary selection
      _tempSelections.remove(currentQuestion.id);
      
      update();
      return; // Don't advance to next question yet
    }

    // For non-custom options, store as temporary selection
    _tempSelections[currentQuestion.id] = option;

    // Clear custom selection if user selects a different option
    if (_customSelectedForQuestion.value == currentQuestion.id) {
      _customSelectedForQuestion.value = '';
    }

    // Update the UI
    update();

    // Auto-advance to next question after delay, but only if no answer exists yet
    if (!isQuestionAnswered(currentQuestion.id)) {
      await Future.delayed(const Duration(milliseconds: 2000)); // Increased delay to 2 seconds
      // Check if the selection is still the same (user hasn't changed it)
      if (_tempSelections[currentQuestion.id] == option) {
        _confirmCurrentSelection();
      }
    }
  }

  // Method to confirm current selection and advance
  void _confirmCurrentSelection() {
    final tempSelection = _tempSelections[currentQuestion.id];
    if (tempSelection != null) {
      // Create final answer
      _answers[currentQuestion.id] = BriefAnswer(
        questionId: currentQuestion.id,
        selectedOptions: [tempSelection],
      );
      
      // Clear temporary selection
      _tempSelections.remove(currentQuestion.id);
      
      update();
      
      // Advance to next question
      _nextQuestion();
    }
  }

  // Method to manually confirm selection (if we want to add a confirm button later)
  void confirmSelection() {
    _confirmCurrentSelection();
  }

  // Method to allow editing of previously answered questions
  void editAnswerSimple(String questionId) {
    if (_answers.containsKey(questionId)) {
      // Convert final answer back to temporary selection
      final answer = _answers[questionId]!;
      if (answer.selectedOptions.isNotEmpty) {
        _tempSelections[questionId] = answer.selectedOptions.first;
      }
      
      // Remove the final answer
      _answers.remove(questionId);
      
      // Jump to that question if needed
      final questionIndex = questions.indexWhere((q) => q.id == questionId);
      if (questionIndex != -1 && questionIndex != currentQuestionIndex) {
        _currentQuestionIndex.value = questionIndex;
      }
      
      update();
    }
  }

  // Submit custom answer
  void submitCustomAnswer() async {
    print('Submitting custom answer: ${customController.text}'); // Debug
    
    if (customController.text.trim().isEmpty) {
      return;
    }

    _isTextLoading.value = true;
    update();

    // Simulate processing
    await Future.delayed(const Duration(milliseconds: 800));

    // Store custom answer with "Custom" as selected option and custom text
    _answers[currentQuestion.id] = BriefAnswer(
      questionId: currentQuestion.id,
      selectedOptions: ['Custom'],
      textInput: customController.text.trim(), // Store custom text
    );

    // Clear custom selection and controller
    _customSelectedForQuestion.value = '';
    customController.clear();

    _isTextLoading.value = false;
    update();

    // Auto-advance to next question
    await Future.delayed(const Duration(milliseconds: 400));
    _nextQuestion();
  }

  void submitTextAnswer(
    String questionId,
    TextEditingController controller,
  ) async {
    if (controller.text.trim().isEmpty) {
      return;
    }

    _isTextLoading.value = true;
    update();

    // Simulate processing
    await Future.delayed(const Duration(milliseconds: 800));

    _answers[questionId] = BriefAnswer(
      questionId: questionId,
      textInput: controller.text.trim(),
    );

    // Clear the text controller
    controller.clear();

    _isTextLoading.value = false;
    update();

    // Auto-advance to next question
    await Future.delayed(const Duration(milliseconds: 400));
    _nextQuestion();
  }

  void selectImage(String? imagePath) async {
    if (imagePath == null || imagePath.isEmpty) {
      // Remove image
      _inspirationImage.value = '';
      _answers.remove('inspiration');
    } else {
      // Set image
      _inspirationImage.value = imagePath;
      
      // Create answer for inspiration question
      _answers['inspiration'] = BriefAnswer(
        questionId: 'inspiration',
        selectedOptions: ['Image'],
        textInput: imagePath, // Store image path as text input
      );
    }
    
    update();
    
    // Auto-advance to next question if image is selected
    if (imagePath != null && imagePath.isNotEmpty) {
      await Future.delayed(const Duration(milliseconds: 800));
      _nextQuestion();
    }
  }

  void _nextQuestion() {
    // Clear custom selection when moving to next question
    _customSelectedForQuestion.value = '';
    
    // Clear any temporary selections for the current question
    _tempSelections.remove(currentQuestion.id);
    
    // Special case: if we just answered question 5 (index 4), show last two questions
    if (currentQuestionIndex == 4) {
      _showLastTwoQuestions.value = true;
      _currentQuestionIndex.value = 5; // Move to first text question
      update();
      return;
    }

    if (currentQuestionIndex < questions.length - 1) {
      _currentQuestionIndex.value++;
      update();
    } else {
      // Check if all questions are actually answered
      if (isAllQuestionsCompleted) {
        update(); // Update UI to show Next Steps button
        _showCompletionScreen();
      } else {
        update();
      }
    }
  }

  void previousQuestion() {
    if (currentQuestionIndex > 0) {
      _currentQuestionIndex.value--;
      update();
    }
  }

  void _showCompletionScreen() {
    // Only show completion message if all questions are actually answered
    if (isAllQuestionsCompleted) {
      Get.snackbar(
        'Brief Complete!',
        'Your creative brief has been completed successfully.',
        snackPosition: SnackPosition.TOP,
        backgroundColor: Colors.black,
        colorText: Colors.white,
      );
    }
  }

  void goBack() {
    Get.back();
  }

  // Method to jump to a specific question (for navigation)
  void jumpToQuestion(int index) {
    if (index >= 0 && index < questions.length) {
      _currentQuestionIndex.value = index;
      update();
    }
  }

  // Method to check if all questions are completed
  bool get isAllQuestionsCompleted => _answers.length == questions.length;

  // Method to get completion percentage
  double get completionPercentage => _answers.length / questions.length;

  bool get isLastQuestion => currentQuestionIndex == questions.length - 1;
  bool get isFirstQuestion => currentQuestionIndex == 0;

  double get progressPercentage =>
      (currentQuestionIndex + 1) / questions.length;
  
  // Reset all answers and go back to the first question
  void resetAllAnswers() {
    _answers.clear();
    _tempSelections.clear();
    _customSelectedForQuestion.value = '';
    _currentQuestionIndex.value = 0;
    _showLastTwoQuestions.value = false;
    _editingQuestions.clear();
    colorController.clear();
    fabricController.clear();
    customController.clear();
    update();
  }
  
  // Edit answer method - allows editing a specific question's answer
  void editAnswer(String questionId) {
    print('=== EDIT ANSWER CLICKED ===');
    print('Question ID: $questionId');
    print('Current answer: ${_answers[questionId]?.selectedOptions}');
    
    // Show a dialog to allow editing
    _showEditDialog(questionId);
  }
  
  // Show edit dialog for a question
  void _showEditDialog(String questionId) {
    final question = questions.firstWhere((q) => q.id == questionId);
    final currentAnswer = _answers[questionId];
    
    // Create a temporary list to track changes
    RxList<String> tempSelectedOptions = (currentAnswer?.selectedOptions.toList() ?? []).obs;
    
    // Create a temporary controller for custom text
    final tempCustomController = TextEditingController();
    if (currentAnswer?.textInput != null && currentAnswer!.textInput!.isNotEmpty) {
      tempCustomController.text = currentAnswer.textInput!;
    }
    
    // Track if custom is selected
    RxBool isCustomSelected = tempSelectedOptions.contains('Custom').obs;
    
    Get.dialog(
      AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: Text(
          'Edit Answer',
          style: TextStyle(fontSize: 18, fontWeight: FontWeight.w600),
        ),
        content: SizedBox(
          width: double.maxFinite,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                question.question,
                style: TextStyle(fontSize: 14, color: Colors.grey[600]),
              ),
              SizedBox(height: 16),
              Text(
                'Select your answer:',
                style: TextStyle(fontSize: 16, fontWeight: FontWeight.w500),
              ),
              SizedBox(height: 12),
              Obx(() => Wrap(
                children: question.options.map((option) {
                  final isSelected = tempSelectedOptions.contains(option);
                  return GestureDetector(
                    onTap: () {
                      if (question.allowMultiple) {
                        if (isSelected) {
                          tempSelectedOptions.remove(option);
                        } else {
                          tempSelectedOptions.add(option);
                        }
                      } else {
                        tempSelectedOptions.value = [option];
                      }
                      
                      // Update custom selected state
                      isCustomSelected.value = tempSelectedOptions.contains('Custom');
                    },
                    child: Container(
                      margin: EdgeInsets.only(right: 8, bottom: 8),
                      padding: EdgeInsets.symmetric(horizontal: 16, vertical: 10),
                      decoration: BoxDecoration(
                        color: isSelected ? Colors.black : Colors.grey[100],
                        borderRadius: BorderRadius.circular(25),
                        border: Border.all(
                          color: isSelected ? Colors.black : Colors.grey[300]!,
                        ),
                      ),
                      child: Text(
                        option,
                        style: TextStyle(
                          color: isSelected ? Colors.white : Colors.black,
                          fontSize: 14,
                          fontWeight: isSelected ? FontWeight.w500 : FontWeight.w400,
                        ),
                      ),
                    ),
                  );
                }).toList(),
              )),
              SizedBox(height: 16),
              // Show custom text field if Custom is selected
              Obx(() => isCustomSelected.value ? Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Enter custom answer:',
                    style: TextStyle(fontSize: 14, fontWeight: FontWeight.w500),
                  ),
                  SizedBox(height: 8),
                  TextField(
                    controller: tempCustomController,
                    decoration: InputDecoration(
                      hintText: 'Type your custom answer...',
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                      contentPadding: EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                    ),
                    maxLines: 2,
                  ),
                ],
              ) : SizedBox.shrink()),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.of(Get.overlayContext!).pop();
              // Dispose temporary controller after dialog is closed
              Future.delayed(Duration(milliseconds: 100), () {
                tempCustomController.dispose();
              });
            },
            child: Text(
              'Cancel',
              style: TextStyle(color: Colors.grey[600]),
            ),
          ),
          ElevatedButton(
            onPressed: () {
              // Validate custom input if Custom is selected
              if (tempSelectedOptions.contains('Custom') && tempCustomController.text.trim().isEmpty) {
                Get.snackbar(
                  'Invalid Input',
                  'Please enter a custom answer',
                  backgroundColor: Colors.black,
                  colorText: Colors.white,
                  snackPosition: SnackPosition.TOP,
                  duration: Duration(seconds: 2),
                );
                return;
              }
              
              // Save the changes
              _answers[questionId] = BriefAnswer(
                questionId: questionId,
                selectedOptions: tempSelectedOptions.toList(),
                textInput: tempSelectedOptions.contains('Custom') 
                    ? tempCustomController.text.trim() 
                    : null,
              );
              
              // Close dialog first
              Navigator.of(Get.overlayContext!).pop();
              
              // Dispose temporary controller after dialog is closed
              Future.delayed(Duration(milliseconds: 100), () {
                tempCustomController.dispose();
              });
              
              // Then update and show success message
              update();
              Get.snackbar(
                'Answer Updated',
                'Your answer has been updated successfully',
                backgroundColor: Colors.black,
                colorText: Colors.white,
                duration: Duration(seconds: 2),
                margin: EdgeInsets.all(16),
                snackPosition: SnackPosition.TOP,
              );
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.black,
              foregroundColor: Colors.white,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(8),
              ),
            ),
            child: Text('Save Changes'),
          ),
        ],
      ),
    );
  }

  // New methods for the updated UI
  bool isQuestionAnswered(String questionId) {
    return _answers.containsKey(questionId);
  }

  BriefAnswer? getAnswer(String questionId) {
    return _answers[questionId];
  }

  // Method to get number of questions to show in the list
  int get questionsToShow {
    if (_showLastTwoQuestions.value) {
      return questions.length; // Show all questions
    }
    return currentQuestionIndex + 1; // Show up to current question
  }

  // Check if we should show the bottom input area
  bool get shouldShowBottomInput {
    if (_showLastTwoQuestions.value) {
      return false; // Don't show bottom input when showing last two questions
    }
    
    // Don't show bottom input for chip questions
    if (currentQuestion.type == 'chips') {
      return false;
    }
    
    // Don't show custom input if custom is selected for current question
    if (isCustomSelectedForCurrentQuestion()) {
      return false; // Custom input will be shown inline
    }
    
    // Only show bottom input for text type questions when not showing last two questions together
    return currentQuestion.type == 'text' && !_showLastTwoQuestions.value;
  }

  // Check if we should show the button
  bool get shouldShowButton {
    return _showLastTwoQuestions.value || isAllQuestionsCompleted;
  }

  // Check if we should show animation after a specific question
  bool shouldShowAnimationAfterQuestion(int questionIndex) {
    // Don't show animation when custom is selected for current question
    if (isCustomSelectedForCurrentQuestion() && questionIndex == currentQuestionIndex) {
      return false;
    }
    
    // Don't show animation when showing last two questions together
    if (_showLastTwoQuestions.value) {
      return false;
    }
    
    // Don't show animation if all questions are completed
    if (isAllQuestionsCompleted) {
      return false;
    }
    
    // Show animation below the current unanswered question
    // This means animation shows below current question's answers, not after answering
    bool isCurrentQuestion = questionIndex == currentQuestionIndex;
    bool isNotLastQuestion = questionIndex < questions.length - 1;
    
    return isCurrentQuestion && isNotLastQuestion;
  }

  // Manual methods for debugging
  void manualNextQuestion() {
    _nextQuestion();
  }

  void checkCompletionStatus() {
    print('Current question index: ${currentQuestionIndex}');
    print('Total questions: ${questions.length}');
    print('Answers count: ${_answers.length}');
    print('Is last question: ${isLastQuestion}');
    print('Is all completed: ${isAllQuestionsCompleted}');
  }

  void enableEditing(String questionId) {
    _editingQuestions.add(questionId);
    update();
  }

  void cancelEditing(String questionId) {
    _editingQuestions.remove(questionId);
    update();
  }

  bool isEditing(String questionId) {
    return _editingQuestions.contains(questionId);
  }

  // Save creative brief data to DesignDataService
  void _saveCreativeBriefData() {
    // Convert answers to a format suitable for design generation
    Map<String, dynamic> creativeBriefData = {};
    
    for (var entry in _answers.entries) {
      String questionId = entry.key;
      BriefAnswer answer = entry.value;
      
      switch (questionId) {
        case 'garment_type':
          creativeBriefData['garmentType'] = answer.selectedOptions.isNotEmpty 
              ? answer.selectedOptions.first 
              : '';
          if (answer.textInput?.isNotEmpty == true) {
            creativeBriefData['customGarmentType'] = answer.textInput;
          }
          break;
        case 'style':
          creativeBriefData['style'] = answer.selectedOptions.isNotEmpty 
              ? answer.selectedOptions.first 
              : '';
          if (answer.textInput?.isNotEmpty == true) {
            creativeBriefData['customStyle'] = answer.textInput;
          }
          break;
        case 'target_audience':
          creativeBriefData['targetAudience'] = answer.selectedOptions.isNotEmpty 
              ? answer.selectedOptions.first 
              : '';
          if (answer.textInput?.isNotEmpty == true) {
            creativeBriefData['customTargetAudience'] = answer.textInput;
          }
          break;
        case 'occasion':
          creativeBriefData['occasion'] = answer.selectedOptions.isNotEmpty 
              ? answer.selectedOptions.first 
              : '';
          if (answer.textInput?.isNotEmpty == true) {
            creativeBriefData['customOccasion'] = answer.textInput;
          }
          break;
        case 'inspiration':
          // For image type, save the image path directly
          if (answer.textInput?.isNotEmpty == true && answer.selectedOptions.contains('Image')) {
            creativeBriefData['inspiration'] = answer.textInput; // Save image path
            creativeBriefData['inspirationType'] = 'image';
          } else {
            // Legacy text-based inspiration
            creativeBriefData['inspiration'] = answer.selectedOptions.isNotEmpty 
                ? answer.selectedOptions.first 
                : '';
            creativeBriefData['inspirationType'] = 'text';
            if (answer.textInput?.isNotEmpty == true) {
              creativeBriefData['customInspiration'] = answer.textInput;
            }
          }
          break;
        case 'colors':
          creativeBriefData['colors'] = answer.textInput ?? '';
          break;
        case 'fabrics':
          creativeBriefData['fabrics'] = answer.textInput ?? '';
          break;
      }
    }
    
    // Save to design data service
    _dataService.setCreativeBriefData(creativeBriefData);
    
    print('Creative Brief data saved: $creativeBriefData');
  }

  // Method to proceed to next screen with data saving
  void proceedToNextScreen() {
    _saveCreativeBriefData();
    
    // Pass edit mode data to next screen
    if (_isEditMode.value && _editingTechPack != null) {
      // In edit mode, skip onboarding and go directly to questionnaire
      Get.toNamed('/refining_concept', arguments: {
        'editMode': true,
        'techPackModel': _editingTechPack,
      });
    } else {
      Get.toNamed('/refine_concept');
    }
  }
}