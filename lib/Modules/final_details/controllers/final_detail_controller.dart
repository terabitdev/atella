import 'dart:async';
import 'package:atella/Data/Models/brief_questions_model.dart';
import 'package:atella/Data/Models/tech_pack_model.dart';
import 'package:atella/services/designservices/design_data_service.dart';
import 'package:atella/Modules/tech_pack/controllers/generate_tech_pack_controller.dart';
import 'package:atella/services/PaymentService/stripe_subscription_service.dart';
import 'package:atella/services/PaymentService/revenuecat_service.dart';
import 'package:atella/services/firebase/services/design_quota_service.dart';
import 'package:atella/services/analytics/posthog_analytics_service.dart';
import 'package:atella/Modules/final_details/Views/Widgets/free_limit_dialog.dart';
import 'package:atella/Modules/final_details/Views/Widgets/limit_exceeded_dialog.dart';
import 'package:atella/Modules/final_details/Views/Widgets/usage_warning_dialog.dart';
import 'package:atella/services/localization/final_details_localization_service.dart';
import 'package:atella/l10n/generated/app_localizations.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

import 'package:atella/core/utils/app_snackbar.dart';
class FinalDetailsController extends GetxController {
  final DesignDataService _dataService = Get.find<DesignDataService>();
  final StripeSubscriptionService _stripeService = StripeSubscriptionService();
  final RevenueCatService _revenueCatService = RevenueCatService();
  final DesignQuotaService _quotaService = DesignQuotaService();
  final FirebaseAuth _auth = FirebaseAuth.instance;

  // Live localized price string for the design add-on (iOS only).
  // Null on Android or if the RevenueCat fetch failed — dialogs fall back to localisation.
  String? _designPriceString;
  
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
    _checkForEditMode();
    _fetchAddonPrices();
  }

  Future<void> _fetchAddonPrices() async {
    try {
      final prices = await _revenueCatService.fetchAddonPriceStrings();
      _designPriceString = prices.designPrice;
    } catch (e) {
      // _designPriceString stays null — dialogs fall back to localisation strings
    }
  }
  
  void _checkForEditMode() {
    final arguments = Get.arguments;
    print('=== FINAL DETAILS EDIT MODE CHECK ===');
    print('Arguments received: $arguments');
    print('Arguments type: ${arguments.runtimeType}');
    
    if (arguments != null && arguments is Map<String, dynamic>) {
      final isEditMode = arguments['editMode'] == true;
      print('Edit mode flag: ${arguments['editMode']}');
      print('Edit mode detected: $isEditMode');
      
      if (isEditMode) {
        print('🟢 ENTERING FINAL DETAILS EDIT MODE');
        _isEditMode.value = true;
        _editingTechPack = arguments['techPackModel'] as TechPackModel?;
        print('TechPack model: ${_editingTechPack?.projectName}');
        _loadExistingFinalDetailsData();
      } else {
        print('🔴 EDIT MODE FLAG IS FALSE');
      }
    } else {
      print('🔴 NO ARGUMENTS OR WRONG FORMAT RECEIVED');
    }
  }
  
  void _loadExistingFinalDetailsData() {
    // Get data from design data service (loaded in creative brief)
    final finalDetailsData = _dataService.getFinalDetailsData();
    print('Loading final details data: $finalDetailsData');
    
    if (finalDetailsData.isNotEmpty) {
      // Load checkbox-based answers
      final targetSeason = finalDetailsData['target_season'] as String? ?? '';
      if (targetSeason.isNotEmpty) {
        final seasons = targetSeason.split(', ');
        _answers['target_season'] = BriefAnswer(
          questionId: 'target_season',
          selectedOptions: seasons,
        );
      }
      
      final targetBudget = finalDetailsData['target_budget'] as String? ?? '';
      if (targetBudget.isNotEmpty) {
        _answers['target_budget'] = BriefAnswer(
          questionId: 'target_budget',
          selectedOptions: [targetBudget],
        );
      }
      
      final desiredFeatures = finalDetailsData['desired_features'] as String? ?? '';
      if (desiredFeatures.isNotEmpty) {
        final features = desiredFeatures.split(', ');
        _answers['desired_features'] = BriefAnswer(
          questionId: 'desired_features',
          selectedOptions: features,
          textInput: finalDetailsData['customFeatures'] as String?,
        );
      }
      
      // Load text-based answers
      final additionalDetails = finalDetailsData['additional_details'] as String? ?? '';
      if (additionalDetails.isNotEmpty) {
        customInputController.text = additionalDetails;
        _answers['additional_details'] = BriefAnswer(
          questionId: 'additional_details',
          textInput: additionalDetails,
        );
      }
      
      // In edit mode, show all questions
      _currentQuestionIndex.value = questions.length - 1;
      
      // Force reactive update
      _answers.refresh();
      update();
      
      print('Loaded ${_answers.length} answers for final details');
    }
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
    final context = Get.context;
    final l10n = context != null ? AppLocalizations.of(context) : null;
    _currentTime.value = l10n?.fdToday(timeString) ?? 'Today, $timeString';
  }

  BriefQuestion get currentQuestion => questions[currentQuestionIndex];

  // Check if option is selected
  bool isOptionSelected(String questionId, String option) {
    final answer = _answers[questionId];
    return answer?.selectedOptions.contains(option) ?? false;
  }

  // Toggle option selection (for checkboxes)
  void toggleOption(String questionId, String option) async {
    print('=== TOGGLE OPTION ===');
    print('Question ID: $questionId');
    print('Option: $option');
    print('Is Edit Mode: $_isEditMode.value');
    
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

    // Special handling for desired_features question
    if (questionId == 'desired_features') {
      if (option == 'Other: ?' && selectedOptions.contains(option)) {
        // If "Other: ?" is selected, advance to show question 4
        _currentQuestionIndex.value = 3; // Move to question 4
      } else if (option != 'Other: ?' && !selectedOptions.contains('Other: ?')) {
        // If any other option is selected (and "Other: ?" is not selected)
        // Stay on question 3 to show the Generate button
        _currentQuestionIndex.value = 2; // Stay on question 3
      } else if (!selectedOptions.contains('Other: ?') && selectedOptions.isNotEmpty) {
        // If "Other: ?" was deselected but other options remain
        _currentQuestionIndex.value = 2; // Go back to question 3
      }
      update();
      return;
    }

    update();

    // In edit mode, don't auto-advance - let user freely change answers
    if (_isEditMode.value) {
      return;
    }

    // Auto-advance for single selection questions (budget)
    if (!question.allowMultiple && selectedOptions.isNotEmpty) {
      await Future.delayed(const Duration(milliseconds: 600));
      _nextQuestion();
    } else if (question.allowMultiple && selectedOptions.isNotEmpty) {
      // For multiple selection, auto-advance after a longer delay to allow more selections
      await Future.delayed(const Duration(milliseconds: 2000));
      // Only advance if user hasn't made more selections in the meantime
      final currentAnswerAfterDelay = _answers[questionId];
      if (currentAnswerAfterDelay?.selectedOptions.length ==
          selectedOptions.length) {
        _nextQuestion();
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
      // Check if we should skip question 4
      if (currentQuestionIndex == 2) { // Moving from question 3
        final answer = _answers['desired_features'];
        if (answer != null && !answer.selectedOptions.contains('Other: ?')) {
          // Skip question 4 if "Other: ?" is not selected
          // Don't advance automatically, user should click Generate button
          return;
        }
      }
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
    Navigator.of(Get.context!).pop();
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
  void generateDesign() async {
    // Check if user can generate designs (only for non-edit mode)
    if (!_isEditMode.value) {
      // Get current subscription to determine plan type
      final subscription = await _stripeService.getCurrentUserSubscription();

      // Check if user is on FREE plan - use email-based quota
      if (subscription != null && subscription.subscriptionPlan == 'FREE') {
        final user = _auth.currentUser;
        if (user?.email == null) {
          showAppSnackbar(
            'Error',
            'Unable to verify user email',
            snackPosition: SnackPosition.TOP,
            backgroundColor: Colors.red,
            colorText: Colors.white,
          );
          return;
        }

        // Check email-based quota (persists across account deletions).
        // This only checks eligibility — the design credit itself is spent
        // later, at whichever of Save Design / Generate Tech Pack / 3rd
        // modification happens first (see DesignCreditService).
        bool hasQuota = await _quotaService.hasRemainingQuota(user!.email!);
        if (!hasQuota && !subscription.hasFreeExtraDesigns) {
          _showFreeUserLimitDialog();
          return;
        }
      } else {
        // For paid plans - use existing stripe service logic
        if (subscription != null && subscription.isDesignUsageAt80Percent) {
          _show80PercentWarningDialog(subscription);
          return;
        }

        bool canGenerate = await _stripeService.canGenerateDesign();
        if (!canGenerate) {
          _showLimitExceededDialog();
          return;
        }
      }
    }

    // Proceed with actual generation
    _proceedWithGeneration();
  }
  
  // Separate method for the actual generation logic
  void _proceedWithGeneration() async {
    // Store final details data in the design data service
    _saveFinalDetailsData();

    // Track final details completion
    final data = _dataService.getFinalDetailsData();
    final season = data['target_season'];
    PostHogAnalyticsService().trackFinalDetailsCompleted(
      season: season is List ? season.join(', ') : season?.toString() ?? '',
      budget: data['target_budget']?.toString() ?? '',
      values: data['desired_features']?.toString() ?? '',
    );

    // Force delete existing TechPackController to ensure fresh generation
    if (Get.isRegistered<TechPackController>()) {
      try {
        // Force delete even if it's permanent
        Get.delete<TechPackController>(force: true);
        print('Deleted existing TechPackController for fresh generation');
      } catch (e) {
        print('Error deleting TechPackController: $e');
      }
    }

    // Navigate to tech pack generation screen with edit mode data
    if (_isEditMode.value && _editingTechPack != null) {
      Get.toNamed('/generate_tech_pack', arguments: {
        'editMode': true,
        'techPackModel': _editingTechPack,
        'forceRegenerate': true,  // Add flag to force regeneration
      });
      
      final context = Get.context;
      final l10n = context != null ? AppLocalizations.of(context) : null;
      showAppSnackbar(
        l10n?.fdRegeneratingDesigns ?? 'Regenerating Designs!',
        l10n?.fdRegeneratingDesignsMessage ?? 'Creating a new design based on your updated preferences...',
        snackPosition: SnackPosition.TOP,
        backgroundColor:Colors.black,
        colorText: Colors.white,
        duration: const Duration(milliseconds: 1500),
      );
    } else {
      Get.toNamed('/generate_tech_pack', arguments: {
        'forceRegenerate': true,  // Add flag to force regeneration
      });

      final context = Get.context;
      final l10n = context != null ? AppLocalizations.of(context) : null;
      showAppSnackbar(
        l10n?.fdGeneratingDesigns ?? 'Generating Designs!',
        l10n?.fdGeneratingDesignsMessage ?? 'Creating your unique design based on your preferences...',
        snackPosition: SnackPosition.TOP,
        backgroundColor: Colors.black,
        colorText: Colors.white,
        duration: const Duration(milliseconds: 1500),
      );
    }
  }

  // Show 80% usage warning dialog
  void _show80PercentWarningDialog(subscription) async {
    final int usedCount = subscription.designsGeneratedThisMonth;
    final int totalCount = subscription.getTotalAllowedDesigns();
    // Check if user is on a paid plan (STARTER, PRO, or STUDIO)
    final bool isPaidUser = subscription.subscriptionPlan.startsWith('STARTER') ||
                           subscription.subscriptionPlan.startsWith('PRO') ||
                           subscription.subscriptionPlan.startsWith('STUDIO');

    Get.dialog(
      UsageWarningDialog(
        usedCount: usedCount,
        totalCount: totalCount,
        isDesign: true,
        isPaidUser: isPaidUser,
        designPriceString: _designPriceString,
        onGetExtraDesigns: () async {
          bool success = await _revenueCatService.purchaseExtraDesigns();
          if (success) {
            await _stripeService.incrementDesignUsage();
            Navigator.of(Get.overlayContext!).pop(); // Close the dialog
            _proceedWithGeneration();
          }
        },
        onContinue: () async {
          Navigator.of(Get.overlayContext!).pop();
          await _stripeService.incrementDesignUsage();
          _proceedWithGeneration();
        },
      ),
      barrierDismissible: false,
    );
  }

  // Show limit dialog for free users with option to purchase add-ons
  void _showFreeUserLimitDialog() {
    Get.dialog(
      FreeUserLimitDialog(
        onClose: () => Navigator.of(Get.overlayContext!).pop(),
        designPriceString: _designPriceString,
        onGetExtraDesigns: () async {
          bool success = await _revenueCatService.purchaseFreeExtraDesigns();
          if (success) {
            Navigator.of(Get.overlayContext!).pop();
            await _stripeService.incrementFreeExtraDesignUsage();
            _proceedWithGeneration();
          }
        },
      ),
      barrierDismissible: false,
    );
  }

  // Show limit exceeded dialog
  void _showLimitExceededDialog() async {
    // Get current subscription to check if user is paid
    final subscription = await _stripeService.getCurrentUserSubscription();
    final bool isPaidUser = subscription != null &&
                           (subscription.subscriptionPlan.startsWith('STARTER') ||
                            subscription.subscriptionPlan.startsWith('PRO') ||
                            subscription.subscriptionPlan.startsWith('STUDIO'));

    Get.dialog(
      LimitExceededDialog(
        isPaidUser: isPaidUser,
        designPriceString: _designPriceString,
        onGetExtraDesigns: () async {
          bool success = await _revenueCatService.purchaseExtraDesigns();
          if (success) {
            await _stripeService.incrementDesignUsage();
            Navigator.of(Get.overlayContext!).pop();
            _proceedWithGeneration();
          }
        },
        onMaybeLater: () {
          Navigator.of(Get.overlayContext!).pop();
        },
      ),
      barrierDismissible: false,
    );
  }
  
  void _saveFinalDetailsData() {
    // Convert answers to a format suitable for design generation
    Map<String, dynamic> finalDetailsData = {};
    
    for (var entry in _answers.entries) {
      String questionId = entry.key;
      BriefAnswer answer = entry.value;
      
      switch (questionId) {
        case 'target_season':
          finalDetailsData['season'] = answer.selectedOptions.join(', ');
          break;
        case 'target_budget':
          finalDetailsData['budget'] = answer.selectedOptions.isNotEmpty 
              ? answer.selectedOptions.first 
              : '';
          break;
        case 'desired_features':
          finalDetailsData['features'] = answer.selectedOptions.join(', ');
          if (answer.textInput?.isNotEmpty == true) {
            finalDetailsData['customFeatures'] = answer.textInput;
          }
          break;
        case 'additional_details':
          finalDetailsData['additionalDetails'] = answer.textInput ?? '';
          break;
      }
    }
    
    // Save to design data service
    _dataService.setFinalDetailsData(finalDetailsData);
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
    
    // Check if "Other: ?" is selected in desired_features
    final answer = _answers['desired_features'];
    bool hasSelectedOther = answer?.selectedOptions.contains('Other: ?') ?? false;
    
    // If we're on question 3 and "Other" is NOT selected, this is the last question - no animation
    if (questionIndex == 2 && !hasSelectedOther && answer?.selectedOptions.isNotEmpty == true) {
      return false;
    }
    
    // Show animation below the current unanswered question
    // This means animation shows below current question's answers, not after answering
    bool isCurrentQuestion = questionIndex == currentQuestionIndex;
    bool isNotLastQuestion = questionIndex < questions.length - 1;
    
    // Additional check: if on question 3 without "Other", it's effectively the last question
    if (isCurrentQuestion && questionIndex == 2 && !hasSelectedOther) {
      return false;
    }
    
    return isCurrentQuestion && isNotLastQuestion;
  }

  // Method to get number of questions to show in the list
  int get questionsToShow {
    // In edit mode, always show all relevant questions
    if (_isEditMode.value) {
      // Check if we should show question 4 in edit mode
      final answer = _answers['desired_features'];
      bool showQuestion4 = answer?.selectedOptions.contains('Other: ?') ?? false;
      final result = showQuestion4 ? 4 : 3;
      print('Edit mode questionsToShow: $result (showQuestion4: $showQuestion4)');
      return result;
    }
    
    // Always show questions up to the current one
    int baseQuestions = currentQuestionIndex >= 2 ? 3 : currentQuestionIndex + 1;
    
    // Check if we should show question 4
    final answer = _answers['desired_features'];
    bool showQuestion4 = answer?.selectedOptions.contains('Other: ?') ?? false;
    
    if (showQuestion4 && currentQuestionIndex >= 2) {
      return 4; // Show all 4 questions
    }
    
    return baseQuestions;
  }
  
  // Check if the 4th question should be shown based on 3rd question answer
  bool shouldShowFourthQuestion() {
    final answer = _answers['desired_features'];
    return answer?.selectedOptions.contains('Other: ?') ?? false;
  }
  
  // Reset all answers and go back to the first question
  void resetAllAnswers() {
    _answers.clear();
    _editingQuestions.clear();
    _currentQuestionIndex.value = 0;
    otherFeaturesController.clear();
    customInputController.clear();
    update();
  }

  // ==================== LOCALIZATION HELPER METHODS ====================

  /// Get localized question text
  String getLocalizedQuestionText(BuildContext context, String questionId) {
    final service = FinalDetailsLocalizationService(context);
    return service.getLocalizedQuestion(questionId);
  }

  /// Get localized option text (English -> Localized)
  String getLocalizedOption(BuildContext context, String englishOption) {
    final service = FinalDetailsLocalizationService(context);
    return service.getLocalizedOption(englishOption);
  }

  /// Get English option text (Localized -> English) - for API payloads
  String getEnglishOption(BuildContext context, String localizedOption) {
    final service = FinalDetailsLocalizationService(context);
    return service.getEnglishOption(localizedOption);
  }

  /// Get list of localized options
  List<String> getLocalizedOptions(BuildContext context, List<String> englishOptions) {
    final service = FinalDetailsLocalizationService(context);
    return service.getLocalizedOptions(englishOptions);
  }

}