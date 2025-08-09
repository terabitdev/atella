import 'dart:async';
import 'package:atella/Data/Models/brief_questions_model.dart';
import 'package:atella/services/designservices/design_data_service.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

class CreativeBriefController extends GetxController {
  final DesignDataService _dataService = Get.find<DesignDataService>();
  
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
      type: 'chips',
      options: ['Instagram', 'Brands', 'Moodboards', 'Artists', 'Custom'],
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
  void editAnswer(String questionId) {
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
          creativeBriefData['inspiration'] = answer.selectedOptions.isNotEmpty 
              ? answer.selectedOptions.first 
              : '';
          if (answer.textInput?.isNotEmpty == true) {
            creativeBriefData['customInspiration'] = answer.textInput;
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
    Get.toNamed('/refine_concept');
  }
}