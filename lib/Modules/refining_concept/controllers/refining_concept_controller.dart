import 'dart:async';
import 'package:atella/Data/Models/brief_questions_model.dart';
import 'package:atella/Data/Models/tech_pack_model.dart';
import 'package:atella/services/designservices/design_data_service.dart';
import 'package:atella/Modules/tech_pack/controllers/generate_tech_pack_controller.dart';
import 'package:atella/Modules/creative_brief/controllers/creative_brief_controller.dart';
import 'package:atella/services/PaymentService/stripe_subscription_service.dart';
import 'package:atella/services/PaymentService/revenuecat_service.dart';
import 'package:atella/services/firebase/services/design_quota_service.dart';
import 'package:atella/Modules/final_details/Views/Widgets/free_limit_dialog.dart';
import 'package:atella/Modules/final_details/Views/Widgets/limit_exceeded_dialog.dart';
import 'package:atella/Modules/final_details/Views/Widgets/usage_warning_dialog.dart';
import 'package:atella/services/analytics/posthog_analytics_service.dart';
import 'package:atella/services/localization/refining_concept_localization_service.dart';
import 'package:atella/services/internet_connectivity_checker.dart';
import 'package:atella/l10n/generated/app_localizations.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';

class RefiningConceptController extends GetxController {
  final DesignDataService _dataService = Get.find<DesignDataService>();
  final StripeSubscriptionService _stripeService = StripeSubscriptionService();
  final RevenueCatService _revenueCatService = RevenueCatService();
  final DesignQuotaService _quotaService = DesignQuotaService();
  final FirebaseAuth _auth = FirebaseAuth.instance;

  // Mapping of garment categories to visible special detail categories
  // Defines which special detail categories should be shown for each garment category
  static const Map<String, List<String>> _categoryToSpecialDetailsMapping = {
    'Tops': ['Necklines', 'Sleeves', 'Closures', 'Pockets', 'Finishes'],
    'Bottoms': ['Closures', 'Pockets', 'Waist', 'Legs', 'Finishes'],
    'Dresses': ['Necklines', 'Sleeves', 'Closures', 'Pockets', 'Waist', 'Finishes'],
    'Jumpsuits': ['Necklines', 'Sleeves', 'Closures', 'Pockets', 'Waist', 'Legs', 'Finishes'],
    'Outerwear': ['Necklines', 'Sleeves', 'Closures', 'Pockets', 'Finishes'],
    'Sportswear': ['Necklines', 'Sleeves', 'Closures', 'Pockets', 'Waist', 'Legs', 'Finishes'],
    'Accessories': ['Closures', 'Finishes'],
  };

  // Edit mode tracking
  final RxBool _isEditMode = false.obs;
  bool get isEditMode => _isEditMode.value;
  TechPackModel? _editingTechPack;
  TechPackModel? get editingTechPack => _editingTechPack;

  // Current question index
  final RxInt _currentQuestionIndex = 0.obs;
  int get currentQuestionIndex => _currentQuestionIndex.value;

  // Maximum question index that has ever been shown (to keep questions visible)
  final RxInt _maxQuestionIndexShown = 0.obs;
  int get maxQuestionIndexShown => _maxQuestionIndexShown.value;

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

  // Custom controllers for categorized questions
  final specificFeaturesCustomController =
      TextEditingController(); // For specific_features custom

  // Loading state for text input
  final RxBool _isTextLoading = false.obs;
  bool get isTextLoading => _isTextLoading.value;

  // Track which question has custom selected
  final RxString _customSelectedForQuestion = ''.obs;
  String get customSelectedForQuestion => _customSelectedForQuestion.value;

  // Track which category has custom selected for categorized questions
  // Format: "questionId:categoryName" e.g., "specific_features:Necklines"
  final RxString _customSelectedForCategory = ''.obs;
  String get customSelectedForCategory => _customSelectedForCategory.value;

  // Track temporary selections before they are confirmed
  final RxMap<String, String> _tempSelections = <String, String>{}.obs;
  Map<String, String> get tempSelections => _tempSelections;
  // Temporary multi-selections for allowMultiple questions
  final RxSet<String> _tempMultiSelections = <String>{}.obs;
  RxSet<String> get tempMultiSelections => _tempMultiSelections;
  Timer? _multiSelectDebounce;
  // Temporary categorized selections: one option per category (for categorized questions)
  final RxMap<String, String> _tempCategorizedSelections =
      <String, String>{}.obs;
  Timer? _categorizedDebounce;

  // Editing state for text questions
  final RxSet<String> _editingQuestions = <String>{}.obs;
  Set<String> get editingQuestions => _editingQuestions;

  // Track expanded/collapsed state for chip sections
  final RxMap<String, bool> _expandedCategories = <String, bool>{}.obs;
  Map<String, bool> get expandedCategories => _expandedCategories;

  // Toggle category expansion
  void toggleCategory(String categoryKey) {
    _expandedCategories[categoryKey] =
        !(_expandedCategories[categoryKey] ?? false);
    update();
  }

  // Expand category
  void expandCategory(String categoryKey) {
    _expandedCategories[categoryKey] = true;
    update();
  }

  // Collapse category
  void collapseCategory(String categoryKey) {
    _expandedCategories[categoryKey] = false;
    update();
  }

  /// Get the garment category from creative brief data
  /// Extracts the category part from "Category:GarmentType" format (e.g., "Tops:T-shirt" -> "Tops")
  String _getGarmentCategoryFromCreativeBrief() {
    try {
      // Try to get creative brief controller if registered
      if (Get.isRegistered<CreativeBriefController>()) {
        final creativeBriefController = Get.find<CreativeBriefController>();
        final answer = creativeBriefController.answers['garment_type'];

        if (answer != null && answer.selectedOptions.isNotEmpty) {
          final garmentType = answer.selectedOptions.first;

          // Extract category from "Category:GarmentType" format
          if (garmentType.contains(':')) {
            final parts = garmentType.split(':');
            if (parts.isNotEmpty) {
              final category = parts[0].trim();
              debugPrint('🎯 Extracted garment category: "$category" from "$garmentType"');
              return category;
            }
          }
        }
      }
    } catch (e) {
      debugPrint('⚠️ Error getting garment category from creative brief: $e');
    }

    // Return empty string if no category found
    return '';
  }

  /// Get filtered categories for special details question based on garment category
  /// Returns only the categories that are relevant for the selected garment type
  Map<String, List<String>> getFilteredSpecialDetailsCategories(
    Map<String, List<String>> allCategories,
  ) {
    final garmentCategory = _getGarmentCategoryFromCreativeBrief();

    // If no garment category found, return all categories (fallback)
    if (garmentCategory.isEmpty) {
      debugPrint('ℹ️ No garment category found, showing all special detail categories');
      return allCategories;
    }

    // Get the allowed categories for this garment category
    final allowedCategories = _categoryToSpecialDetailsMapping[garmentCategory];

    if (allowedCategories == null || allowedCategories.isEmpty) {
      debugPrint('⚠️ No mapping found for garment category: "$garmentCategory", showing all');
      return allCategories;
    }

    // Filter the categories map to only include allowed categories
    final filteredCategories = <String, List<String>>{};
    for (final categoryName in allowedCategories) {
      if (allCategories.containsKey(categoryName)) {
        filteredCategories[categoryName] = allCategories[categoryName]!;
      }
    }

    debugPrint('✅ Filtered special details for "$garmentCategory": ${filteredCategories.keys.toList()}');
    debugPrint('   Hidden categories: ${allCategories.keys.where((k) => !filteredCategories.containsKey(k)).toList()}');

    return filteredCategories;
  }

  // Questions data - chip questions only, no text type questions in this flow
  final List<BriefQuestion> questions = [
    BriefQuestion(
      id: 'garment_type',
      question: 'What fit are you aiming for? (multiple selection) 📏',
      type: 'chips',
      options: [
        'Slim',
        'Oversized',
        'Regular',
        'Straight',
        'Fitted',
        'Tailored',
        'Cropped',
        'Relaxed',
        'Long',
        'Custom',
      ],
      allowMultiple: true,
    ),
    BriefQuestion(
      id: 'specific_features',
      question: 'Do you want to add special details? (multiple selection) ✂️',
      type: 'chips_categorized',
      options: [],
      categories: {
        'Necklines': [
          'Crew',
          'V-neck',
          'Square',
          'Half-shoulder',
          'Scoop',
          'Boat neck',
          'Custom',
        ],
        'Sleeves': [
          'Sleeveless',
          'Short ¾',
          'Long',
          'Puff',
          'Raglan',
          'Cap',
          'Custom',
        ],
        'Closures': [
          'Zipper (metal/plastic/invisible)',
          'Buttons',
          'Hooks',
          'Velcro',
          'Snaps',
          'Custom',
        ],
        'Pockets': ['Patch', 'Welt', 'Flap', 'Hidden', 'Cargo', 'Custom'],
        'Waist': [
          'Elastic',
          'High-waist',
          'Low-rise',
          'Belted',
          'Drawstring',
          'Custom',
        ],
        'Legs': [
          'Straight leg',
          'Tapered',
          'Wide leg',
          'Bootcut',
          'Flared',
          'Custom',
        ],
        'Finishes': [
          'Lining',
          'Topstitching',
          'Embroidery',
          'Lace',
          'Sequins',
          'Appliqués',
          'Custom',
        ],
      },
    ),
    BriefQuestion(
      id: 'seasonal_constraint',
      question: 'Is there a seasonal constraint? 🌤️',
      type: 'chips',
      options: ['Summer', 'Mid-Season', 'All-Season', 'Custom'],
    ),
    BriefQuestion(
      id: 'target_budget',
      question: 'What is your target budget per piece? 💵',
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
          'Would you like to include any specific functionalities or values? 🧶',
      type: 'chips',
      options: [
        'Organic Fabric',
        'Locally Made',
        'Upcycled',
        'UV Protection',
        'Quick-Dry',
        'Wrinkle-Free',
        'Custom',
      ],
    ),
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
    print('=== REFINING CONCEPT EDIT MODE CHECK ===');
    print('Arguments received: $arguments');

    if (arguments != null && arguments is Map<String, dynamic>) {
      // Check for "edit current session" mode (from generate_tech_pack screen)
      final editCurrentSession = arguments['editCurrentSession'] == true;
      final preserveAnswers = arguments['preserveAnswers'] == true;

      // Check for "edit existing tech pack" mode (from preview screen)
      final isEditMode = arguments['editMode'] == true;

      print('Edit current session flag: $editCurrentSession');
      print('Preserve answers flag: $preserveAnswers');
      print('Edit mode detected: $isEditMode');

      if (editCurrentSession || preserveAnswers) {
        // User wants to edit the current session - DON'T reset answers
        print('🟢 EDITING CURRENT SESSION - Preserving existing answers');
        // Answers are already in memory, no need to reload
      } else if (isEditMode) {
        print('🟢 ENTERING EDIT MODE (from saved tech pack)');
        _isEditMode.value = true;
        _editingTechPack = arguments['techPackModel'] as TechPackModel?;
        _loadExistingRefinedConceptData();
      } else {
        print('🔴 NORMAL MODE - Fresh start');
      }
    }
  }

  void _loadExistingRefinedConceptData() {
    // Get data from design data service (loaded in creative brief)
    final refinedConceptData = _dataService.getRefinedConceptData();
    print('Loading refined concept data: $refinedConceptData');

    if (refinedConceptData.isNotEmpty) {
      // Load chip-based answers
      final garmentType =
          refinedConceptData['garment_type'] as String? ??
          refinedConceptData['silhouette'] as String? ??
          '';
      final customSilhouette =
          refinedConceptData['custom_garment_type'] as String? ??
          refinedConceptData['customSilhouette'] as String? ??
          '';
      if (garmentType.isNotEmpty || customSilhouette.isNotEmpty) {
        final List<String> selections = garmentType
            .split(',')
            .map((e) => e.trim())
            .where((e) => e.isNotEmpty)
            .toList();
        if (customSilhouette.isNotEmpty &&
            !selections.contains('Custom') &&
            !selections.any((opt) => opt.endsWith(':Custom'))) {
          selections.add('Custom');
        }
        if (selections.isEmpty && customSilhouette.isNotEmpty) {
          selections.add('Custom');
        }
        String formattedCustomSilhouette = customSilhouette;
        if (formattedCustomSilhouette.isNotEmpty &&
            !formattedCustomSilhouette.contains(':')) {
          final prefixedSelection = selections.firstWhere(
            (opt) => opt.contains(':Custom'),
            orElse: () => '',
          );
          if (prefixedSelection.isNotEmpty) {
            final categoryName = prefixedSelection.split(':').first;
            formattedCustomSilhouette =
                '$categoryName:$formattedCustomSilhouette';
          }
        }
        final String? silhouetteText = formattedCustomSilhouette.isNotEmpty
            ? formattedCustomSilhouette
            : null;
        _answers['garment_type'] = BriefAnswer(
          questionId: 'garment_type',
          selectedOptions: selections,
          textInput: silhouetteText,
        );
      }

      final specificFeatures =
          refinedConceptData['specific_features'] as String? ??
          refinedConceptData['features'] as String? ??
          '';
      final customFeatures =
          refinedConceptData['custom_specific_features'] as String? ??
          refinedConceptData['customFeatures'] as String? ??
          '';
      if (specificFeatures.isNotEmpty || customFeatures.isNotEmpty) {
        final multi = specificFeatures
            .split(',')
            .map((e) => e.trim())
            .where((e) => e.isNotEmpty)
            .toList();
        String formattedCustomFeatures = customFeatures;
        if (formattedCustomFeatures.isNotEmpty &&
            !formattedCustomFeatures.contains('|||') &&
            !formattedCustomFeatures.contains(':')) {
          final prefixedSelections = multi
              .where((opt) => opt.contains(':Custom'))
              .toList();
          if (prefixedSelections.isNotEmpty) {
            final category = prefixedSelections.first.split(':').first;
            formattedCustomFeatures = '$category:$formattedCustomFeatures';
          }
        }
        final String? featuresText = formattedCustomFeatures.isNotEmpty
            ? formattedCustomFeatures
            : null;
        _answers['specific_features'] = BriefAnswer(
          questionId: 'specific_features',
          selectedOptions: multi,
          textInput: featuresText,
        );
      }

      final seasonalConstraint =
          refinedConceptData['seasonal_constraint'] as String? ??
          refinedConceptData['season'] as String? ??
          '';
      final customSeason =
          refinedConceptData['custom_season'] as String? ??
          refinedConceptData['customSeason'] as String? ??
          '';
      if (seasonalConstraint.isNotEmpty || customSeason.isNotEmpty) {
        final List<String> selections = [];
        if (seasonalConstraint.isNotEmpty) {
          selections.add(seasonalConstraint);
        }
        if (selections.isEmpty && customSeason.isNotEmpty) {
          selections.add('Custom');
        }
        _answers['seasonal_constraint'] = BriefAnswer(
          questionId: 'seasonal_constraint',
          selectedOptions: selections,
          textInput: customSeason.isNotEmpty ? customSeason : null,
        );
      }

      final targetBudget =
          refinedConceptData['target_budget'] as String? ??
          refinedConceptData['budget'] as String? ??
          '';
      final customBudget =
          refinedConceptData['custom_budget'] as String? ??
          refinedConceptData['customBudget'] as String? ??
          '';
      if (targetBudget.isNotEmpty || customBudget.isNotEmpty) {
        final List<String> selections = [];
        if (targetBudget.isNotEmpty) {
          selections.add(targetBudget);
        }
        if (selections.isEmpty && customBudget.isNotEmpty) {
          selections.add('Custom');
        }
        _answers['target_budget'] = BriefAnswer(
          questionId: 'target_budget',
          selectedOptions: selections,
          textInput: customBudget.isNotEmpty ? customBudget : null,
        );
      }

      final functionalitiesValues =
          refinedConceptData['functionalities_values'] as String? ??
          refinedConceptData['values'] as String? ??
          '';
      final customValues =
          refinedConceptData['custom_functionalities_values'] as String? ??
          refinedConceptData['customValues'] as String? ??
          '';
      if (functionalitiesValues.isNotEmpty || customValues.isNotEmpty) {
        final List<String> selections = [];
        if (functionalitiesValues.isNotEmpty) {
          selections.add(functionalitiesValues);
        }
        if (selections.isEmpty && customValues.isNotEmpty) {
          selections.add('Custom');
        }
        _answers['functionalities_values'] = BriefAnswer(
          questionId: 'functionalities_values',
          selectedOptions: selections,
          textInput: customValues.isNotEmpty ? customValues : null,
        );
      }

      // In edit mode, show all questions
      _currentQuestionIndex.value = questions.length - 1;
      _maxQuestionIndexShown.value =
          questions.length - 1; // Set max to show all questions

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
    specificFeaturesCustomController.dispose();
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
    // Get localized "Today" text
    final context = Get.context;
    final todayText = context != null
        ? AppLocalizations.of(context)?.rcToday ?? 'Today'
        : 'Today';
    _currentTime.value = '$todayText, $timeString';
  }

  BriefQuestion get currentQuestion => questions[currentQuestionIndex];

  // Check if option is selected including custom selection and temporary selections
  bool isOptionSelected(String option, {String? forQuestionId}) {
    final questionId = forQuestionId ?? currentQuestion.id;

    // Special handling for Custom option
    if (option == 'Custom') {
      // Check if custom is currently selected for this question (not answered yet)
      if (_customSelectedForQuestion.value == questionId) {
        return true;
      }
      // Check if custom answer is already submitted
      final answer = _answers[questionId];
      return answer?.selectedOptions.contains(option) ?? false;
    }

    // Get the question to check its properties
    final question = questions.firstWhere(
      (q) => q.id == questionId,
      orElse: () => currentQuestion,
    );

    // For multi-select questions, reflect temporary multi selections before confirmation
    if (question.allowMultiple &&
        !isQuestionAnswered(questionId) &&
        questionId == currentQuestion.id) {
      return _tempMultiSelections.contains(option);
    }
    // For categorized questions, reflect temporary per-category selections
    if (question.type == 'chips_categorized' &&
        !isQuestionAnswered(questionId) &&
        questionId == currentQuestion.id) {
      return _tempCategorizedSelections.values.contains(option);
    }

    // Check temporary selection first (for unanswered question)
    if (!isQuestionAnswered(questionId)) {
      return _tempSelections[questionId] == option;
    }

    // For answered questions, check final answer
    final answer = _answers[questionId];
    return answer?.selectedOptions.contains(option) ?? false;
  }

  // Check if custom is selected for current question
  bool isCustomSelectedForCurrentQuestion() {
    final result = _customSelectedForQuestion.value == currentQuestion.id;
    print(
      'isCustomSelectedForCurrentQuestion called: $_customSelectedForQuestion.value == ${currentQuestion.id} = $result',
    ); // Debug
    return result;
  }

  // Check if custom is selected for a specific category
  bool isCustomSelectedForCategory(String questionId, String categoryName) {
    return _customSelectedForCategory.value == '$questionId:$categoryName';
  }

  // Get the category name for which custom is selected (if any)
  String? getCustomSelectedCategory(String questionId) {
    final customCategory = _customSelectedForCategory.value;
    if (customCategory.startsWith('$questionId:')) {
      return customCategory.substring('$questionId:'.length);
    }
    return null;
  }

  // Get custom selected info for ANY question (returns Map with questionId and categoryName)
  Map<String, String>? getAnyCustomSelectedCategory() {
    final customCategory = _customSelectedForCategory.value;
    if (customCategory.isNotEmpty && customCategory.contains(':')) {
      final parts = customCategory.split(':');
      if (parts.length == 2) {
        return {'questionId': parts[0], 'categoryName': parts[1]};
      }
    }
    return null;
  }

  // Get custom selected question ID for ANY regular chip question (not just current)
  String? getAnyCustomSelectedQuestion() {
    if (_customSelectedForQuestion.value.isNotEmpty) {
      return _customSelectedForQuestion.value;
    }
    return null;
  }

  String? getTempSelectionForCategory(String categoryName) {
    return _tempCategorizedSelections[categoryName];
  }

  void selectOption(String option, {String? forQuestionId}) async {
    final questionId = forQuestionId ?? currentQuestion.id;
    print('Selecting option: $option for question: $questionId'); // Debug

    // Get the question
    final question = questions.firstWhere(
      (q) => q.id == questionId,
      orElse: () => currentQuestion,
    );

    // Check if this option is already selected (for deselection)
    final isAlreadySelected =
        _tempSelections[questionId] == option ||
        (_answers.containsKey(questionId) &&
            _answers[questionId]!.selectedOptions.contains(option));

    // If "Custom" is selected
    if (option == 'Custom') {
      print('Custom selected for question: $questionId'); // Debug

      // Check if custom is already selected - if so, deselect it
      final isCustomAlreadySelected =
          _customSelectedForQuestion.value == questionId;

      if (isCustomAlreadySelected) {
        // DESELECT CUSTOM
        print('Deselecting Custom for question: $questionId');
        _customSelectedForQuestion.value = '';
        customController.clear();
        update();
        return;
      }

      // SELECT CUSTOM
      _customSelectedForQuestion.value = questionId;

      // Clear any temporary selection
      _tempSelections.remove(questionId);

      // Navigate to the question if it's not the current one
      if (questionId != currentQuestion.id) {
        final questionIndex = questions.indexWhere((q) => q.id == questionId);
        if (questionIndex != -1) {
          _currentQuestionIndex.value = questionIndex;
        }
      }

      update();
      return; // Don't advance to next question yet
    }

    // Handle multi-select questions: toggle selection and debounce confirm
    if (question.allowMultiple) {
      // If this is an already-answered question being edited, load existing answers first
      if (isQuestionAnswered(questionId) && _tempMultiSelections.isEmpty) {
        final existingAnswer = _answers[questionId];
        if (existingAnswer != null) {
          _tempMultiSelections.addAll(existingAnswer.selectedOptions);
          print(
            'Loaded existing multi-select answers for editing: ${existingAnswer.selectedOptions}',
          );
        }
      }

      // Toggle option in temp multi selections
      if (_tempMultiSelections.contains(option)) {
        _tempMultiSelections.remove(option);
      } else {
        _tempMultiSelections.add(option);
        // When a regular option is selected, remove "Custom" from selections and clear custom text
        if (_tempMultiSelections.contains('Custom')) {
          _tempMultiSelections.remove('Custom');
          // Also clear custom selection state and controller
          if (_customSelectedForQuestion.value == questionId) {
            _customSelectedForQuestion.value = '';
            customController.clear();
          }
          // Remove custom text from the answer if it exists
          final existingAnswer = _answers[questionId];
          if (existingAnswer != null && existingAnswer.textInput != null) {
            _answers[questionId] = BriefAnswer(
              questionId: questionId,
              selectedOptions: existingAnswer.selectedOptions
                  .where((opt) => opt != 'Custom')
                  .toList(),
              textInput: null, // Clear custom text
            );
          }
        }
      }

      // Collapse the section immediately after selection (like creative brief)
      collapseCategory(questionId);

      update();

      // If question is already answered, update immediately (no delay for edits)
      if (isQuestionAnswered(questionId)) {
        print('Updating already answered multi-select question immediately');
        _confirmMultiSelection(
          shouldAdvance: false,
          forQuestionId: questionId,
        ); // Don't advance when editing
      } else {
        // For new answers, debounce auto-confirmation (2 seconds like creative brief)
        _multiSelectDebounce?.cancel();
        final capturedQuestionId =
            questionId; // Capture in local variable for closure
        _multiSelectDebounce = Timer(const Duration(milliseconds: 2000), () {
          if (_tempMultiSelections.isNotEmpty &&
              !isQuestionAnswered(capturedQuestionId)) {
            _confirmMultiSelection(
              shouldAdvance: true,
              forQuestionId: capturedQuestionId,
            ); // Advance for new answers
          }
        });
      }
      return;
    }

    // For non-custom options (single select), check if clicking to deselect
    if (isAlreadySelected) {
      print('Deselecting option: $option for question: $questionId');

      // Remove temporary selection
      _tempSelections.remove(questionId);

      // Remove final answer if it exists
      _answers.remove(questionId);

      update();
      return; // Don't advance, just deselect
    }

    // For non-custom options, store as temporary selection
    _tempSelections[questionId] = option;

    // Clear custom selection if user selects a different option
    if (_customSelectedForQuestion.value == questionId) {
      _customSelectedForQuestion.value = '';
    }

    // Collapse the section immediately after selection (like creative brief)
    collapseCategory(questionId);

    // Update the UI
    update();

    // If question is already answered, update the answer immediately (no delay for edits)
    if (isQuestionAnswered(questionId)) {
      print('Updating already answered question immediately: $questionId');
      _confirmCurrentSelection(
        forQuestionId: questionId,
        shouldAdvance: false,
      ); // Don't advance when editing
    } else {
      // Auto-advance to next question after delay for new answers (2 seconds like creative brief)
      await Future.delayed(const Duration(milliseconds: 2000));
      // Check if the selection is still the same (user hasn't changed it)
      if (_tempSelections[questionId] == option) {
        _confirmCurrentSelection(
          forQuestionId: questionId,
          shouldAdvance: true,
        ); // Advance for new answers
      }
    }
  }

  // Confirm multi-select temp selections into final answer and advance
  void _confirmMultiSelection({
    bool shouldAdvance = true,
    String? forQuestionId,
  }) {
    if (_tempMultiSelections.isEmpty) return;

    final confirmedQuestionId = forQuestionId ?? currentQuestion.id;

    // Get existing answer to check for custom text
    final existingAnswer = _answers[confirmedQuestionId];

    // Determine if we should keep custom text
    // Only keep if "Custom" is in the selections
    final shouldKeepCustomText = _tempMultiSelections.contains('Custom');
    final customText = shouldKeepCustomText ? existingAnswer?.textInput : null;

    // Save all selected options
    _answers[confirmedQuestionId] = BriefAnswer(
      questionId: confirmedQuestionId,
      selectedOptions: _tempMultiSelections.toList(),
      textInput: customText, // Only include custom text if "Custom" is selected
    );
    _tempMultiSelections.clear();
    _answers.refresh();

    // Update max question index to ensure next question becomes visible
    final questionIndex = questions.indexWhere(
      (q) => q.id == confirmedQuestionId,
    );
    if (questionIndex != -1 && questionIndex >= _maxQuestionIndexShown.value) {
      // Show the next question by updating max index
      final nextIndex = questionIndex + 1;
      if (nextIndex < questions.length &&
          nextIndex > _maxQuestionIndexShown.value) {
        _maxQuestionIndexShown.value = nextIndex;
      }
    }

    update();

    // Only advance to next question if this is a new answer (not editing)
    if (shouldAdvance) {
      _nextQuestion();
    }
  }

  // Handle categorized selection (one per category, multiple categories allowed)
  void selectCategorizedOption(
    String questionId,
    String category,
    String option,
  ) {
    if (questionId == 'specific_features') {
      print('=== SELECTING CATEGORIZED OPTION ===');
      print('Question: $questionId');
      print('Category: $category');
      print('Option: $option');
      print('Current temp selections: $_tempCategorizedSelections');
      print('Current answer: ${_answers[questionId]}');
    }

    if (currentQuestion.id != questionId) {
      final qIndex = questions.indexWhere((q) => q.id == questionId);
      if (qIndex != -1) {
        _currentQuestionIndex.value = qIndex;
      }
    }

    // If "Custom" is selected, show text field
    if (option == 'Custom') {
      print('Custom selected for question: $questionId, category: $category');
      _customSelectedForCategory.value = '$questionId:$category';
      // Clear any temporary selection for this category
      _tempCategorizedSelections.remove(category);
      update();
      return; // Don't auto-confirm yet, wait for custom text input
    }

    // Clear custom selection if user selects a different option
    if (_customSelectedForCategory.value == '$questionId:$category') {
      _customSelectedForCategory.value = '';
    }

    // Check if clicking on the same option (deselection)
    final isSameOptionSelected = _tempCategorizedSelections[category] == option;

    // Also check if this option exists in the final answer
    final existingAnswer = _answers[questionId];
    final isInFinalAnswer =
        existingAnswer?.selectedOptions.any(
          (opt) => opt == '$category:$option' || opt == option,
        ) ??
        false;

    if (questionId == 'specific_features') {
      print('Is same option selected: $isSameOptionSelected');
      print('Is in final answer: $isInFinalAnswer');
    }

    if (isSameOptionSelected || isInFinalAnswer) {
      // DESELECTION: User is clicking on already selected option
      if (questionId == 'specific_features') {
        print('DESELECTING option');
      }
      _categorizedDebounce?.cancel();

      // Remove from temp selections
      _tempCategorizedSelections.remove(category);

      // Also remove from final answer if it exists
      if (existingAnswer != null) {
        List<String> updatedOptions = existingAnswer.selectedOptions.toList();
        updatedOptions.removeWhere(
          (opt) => opt == option || opt == '$category:$option',
        );

        if (questionId == 'specific_features') {
          print('Updated options after deselection: $updatedOptions');
        }

        if (updatedOptions.isEmpty) {
          // If no selections remain, remove the entire answer
          _answers.remove(questionId);
        } else {
          // Update answer with remaining selections
          _answers[questionId] = BriefAnswer(
            questionId: questionId,
            selectedOptions: updatedOptions,
            textInput: existingAnswer.textInput,
          );
        }
        _answers.refresh();
      }

      // Collapse and update UI
      final categoryKey = '${questionId}_$category';
      collapseCategory(categoryKey);
      update();

      // Don't schedule any new timers for deselection
      return;
    } else {
      // SELECTION: Set the new temp selection
      if (questionId == 'specific_features') {
        print('SELECTING option - adding to temp');
      }
      _tempCategorizedSelections[category] = option;
    }

    // Collapse the category section immediately after selection (like creative brief)
    final categoryKey = '${questionId}_$category';
    collapseCategory(categoryKey);

    update();

    // Check if this is an already answered question being edited
    if (isQuestionAnswered(questionId) &&
        _tempCategorizedSelections.isNotEmpty) {
      // For editing existing answers, update immediately (no debounce)
      _categorizedDebounce?.cancel();
      _confirmCategorizedSelections(questionId);
    } else if (_tempCategorizedSelections.isNotEmpty) {
      // Debounce confirmation for new selections (2 seconds)
      _categorizedDebounce?.cancel();
      _categorizedDebounce = Timer(const Duration(milliseconds: 2000), () {
        if (_tempCategorizedSelections.isNotEmpty) {
          _confirmCategorizedSelections(questionId);
        }
      });
    }
  }

  void _confirmCategorizedSelections(String questionId) {
    if (_tempCategorizedSelections.isEmpty) return;

    if (questionId == 'specific_features') {
      print('=== CONFIRMING CATEGORIZED SELECTIONS ===');
      print('Question: $questionId');
      print('Temp selections to confirm: $_tempCategorizedSelections');
    }

    // Get existing answer to preserve custom selections
    final existingAnswer = _answers[questionId];
    List<String> selectedOptions =
        existingAnswer?.selectedOptions.toList() ?? [];
    String? customText = existingAnswer?.textInput;

    if (questionId == 'specific_features') {
      print('Existing selectedOptions: $selectedOptions');
      print('Existing customText: $customText');
    }

    // Parse existing custom texts to clean up when switching to regular options
    Map<String, String> customTexts = {};
    if (customText != null && customText.contains('|||')) {
      final parts = customText.split('|||');
      for (var part in parts) {
        if (part.contains(':')) {
          final keyValue = part.split(':');
          if (keyValue.length >= 2) {
            customTexts[keyValue[0]] = keyValue.sublist(1).join(':');
          }
        }
      }
    } else if (customText != null &&
        customText.isNotEmpty &&
        customText.contains(':')) {
      // Single custom text format
      final separatorIndex = customText.indexOf(':');
      final key = customText.substring(0, separatorIndex);
      final value = customText.substring(separatorIndex + 1);
      customTexts[key] = value;
    }

    if (questionId == 'specific_features') {
      print('Parsed customTexts: $customTexts');
    }

    // Add new selections with category prefix format: "categoryName:optionName"
    // This allows us to track which category each option belongs to
    for (var entry in _tempCategorizedSelections.entries) {
      // Remove any existing option for this category (both with and without prefix)
      selectedOptions.removeWhere(
        (opt) => opt == entry.value || opt.startsWith('${entry.key}:'),
      );
      // Add the new selection with category prefix
      selectedOptions.add('${entry.key}:${entry.value}');

      // Remove custom text for this category if switching to a regular option
      customTexts.remove(entry.key);
    }

    // Reconstruct custom text string
    final customTextString = customTexts.entries
        .map((e) => '${e.key}:${e.value}')
        .join('|||');

    if (questionId == 'specific_features') {
      print('Final selectedOptions: $selectedOptions');
      print('Final customTextString: $customTextString');
    }

    _answers[questionId] = BriefAnswer(
      questionId: questionId,
      selectedOptions: selectedOptions,
      textInput: customTextString.isNotEmpty ? customTextString : null,
    );
    _tempCategorizedSelections.clear();
    _answers.refresh();

    // Update max question index to ensure next question becomes visible
    final questionIndex = questions.indexWhere((q) => q.id == questionId);
    if (questionIndex != -1 && questionIndex >= _maxQuestionIndexShown.value) {
      // Show the next question by updating max index
      final nextIndex = questionIndex + 1;
      if (nextIndex < questions.length &&
          nextIndex > _maxQuestionIndexShown.value) {
        _maxQuestionIndexShown.value = nextIndex;
      }
    }

    update();

    _nextQuestion();
  }

  // Method to confirm current selection and advance
  void _confirmCurrentSelection({
    String? forQuestionId,
    bool shouldAdvance = true,
  }) {
    final confirmedQuestionId = forQuestionId ?? currentQuestion.id;
    final tempSelection = _tempSelections[confirmedQuestionId];
    if (tempSelection != null) {
      // Create final answer
      _answers[confirmedQuestionId] = BriefAnswer(
        questionId: confirmedQuestionId,
        selectedOptions: [tempSelection],
      );

      // Clear temporary selection
      _tempSelections.remove(confirmedQuestionId);

      // Update max question index to ensure next question becomes visible
      final questionIndex = questions.indexWhere(
        (q) => q.id == confirmedQuestionId,
      );
      if (questionIndex != -1 &&
          questionIndex >= _maxQuestionIndexShown.value) {
        // Show the next question by updating max index
        final nextIndex = questionIndex + 1;
        if (nextIndex < questions.length &&
            nextIndex > _maxQuestionIndexShown.value) {
          _maxQuestionIndexShown.value = nextIndex;
        }
      }

      update();

      // Only advance to next question if this is a new answer (not editing)
      if (shouldAdvance) {
        _nextQuestion();
      }
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

  // Edit existing custom answer - reload text for editing
  void editCustomAnswer(String questionId, String existingText) {
    // Load the custom text into the controller
    customController.text = existingText;

    // Mark custom as selected for this question
    _customSelectedForQuestion.value = questionId;

    // Remove the answer so it can be re-submitted
    _answers.remove(questionId);

    // Navigate to the question if needed
    final questionIndex = questions.indexWhere((q) => q.id == questionId);
    if (questionIndex != -1) {
      _currentQuestionIndex.value = questionIndex;
    }

    update();
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

  // Edit existing categorized custom answer - reload text for editing
  void editCategorizedCustomAnswer(
    String questionId,
    String categoryName,
    String existingText,
    TextEditingController controller,
  ) {
    print('=== EDITING CATEGORIZED CUSTOM ANSWER ===');
    print('Question ID: $questionId');
    print('Category: $categoryName');
    print('Existing Text: $existingText');

    // Load the custom text into the provided controller
    controller.text = existingText;

    // Mark custom as selected for this category
    _customSelectedForCategory.value = '$questionId:$categoryName';

    // Get existing answer
    final existingAnswer = _answers[questionId];
    if (existingAnswer != null) {
      print('Current answer before edit: ${existingAnswer.selectedOptions}');
      print('Current textInput before edit: ${existingAnswer.textInput}');

      // Remove the custom option for this category from selectedOptions
      // so it can be re-submitted
      List<String> updatedOptions = existingAnswer.selectedOptions
          .where((opt) => !opt.startsWith('$categoryName:'))
          .toList();

      // Also remove this category's custom text from textInput
      String? customText = existingAnswer.textInput;
      Map<String, String> customTexts = {};

      // Parse existing custom texts - handle both single and multiple entries
      if (customText != null && customText.isNotEmpty) {
        if (customText.contains('|||')) {
          // Multiple custom texts
          final parts = customText.split('|||');
          for (var part in parts) {
            if (part.contains(':')) {
              final keyValue = part.split(':');
              if (keyValue.length >= 2 && keyValue[0] != categoryName) {
                customTexts[keyValue[0]] = keyValue.sublist(1).join(':');
              }
            }
          }
        } else if (customText.contains(':')) {
          // Single custom text
          final separatorIndex = customText.indexOf(':');
          final key = customText.substring(0, separatorIndex);
          final value = customText.substring(separatorIndex + 1);
          // Only keep it if it's not the category being edited
          if (key != categoryName) {
            customTexts[key] = value;
          }
        }
      }

      final customTextString = customTexts.entries
          .map((e) => '${e.key}:${e.value}')
          .join('|||');

      print('Updated selectedOptions: $updatedOptions');
      print('Updated textInput: $customTextString');

      // Update answer without this category's custom
      _answers[questionId] = BriefAnswer(
        questionId: questionId,
        selectedOptions: updatedOptions,
        textInput: customTextString.isNotEmpty ? customTextString : null,
      );
    }

    // Navigate to the question if needed
    final questionIndex = questions.indexWhere((q) => q.id == questionId);
    if (questionIndex != -1) {
      _currentQuestionIndex.value = questionIndex;
    }

    print('Edit mode activated for $categoryName');
    update();
  }

  // Submit custom answer for categorized questions (specific_features)
  void submitCategorizedCustomAnswer(
    String questionId,
    String categoryName,
    TextEditingController controller,
  ) async {
    print('=== SUBMITTING CATEGORIZED CUSTOM ANSWER ===');
    print('Question ID: $questionId');
    print('Category: $categoryName');
    print('Custom Text: ${controller.text}');

    if (controller.text.trim().isEmpty) {
      return;
    }

    _isTextLoading.value = true;
    update();

    // Simulate processing
    await Future.delayed(const Duration(milliseconds: 800));

    // Get existing answer or create new one
    final existingAnswer = _answers[questionId];
    List<String> selectedOptions =
        existingAnswer?.selectedOptions.toList() ?? [];

    print('Existing selectedOptions before: $selectedOptions');
    print('Existing textInput before: ${existingAnswer?.textInput}');

    // Remove any existing option for this category (if it exists)
    // For categorized questions, we store options as "categoryName:optionName" or "categoryName:Custom"
    selectedOptions.removeWhere((opt) => opt.startsWith('$categoryName:'));

    // Add the custom option with format "categoryName:Custom"
    selectedOptions.add('$categoryName:Custom');

    // Store custom text - we'll use a special format to store custom text per category
    // Format: "category1:customText|||category2:customText" or just store in textInput
    String? customText = existingAnswer?.textInput;
    Map<String, String> customTexts = {};

    // Parse existing custom texts if they exist (format: "category1:text1|||category2:text2")
    if (customText != null && customText.isNotEmpty) {
      if (customText.contains('|||')) {
        // Multiple custom texts
        final parts = customText.split('|||');
        for (var part in parts) {
          if (part.contains(':')) {
            final keyValue = part.split(':');
            if (keyValue.length >= 2) {
              customTexts[keyValue[0]] = keyValue.sublist(1).join(':');
            }
          }
        }
      } else if (customText.contains(':')) {
        // Single custom text
        final separatorIndex = customText.indexOf(':');
        final key = customText.substring(0, separatorIndex);
        final value = customText.substring(separatorIndex + 1);
        customTexts[key] = value;
      }
    }

    // Update custom text for this category
    customTexts[categoryName] = controller.text.trim();

    // Reconstruct custom text string
    final customTextString = customTexts.entries
        .map((e) => '${e.key}:${e.value}')
        .join('|||');

    print('Custom texts map: $customTexts');
    print('Final customTextString: $customTextString');
    print('Final selectedOptions: $selectedOptions');

    _answers[questionId] = BriefAnswer(
      questionId: questionId,
      selectedOptions: selectedOptions,
      textInput: customTextString.isNotEmpty ? customTextString : null,
    );

    print('Answer stored: ${_answers[questionId]}');

    // Clear custom selection and controller
    _customSelectedForCategory.value = '';
    controller.clear();

    _isTextLoading.value = false;
    update();

    // Auto-advance to next question if this is the current question
    if (questionId == currentQuestion.id) {
      await Future.delayed(const Duration(milliseconds: 400));
      _nextQuestion();
    }
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
      // Update max index if we've moved forward
      if (_currentQuestionIndex.value > _maxQuestionIndexShown.value) {
        _maxQuestionIndexShown.value = _currentQuestionIndex.value;
      }
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
      final context = Get.context;
      final l10n = context != null ? AppLocalizations.of(context) : null;
      Get.snackbar(
        l10n?.rcSnackbarRefiningComplete ?? 'Refining Complete!',
        l10n?.rcSnackbarRefiningCompleteMessage ??
            'Your concept has been refined successfully.',
        snackPosition: SnackPosition.TOP,
        backgroundColor: Colors.black,
        colorText: Colors.white,
        duration: const Duration(milliseconds: 1500),
      );
    }
  }

  void goBack() {
    Navigator.of(Get.context!).pop();
  }

  // Method to jump to a specific question (for navigation)
  void jumpToQuestion(int index) {
    if (index >= 0 && index < questions.length) {
      _currentQuestionIndex.value = index;
      // Update max index if we've jumped forward
      if (index > _maxQuestionIndexShown.value) {
        _maxQuestionIndexShown.value = index;
      }
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
    _maxQuestionIndexShown.value = 0; // Reset max shown index
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
    // Don't show animation when custom is selected for the max question shown
    if (isCustomSelectedForCurrentQuestion() &&
        questionIndex == maxQuestionIndexShown) {
      return false;
    }

    // Don't show animation if all questions are completed
    if (isAllQuestionsCompleted) {
      return false;
    }

    // Show animation below the furthest question reached (not the current edited question)
    // This ensures the loading indicator never moves backward when editing previous answers
    bool isMaxQuestion = questionIndex == maxQuestionIndexShown;
    bool isNotLastQuestion = questionIndex < questions.length - 1;

    return isMaxQuestion && isNotLastQuestion;
  }

  // Method to get number of questions to show in the list
  int get questionsToShow {
    // In edit mode, always show all questions
    if (_isEditMode.value) {
      return questions.length;
    }

    // If all questions have been answered, keep showing all questions
    // This prevents questions from disappearing when user edits a previous question
    if (isAllQuestionsCompleted) {
      return questions.length;
    }

    if (maxQuestionIndexShown >= 5) {
      return questions
          .length; // Show all questions after question 5 has been shown
    }
    // Use max index to keep questions visible even when user goes back to edit
    return maxQuestionIndexShown + 1; // Show progressive questions for 1-5
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
          // Preserve multi-select by joining with commas
          refinedConceptData['silhouette'] = answer.selectedOptions.isNotEmpty
              ? answer.selectedOptions.join(', ')
              : '';
          if (answer.textInput?.isNotEmpty == true) {
            refinedConceptData['customSilhouette'] = answer.textInput;
          }
          break;
        case 'specific_features':
          print('=== PROCESSING SPECIFIC_FEATURES FOR API ===');
          print('Raw answer.selectedOptions: ${answer.selectedOptions}');
          print('Raw answer.textInput: ${answer.textInput}');

          // Features can be from multiple categories
          // Parse custom texts to replace "Custom" with actual values
          Map<String, String> customTexts = {};
          if (answer.textInput?.isNotEmpty == true) {
            final textInput = answer.textInput!;
            if (textInput.contains('|||')) {
              final parts = textInput.split('|||');
              for (var part in parts) {
                if (part.contains(':')) {
                  final keyValue = part.split(':');
                  if (keyValue.length >= 2) {
                    customTexts[keyValue[0]] = keyValue.sublist(1).join(':');
                  }
                }
              }
            } else if (textInput.contains(':')) {
              final separatorIndex = textInput.indexOf(':');
              final key = textInput.substring(0, separatorIndex);
              final value = textInput.substring(separatorIndex + 1);
              customTexts[key] = value;
            }
          }

          print('Parsed customTexts map: $customTexts');

          // Process selected options and replace "Custom" with actual values
          List<String> processedFeatures = [];
          for (var option in answer.selectedOptions) {
            print('Processing option: $option');
            if (option.contains(':')) {
              final parts = option.split(':');
              final category = parts[0];
              final value = parts[1];

              print('  Category: $category, Value: $value');

              if (value == 'Custom' && customTexts.containsKey(category)) {
                // Replace "Custom" with the actual custom text
                final replacedValue = '$category:${customTexts[category]}';
                print('  Replacing with: $replacedValue');
                processedFeatures.add(replacedValue);
              } else {
                // Keep regular option as is
                print('  Keeping as is: $option');
                processedFeatures.add(option);
              }
            } else {
              print('  No colon, keeping as is: $option');
              processedFeatures.add(option);
            }
          }

          print('Final processedFeatures: $processedFeatures');
          final featuresString = processedFeatures.isNotEmpty
              ? processedFeatures.join(', ')
              : '';
          print('Final features string for API: $featuresString');

          refinedConceptData['features'] = featuresString;
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

    // Track refined concept completion
    final data = _dataService.getRefinedConceptData();
    PostHogAnalyticsService().trackRefinedConceptCompleted(
      silhouette:
          data['garment_type']?.toString() ??
          data['silhouette']?.toString() ??
          '',
      features:
          data['specific_features']?.toString() ??
          data['features']?.toString() ??
          '',
    );

    // Pass edit mode data to next screen
    if (_isEditMode.value && _editingTechPack != null) {
      // In edit mode, skip onboarding and go directly to questionnaire
      Get.toNamed(
        '/final_details',
        arguments: {'editMode': true, 'techPackModel': _editingTechPack},
      );
    } else {
      Get.toNamed('/final_detail_onboard');
    }
  }

  // Method to proceed directly to design generation (skipping Final Details)
  void proceedToDesignGeneration() async {
    // INTERNET CHECK: Verify internet connection before generation (mobile only)
    final hasInternet = await InternetConnectivityChecker.hasInternetConnection();
    if (!hasInternet) {
      final l10n = AppLocalizations.of(Get.context!)!;
      Get.snackbar(
        l10n.noInternetConnection,
        l10n.noInternetConnectionMessage,
        backgroundColor: Colors.red,
        colorText: Colors.white,
        snackPosition: SnackPosition.TOP,
        duration: const Duration(seconds: 3),
        icon: Icon(
          Icons.wifi_off_rounded,
          color: Colors.white,
          size: 28.sp,
        ),
      );
      return;
    }

    // Ensure Creative Brief data is saved (if controller still exists)
    if (Get.isRegistered<CreativeBriefController>()) {
      final creativeBriefController = Get.find<CreativeBriefController>();
      // Call the save method directly without navigating
      creativeBriefController.saveCreativeBriefData();
      print('Creative Brief data saved from existing controller');
    } else {
      print(
        'WARNING: Creative Brief controller not found - data may not be saved',
      );
    }

    // Save refined concept data
    _saveRefinedConceptData();

    // Save empty/default final details data since we're skipping that screen
    _saveDefaultFinalDetailsData();

    // Check if user can generate designs (only for non-edit mode)
    if (!_isEditMode.value) {
      // Get current subscription to determine plan type
      final subscription = await _stripeService.getCurrentUserSubscription();

      // Check if user is on FREE plan - use email-based quota
      if (subscription != null && subscription.subscriptionPlan == 'FREE') {
        final user = _auth.currentUser;
        if (user?.email == null) {
          Get.snackbar(
            'Error',
            'Unable to verify user email',
            snackPosition: SnackPosition.TOP,
            backgroundColor: Colors.red,
            colorText: Colors.white,
          );
          return;
        }

        // Check email-based quota (persists across account deletions)
        bool hasQuota = await _quotaService.hasRemainingQuota(user!.email!);
        if (hasQuota) {
          // Consume one email-based free design
          try {
            bool incrementSuccess = await _quotaService.incrementDesignUsage(
              user.email!,
            );
            if (!incrementSuccess) {
              Get.snackbar(
                'Error',
                'Failed to track design usage. Please try again.',
                snackPosition: SnackPosition.TOP,
                backgroundColor: Colors.red,
                colorText: Colors.white,
              );
              return;
            }
          } catch (e) {
            Get.snackbar(
              'Error',
              'Failed to track design usage. Please try again.',
              snackPosition: SnackPosition.TOP,
              backgroundColor: Colors.red,
              colorText: Colors.white,
            );
            return;
          }
        } else {
          // Email quota exhausted — check free add-on designs
          if (subscription.hasFreeExtraDesigns) {
            await _stripeService.incrementFreeExtraDesignUsage();
          } else {
            _showLimitExceededDialog();
            return;
          }
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

        // Increment design usage count for paid plans
        await _stripeService.incrementDesignUsage();
      }
    }

    // Proceed with actual generation
    _proceedWithGeneration();
  }

  // Show 80% usage warning dialog
  void _show80PercentWarningDialog(subscription) async {
    final int usedCount = subscription.designsGeneratedThisMonth;
    final int totalCount = subscription.getTotalAllowedDesigns();
    // Check if user is on a paid plan (STARTER, PRO, or STUDIO)
    final bool isPaidUser =
        subscription.subscriptionPlan.startsWith('STARTER') ||
        subscription.subscriptionPlan.startsWith('PRO') ||
        subscription.subscriptionPlan.startsWith('STUDIO');

    Get.dialog(
      UsageWarningDialog(
        usedCount: usedCount,
        totalCount: totalCount,
        isDesign: true,
        isPaidUser: isPaidUser,
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

  // Show limit exceeded dialog
  void _showLimitExceededDialog() async {
    // Get current subscription to check if user is paid
    final subscription = await _stripeService.getCurrentUserSubscription();
    final bool isPaidUser =
        subscription != null &&
        (subscription.subscriptionPlan.startsWith('STARTER') ||
            subscription.subscriptionPlan.startsWith('PRO') ||
            subscription.subscriptionPlan.startsWith('STUDIO'));

    // FREE users: show dialog with option to buy add-on designs
    if (!isPaidUser) {
      Get.dialog(
        FreeUserLimitDialog(
          onClose: () => Navigator.of(Get.overlayContext!).pop(),
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
      return;
    }

    // Paid users who've exceeded their monthly limit
    Get.dialog(
      LimitExceededDialog(
        isPaidUser: true,
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

  // Separate method for the actual generation logic
  void _proceedWithGeneration() async {
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
      Get.toNamed(
        '/generate_tech_pack',
        arguments: {
          'editMode': true,
          'techPackModel': _editingTechPack,
          'forceRegenerate': true, // Add flag to force regeneration
        },
      );

      final context = Get.context;
      final l10n = context != null ? AppLocalizations.of(context) : null;
      Get.snackbar(
        l10n?.rcSnackbarRegeneratingDesigns ?? 'Regenerating Designs!',
        l10n?.rcSnackbarRegeneratingDesignsMessage ??
            'Creating 3 new designs based on your updated preferences...',
        snackPosition: SnackPosition.TOP,
        backgroundColor: Colors.black,
        colorText: Colors.white,
        duration: const Duration(milliseconds: 1500),
      );
    } else {
      Get.toNamed(
        '/generate_tech_pack',
        arguments: {
          'forceRegenerate': true, // Add flag to force regeneration
        },
      );

      final context = Get.context;
      final l10n = context != null ? AppLocalizations.of(context) : null;
      Get.snackbar(
        l10n?.rcSnackbarGeneratingDesigns ?? 'Generating Designs!',
        l10n?.rcSnackbarGeneratingDesignsMessage ??
            'Creating 3 unique designs based on your preferences...',
        snackPosition: SnackPosition.TOP,
        backgroundColor: Colors.black,
        colorText: Colors.white,
        duration: const Duration(milliseconds: 1500),
      );
    }
  }

  // Save default/empty final details data when skipping Final Details screen
  void _saveDefaultFinalDetailsData() {
    // IMPORTANT: These values MUST remain in English for API compatibility
    // The API expects English values, not localized ones
    Map<String, dynamic> finalDetailsData = {
      'season': 'All-Season (Layer-Friendly)', // Default to all-season
      'budget':
          'Mid-Range (€30-50 Production / €60-120 Retail)', // Default to mid-range
      'features': '', // No special features by default
      'customFeatures': '',
      'additionalDetails': '', // No additional details
    };

    // Save to design data service
    _dataService.setFinalDetailsData(finalDetailsData);

    print('Default Final Details data saved: $finalDetailsData');
  }

  // Edit answer method - allows editing a specific question's answer
  void editAnswer(String questionId) {
    // Get localization at the start
    final context = Get.context;
    final l10n = context != null ? AppLocalizations.of(context) : null;

    final question = questions.firstWhere((q) => q.id == questionId);
    final currentAnswer = _answers[questionId];
    // Create a temporary list to track changes
    // For categorized questions, we need to handle both formats: "categoryName:option" and just "option"
    RxList<String> tempSelectedOptions = RxList<String>();
    if (currentAnswer != null) {
      // If it's a categorized question, preserve the format
      if (question.type == 'chips_categorized' && question.categories != null) {
        tempSelectedOptions.value = currentAnswer.selectedOptions.toList();
      } else {
        tempSelectedOptions.value = currentAnswer.selectedOptions.toList();
      }
    }

    // Create a temporary controller for custom text (for regular chip questions)
    final tempCustomController = TextEditingController();
    if (currentAnswer?.textInput != null &&
        currentAnswer!.textInput!.isNotEmpty) {
      tempCustomController.text = currentAnswer.textInput!;
    }

    // Track if custom is selected (for regular chip questions)
    RxBool isCustomSelected = tempSelectedOptions.contains('Custom').obs;

    // For categorized questions, store custom controllers per category
    Map<String, TextEditingController> categoryCustomControllers = {};
    Map<String, RxString> categoryCustomSelected = {};

    // Get all options (either from options list or flattened from categories)
    List<String> allOptions = [];
    Map<String, List<String>>? categoriesMap;

    if (question.type == 'chips_categorized' && question.categories != null) {
      // For categorized questions, flatten all category options
      categoriesMap = question.categories;
      for (var category in question.categories!.entries) {
        allOptions.addAll(category.value);
        // Initialize controllers and tracking for each category
        categoryCustomControllers[category.key] = TextEditingController();
        categoryCustomSelected[category.key] = ''.obs;

        // Load existing custom text for this category if it exists
        final categoryHasCustom =
            currentAnswer?.selectedOptions.any(
              (opt) => opt == '${category.key}:Custom',
            ) ??
            false;
        if (categoryHasCustom && currentAnswer?.textInput != null) {
          final customText = currentAnswer!.textInput!;
          if (customText.contains('|||')) {
            final parts = customText.split('|||');
            for (var part in parts) {
              if (part.startsWith('${category.key}:')) {
                categoryCustomControllers[category.key]!.text = part.substring(
                  '${category.key}:'.length,
                );
                categoryCustomSelected[category.key]!.value = category.key;
                break;
              }
            }
          } else if (customText.startsWith('${category.key}:')) {
            categoryCustomControllers[category.key]!.text = customText
                .substring('${category.key}:'.length);
            categoryCustomSelected[category.key]!.value = category.key;
          } else if (!customText.contains(':')) {
            // Legacy format
            categoryCustomControllers[category.key]!.text = customText;
            categoryCustomSelected[category.key]!.value = category.key;
          }
        }
      }
    } else {
      // For regular chip questions, use options list
      allOptions = question.options;
    }

    Get.dialog(
      AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: Text(
          l10n?.rcDialogEditAnswer ?? 'Edit Answer',
          style: TextStyle(fontSize: 18, fontWeight: FontWeight.w600),
        ),
        content: SizedBox(
          width: double.maxFinite,
          child: SingleChildScrollView(
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
                  l10n?.rcDialogSelectAnswer ?? 'Select your answer:',
                  style: TextStyle(fontSize: 16, fontWeight: FontWeight.w500),
                ),
                SizedBox(height: 12),
                // Show categorized chips if applicable
                if (question.type == 'chips_categorized' &&
                    categoriesMap != null)
                  ...categoriesMap.entries.map((category) {
                    final customSelectedCategory =
                        categoryCustomSelected[category.key]!;
                    final tempCategoryCustomController =
                        categoryCustomControllers[category.key]!;

                    return Obx(
                      () => Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          // Category title
                          Padding(
                            padding: EdgeInsets.only(bottom: 8, top: 8),
                            child: Text(
                              category.key,
                              style: TextStyle(
                                fontSize: 13,
                                fontWeight: FontWeight.w600,
                                color: Colors.grey[700],
                              ),
                            ),
                          ),
                          // Category options
                          Wrap(
                            spacing: 8,
                            runSpacing: 8,
                            children: category.value.map((option) {
                              // Check if this option is selected (handle both formats)
                              // Check for direct match, category prefix match, or custom selection
                              final bool customActiveForCategory =
                                  tempSelectedOptions.contains(
                                    '${category.key}:Custom',
                                  ) ||
                                  customSelectedCategory.value == category.key;

                              final bool isSelected;
                              if (option == 'Custom') {
                                isSelected = customActiveForCategory;
                              } else if (customActiveForCategory) {
                                isSelected = false;
                              } else {
                                isSelected =
                                    tempSelectedOptions.contains(
                                      '${category.key}:$option',
                                    ) ||
                                    tempSelectedOptions.contains(option);
                              }

                              return GestureDetector(
                                onTap: () {
                                  if (option == 'Custom') {
                                    // Toggle custom selection for this category
                                    if (customSelectedCategory.value ==
                                        category.key) {
                                      customSelectedCategory.value = '';
                                      tempCategoryCustomController.clear();
                                      // Remove custom option
                                      tempSelectedOptions.removeWhere(
                                        (opt) =>
                                            opt == '${category.key}:Custom' ||
                                            opt == 'Custom',
                                      );
                                    } else {
                                      customSelectedCategory.value =
                                          category.key;
                                      // Remove other options from this category
                                      tempSelectedOptions.removeWhere(
                                        (opt) =>
                                            category.value.contains(opt) ||
                                            opt.startsWith('${category.key}:'),
                                      );
                                      // Add custom option
                                      tempSelectedOptions.add(
                                        '${category.key}:Custom',
                                      );
                                    }
                                  } else {
                                    // Regular option selected
                                    // Check if clicking to deselect
                                    if (isSelected) {
                                      // Deselect by removing from this category
                                      tempSelectedOptions.removeWhere(
                                        (opt) =>
                                            opt == option ||
                                            opt == '${category.key}:$option',
                                      );
                                    } else {
                                      // Select - enforce one selection per category
                                      tempSelectedOptions.removeWhere(
                                        (o) =>
                                            category.value.contains(o) ||
                                            o.startsWith('${category.key}:'),
                                      );
                                      tempSelectedOptions.add(
                                        '${category.key}:$option',
                                      );
                                    }
                                    // Clear custom selection for this category
                                    if (customSelectedCategory.value ==
                                        category.key) {
                                      customSelectedCategory.value = '';
                                      tempCategoryCustomController.clear();
                                    }
                                  }
                                },
                                child: Container(
                                  padding: EdgeInsets.symmetric(
                                    horizontal: 14,
                                    vertical: 8,
                                  ),
                                  decoration: BoxDecoration(
                                    color: isSelected
                                        ? Colors.black
                                        : Colors.grey[100],
                                    borderRadius: BorderRadius.circular(20),
                                    border: Border.all(
                                      color: isSelected
                                          ? Colors.black
                                          : Colors.grey[300]!,
                                    ),
                                  ),
                                  child: Text(
                                    option,
                                    style: TextStyle(
                                      color: isSelected
                                          ? Colors.white
                                          : Colors.black,
                                      fontSize: 13,
                                      fontWeight: isSelected
                                          ? FontWeight.w500
                                          : FontWeight.w400,
                                    ),
                                  ),
                                ),
                              );
                            }).toList(),
                          ),
                          // Show custom text field if Custom is selected for this category
                          if (customSelectedCategory.value == category.key) ...[
                            SizedBox(height: 12),
                            TextField(
                              controller: tempCategoryCustomController,
                              decoration: InputDecoration(
                                hintText:
                                    'Enter custom ${category.key.toLowerCase()}...',
                                border: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(8),
                                ),
                                contentPadding: EdgeInsets.symmetric(
                                  horizontal: 12,
                                  vertical: 8,
                                ),
                              ),
                              maxLines: 2,
                            ),
                          ],
                          SizedBox(height: 8),
                        ],
                      ),
                    );
                  }).toList()
                else
                  // Show regular chips
                  Obx(
                    () => Wrap(
                      spacing: 8,
                      runSpacing: 8,
                      children: allOptions.map((option) {
                        final isSelected = tempSelectedOptions.contains(option);
                        return GestureDetector(
                          onTap: () {
                            if (question.allowMultiple) {
                              // Toggle for multiple selection
                              isSelected
                                  ? tempSelectedOptions.remove(option)
                                  : tempSelectedOptions.add(option);
                            } else {
                              // Toggle for single selection
                              if (isSelected) {
                                // Deselect by clearing the list
                                tempSelectedOptions.clear();
                              } else {
                                // Select by setting as the only option
                                tempSelectedOptions.value = [option];
                              }
                            }

                            // Update custom selected state
                            isCustomSelected.value = tempSelectedOptions
                                .contains('Custom');
                          },
                          child: Container(
                            margin: EdgeInsets.only(right: 8, bottom: 8),
                            padding: EdgeInsets.symmetric(
                              horizontal: 16,
                              vertical: 10,
                            ),
                            decoration: BoxDecoration(
                              color: isSelected
                                  ? Colors.black
                                  : Colors.grey[100],
                              borderRadius: BorderRadius.circular(25),
                              border: Border.all(
                                color: isSelected
                                    ? Colors.black
                                    : Colors.grey[300]!,
                              ),
                            ),
                            child: Text(
                              option,
                              style: TextStyle(
                                color: isSelected ? Colors.white : Colors.black,
                                fontSize: 14,
                                fontWeight: isSelected
                                    ? FontWeight.w500
                                    : FontWeight.w400,
                              ),
                            ),
                          ),
                        );
                      }).toList(),
                    ),
                  ),
                SizedBox(height: 16),
                // Show custom text field if Custom is selected
                Obx(
                  () => isCustomSelected.value
                      ? Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              l10n?.rcDialogEnterCustomAnswer ??
                                  'Enter custom answer:',
                              style: TextStyle(
                                fontSize: 14,
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                            SizedBox(height: 8),
                            TextField(
                              controller: tempCustomController,
                              decoration: InputDecoration(
                                hintText:
                                    l10n?.rcDialogCustomAnswerHint ??
                                    'Type your custom answer...',
                                border: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(8),
                                ),
                                contentPadding: EdgeInsets.symmetric(
                                  horizontal: 12,
                                  vertical: 8,
                                ),
                              ),
                              maxLines: 2,
                            ),
                          ],
                        )
                      : SizedBox.shrink(),
                ),
              ],
            ),
          ),
        ),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.of(Get.overlayContext!).pop();
              // Dispose temporary controllers after dialog is closed
              Future.delayed(Duration(milliseconds: 100), () {
                if (question.type == 'chips_categorized' &&
                    categoriesMap != null) {
                  // Dispose category controllers
                  for (var controller in categoryCustomControllers.values) {
                    controller.dispose();
                  }
                } else {
                  tempCustomController.dispose();
                }
              });
            },
            child: Text(
              l10n?.rcDialogCancel ?? 'Cancel',
              style: TextStyle(color: Colors.grey[600]),
            ),
          ),
          ElevatedButton(
            onPressed: () {
              // Get localization before any operations
              final context = Get.context;
              final l10n = context != null
                  ? AppLocalizations.of(context)
                  : null;

              final bool isCategorizedDialog =
                  question.type == 'chips_categorized' && categoriesMap != null;

              if (isCategorizedDialog) {
                // Validate custom inputs for categorized questions
                for (var category in categoriesMap.entries) {
                  final hasCustom = tempSelectedOptions.contains(
                    '${category.key}:Custom',
                  );
                  final controller = categoryCustomControllers[category.key]!;
                  if (hasCustom && controller.text.trim().isEmpty) {
                    Get.snackbar(
                      l10n?.rcSnackbarInvalidInput ?? 'Invalid Input',
                      l10n?.rcSnackbarInvalidInputCategoryMessage(
                            category.key,
                          ) ??
                          'Please enter a custom answer for ${category.key}',
                      backgroundColor: Colors.black,
                      colorText: Colors.white,
                      snackPosition: SnackPosition.TOP,
                      duration: const Duration(milliseconds: 1500),
                    );
                    return;
                  }
                }

                // Collect custom texts for all categories
                final Map<String, String> customTexts = {};
                for (var category in categoriesMap.entries) {
                  final hasCustom = tempSelectedOptions.contains(
                    '${category.key}:Custom',
                  );
                  if (hasCustom) {
                    final controller = categoryCustomControllers[category.key]!;
                    customTexts[category.key] = controller.text.trim();
                  }
                }

                // Build custom text string: "category1:text1|||category2:text2"
                String? customTextString;
                if (customTexts.isNotEmpty) {
                  customTextString = customTexts.entries
                      .map((e) => '${e.key}:${e.value}')
                      .join('|||');
                }

                _answers[questionId] = BriefAnswer(
                  questionId: questionId,
                  selectedOptions: tempSelectedOptions.toList(),
                  textInput: customTextString,
                );
              } else {
                // For regular chip questions
                if (tempSelectedOptions.contains('Custom') &&
                    tempCustomController.text.trim().isEmpty) {
                  Get.snackbar(
                    l10n?.rcSnackbarInvalidInput ?? 'Invalid Input',
                    l10n?.rcSnackbarInvalidInputMessage ??
                        'Please enter a custom answer',
                    backgroundColor: Colors.black,
                    colorText: Colors.white,
                    snackPosition: SnackPosition.TOP,
                    duration: const Duration(milliseconds: 1500),
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
              }

              final overlayContext = Get.overlayContext;
              if (overlayContext != null) {
                FocusScope.of(overlayContext).unfocus();
              }

              Navigator.of(Get.overlayContext!).pop();
              update();
              Get.snackbar(
                l10n?.rcSnackbarAnswerUpdated ?? 'Answer Updated',
                l10n?.rcSnackbarAnswerUpdatedMessage ??
                    'Your answer has been updated successfully',
                backgroundColor: Colors.black,
                colorText: Colors.white,
                snackPosition: SnackPosition.TOP,
                duration: const Duration(milliseconds: 1500),
                margin: const EdgeInsets.all(16),
              );

              Future.delayed(const Duration(milliseconds: 100), () {
                if (isCategorizedDialog) {
                  for (var controller in categoryCustomControllers.values) {
                    controller.dispose();
                  }
                } else {
                  tempCustomController.dispose();
                }
              });
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.black,
              foregroundColor: Colors.white,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(8),
              ),
            ),
            child: Text(l10n?.rcDialogSaveChanges ?? 'Save Changes'),
          ),
        ],
      ),
    );
  }

  // ============================================================================
  // LOCALIZATION HELPER METHODS
  // ============================================================================
  // These methods handle the presentation layer localization while keeping
  // internal data storage and API communication in English

  /// Get localized question text for display
  String getLocalizedQuestionText(BuildContext context, String questionId) {
    final service = RefiningConceptLocalizationService(context);
    return service.getLocalizedQuestion(questionId);
  }

  /// Get localized category name for display
  String getLocalizedCategoryName(BuildContext context, String categoryName) {
    final service = RefiningConceptLocalizationService(context);
    return service.getLocalizedCategory(categoryName);
  }

  /// Get localized option for display (single option)
  String getLocalizedOption(BuildContext context, String englishOption) {
    final service = RefiningConceptLocalizationService(context);
    return service.getLocalizedOption(englishOption);
  }

  /// Get localized options for display (list of options)
  List<String> getLocalizedOptions(
    BuildContext context,
    List<String> englishOptions,
  ) {
    final service = RefiningConceptLocalizationService(context);
    return service.getLocalizedOptions(englishOptions);
  }

  /// Get localized categories map for display
  Map<String, List<String>> getLocalizedCategories(
    BuildContext context,
    Map<String, List<String>> englishCategories,
  ) {
    final service = RefiningConceptLocalizationService(context);
    return service.getLocalizedCategories(englishCategories);
  }

  /// Convert localized option back to English for API/storage
  String getEnglishOptionFromLocalized(
    BuildContext context,
    String localizedOption,
  ) {
    final service = RefiningConceptLocalizationService(context);
    return service.getEnglishOption(localizedOption);
  }
}
