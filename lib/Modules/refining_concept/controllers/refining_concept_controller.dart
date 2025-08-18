import 'dart:async';
import 'package:atella/Data/Models/brief_questions_model.dart';
import 'package:atella/Data/Models/tech_pack_model.dart';
import 'package:atella/services/designservices/design_data_service.dart';
import 'package:atella/services/firebase/edit/edit_data_service.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

class RefiningConceptController extends GetxController {
  final DesignDataService _dataService = Get.find<DesignDataService>();
  final EditDataService _editDataService = EditDataService();
  
  // Edit mode tracking
  final RxBool _isEditMode = false.obs;
  bool get isEditMode => _isEditMode.value;
  TechPackModel? _editingTechPack;
  TechPackModel? get editingTechPack => _editingTechPack;
  
  // Current question index
  final RxInt _currentQuestionIndex = 0.obs;
  int get currentQuestionIndex => _currentQuestionIndex.value;

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

  // Track which question has custom selected
  final RxString _customSelectedForQuestion = ''.obs;
  String get customSelectedForQuestion => _customSelectedForQuestion.value;

  // Track temporary selections before they are confirmed
  final RxMap<String, String> _tempSelections = <String, String>{}.obs;
  Map<String, String> get tempSelections => _tempSelections;

  // Editing state for text questions
  final RxSet<String> _editingQuestions = <String>{}.obs;
  Set<String> get editingQuestions => _editingQuestions;

  // Questions data - chip questions only, no text type questions in this flow
  final List<BriefQuestion> questions = [
    BriefQuestion(
      id: 'garment_type',
      question: 'What type of garment would you like to create?',
      type: 'chips',
      options: ['Oversized', 'Straight', 'Fitted', 'Cropped', 'Long', 'Custom'],
    ),
    BriefQuestion(
      id: 'specific_features',
      question: 'Do you want any specific features?',
      type: 'chips',
      options: [
        'Chest',
        'Pockets',
        'Embroidery',
        'Mother-Of-Pearl Buttons',
        'Cuban collar',
        'Short Or Long Sleeves',
        'Slits',
        'Custom',
      ],
    ),
    BriefQuestion(
      id: 'seasonal_constraint',
      question: 'Is there a seasonal constraint?',
      type: 'chips',
      options: ['Summer', 'Mid-Season', 'All-Season', 'Custom'],
    ),
    BriefQuestion(
      id: 'target_budget',
      question: 'What is your target budget per piece?',
      type: 'chips',
      options: [
        'Price Range In €',
        'An Indication Of The Market Level',
        'Entry',
        'Mid-Range',
        'Premium',
        'Custom',
      ],
    ),
    BriefQuestion(
      id: 'functionalities_values',
      question:
          'Would you like to include any specific functionalities or values?',
      type: 'chips',
      options: [
        'Organic Fabric',
        'Locally Made',
        'Upcycled',
        'UV Protection',
        'Quick-Dry',
        'Wrinkle-Free',
        'Custom',
      ],)
  ];

  @override
  void onInit() {
    super.onInit();
    _startTimeUpdater();
    _updateCurrentTime();
    _checkForEditMode();
  }
  
  void _checkForEditMode() {
    final arguments = Get.arguments;
    print('Refining Concept Controller - Arguments received: $arguments');
    
    if (arguments != null && arguments is Map<String, dynamic>) {
      final isEditMode = arguments['editMode'] == true;
      print('Edit mode detected: $isEditMode');
      
      if (isEditMode) {
        _isEditMode.value = true;
        _editingTechPack = arguments['techPackModel'] as TechPackModel?;
        _loadExistingRefinedConceptData();
      }
    }
  }
  
  void _loadExistingRefinedConceptData() {
    // Get data from design data service (loaded in creative brief)
    final refinedConceptData = _dataService.getRefinedConceptData();
    print('Loading refined concept data: $refinedConceptData');
    
    if (refinedConceptData.isNotEmpty) {
      // Load chip-based answers
      final garmentType = refinedConceptData['garment_type'] as String? ?? '';
      if (garmentType.isNotEmpty) {
        _answers['garment_type'] = BriefAnswer(
          questionId: 'garment_type',
          selectedOptions: [garmentType],
        );
      }
      
      final specificFeatures = refinedConceptData['specific_features'] as String? ?? '';
      if (specificFeatures.isNotEmpty) {
        _answers['specific_features'] = BriefAnswer(
          questionId: 'specific_features',
          selectedOptions: [specificFeatures],
        );
      }
      
      final seasonalConstraint = refinedConceptData['seasonal_constraint'] as String? ?? '';
      if (seasonalConstraint.isNotEmpty) {
        _answers['seasonal_constraint'] = BriefAnswer(
          questionId: 'seasonal_constraint',
          selectedOptions: [seasonalConstraint],
        );
      }
      
      final targetBudget = refinedConceptData['target_budget'] as String? ?? '';
      if (targetBudget.isNotEmpty) {
        _answers['target_budget'] = BriefAnswer(
          questionId: 'target_budget',
          selectedOptions: [targetBudget],
        );
      }
      
      final functionalitiesValues = refinedConceptData['functionalities_values'] as String? ?? '';
      if (functionalitiesValues.isNotEmpty) {
        _answers['functionalities_values'] = BriefAnswer(
          questionId: 'functionalities_values',
          selectedOptions: [functionalitiesValues],
        );
      }
      
      // In edit mode, show all questions
      _currentQuestionIndex.value = questions.length - 1;
      
      // Force reactive update
      _answers.refresh();
      update();
      
      print('Loaded ${_answers.length} answers for refined concept');
    }
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

  // Check if option is selected including custom selection and temporary selections
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
    final result = _customSelectedForQuestion.value == currentQuestion.id;
    print('isCustomSelectedForCurrentQuestion called: $_customSelectedForQuestion.value == ${currentQuestion.id} = $result'); // Debug
    return result;
  }

  void selectOption(String option) async {
    print('Selecting option: $option'); // Debug
    
    // If "Custom" is selected, show text field at bottom
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
      await Future.delayed(const Duration(milliseconds: 2000)); // 2 seconds delay
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
  void quickEditAnswer(String questionId) {
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

  void _nextQuestion() {
    // Clear custom selection when moving to next question
    _customSelectedForQuestion.value = '';
    
    // Clear any temporary selections for the current question
    _tempSelections.remove(currentQuestion.id);
    
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
        'Refining Complete!',
        'Your concept has been refined successfully.',
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
    _editingQuestions.clear();
    colorController.clear();
    fabricController.clear();
    customController.clear();
    update();
  }

  // New methods for the updated UI
  bool isQuestionAnswered(String questionId) {
    return _answers.containsKey(questionId);
  }

  BriefAnswer? getAnswer(String questionId) {
    return _answers[questionId];
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

  // Check if we should show animation after a specific question
  bool shouldShowAnimationAfterQuestion(int questionIndex) {
    // Don't show animation when custom is selected for current question
    if (isCustomSelectedForCurrentQuestion() && questionIndex == currentQuestionIndex) {
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

  // Method to get number of questions to show in the list
  int get questionsToShow {
    // In edit mode, always show all questions
    if (_isEditMode.value) {
      return questions.length;
    }
    
    if (currentQuestionIndex >= 5) {
      return questions.length; // Show all questions after question 5
    }
    return currentQuestionIndex + 1; // Show progressive questions for 1-5
  }

  // Save refined concept data to DesignDataService
  void _saveRefinedConceptData() {
    // Convert answers to a format suitable for design generation
    Map<String, dynamic> refinedConceptData = {};
    
    for (var entry in _answers.entries) {
      String questionId = entry.key;
      BriefAnswer answer = entry.value;
      
      switch (questionId) {
        case 'garment_type':
          refinedConceptData['silhouette'] = answer.selectedOptions.isNotEmpty 
              ? answer.selectedOptions.first 
              : '';
          if (answer.textInput?.isNotEmpty == true) {
            refinedConceptData['customSilhouette'] = answer.textInput;
          }
          break;
        case 'specific_features':
          refinedConceptData['features'] = answer.selectedOptions.isNotEmpty 
              ? answer.selectedOptions.first 
              : '';
          if (answer.textInput?.isNotEmpty == true) {
            refinedConceptData['customFeatures'] = answer.textInput;
          }
          break;
        case 'seasonal_constraint':
          refinedConceptData['season'] = answer.selectedOptions.isNotEmpty 
              ? answer.selectedOptions.first 
              : '';
          if (answer.textInput?.isNotEmpty == true) {
            refinedConceptData['customSeason'] = answer.textInput;
          }
          break;
        case 'target_budget':
          refinedConceptData['budget'] = answer.selectedOptions.isNotEmpty 
              ? answer.selectedOptions.first 
              : '';
          if (answer.textInput?.isNotEmpty == true) {
            refinedConceptData['customBudget'] = answer.textInput;
          }
          break;
        case 'functionalities_values':
          refinedConceptData['values'] = answer.selectedOptions.isNotEmpty 
              ? answer.selectedOptions.first 
              : '';
          if (answer.textInput?.isNotEmpty == true) {
            refinedConceptData['customValues'] = answer.textInput;
          }
          break;
      }
    }
    
    // Save to design data service
    _dataService.setRefinedConceptData(refinedConceptData);
    
    print('Refined Concept data saved: $refinedConceptData');
  }

  // Method to proceed to next screen with data saving
  void proceedToNextScreen() {
    _saveRefinedConceptData();
    
    // Pass edit mode data to next screen
    if (_isEditMode.value && _editingTechPack != null) {
      // In edit mode, skip onboarding and go directly to questionnaire
      Get.toNamed('/final_details', arguments: {
        'editMode': true,
        'techPackModel': _editingTechPack,
      });
    } else {
      Get.toNamed('/final_detail_onboard');
    }
  }
  
  // Edit answer method - allows editing a specific question's answer
  void editAnswer(String questionId) {
    final question = questions.firstWhere((q) => q.id == questionId);
    final currentAnswer = _answers[questionId];
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
        title: Text('Edit Answer', style: TextStyle(fontSize: 18, fontWeight: FontWeight.w600)),
        content: SizedBox(
          width: double.maxFinite,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(question.question, style: TextStyle(fontSize: 14, color: Colors.grey[600])),
              SizedBox(height: 16),
              Obx(() => Wrap(
                children: question.options.map((option) {
                  final isSelected = tempSelectedOptions.contains(option);
                  return GestureDetector(
                    onTap: () {
                      if (question.allowMultiple) {
                        isSelected ? tempSelectedOptions.remove(option) : tempSelectedOptions.add(option);
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
                        border: Border.all(color: isSelected ? Colors.black : Colors.grey[300]!),
                      ),
                      child: Text(option, style: TextStyle(
                        color: isSelected ? Colors.white : Colors.black,
                        fontSize: 14, fontWeight: isSelected ? FontWeight.w500 : FontWeight.w400,
                      )),
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
            child: Text('Cancel')
          ),
          ElevatedButton(
            onPressed: () {
              // Validate custom input if Custom is selected
              if (tempSelectedOptions.contains('Custom') && tempCustomController.text.trim().isEmpty) {
                Get.snackbar(
                  'Invalid Input',
                  'Please enter a custom answer',
                  backgroundColor: Colors.orange,
                  colorText: Colors.white,
                  duration: Duration(seconds: 2),
                );
                return;
              }
              
              _answers[questionId] = BriefAnswer(
                questionId: questionId, 
                selectedOptions: tempSelectedOptions.toList(),
                textInput: tempSelectedOptions.contains('Custom') 
                    ? tempCustomController.text.trim() 
                    : null,
              );
              
              Navigator.of(Get.overlayContext!).pop();
              
              // Dispose temporary controller after dialog is closed
              Future.delayed(Duration(milliseconds: 100), () {
                tempCustomController.dispose();
              });
              update();
              Get.snackbar('Answer Updated', 'Successfully updated', backgroundColor: Colors.green, colorText: Colors.white);
            },
            style: ElevatedButton.styleFrom(backgroundColor: Colors.black),
            child: Text('Save Changes'),
          ),
        ],
      ),
    );
  }
}