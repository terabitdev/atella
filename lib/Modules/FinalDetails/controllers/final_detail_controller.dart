import 'dart:async';
import 'package:atella/Data/Models/brief_questions_model.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

class FinalDetailsController extends GetxController {
  // Current question index
  final RxInt _currentQuestionIndex = 0.obs;
  int get currentQuestionIndex => _currentQuestionIndex.value;

  // Real-time timestamp
  final RxString _currentTime = ''.obs;
  String get currentTime => _currentTime.value;
  Timer? _timeTimer;

  // Answers storage - support multiple selections
  final RxMap<String, BriefAnswer> _answers = <String, BriefAnswer>{}.obs;
  Map<String, BriefAnswer> get answers => _answers;

  // Text controllers for custom input
  final otherFeaturesController = TextEditingController();
  final customInputController = TextEditingController();

  // Loading state
  final RxBool _isLoading = false.obs;
  bool get isLoading => _isLoading.value;

  // Editing state for text questions
  final RxSet<String> _editingQuestions = <String>{}.obs;
  Set<String> get editingQuestions => _editingQuestions;

  // Final Details Questions - based on the image
  final List<BriefQuestion> questions = [
    BriefQuestion(
      id: 'target_season',
      question:
          'Great! Let\'s make sure your piece fits perfectly with the season. What kind of weather will it be designed for?',
      type: 'checkbox',
      options: [
        'Summer (Lightweight, Short Or Roll-Up Sleeves)',
        'Mid-Season',
        'All-Season (Layer-Friendly)',
      ],
      allowMultiple: true,
    ),
    BriefQuestion(
      id: 'target_budget',
      question:
          'Got it. And what kind of budget are you working with for this design? I can tailor the fabrics and features accordingly.',
      type: 'checkbox',
      options: [
        'Entry-Level (€15-30 Production / €35-60 Retail)',
        'Mid-Range (€30-50 Production / €60-120 Retail)',
        'Premium (€60+ Production / €120+ Retail)',
      ],
      allowMultiple: false, // Single selection for budget
    ),
    BriefQuestion(
      id: 'desired_features',
      question:
          'Would you like to include any special values or features that matter to you or your brand? I can make sure they\'re part of the final concept',
      type: 'checkbox',
      options: [
        'Organic Fabric',
        'Upcycled Materials',
        'Locally Made (Europe)',
        'UV Protection',
        'Quick-Dry',
        'Wrinkle-Free',
        'Other: ?',
      ],
      allowMultiple: false,
    ),
    
    BriefQuestion(
      id: 'additional_details',
      question: 'Cool — feel free to type in anything else you have in mind!',
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
    otherFeaturesController.dispose();
    customInputController.dispose();
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

  // Check if option is selected
  bool isOptionSelected(String questionId, String option) {
    final answer = _answers[questionId];
    return answer?.selectedOptions.contains(option) ?? false;
  }

  // Toggle option selection (for checkboxes)
  void toggleOption(String questionId, String option) async {
    final currentAnswer = _answers[questionId];
    List<String> selectedOptions =
        currentAnswer?.selectedOptions.toList() ?? [];

    final question = questions.firstWhere((q) => q.id == questionId);

    if (selectedOptions.contains(option)) {
      // Remove if already selected
      selectedOptions.remove(option);
    } else {
      // Add if not selected
      if (question.allowMultiple) {
        selectedOptions.add(option);
      } else {
        // Single selection - replace existing
        selectedOptions = [option];
      }
    }

    // Update answer
    _answers[questionId] = BriefAnswer(
      questionId: questionId,
      selectedOptions: selectedOptions,
      textInput: currentAnswer?.textInput,
    );

    update();

    // Special case: If "Other: ?" is selected in question 3 (desired_features), advance immediately
    if (questionId == 'desired_features' &&
        option == 'Other: ?' &&
        selectedOptions.contains(option)) {
      await Future.delayed(const Duration(milliseconds: 400));
      _nextQuestion();
      return;
    }

    // Auto-advance for single selection questions (budget)
    if (!question.allowMultiple && selectedOptions.isNotEmpty) {
      await Future.delayed(const Duration(milliseconds: 600));
      _nextQuestion();
    } else if (question.allowMultiple && selectedOptions.isNotEmpty) {
      // For multiple selection, auto-advance after a longer delay to allow more selections
      // But not for question 3 when "Other" is selected (handled above)
      if (!(questionId == 'desired_features' &&
          selectedOptions.contains('Other: ?'))) {
        await Future.delayed(const Duration(milliseconds: 2000));
        // Only advance if user hasn't made more selections in the meantime
        final currentAnswerAfterDelay = _answers[questionId];
        if (currentAnswerAfterDelay?.selectedOptions.length ==
            selectedOptions.length) {
          _nextQuestion();
        }
      }
    }
  }

  // Submit text answer
  void submitTextAnswer(
    String questionId,
    TextEditingController controller,
  ) async {
    if (controller.text.trim().isEmpty) return;

    _isLoading.value = true;
    update();

    await Future.delayed(const Duration(milliseconds: 800));

    _answers[questionId] = BriefAnswer(
      questionId: questionId,
      textInput: controller.text.trim(),
    );

    controller.clear();
    _isLoading.value = false;
    update();

    await Future.delayed(const Duration(milliseconds: 400));
    _nextQuestion();
  }

  // Submit "Other" text for features
  void submitOtherFeature(String text) async {
    if (text.trim().isEmpty) return;

    final currentAnswer = _answers['desired_features'];
    List<String> selectedOptions =
        currentAnswer?.selectedOptions.toList() ?? [];

    // Remove existing "Other: ?" and add new "Other: [text]"
    selectedOptions.removeWhere((option) => option.startsWith('Other:'));
    selectedOptions.add('Other: $text');

    _answers['desired_features'] = BriefAnswer(
      questionId: 'desired_features',
      selectedOptions: selectedOptions,
      textInput: text,
    );

    otherFeaturesController.clear();
    update();

    // Auto-advance to next question after submitting other feature
    await Future.delayed(const Duration(milliseconds: 400));
    _nextQuestion();
  }

  void _nextQuestion() {
    if (currentQuestionIndex < questions.length - 1) {
      _currentQuestionIndex.value++;
      update();
    } else {
      // All questions completed
      update();
    }
  }

  // Manual advance for multiple selection questions
  void advanceToNextQuestion() {
    _nextQuestion();
  }

  void previousQuestion() {
    if (currentQuestionIndex > 0) {
      _currentQuestionIndex.value--;
      update();
    }
  }

  void goBack() {
    Get.back();
  }

  // Jump to specific question
  void jumpToQuestion(int index) {
    if (index >= 0 && index < questions.length) {
      _currentQuestionIndex.value = index;
      update();
    }
  }

  // Check if question is answered
  bool isQuestionAnswered(String questionId) {
    final answer = _answers[questionId];
    return (answer?.selectedOptions.isNotEmpty ?? false) ||
        (answer?.textInput?.isNotEmpty ?? false);
  }

  // Get answer for question
  BriefAnswer? getAnswer(String questionId) {
    return _answers[questionId];
  }

  // Check if all questions completed
  bool get isAllQuestionsCompleted => _answers.length == questions.length;

  // Get completion percentage
  double get completionPercentage => _answers.length / questions.length;

  bool get isLastQuestion => currentQuestionIndex == questions.length - 1;
  bool get isFirstQuestion => currentQuestionIndex == 0;

  double get progressPercentage =>
      (currentQuestionIndex + 1) / questions.length;

  // Editing methods
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

  // Generate final design
  void generateDesign() {
    Get.toNamed('/generate_tech_pack');
    Get.snackbar(
      'Design Generated!',
      'Your custom design is being created...',
      snackPosition: SnackPosition.TOP,
      backgroundColor: const Color(0xFF8B5FE6),
      colorText: Colors.white,
    );

    // Navigate to design preview or results screen
    // Get.toNamed('/design-preview');
  }

  bool isOtherSelectedForCurrentQuestion() {
    // Check if current question is desired_features and "Other: ?" is selected
    if (currentQuestion.id == 'desired_features') {
      return isOptionSelected('desired_features', 'Other: ?');
    }
    return false;
  }

  // NEW: Check if we should show animation after a specific question
  bool shouldShowAnimationAfterQuestion(int questionIndex) {
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
    return currentQuestionIndex + 1; // Show progressive questions
  }
}