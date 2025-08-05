import 'dart:async';
import 'package:atella/Data/Models/brief_questions_model.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

class CreativeBriefController extends GetxController {
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

  // Loading state for text input
  final RxBool _isTextLoading = false.obs;
  bool get isTextLoading => _isTextLoading.value;

  // Editing state for text questions
  final RxSet<String> _editingQuestions = <String>{}.obs;
  Set<String> get editingQuestions => _editingQuestions;

  // Questions data
  final List<BriefQuestion> questions = [
    BriefQuestion(
      id: 'garment_type',
      question: 'What type of garment would you like to create?',
      type: 'chips',
      options: ['Jacket', 'Dress', 'Pants', 'New pants', 'Custom'],
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
        'Everyday',
        'Wear',
        'Special',
        'Event',
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

  bool isOptionSelected(String option) {
    final answer = _answers[currentQuestion.id];
    return answer?.selectedOptions.contains(option) ?? false;
  }

  void selectOption(String option) async {
    // Create or update answer
    _answers[currentQuestion.id] = BriefAnswer(
      questionId: currentQuestion.id,
      selectedOptions: [option], // Single selection
    );

    // Update the UI
    update();

    // Auto-advance to next question after short delay
    await Future.delayed(const Duration(milliseconds: 600));
    _nextQuestion();
  }

  void submitTextAnswer(
    String questionId,
    TextEditingController controller,
  ) async {
    // print('submitTextAnswer called for question: $questionId');
    // print('Text content: "${controller.text.trim()}"');
    // print('Current question index before submission: $currentQuestionIndex');

    if (controller.text.trim().isEmpty) {
      // print('Text is empty, returning');
      return;
    }

    // print('Starting text submission process');
    _isTextLoading.value = true;
    update();

    // Simulate processing
    await Future.delayed(const Duration(milliseconds: 800));

    _answers[questionId] = BriefAnswer(
      questionId: questionId,
      textInput: controller.text.trim(),
    );

    // print('Answer saved for question: $questionId');
    // print('Total answers after saving: ${_answers.length}');
    // print('All answers: ${_answers.keys.toList()}');

    // Clear the text controller
    controller.clear();

    _isTextLoading.value = false;
    update();

    // print('About to call _nextQuestion');
    // Auto-advance to next question
    await Future.delayed(const Duration(milliseconds: 400));
    _nextQuestion();
  }

  // Manual method to advance to next question (for debugging)
  void manualNextQuestion() {
    _nextQuestion();
  }

  // Manual method to check completion status
  void checkCompletionStatus() {
    // print('Current question index: ${currentQuestionIndex}');
    // print('Total questions: ${questions.length}');
    // print('Answers count: ${_answers.length}');
    // print('Is last question: ${isLastQuestion}');
    // print('Is all completed: ${isAllQuestionsCompleted}');
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

  void _nextQuestion() {
    // print('_nextQuestion called');
    // print('Current question index: $currentQuestionIndex');
    // print('Total questions: ${questions.length}');

    // Special case: if we just answered question 5 (index 4), show last two questions
    if (currentQuestionIndex == 4) {
      // print('Just answered question 5, showing last two questions');
      _showLastTwoQuestions.value = true;
      _currentQuestionIndex.value = 5; // Move to first text question
      update();
      return;
    }

    if (currentQuestionIndex < questions.length - 1) {
      // print('Advancing to next question');
      _currentQuestionIndex.value++;
      // print('New question index: ${_currentQuestionIndex.value}');
      update();
    } else {
      // print('Reached last question - checking if all are completed');
      // Check if all questions are actually answered
      if (isAllQuestionsCompleted) {
        // print('All questions completed - showing next steps');
        update(); // Update UI to show Next Steps button
        _showCompletionScreen();
      } else {
        // print('On last question but not all answered yet');
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
    return currentQuestionIndex < 5; // Show for first 5 questions
  }

  // Check if we should show the button
  bool get shouldShowButton {
    return _showLastTwoQuestions.value || isAllQuestionsCompleted;
  }
}