import 'dart:async';
import 'package:atella/Data/Models/brief_questions_model.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

class RefiningConceptController extends GetxController {
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

  // Check if option is selected including custom selection
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
    
    // For non-custom options
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
      
      // Remove any existing answer for this question
      _answers.remove(currentQuestion.id);
      
      update();
      return; // Don't advance to next question yet
    }

    // Create or update answer for non-custom options
    _answers[currentQuestion.id] = BriefAnswer(
      questionId: currentQuestion.id,
      selectedOptions: [option], // Single selection
    );

    // Clear custom selection if user selects a different option
    if (_customSelectedForQuestion.value == currentQuestion.id) {
      _customSelectedForQuestion.value = '';
    }

    // Update the UI
    update();

    // Auto-advance to next question after short delay
    await Future.delayed(const Duration(milliseconds: 600));
    _nextQuestion();
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
        backgroundColor: const Color(0xFF8B5FE6),
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
    if (currentQuestionIndex >= 5) {
      return questions.length; // Show all questions after question 5
    }
    return currentQuestionIndex + 1; // Show progressive questions for 1-5
  }
}