import 'dart:async';
import 'package:atella/Data/Models/brief_questions_model.dart';
import 'package:atella/Data/Models/tech_pack_model.dart';
import 'package:atella/services/designservices/design_data_service.dart';
import 'package:atella/services/firebase/edit/edit_data_service.dart';
import 'package:atella/services/analytics/posthog_analytics_service.dart';
import 'package:atella/services/localization/creative_brief_localization_service.dart';
import 'package:atella/l10n/generated/app_localizations.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

class CreativeBriefController extends GetxController {
  final DesignDataService _dataService = Get.find<DesignDataService>();
  final EditDataService _editDataService = EditDataService();

  // Edit mode tracking
  final RxBool _isEditMode = false.obs;
  bool get isEditMode => _isEditMode.value;
  TechPackModel? _editingTechPack;

  // Edit current session mode (when user clicks "Yes, I'd like to make changes")
  final RxBool _isEditingCurrentSession = false.obs;
  bool get isEditingCurrentSession => _isEditingCurrentSession.value;

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
  final colorController =
      TextEditingController(); // For solid colors (hex codes)
  final fabricController = TextEditingController();
  final customController = TextEditingController(); // For custom answers

  // Custom controllers for categorized questions
  final garmentTypeCustomController =
      TextEditingController(); // For garment_type custom
  final fabricCustomController = TextEditingController(); // For fabrics custom
  final printCustomController =
      TextEditingController(); // For colors Prints custom
  final techniqueCustomController =
      TextEditingController(); // For colors Techniques custom

  // Storage for multi-part colors question
  final RxList<String> _selectedColors =
      <String>[].obs; // Hex codes for solid colors
  List<String> get selectedColors => _selectedColors;

  final RxString _selectedPrint = ''.obs; // Selected print option
  String get selectedPrint => _selectedPrint.value;

  final RxString _selectedTechnique = ''.obs; // Selected technique option
  String get selectedTechnique => _selectedTechnique.value;

  // Loading state for text input
  final RxBool _isTextLoading = false.obs;
  bool get isTextLoading => _isTextLoading.value;

  // Image storage for inspiration question - now supports multiple images
  final RxList<String> _inspirationImages = <String>[].obs;
  List<String> get inspirationImages => _inspirationImages;

  // Track which question has custom selected - FIXED: Now properly observable
  final RxString _customSelectedForQuestion = ''.obs;
  String get customSelectedForQuestion => _customSelectedForQuestion.value;

  // Track which category has custom selected for categorized questions
  // Format: "questionId:categoryName" e.g., "garment_type:Tops" or "colors:Prints"
  final RxString _customSelectedForCategory = ''.obs;
  String get customSelectedForCategory => _customSelectedForCategory.value;

  // Track temporary selections before they are confirmed
  final RxMap<String, String> _tempSelections = <String, String>{}.obs;
  Map<String, String> get tempSelections => _tempSelections;

  // Editing state for text questions
  final RxSet<String> _editingQuestions = <String>{}.obs;
  Set<String> get editingQuestions => _editingQuestions;

  // Track expanded state for expandable sections
  final RxMap<String, bool> _expandedCategories = <String, bool>{}.obs;
  Map<String, bool> get expandedCategories => _expandedCategories;

  // Helper methods for expandable categories
  void toggleCategory(String categoryKey) {
    _expandedCategories[categoryKey] = !(_expandedCategories[categoryKey] ?? false);
  }

  void collapseCategory(String categoryKey) {
    _expandedCategories[categoryKey] = false;
  }

  void expandCategory(String categoryKey) {
    _expandedCategories[categoryKey] = true;
  }

  // Questions data
  final List<BriefQuestion> questions = [
    BriefQuestion(
      id: 'garment_type',
      question: 'What type of garment are you creating? 👕',
      type: 'chips_categorized',
      options: [], // Will use categories instead
      categories: {
        'Tops': [
          'T-shirt',
          'Shirt',
          'Blouse',
          'Hoodie',
          'Jacket',
          'Coat',
          'Vest',
          'Tank top',
          'Crop top',
          'Sweater',
          'Custom',
        ],
        'Bottoms': [
          'Pants',
          'Jeans',
          'Skirts',
          'Shorts',
          'Leggings',
          'Culottes',
          'Palazzo',
          'Joggers',
          'Custom',
        ],
        'Dresses': [
          'Casual dress',
          'Evening',
          'Cocktail dress',
          'Gown',
          'Maxi dress',
          'Midi dress',
          'Mini dress',
          'Custom',
        ],
        'Jumpsuits': [
          'Jumpsuit',
          'Romper',
          'Playsuit',
          'Overalls',
          'Custom',
        ],
        'Outerwear': [
          'Trench coat',
          'Bomber jacket',
          'Blazer',
          'Puffer jacket',
          'Custom',
        ],
        'Sportswear': ['Tracksuit', 'Activewear', 'Swimwear', 'Custom'],
        'Accessories': ['Hat', 'Bag', 'Scarf', 'Gloves', 'Custom'],
      },
    ),
    BriefQuestion(
      id: 'style',
      question: 'What is the overall desired style? ✨',
      type: 'chips',
      options: ['Casual', 'Chic', 'Sporty', 'Streetwear', 'Workwear', 'Custom'],
    ),
    BriefQuestion(
      id: 'target_audience',
      question: 'Who is this garment intended for? 👤',
      type: 'chips',
      options: ['Woman', 'Man', 'Child', 'Unisex', 'Target Age', 'Custom'],
    ),
    BriefQuestion(
      id: 'occasion',
      question: 'What is the intended occasion or use? 📅',
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
      question: 'Do you have any visual inspirations or references? 🖼️',
      type: 'image',
      options: [],
    ), 
    BriefQuestion(
      id: 'colors',
      question: 'What colors and patterns should the design include? 🎨',
      type: 'multi_part_color',
      options: [],
      categories: {
        'Prints': [
          'Floral',
          'Abstract',
          'Camouflage',
          'Stripes',
          'Polka dots',
          'Tie-dye',
          'Custom',
        ],
        'Techniques': [
          'Color blocking',
          'Gradient/Ombré',
          'Embroidery',
          'Jacquard',
          'Custom',
        ],
      },
    ),
    BriefQuestion(
      id: 'fabrics',
      question: 'Which fabric or material would you like to use? 🧵',
      type: 'chips_categorized',
      options: [],
      categories: {
        'Cotton': [
          'Lightweight (poplin, voile)',
          'Medium (twill)',
          'Heavy (denim, canvas)',
          'Custom',
        ],
        'Wool': ['Merino', 'Cashmere', 'Tweed', 'Felt', 'Custom'],
        'Silk': ['Satin', 'Chiffon', 'Organza', 'Custom'],
        'Linen': ['Plain', 'Textured', 'Blended', 'Custom'],
        'Synthetic': ['Polyester', 'Nylon', 'Spandex', 'Neoprene', 'Custom'],
        'Eco options': [
          'Organic cotton',
          'Recycled polyester',
          'Bamboo',
          'Hemp',
          'Custom',
        ],
        'Leather/Faux leather': ['Leather', 'Faux leather', 'Custom'],
        'Knitwear': ['Jersey', 'Rib knit', 'Interlock', 'Custom'],
      },
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

      // Check for "edit current session" mode (from generate_tech_pack screen)
      final editCurrentSession = arguments['editCurrentSession'] == true;
      final preserveAnswers = arguments['preserveAnswers'] == true;

      // Check for "edit existing tech pack" mode (from preview screen)
      final isEditMode = arguments['editMode'] == true;
      final techPackModel = arguments['techPackModel'] as TechPackModel?;

      print('Edit current session flag: $editCurrentSession');
      print('Preserve answers flag: $preserveAnswers');
      print('Edit mode flag: ${arguments['editMode']}');
      print('Edit mode detected: $isEditMode');
      print('TechPack model: ${techPackModel?.toString()}');

      if (editCurrentSession || preserveAnswers) {
        // User wants to edit the current session - DON'T reset answers
        print('🟢 EDITING CURRENT SESSION - Preserving existing answers');
        _isEditingCurrentSession.value = true;
        // Answers are already in memory from previous screens, just show them
        _showLastTwoQuestions.value = true;
        _currentQuestionIndex.value = questions.length - 1;
      } else if (isEditMode) {
        print('🟢 ENTERING EDIT MODE (from saved tech pack)');
        _isEditMode.value = true;
        _editingTechPack = techPackModel;
        print('Stored TechPack: ${_editingTechPack?.projectName}');
        _loadExistingDataFromFirebase();
      } else {
        print('🔴 NORMAL MODE - Fresh start');
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
      print(
        'Loading data from Firebase for tech pack: ${_editingTechPack!.id}',
      );

      // Show loading indicator
      final l10n = AppLocalizations.of(Get.context!)!;
      Get.snackbar(
        l10n.loading,
        l10n.loadingExistingDesignData,
        backgroundColor: Colors.black,
        colorText: Colors.white,
        snackPosition: SnackPosition.TOP,
        duration: const Duration(milliseconds: 1500),
      );

      // Get complete edit data from Firebase
      final editData = await _editDataService.getTechPackEditData(
        _editingTechPack!.id,
      );

      if (editData != null) {
        final questionnaireData =
            editData['designQuestionnaire'] as Map<String, dynamic>;
        final parsedData = _editDataService.parseQuestionnaireForEdit(
          questionnaireData,
        );

        // Load creative brief data if available
        if (parsedData.containsKey('creativeBrief')) {
          _loadCreativeBriefAnswers(
            parsedData['creativeBrief'] as Map<String, dynamic>,
          );
        }

        // Store all questionnaire data for later use
        if (parsedData.containsKey('refinedConcept')) {
          _dataService.setRefinedConceptData(
            parsedData['refinedConcept'] as Map<String, dynamic>,
          );
        }
        if (parsedData.containsKey('finalDetails')) {
          _dataService.setFinalDetailsData(
            parsedData['finalDetails'] as Map<String, dynamic>,
          );
        }

        final l10n = AppLocalizations.of(Get.context!)!;
        Get.snackbar(
          l10n.editMode,
          l10n.editingDesign(_editingTechPack!.projectName),
          backgroundColor: Colors.black,
          colorText: Colors.white,
          snackPosition: SnackPosition.TOP,
          duration: const Duration(milliseconds: 1500),
        );
      } else {
        print('No edit data found, using default values');
        _prefillDemoAnswers(_editingTechPack);
      }
    } catch (e) {
      print('Error loading edit data: $e');
      final l10n = AppLocalizations.of(Get.context!)!;
      Get.snackbar(
        l10n.error,
        l10n.failedToLoadExistingData,
        backgroundColor: Colors.black,
        colorText: Colors.white,
        duration: const Duration(milliseconds: 1500),
        snackPosition: SnackPosition.TOP,
      );
      _prefillDemoAnswers(_editingTechPack);
    }
  }

  // Load creative brief answers from Firebase data
  void _loadCreativeBriefAnswers(Map<String, dynamic> creativeBriefData) {
    // print('Loading creative brief answers: $creativeBriefData');

    // Load chip-based answers
    final garmentType =
        creativeBriefData['garment_type'] as String? ??
        creativeBriefData['garmentType'] as String? ??
        '';
    final customGarmentType =
        creativeBriefData['custom_garment_type'] as String? ??
        creativeBriefData['customGarmentType'] as String? ??
        '';
    final List<String> garmentSelections = garmentType
        .split(',')
        .map((e) => e.trim())
        .where((e) => e.isNotEmpty)
        .toList();
    if (garmentSelections.isNotEmpty || customGarmentType.isNotEmpty) {
      if (garmentSelections.isEmpty && customGarmentType.isNotEmpty) {
        garmentSelections.add('Custom');
      }
      String? formattedCustomGarment;
      if (customGarmentType.isNotEmpty) {
        formattedCustomGarment = customGarmentType;
        // Ensure dialog receives category-prefixed custom text
        final categoryWithCustom = garmentSelections.firstWhere(
          (opt) => opt.contains(':Custom'),
          orElse: () => '',
        );
        if (categoryWithCustom.isNotEmpty &&
            !formattedCustomGarment.contains(':')) {
          final categoryName = categoryWithCustom.split(':').first;
          formattedCustomGarment = '$categoryName:$formattedCustomGarment';
        }
      }
      _answers['garment_type'] = BriefAnswer(
        questionId: 'garment_type',
        selectedOptions: garmentSelections,
        textInput: formattedCustomGarment,
      );
    }

    final style =
        creativeBriefData['style'] as String? ??
        creativeBriefData['stylePreference'] as String? ??
        '';
    final customStyle =
        creativeBriefData['custom_style'] as String? ??
        creativeBriefData['customStyle'] as String? ??
        '';
    if (style.isNotEmpty || customStyle.isNotEmpty) {
      final List<String> styleSelections = [];
      if (style.isNotEmpty) {
        styleSelections.add(style);
      }
      if (styleSelections.isEmpty && customStyle.isNotEmpty) {
        styleSelections.add('Custom');
      }
      _answers['style'] = BriefAnswer(
        questionId: 'style',
        selectedOptions: styleSelections,
        textInput: customStyle.isNotEmpty ? customStyle : null,
      );
    }

    final targetAudience =
        creativeBriefData['target_audience'] as String? ??
        creativeBriefData['targetAudience'] as String? ??
        '';
    final customTargetAudience =
        creativeBriefData['custom_target_audience'] as String? ??
        creativeBriefData['customTargetAudience'] as String? ??
        '';
    if (targetAudience.isNotEmpty || customTargetAudience.isNotEmpty) {
      final List<String> audienceSelections = [];
      if (targetAudience.isNotEmpty) {
        audienceSelections.add(targetAudience);
      }
      if (audienceSelections.isEmpty && customTargetAudience.isNotEmpty) {
        audienceSelections.add('Custom');
      }
      final String? customAudienceInput = customTargetAudience.isNotEmpty
          ? customTargetAudience
          : null;
      _answers['target_audience'] = BriefAnswer(
        questionId: 'target_audience',
        selectedOptions: audienceSelections,
        textInput: customAudienceInput,
      );
    }

    final occasion =
        creativeBriefData['occasion'] as String? ??
        creativeBriefData['occasionType'] as String? ??
        '';
    final customOccasion =
        creativeBriefData['custom_occasion'] as String? ??
        creativeBriefData['customOccasion'] as String? ??
        '';
    if (occasion.isNotEmpty || customOccasion.isNotEmpty) {
      final List<String> occasionSelections = [];
      if (occasion.isNotEmpty) {
        occasionSelections.add(occasion);
      }
      if (occasionSelections.isEmpty && customOccasion.isNotEmpty) {
        occasionSelections.add('Custom');
      }
      final String? customOccasionInput = customOccasion.isNotEmpty
          ? customOccasion
          : null;
      _answers['occasion'] = BriefAnswer(
        questionId: 'occasion',
        selectedOptions: occasionSelections,
        textInput: customOccasionInput,
      );
    }

    // Load image-based inspiration (support both single and multiple images)
    final inspiration = creativeBriefData['inspiration'];
    if (inspiration != null) {
      if (inspiration is List) {
        // Multiple images
        final imagePaths = inspiration.cast<String>();
        _inspirationImages.value = imagePaths;
        _answers['inspiration'] = BriefAnswer(
          questionId: 'inspiration',
          selectedOptions: ['Image'],
          textInput: imagePaths.join(
            '|||',
          ), // Use delimiter to store multiple paths
        );
      } else if (inspiration is String && inspiration.isNotEmpty) {
        // Single image or text
        if (inspiration.contains('/') || inspiration.contains('\\')) {
          // Check if it contains multiple images separated by delimiter
          if (inspiration.contains('|||')) {
            final imagePaths = inspiration.split('|||');
            _inspirationImages.value = imagePaths;
          } else {
            // Single image path
            _inspirationImages.value = [inspiration];
          }
          _answers['inspiration'] = BriefAnswer(
            questionId: 'inspiration',
            selectedOptions: ['Image'],
            textInput: inspiration,
          );
        } else {
          // Legacy text data
          _answers['inspiration'] = BriefAnswer(
            questionId: 'inspiration',
            selectedOptions: [inspiration],
          );
        }
      }
    }

    // Load multi-part colors answer
    final solidColors = creativeBriefData['solidColors'];
    final print = creativeBriefData['print'] as String? ?? '';
    final technique = creativeBriefData['technique'] as String? ?? '';

    debugPrint('🎨 Loading colors data:');
    debugPrint('   solidColors: $solidColors');
    debugPrint('   print: $print');
    debugPrint('   technique: $technique');

    if (solidColors != null || print.isNotEmpty || technique.isNotEmpty) {
      // Load solid colors
      if (solidColors is List && solidColors.isNotEmpty) {
        // Filter out empty strings from the colors array
        final filteredColors = solidColors
            .where((color) => color != null && color.toString().trim().isNotEmpty)
            .map((color) => color.toString())
            .toList();
        _selectedColors.value = filteredColors;
        colorController.text = _selectedColors.join(', ');
        debugPrint('   ✅ Loaded ${_selectedColors.length} solid colors (filtered from ${solidColors.length})');
      } else if (solidColors is String && solidColors.isNotEmpty) {
        _selectedColors.value = [solidColors];
        colorController.text = solidColors;
        debugPrint('   ✅ Loaded 1 solid color (string)');
      }

      // Load print and technique
      if (print.isNotEmpty) {
        _selectedPrint.value = print;
        debugPrint('   ✅ Loaded print: $print');
      }
      if (technique.isNotEmpty) {
        _selectedTechnique.value = technique;
        debugPrint('   ✅ Loaded technique: $technique');
      }

      // Create the answer with whatever parts are available
      // Don't require all three parts - load partial data too
      List<String> selectedOptions = [];
      if (print.isNotEmpty) selectedOptions.add(print);
      if (technique.isNotEmpty) selectedOptions.add(technique);

      _answers['colors'] = BriefAnswer(
        questionId: 'colors',
        selectedOptions: selectedOptions,
        textInput: _selectedColors.isNotEmpty
            ? _selectedColors.join('|||')
            : null,
      );
      debugPrint(
        '   ✅ Created colors answer with ${selectedOptions.length} options and ${_selectedColors.length} colors',
      );
    } else {
      debugPrint('   ⚠️ No color data found');
    }

    // Load fabrics as chip selection (categorized chips)
    final fabrics = creativeBriefData['fabrics'] as String? ?? '';
    if (fabrics.isNotEmpty) {
      _answers['fabrics'] = BriefAnswer(
        questionId: 'fabrics',
        selectedOptions: [fabrics],
      );
    }

    // In edit mode, show all questions
    _showLastTwoQuestions.value = true;
    _currentQuestionIndex.value = questions.length - 1;

    // Force reactive update
    _answers.refresh();
    update();

    // print('Loaded ${_answers.length} answers for creative brief');
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

    // Example: Pre-fill multi-part colors (using project name as example)
    if (techPack?.projectName.toLowerCase().contains('blue') == true) {
      _selectedColors.value = ['#0000FF', '#000080'];
      _selectedPrint.value = 'Stripes';
      _selectedTechnique.value = 'Color blocking';
      colorController.text = _selectedColors.join(', ');
      _answers['colors'] = BriefAnswer(
        questionId: 'colors',
        selectedOptions: ['Stripes', 'Color blocking'],
        textInput: _selectedColors.join('|||'),
      );
    } else {
      // Default colors for edit mode
      _selectedColors.value = ['#000000', '#FFFFFF'];
      _selectedPrint.value = 'Floral';
      _selectedTechnique.value = 'Embroidery';
      colorController.text = _selectedColors.join(', ');
      _answers['colors'] = BriefAnswer(
        questionId: 'colors',
        selectedOptions: ['Floral', 'Embroidery'],
        textInput: _selectedColors.join('|||'),
      );
    }
    print('Pre-filled colors: ${_answers['colors']}');

    // Example: Pre-fill fabrics as chip selection (categorized chips)
    if (techPack?.collectionName.toLowerCase().contains('summer') == true) {
      _answers['fabrics'] = BriefAnswer(
        questionId: 'fabrics',
        selectedOptions: [
          'Lightweight (poplin, voile)',
        ], // Cotton category option
      );
    } else {
      // Default fabrics for edit mode
      _answers['fabrics'] = BriefAnswer(
        questionId: 'fabrics',
        selectedOptions: ['Medium (twill)'], // Cotton category option
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
      final l10n = AppLocalizations.of(Get.context!)!;
      Get.snackbar(
        l10n.dataLoaded,
        l10n.previousAnswersLoadedForEditing,
        backgroundColor: Colors.green,
        colorText: Colors.white,
        duration: const Duration(milliseconds: 1500),
      );
    });
  }

  @override
  void onClose() {
    _timeTimer?.cancel();
    colorController.dispose();
    fabricController.dispose();
    customController.dispose();
    garmentTypeCustomController.dispose();
    fabricCustomController.dispose();
    printCustomController.dispose();
    techniqueCustomController.dispose();
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
        ? AppLocalizations.of(context)?.today ?? 'Today'
        : 'Today';
    _currentTime.value = '$todayText, $timeString';
  }

  BriefQuestion get currentQuestion => questions[currentQuestionIndex];

  // FIXED: Check if option is selected including custom selection and temporary selections
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
    return _customSelectedForQuestion.value == currentQuestion.id;
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
        return {
          'questionId': parts[0],
          'categoryName': parts[1],
        };
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

  void selectOption(
    String option, {
    String? forQuestionId,
    String? categoryName,
  }) async {
    // Determine which question this selection is for
    final questionId = forQuestionId ?? currentQuestion.id;

    print(
      'Selecting option: $option for question: $questionId, category: $categoryName',
    ); // Debug

    // Check if this option is already selected (for deselection)
    final tempValue = categoryName != null ? '$categoryName:$option' : option;
    final answerValue = categoryName != null ? '$categoryName:$option' : option;
    final isAlreadySelected = _tempSelections[questionId] == tempValue ||
        (_answers.containsKey(questionId) &&
            _answers[questionId]!.selectedOptions.contains(answerValue));

    // If "Custom" is selected
    if (option == 'Custom') {
      print(
        'Custom selected for question: $questionId, category: $categoryName',
      ); // Debug

      // Check if custom is already selected - if so, deselect it
      final isCustomAlreadySelected = categoryName != null
          ? _customSelectedForCategory.value == '$questionId:$categoryName'
          : _customSelectedForQuestion.value == questionId;

      if (isCustomAlreadySelected) {
        // DESELECT CUSTOM
        print('Deselecting Custom for question: $questionId');
        if (categoryName != null) {
          _customSelectedForCategory.value = '';
        } else {
          _customSelectedForQuestion.value = '';
        }
        // Clear the custom controller
        customController.clear();
        update();
        return;
      }

      // SELECT CUSTOM
      // For categorized questions, track which category has custom selected
      if (categoryName != null) {
        _customSelectedForCategory.value = '$questionId:$categoryName';
        // Clear regular custom selection
        _customSelectedForQuestion.value = '';
      } else {
        // For regular chip questions
        _customSelectedForQuestion.value = questionId;
        // Clear category custom selection
        _customSelectedForCategory.value = '';
      }

      // Clear any temporary selection
      _tempSelections.remove(questionId);

      // Clear any existing answer (allow switching from regular option to custom)
      _answers.remove(questionId);

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

    // For non-custom options, check if clicking to deselect
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
    // For categorized questions, store with category prefix
    if (categoryName != null) {
      _tempSelections[questionId] = '$categoryName:$option';
    } else {
      _tempSelections[questionId] = option;
    }

    // Clear custom selection if user selects a different option
    if (_customSelectedForQuestion.value == questionId) {
      _customSelectedForQuestion.value = '';
    }
    if (categoryName != null &&
        _customSelectedForCategory.value == '$questionId:$categoryName') {
      _customSelectedForCategory.value = '';
    }

    // Collapse the section immediately after selection
    if (categoryName != null) {
      final categoryKey = '${questionId}_$categoryName';
      collapseCategory(categoryKey);
    } else {
      collapseCategory(questionId);
    }

    // Update the UI
    update();

    // If question is already answered, update the answer immediately (no delay for edits)
    if (isQuestionAnswered(questionId)) {
      print('Updating already answered question immediately: $questionId');
      _confirmCurrentSelection(questionId);
    } else {
      // Auto-advance to next question after delay for new answers
      await Future.delayed(
        const Duration(milliseconds: 2000),
      ); // Increased delay to 2 seconds
      // Check if the selection is still the same (user hasn't changed it)
      final expectedValue = categoryName != null ? '$categoryName:$option' : option;
      if (_tempSelections[questionId] == expectedValue) {
        _confirmCurrentSelection(questionId);
      }
    }
  }

  // Method to confirm current selection and advance
  void _confirmCurrentSelection(String questionId) {
    final tempSelection = _tempSelections[questionId];
    print('=== _confirmCurrentSelection called ===');
    print('Question ID: $questionId');
    print('Temp selection: $tempSelection');
    if (tempSelection != null) {
      print('=== CONFIRMING SELECTION ===');
      print('Question ID: $questionId');
      print('Selected option: $tempSelection');

      // Create final answer
      _answers[questionId] = BriefAnswer(
        questionId: questionId,
        selectedOptions: [tempSelection],
      );

      print('Answer created: ${_answers[questionId]}');
      print('Is question answered: ${isQuestionAnswered(questionId)}');

      // Clear temporary selection
      _tempSelections.remove(questionId);

      // Trigger multiple updates to ensure reactivity
      _answers.refresh();
      _tempSelections.refresh();
      update();

      // Force another update after a short delay to ensure UI updates
      Future.delayed(const Duration(milliseconds: 50), () {
        _answers.refresh();
        update();
      });

      print('Answers map size: ${_answers.length}');
      print('All answered questions: ${_answers.keys.toList()}');

      // Find the question index
      final questionIndex = questions.indexWhere((q) => q.id == questionId);

      // For the last question, delay advancement to ensure UI updates
      if (questionIndex == questions.length - 1) {
        print('Last question answered, delaying next question call');
        Future.delayed(const Duration(milliseconds: 300), () {
          _nextQuestion();
        });
      } else {
        // For non-last questions, only advance if it's the current question
        if (questionId == currentQuestion.id) {
          _nextQuestion();
        } else {
          // If answering a later question while on an earlier one, just update UI
          print('Answered a later question, staying on current question');
        }
      }
    }
  }

  // Method to manually confirm selection (if we want to add a confirm button later)
  void confirmSelection({String? forQuestionId}) {
    final questionId = forQuestionId ?? currentQuestion.id;
    _confirmCurrentSelection(questionId);
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

  // Edit existing categorized custom answer - reload text for editing
  void editCategorizedCustomAnswer(
    String questionId,
    String categoryName,
    String existingText,
    TextEditingController controller,
  ) {
    // Load the custom text into the provided controller
    controller.text = existingText;

    // Mark custom as selected for this category
    _customSelectedForCategory.value = '$questionId:$categoryName';

    // For single-selection questions (garment_type, fabrics):
    // Simply remove the answer so it can be re-submitted
    _answers.remove(questionId);

    // Navigate to the question if needed
    final questionIndex = questions.indexWhere((q) => q.id == questionId);
    if (questionIndex != -1) {
      _currentQuestionIndex.value = questionIndex;
    }

    update();
  }

  // Edit existing color custom answer (Prints or Techniques) - reload text for editing
  void editColorCustomAnswer(
    String categoryName,
    String fullTextInput,
    TextEditingController controller,
  ) {
    // Parse the special format: solidColors|||customPrint|||customTechnique
    String existingText = '';

    if (fullTextInput.contains('|||')) {
      final parts = fullTextInput.split('|||');
      if (parts.length >= 3) {
        // Extract the relevant part based on category
        if (categoryName == 'Prints') {
          existingText = parts[1]; // Custom print is at index 1
        } else if (categoryName == 'Techniques') {
          existingText = parts[2]; // Custom technique is at index 2
        }
      }
    }

    // Load the custom text into the provided controller
    controller.text = existingText;

    // Mark custom as selected for this category
    _customSelectedForCategory.value = 'colors:$categoryName';

    // Get existing answer for colors question
    final existingAnswer = _answers['colors'];
    if (existingAnswer != null) {
      // Remove the custom option for this category from selectedOptions
      // so it can be re-submitted
      List<String> updatedOptions = existingAnswer.selectedOptions.toList();

      if (categoryName == 'Prints') {
        updatedOptions.removeWhere(
          (opt) => opt == _selectedPrint.value || opt == 'Prints:Custom',
        );
        _selectedPrint.value = ''; // Clear selection
      } else if (categoryName == 'Techniques') {
        updatedOptions.removeWhere(
          (opt) => opt == _selectedTechnique.value || opt == 'Techniques:Custom',
        );
        _selectedTechnique.value = ''; // Clear selection
      }

      // Parse and preserve the other parts of textInput
      String? solidColorsText;
      List<String> customParts = ['', '']; // [customPrint, customTechnique]

      if (fullTextInput.contains('|||')) {
        final parts = fullTextInput.split('|||');
        if (parts.length >= 3) {
          solidColorsText = parts[0];
          customParts[0] = parts[1]; // Custom print
          customParts[1] = parts[2]; // Custom technique
        }
      }

      // Clear the part we're editing
      if (categoryName == 'Prints') {
        customParts[0] = ''; // Clear custom print
      } else if (categoryName == 'Techniques') {
        customParts[1] = ''; // Clear custom technique
      }

      // Reconstruct textInput without the part being edited
      String finalTextInput = solidColorsText ?? '';
      if (customParts[0].isNotEmpty || customParts[1].isNotEmpty) {
        finalTextInput =
            '${solidColorsText ?? ''}|||${customParts[0]}|||${customParts[1]}';
      }

      // Update answer without this category's custom
      _answers['colors'] = BriefAnswer(
        questionId: 'colors',
        selectedOptions: updatedOptions,
        textInput: finalTextInput.isNotEmpty ? finalTextInput : null,
      );
    }

    // Navigate to the colors question if needed
    final questionIndex = questions.indexWhere((q) => q.id == 'colors');
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

  // Submit custom answer for categorized questions (garment_type, fabrics)
  void submitCategorizedCustomAnswer(
    String questionId,
    String categoryName,
    TextEditingController controller,
  ) async {
    print(
      'Submitting categorized custom answer: ${controller.text} for $questionId:$categoryName',
    ); // Debug

    if (controller.text.trim().isEmpty) {
      return;
    }

    _isTextLoading.value = true;
    update();

    // Simulate processing
    await Future.delayed(const Duration(milliseconds: 800));

    // For garment_type and fabrics: SINGLE SELECTION ONLY
    // Store only this custom option, replacing any previous selection
    _answers[questionId] = BriefAnswer(
      questionId: questionId,
      selectedOptions: ['$categoryName:Custom'],
      textInput: controller.text.trim(), // Store simple custom text
    );

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

  // Submit custom answer for colors question (Prints or Techniques)
  void submitColorCustomAnswer(
    String categoryName,
    TextEditingController controller,
  ) async {
    print(
      'Submitting color custom answer: ${controller.text} for $categoryName',
    ); // Debug

    if (controller.text.trim().isEmpty) {
      return;
    }

    _isTextLoading.value = true;
    update();

    // Simulate processing
    await Future.delayed(const Duration(milliseconds: 800));

    // Get existing answer or create new one
    final existingAnswer = _answers['colors'];
    List<String> selectedOptions =
        existingAnswer?.selectedOptions.toList() ?? [];
    String? solidColorsText =
        existingAnswer?.textInput; // This stores solid colors

    // Store custom print/technique text separately
    // We'll use a special format: "solidColors|||customPrint|||customTechnique"
    List<String> customParts = ['', '']; // [customPrint, customTechnique]

    // Parse existing custom text if it exists (format: solidColors|||customPrint|||customTechnique)
    if (solidColorsText != null && solidColorsText.contains('|||')) {
      final parts = solidColorsText.split('|||');
      if (parts.length >= 3) {
        solidColorsText = parts[0]; // Solid colors
        customParts[0] = parts[1]; // Custom print
        customParts[1] = parts[2]; // Custom technique
      } else if (parts.length == 2) {
        // Legacy format - might be just solid colors
        if (parts[0].startsWith('#')) {
          solidColorsText = solidColorsText; // Keep as is
        }
      }
    }

    // Update the custom part for the selected category
    if (categoryName == 'Prints') {
      selectedOptions.removeWhere(
        (opt) => opt == _selectedPrint.value || opt == 'Prints:Custom',
      );
      _selectedPrint.value = 'Custom';
      customParts[0] = controller.text.trim();
      selectedOptions.add('Prints:Custom');
    } else if (categoryName == 'Techniques') {
      selectedOptions.removeWhere(
        (opt) => opt == _selectedTechnique.value || opt == 'Techniques:Custom',
      );
      _selectedTechnique.value = 'Custom';
      customParts[1] = controller.text.trim();
      selectedOptions.add('Techniques:Custom');
    }

    // Reconstruct textInput: solidColors|||customPrint|||customTechnique
    String finalTextInput = solidColorsText ?? '';
    if (customParts[0].isNotEmpty || customParts[1].isNotEmpty) {
      finalTextInput =
          '${solidColorsText ?? ''}|||${customParts[0]}|||${customParts[1]}';
    }

    _answers['colors'] = BriefAnswer(
      questionId: 'colors',
      selectedOptions: selectedOptions,
      textInput: finalTextInput,
    );

    // Clear custom selection and controller
    _customSelectedForCategory.value = '';
    controller.clear();

    _isTextLoading.value = false;
    update();

    // Auto-advance to next question if this is the current question
    if (currentQuestion.id == 'colors') {
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

  // Add a new image to the inspiration images list
  void addImage(String imagePath) async {
    if (imagePath.isEmpty) return;

    // Check if this is the first image being added
    final isFirstImage = _inspirationImages.isEmpty;

    // Add image to list if not already present
    if (!_inspirationImages.contains(imagePath)) {
      _inspirationImages.add(imagePath);

      // Update answer with all image paths
      _updateInspirationAnswer();
    }

    update();

    // Auto-advance to next question when first image is selected
    if (isFirstImage && currentQuestion.id == 'inspiration') {
      await Future.delayed(const Duration(milliseconds: 800));
      _nextQuestion();
    }
  }

  // Remove a specific image from the inspiration images list
  void removeImage(String imagePath) {
    _inspirationImages.remove(imagePath);

    // Update answer
    if (_inspirationImages.isEmpty) {
      _answers.remove('inspiration');
    } else {
      _updateInspirationAnswer();
    }

    update();
  }

  // Update the inspiration answer with current images
  void _updateInspirationAnswer() {
    if (_inspirationImages.isEmpty) {
      _answers.remove('inspiration');
      _answers.refresh(); // Trigger reactive update
      return;
    }

    _answers['inspiration'] = BriefAnswer(
      questionId: 'inspiration',
      selectedOptions: ['Image'],
      textInput: _inspirationImages.join(
        '|||',
      ), // Store all paths with delimiter
    );

    // Trigger reactive update for the map
    _answers.refresh();
  }

  // Legacy method for backward compatibility - now adds image instead of replacing
  void selectImage(String? imagePath) async {
    if (imagePath != null && imagePath.isNotEmpty) {
      addImage(imagePath);
    }
  }

  // Skip the inspiration question
  void skipInspirationQuestion() async {
    // Clear any selected images
    _inspirationImages.clear();
    _answers.remove('inspiration');

    // Mark question as skipped by creating an empty answer
    _answers['inspiration'] = BriefAnswer(
      questionId: 'inspiration',
      selectedOptions: ['Skipped'],
      textInput: null,
    );

    // Trigger reactive update for the map
    _answers.refresh();
    update();

    // Auto-advance to next question
    await Future.delayed(const Duration(milliseconds: 400));
    _nextQuestion();
  }

  // Methods for multi-part colors question
  void addColorFromPicker(String hexCode) {
    if (hexCode.isNotEmpty && !_selectedColors.contains(hexCode)) {
      _selectedColors.add(hexCode);
      // Update text controller to show all colors
      colorController.text = _selectedColors.join(', ');
      _checkAndSaveColorsAnswer(trigger: 'color');
      update();
    }
  }

  void removeColor(String hexCode) {
    _selectedColors.remove(hexCode);
    colorController.text = _selectedColors.join(', ');
    _checkAndSaveColorsAnswer(trigger: 'color');
    update();
  }

  void selectPrint(String print) {
    if (print == 'Custom') {
      // Toggle custom selection
      if (_customSelectedForCategory.value == 'colors:Prints') {
        // Deselect custom
        _customSelectedForCategory.value = '';
        printCustomController.clear();
        update();
        return;
      }
      // Select custom - show text input for Prints
      _customSelectedForCategory.value = 'colors:Prints';
      _selectedPrint.value = '';
      update();
      return;
    }

    // Check if clicking already selected print to deselect
    if (_selectedPrint.value == print) {
      // Deselect print
      _selectedPrint.value = '';
      // May need to remove the answer if it's the only part selected
      update();
      return;
    }

    // Select new print
    _selectedPrint.value = print;
    // Clear custom selection if a regular option is selected
    if (_customSelectedForCategory.value == 'colors:Prints') {
      _customSelectedForCategory.value = '';
    }
    // Collapse the Prints section after selection
    collapseCategory('colors_Prints');
    _checkAndSaveColorsAnswer(trigger: 'print');
    update();
  }

  void selectTechnique(String technique) {
    if (technique == 'Custom') {
      // Toggle custom selection
      if (_customSelectedForCategory.value == 'colors:Techniques') {
        // Deselect custom
        _customSelectedForCategory.value = '';
        techniqueCustomController.clear();
        update();
        return;
      }
      // Select custom - show text input for Techniques
      _customSelectedForCategory.value = 'colors:Techniques';
      _selectedTechnique.value = '';
      update();
      return;
    }

    // Check if clicking already selected technique to deselect
    if (_selectedTechnique.value == technique) {
      // Deselect technique
      _selectedTechnique.value = '';
      // May need to remove the answer if it's the only part selected
      update();
      return;
    }

    // Select new technique
    _selectedTechnique.value = technique;
    // Clear custom selection if a regular option is selected
    if (_customSelectedForCategory.value == 'colors:Techniques') {
      _customSelectedForCategory.value = '';
    }
    // Collapse the Techniques section after selection
    collapseCategory('colors_Techniques');
    _checkAndSaveColorsAnswer(trigger: 'technique');
    update();
  }

  void updateColorsFromEditDialog({
    String? printSelection,
    String? techniqueSelection,
    String? customPrintText,
    String? customTechniqueText,
  }) {
    final selectedOptions = <String>[];

    String finalPrintValue = '';
    String finalTechniqueValue = '';

    String customPrintValue = customPrintText ?? '';
    String customTechniqueValue = customTechniqueText ?? '';

    if (printSelection != null && printSelection.isNotEmpty) {
      if (printSelection == 'Custom') {
        selectedOptions.add('Prints:Custom');
        finalPrintValue = 'Custom';
      } else {
        selectedOptions.add(printSelection);
        finalPrintValue = printSelection;
        customPrintValue = '';
      }
    } else {
      customPrintValue = '';
    }

    if (techniqueSelection != null && techniqueSelection.isNotEmpty) {
      if (techniqueSelection == 'Custom') {
        selectedOptions.add('Techniques:Custom');
        finalTechniqueValue = 'Custom';
      } else {
        selectedOptions.add(techniqueSelection);
        finalTechniqueValue = techniqueSelection;
        customTechniqueValue = '';
      }
    } else {
      customTechniqueValue = '';
    }

    _selectedPrint.value = finalPrintValue;
    _selectedTechnique.value = finalTechniqueValue;

    final solidColorsText = _selectedColors.isNotEmpty
        ? _selectedColors.join('|||')
        : '';

    String? textInput;
    if (solidColorsText.isNotEmpty ||
        customPrintValue.isNotEmpty ||
        customTechniqueValue.isNotEmpty) {
      textInput =
          '$solidColorsText|||$customPrintValue|||$customTechniqueValue';
    }

    _answers['colors'] = BriefAnswer(
      questionId: 'colors',
      selectedOptions: selectedOptions,
      textInput: textInput,
    );
    _answers.refresh();
    update();
  }

  void _checkAndSaveColorsAnswer({String? trigger}) {
    final hadAnswer = _answers.containsKey('colors');
    final hasAnySelection =
        _selectedColors.isNotEmpty ||
        _selectedPrint.value.isNotEmpty ||
        _selectedTechnique.value.isNotEmpty;

    if (!hasAnySelection) {
      if (hadAnswer) {
        _answers.remove('colors');
        _answers.refresh();
      }
      return;
    }

    // Get existing answer to preserve custom print/technique text
    final existingAnswer = _answers['colors'];
    String customPrintText = '';
    String customTechniqueText = '';

    // Parse existing custom text if it exists (format: solidColors|||customPrint|||customTechnique)
    if (existingAnswer?.textInput != null &&
        existingAnswer!.textInput!.contains('|||')) {
      final parts = existingAnswer.textInput!.split('|||');
      if (parts.length >= 3) {
        customPrintText = parts[1];
        customTechniqueText = parts[2];
      }
    }

    final selectedOptions = <String>[];
    if (_selectedPrint.value.isNotEmpty) {
      if (_selectedPrint.value == 'Custom') {
        selectedOptions.add('Prints:Custom');
      } else {
        selectedOptions.add(_selectedPrint.value);
      }
    } else if (existingAnswer?.selectedOptions.contains('Prints:Custom') ??
        false) {
      // Preserve custom print option if it exists
      selectedOptions.add('Prints:Custom');
    }

    if (_selectedTechnique.value.isNotEmpty) {
      if (_selectedTechnique.value == 'Custom') {
        selectedOptions.add('Techniques:Custom');
      } else {
        selectedOptions.add(_selectedTechnique.value);
      }
    } else if (existingAnswer?.selectedOptions.contains('Techniques:Custom') ??
        false) {
      // Preserve custom technique option if it exists
      selectedOptions.add('Techniques:Custom');
    }

    // Build textInput: solidColors|||customPrint|||customTechnique
    String? textInput;
    final solidColorsText = _selectedColors.isNotEmpty
        ? _selectedColors.join('|||')
        : '';

    if (solidColorsText.isNotEmpty ||
        customPrintText.isNotEmpty ||
        customTechniqueText.isNotEmpty) {
      textInput = '$solidColorsText|||$customPrintText|||$customTechniqueText';
    }

    _answers['colors'] = BriefAnswer(
      questionId: 'colors',
      selectedOptions: selectedOptions,
      textInput: textInput,
    );
    _answers.refresh();

    // Auto-advance to next question after selection (both initial and modification)
    if (currentQuestion.id == 'colors') {
      final currentIndex = currentQuestionIndex;
      Future.delayed(const Duration(milliseconds: 1200), () {
        if (_currentQuestionIndex.value == currentIndex &&
            currentQuestion.id == 'colors') {
          _nextQuestion();
        }
      });
    }
  }

  void clearColorsSelection() {
    _selectedColors.clear();
    _selectedPrint.value = '';
    _selectedTechnique.value = '';
    colorController.clear();
    _answers.remove('colors');
    _answers.refresh();
    update();
  }

  void _nextQuestion() {
    print('=== NEXT QUESTION CALLED ===');
    print('Current question index: $currentQuestionIndex');
    print('Total questions: ${questions.length}');
    print('All questions completed: $isAllQuestionsCompleted');

    // Clear custom selection when moving to next question
    _customSelectedForQuestion.value = '';

    // Clear any temporary selections for the current question
    _tempSelections.remove(currentQuestion.id);

    if (currentQuestionIndex < questions.length - 1) {
      print('Moving to next question');
      _currentQuestionIndex.value++;
      update();
    } else {
      print('At last question or beyond');
      // Check if all questions are actually answered
      if (isAllQuestionsCompleted) {
        print('All questions completed, showing completion screen');
        update(); // Update UI to show Next Steps button
        _showCompletionScreen();
      } else {
        print('Not all questions completed yet');
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
      final l10n = AppLocalizations.of(Get.context!)!;
      Get.snackbar(
        l10n.briefComplete,
        l10n.briefCompletedSuccessfully,
        snackPosition: SnackPosition.TOP,
        backgroundColor: Colors.black,
        colorText: Colors.white,
        duration: const Duration(milliseconds: 1500),
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

    // Special handling for multi-part color question
    if (question.type == 'multi_part_color') {
      _showMultiPartColorEditDialog(questionId);
      return;
    }

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
            // Legacy format without category prefix
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
          'Edit Answer',
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
                  'Select your answer:',
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
                                    tempSelectedOptions.contains(option) ||
                                    tempSelectedOptions.contains(
                                      '${category.key}:$option',
                                    );
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
                                    if (question.allowMultiple) {
                                      // Toggle for multiple selection
                                      if (isSelected) {
                                        tempSelectedOptions.remove(option);
                                        tempSelectedOptions.removeWhere(
                                          (opt) =>
                                              opt == '${category.key}:$option',
                                        );
                                      } else {
                                        tempSelectedOptions.removeWhere(
                                          (opt) =>
                                              category.value.contains(opt) ||
                                              opt.startsWith(
                                                '${category.key}:',
                                              ),
                                        );
                                        tempSelectedOptions.add(option);
                                      }
                                    } else {
                                      // Toggle for single selection
                                      if (isSelected) {
                                        // Deselect by removing from this category
                                        tempSelectedOptions.removeWhere(
                                          (opt) =>
                                              opt == option ||
                                              opt == '${category.key}:$option',
                                        );
                                      } else {
                                        // Select by clearing category and adding new option
                                        tempSelectedOptions.removeWhere(
                                          (opt) =>
                                              category.value.contains(opt) ||
                                              opt.startsWith('${category.key}:'),
                                        );
                                        tempSelectedOptions.value = [option];
                                      }
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
                              if (isSelected) {
                                tempSelectedOptions.remove(option);
                              } else {
                                tempSelectedOptions.add(option);
                              }
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
                                hintText: 'Type your custom answer...',
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
            child: Text('Cancel', style: TextStyle(color: Colors.grey[600])),
          ),
          ElevatedButton(
            onPressed: () {
              // For categorized questions, validate and collect custom text
              if (question.type == 'chips_categorized' &&
                  categoriesMap != null) {
                // Validate custom inputs for categorized questions
                for (var category in categoriesMap.entries) {
                  final hasCustom = tempSelectedOptions.contains(
                    '${category.key}:Custom',
                  );
                  final controller = categoryCustomControllers[category.key]!;
                  if (hasCustom && controller.text.trim().isEmpty) {
                    final l10n = AppLocalizations.of(Get.context!)!;
                    Get.snackbar(
                      l10n.invalidInput,
                      l10n.pleaseEnterCustomAnswer(category.key),
                      backgroundColor: Colors.black,
                      colorText: Colors.white,
                      snackPosition: SnackPosition.TOP,
                      duration: const Duration(milliseconds: 1500),
                    );
                    return;
                  }
                }

                // Collect custom texts for all categories
                Map<String, String> customTexts = {};
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

                // Save the changes
                _answers[questionId] = BriefAnswer(
                  questionId: questionId,
                  selectedOptions: tempSelectedOptions.toList(),
                  textInput: customTextString,
                );
              } else {
                // For regular chip questions
                // Validate custom input if Custom is selected
                if (tempSelectedOptions.contains('Custom') &&
                    tempCustomController.text.trim().isEmpty) {
                  final l10n = AppLocalizations.of(Get.context!)!;
                  Get.snackbar(
                    l10n.invalidInput,
                    l10n.pleaseEnterCustomAnswerGeneric,
                    backgroundColor: Colors.black,
                    colorText: Colors.white,
                    snackPosition: SnackPosition.TOP,
                    duration: const Duration(milliseconds: 1500),
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
              }

              // Close dialog first
              Navigator.of(Get.overlayContext!).pop();

              // Then update and show success message
              update();
              final l10n = AppLocalizations.of(Get.context!)!;
              Get.snackbar(
                l10n.answerUpdated,
                l10n.answerUpdatedSuccessfully,
                backgroundColor: Colors.black,
                colorText: Colors.white,
                duration: const Duration(milliseconds: 1500),
                margin: EdgeInsets.all(16),
                snackPosition: SnackPosition.TOP,
              );

              if (question.type == 'chips_categorized' &&
                  categoriesMap != null) {
                Future.delayed(const Duration(milliseconds: 100), () {
                  for (var controller in categoryCustomControllers.values) {
                    controller.dispose();
                  }
                });
              } else {
                Future.delayed(const Duration(milliseconds: 100), () {
                  tempCustomController.dispose();
                });
              }
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

  // Show edit dialog for multi-part color question
  void _showMultiPartColorEditDialog(String questionId) {
    final question = questions.firstWhere((q) => q.id == questionId);

    final existingAnswer = _answers['colors'];

    String customPrintText = '';
    String customTechniqueText = '';

    if (existingAnswer?.textInput != null &&
        existingAnswer!.textInput!.contains('|||')) {
      final parts = existingAnswer.textInput!.split('|||');
      if (parts.length >= 2) {
        customPrintText = parts[1];
      }
      if (parts.length >= 3) {
        customTechniqueText = parts[2];
      }
    }

    final bool hasCustomPrint =
        existingAnswer?.selectedOptions.contains('Prints:Custom') ?? false;
    final bool hasCustomTechnique =
        existingAnswer?.selectedOptions.contains('Techniques:Custom') ?? false;

    if (existingAnswer?.textInput != null &&
        !existingAnswer!.textInput!.contains('|||')) {
      if (hasCustomPrint && customPrintText.isEmpty) {
        customPrintText = existingAnswer.textInput!;
      }
      if (hasCustomTechnique && customTechniqueText.isEmpty) {
        customTechniqueText = existingAnswer.textInput!;
      }
    }

    final printCustomController = TextEditingController(text: customPrintText);
    final techniqueCustomController = TextEditingController(
      text: customTechniqueText,
    );

    final RxString tempPrint =
        (hasCustomPrint ? 'Custom' : _selectedPrint.value).obs;
    final RxString tempTechnique =
        (hasCustomTechnique ? 'Custom' : _selectedTechnique.value).obs;

    Get.dialog(
      AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: Text(
          'Edit Prints & Techniques',
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
                  'Select your prints and techniques',
                  style: TextStyle(fontSize: 14, color: Colors.grey[600]),
                ),
                SizedBox(height: 16),
                Text(
                  'Prints',
                  style: TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                    color: Colors.grey[700],
                  ),
                ),
                SizedBox(height: 8),
                Obx(
                  () => Wrap(
                    spacing: 8,
                    runSpacing: 8,
                    children: (question.categories!['Prints'] ?? []).map((
                      print,
                    ) {
                      final isSelected = tempPrint.value == print;
                      return GestureDetector(
                        onTap: () {
                          tempPrint.value = print;
                          if (print != 'Custom') {
                            printCustomController.clear();
                          }
                        },
                        child: Container(
                          padding: EdgeInsets.symmetric(
                            horizontal: 14,
                            vertical: 8,
                          ),
                          decoration: BoxDecoration(
                            color: isSelected ? Colors.black : Colors.grey[100],
                            borderRadius: BorderRadius.circular(20),
                            border: Border.all(
                              color: isSelected
                                  ? Colors.black
                                  : Colors.grey[300]!,
                            ),
                          ),
                          child: Text(
                            print,
                            style: TextStyle(
                              color: isSelected ? Colors.white : Colors.black,
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
                ),
                Obx(
                  () => tempPrint.value == 'Custom'
                      ? Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            SizedBox(height: 12),
                            TextField(
                              controller: printCustomController,
                              decoration: InputDecoration(
                                hintText: 'Enter custom print...',
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
                SizedBox(height: 16),
                Text(
                  'Techniques',
                  style: TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                    color: Colors.grey[700],
                  ),
                ),
                SizedBox(height: 8),
                Obx(
                  () => Wrap(
                    spacing: 8,
                    runSpacing: 8,
                    children: (question.categories!['Techniques'] ?? []).map((
                      technique,
                    ) {
                      final isSelected = tempTechnique.value == technique;
                      return GestureDetector(
                        onTap: () {
                          tempTechnique.value = technique;
                          if (technique != 'Custom') {
                            techniqueCustomController.clear();
                          }
                        },
                        child: Container(
                          padding: EdgeInsets.symmetric(
                            horizontal: 14,
                            vertical: 8,
                          ),
                          decoration: BoxDecoration(
                            color: isSelected ? Colors.black : Colors.grey[100],
                            borderRadius: BorderRadius.circular(20),
                            border: Border.all(
                              color: isSelected
                                  ? Colors.black
                                  : Colors.grey[300]!,
                            ),
                          ),
                          child: Text(
                            technique,
                            style: TextStyle(
                              color: isSelected ? Colors.white : Colors.black,
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
                ),
                Obx(
                  () => tempTechnique.value == 'Custom'
                      ? Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            SizedBox(height: 12),
                            TextField(
                              controller: techniqueCustomController,
                              decoration: InputDecoration(
                                hintText: 'Enter custom technique...',
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
            onPressed: () => Navigator.of(Get.overlayContext!).pop(),
            child: Text('Cancel', style: TextStyle(color: Colors.grey[600])),
          ),
          ElevatedButton(
            onPressed: () {
              final l10n = AppLocalizations.of(Get.context!)!;
              if (tempPrint.value == 'Custom' &&
                  printCustomController.text.trim().isEmpty) {
                Get.snackbar(
                  l10n.invalidInput,
                  l10n.pleaseEnterCustomPrint,
                  backgroundColor: Colors.black,
                  colorText: Colors.white,
                  snackPosition: SnackPosition.TOP,
                  duration: const Duration(milliseconds: 1500),
                );
                return;
              }

              if (tempTechnique.value == 'Custom' &&
                  techniqueCustomController.text.trim().isEmpty) {
                Get.snackbar(
                  l10n.invalidInput,
                  l10n.pleaseEnterCustomTechnique,
                  backgroundColor: Colors.black,
                  colorText: Colors.white,
                  snackPosition: SnackPosition.TOP,
                  duration: const Duration(milliseconds: 1500),
                );
                return;
              }

              updateColorsFromEditDialog(
                printSelection: tempPrint.value,
                techniqueSelection: tempTechnique.value,
                customPrintText: tempPrint.value == 'Custom'
                    ? printCustomController.text.trim()
                    : null,
                customTechniqueText: tempTechnique.value == 'Custom'
                    ? techniqueCustomController.text.trim()
                    : null,
              );

              final dialogContext = Get.overlayContext;
              if (dialogContext != null) {
                FocusScope.of(dialogContext).unfocus();
              }

              Navigator.of(Get.overlayContext!).pop();

              update();
              final l10nSnack = AppLocalizations.of(Get.context!)!;
              Get.snackbar(
                l10nSnack.answerUpdated,
                l10nSnack.printsAndTechniquesUpdated,
                backgroundColor: Colors.black,
                colorText: Colors.white,
                duration: const Duration(milliseconds: 1500),
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
    ).whenComplete(() {
      Future.delayed(const Duration(milliseconds: 100), () {
        printCustomController.dispose();
        techniqueCustomController.dispose();
      });
    });
  }

  // New methods for the updated UI
  bool isQuestionAnswered(String questionId) {
    final answered = _answers.containsKey(questionId);
    // Access the observable to ensure Obx detects changes
    _answers.isEmpty; // This triggers reactivity
    return answered;
  }

  BriefAnswer? getAnswer(String questionId) {
    return _answers[questionId];
  }

  // Method to get number of questions to show in the list
  int get questionsToShow {
    // Always show all answered questions + current unanswered question
    // This allows users to edit any previous answer
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
    if (isCustomSelectedForCurrentQuestion() &&
        questionIndex == currentQuestionIndex) {
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
  void saveCreativeBriefData() {
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
          creativeBriefData['targetAudience'] =
              answer.selectedOptions.isNotEmpty
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
          // Check if question was skipped
          if (answer.selectedOptions.contains('Skipped')) {
            creativeBriefData['inspiration'] = [];
            creativeBriefData['inspirationType'] = 'skipped';
          }
          // For image type, save the image paths
          else if (answer.textInput?.isNotEmpty == true &&
              answer.selectedOptions.contains('Image')) {
            // Multiple images stored with delimiter
            if (answer.textInput!.contains('|||')) {
              final imagePaths = answer.textInput!.split('|||');
              creativeBriefData['inspiration'] = imagePaths; // Save as array
            } else {
              // Single image (backward compatibility)
              creativeBriefData['inspiration'] = [
                answer.textInput!,
              ]; // Save as array
            }
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
          print('=== PROCESSING COLORS FOR API ===');
          print('Raw answer.textInput: ${answer.textInput}');
          print('Raw answer.selectedOptions: ${answer.selectedOptions}');

          // Multi-part colors: solid colors, print, technique
          // textInput format: "solidColors|||customPrint|||customTechnique"
          // selectedOptions contains ['Prints:value', 'Techniques:value'] where value can be regular option or 'Custom'

          String? customPrintText;
          String? customTechniqueText;
          List<String> solidColorsList = [];

          // Parse textInput to extract solid colors and custom texts
          if (answer.textInput?.isNotEmpty == true) {
            final parts = answer.textInput!.split('|||');
            print('Split parts: $parts');
            if (parts.isNotEmpty) {
              // First part is solid colors (can be empty or hex codes separated by commas)
              if (parts[0].isNotEmpty && parts[0].contains('#')) {
                solidColorsList = parts[0].split(',').map((e) => e.trim()).toList();
              }
              // Second part is custom print text (if exists)
              if (parts.length >= 2 && parts[1].isNotEmpty) {
                customPrintText = parts[1];
                print('Custom print text found: $customPrintText');
              }
              // Third part is custom technique text (if exists)
              if (parts.length >= 3 && parts[2].isNotEmpty) {
                customTechniqueText = parts[2];
                print('Custom technique text found: $customTechniqueText');
              }
            }
          }

          creativeBriefData['solidColors'] = solidColorsList;

          // Process print - handle both regular options and custom
          // Regular format: selectedOptions: ['Floral', 'Embroidery']
          // Custom format: selectedOptions: ['Prints:Custom'] with textInput containing custom text
          if (answer.selectedOptions.isNotEmpty) {
            // Try to find option with "Prints:" prefix (Custom case)
            final printOptionWithPrefix = answer.selectedOptions.firstWhere(
              (opt) => opt.startsWith('Prints:'),
              orElse: () => '',
            );

            if (printOptionWithPrefix.isNotEmpty) {
              // Custom option format: "Prints:Custom"
              final printValue = printOptionWithPrefix.substring('Prints:'.length);
              if (printValue == 'Custom' && customPrintText != null) {
                creativeBriefData['print'] = customPrintText; // Use actual custom text
                print('Using custom print text: $customPrintText');
              } else {
                creativeBriefData['print'] = printValue;
                print('Using print option with prefix: $printValue');
              }
            } else {
              // Regular option format: just the option name (first item in selectedOptions)
              final regularPrintOption = answer.selectedOptions.first;
              // Make sure it's not a Techniques option
              if (!regularPrintOption.startsWith('Techniques:')) {
                creativeBriefData['print'] = regularPrintOption;
                print('Using regular print option: $regularPrintOption');
              }
            }
          }

          // Process technique - handle both regular options and custom
          if (answer.selectedOptions.isNotEmpty) {
            // Try to find option with "Techniques:" prefix (Custom case)
            final techniqueOptionWithPrefix = answer.selectedOptions.firstWhere(
              (opt) => opt.startsWith('Techniques:'),
              orElse: () => '',
            );

            if (techniqueOptionWithPrefix.isNotEmpty) {
              // Custom option format: "Techniques:Custom"
              final techniqueValue = techniqueOptionWithPrefix.substring('Techniques:'.length);
              if (techniqueValue == 'Custom' && customTechniqueText != null) {
                creativeBriefData['technique'] = customTechniqueText; // Use actual custom text
                print('Using custom technique text: $customTechniqueText');
              } else {
                creativeBriefData['technique'] = techniqueValue;
                print('Using technique option with prefix: $techniqueValue');
              }
            } else if (answer.selectedOptions.length > 1) {
              // Regular option format: second item in selectedOptions
              final regularTechniqueOption = answer.selectedOptions[1];
              // Make sure it's not a Prints option
              if (!regularTechniqueOption.startsWith('Prints:')) {
                creativeBriefData['technique'] = regularTechniqueOption;
                print('Using regular technique option: $regularTechniqueOption');
              }
            }
          }

          print('Final print value for API: ${creativeBriefData['print']}');
          print('Final technique value for API: ${creativeBriefData['technique']}');
          break;
        case 'fabrics':
          print('=== PROCESSING FABRICS FOR API ===');
          print('Raw answer.selectedOptions: ${answer.selectedOptions}');
          print('Raw answer.textInput: ${answer.textInput}');

          // Fabrics is a categorized chips question (selectedOptions)
          // Format: "categoryName:value" where value can be regular option or 'Custom'
          // If Custom, textInput contains the actual custom text
          if (answer.selectedOptions.isNotEmpty) {
            final fabricOption = answer.selectedOptions.first;
            if (fabricOption.contains(':')) {
              final parts = fabricOption.split(':');
              final fabricValue = parts.length > 1 ? parts[1] : fabricOption;

              // If value is "Custom", use the textInput instead
              if (fabricValue == 'Custom' && answer.textInput?.isNotEmpty == true) {
                creativeBriefData['fabrics'] = answer.textInput!; // Use actual custom text
                print('Using custom fabric text: ${answer.textInput}');
              } else {
                creativeBriefData['fabrics'] = fabricValue; // Use regular option
                print('Using regular fabric option: $fabricValue');
              }
            } else {
              creativeBriefData['fabrics'] = fabricOption;
            }
          } else {
            creativeBriefData['fabrics'] = '';
          }

          print('Final fabrics value for API: ${creativeBriefData['fabrics']}');
          break;
      }
    }

    // Save to design data service
    _dataService.setCreativeBriefData(creativeBriefData);

    print('Creative Brief data saved: $creativeBriefData');
  }

  // Method to proceed to next screen with data saving
  void proceedToNextScreen() {
    saveCreativeBriefData();
    // _saveCreativeBriefData();

    // Track creative brief completion
    final data = _dataService.getCreativeBriefData();
    PostHogAnalyticsService().trackCreativeBriefCompleted(
      garmentType: data['garment_type']?.toString() ?? '',
      style: data['style']?.toString() ?? '',
      targetAudience: data['target_audience']?.toString() ?? '',
    );

    // Pass edit mode data to next screen
    if (_isEditingCurrentSession.value) {
      // Editing current session - skip onboarding and preserve answers
      print('🔄 Continuing to Refining Concept in edit current session mode');
      Get.toNamed(
        '/refining_concept',
        arguments: {'editCurrentSession': true, 'preserveAnswers': true},
      );
    } else if (_isEditMode.value && _editingTechPack != null) {
      // In edit mode, skip onboarding and go directly to questionnaire
      Get.toNamed(
        '/refining_concept',
        arguments: {'editMode': true, 'techPackModel': _editingTechPack},
      );
    } else {
      Get.toNamed('/refine_concept');
    }
  }

  // ============================================================================
  // LOCALIZATION HELPER METHODS (Presentation Layer Only)
  // ============================================================================
  // CRITICAL: These methods are ONLY for UI display purposes.
  // All internal storage, business logic, and API calls continue to use English.
  // Language changes affect ONLY what users see, not internal data.

  /// Get localized question text for display
  /// Internal questionId remains in English
  String getLocalizedQuestionText(BuildContext context, String questionId) {
    final service = CreativeBriefLocalizationService(context);
    return service.getLocalizedQuestion(questionId);
  }

  /// Get localized category name for display
  /// Internal category storage remains in English
  String getLocalizedCategoryName(BuildContext context, String categoryName) {
    final service = CreativeBriefLocalizationService(context);
    return service.getLocalizedCategory(categoryName);
  }

  /// Get localized option for display
  /// Internal option storage remains in English
  String getLocalizedOption(BuildContext context, String englishOption) {
    final service = CreativeBriefLocalizationService(context);
    return service.getLocalizedOption(englishOption);
  }

  /// Get localized list of options for display
  /// Internal options list remains in English
  List<String> getLocalizedOptions(BuildContext context, List<String> englishOptions) {
    final service = CreativeBriefLocalizationService(context);
    return service.getLocalizedOptions(englishOptions);
  }

  /// Get localized categories map for display
  /// Internal categories map remains in English
  Map<String, List<String>> getLocalizedCategories(
    BuildContext context,
    Map<String, List<String>> englishCategories,
  ) {
    final service = CreativeBriefLocalizationService(context);
    return service.getLocalizedCategories(englishCategories);
  }

  /// Convert user-selected localized option back to English for storage
  /// This ensures internal storage always uses English
  String getEnglishOptionFromLocalized(BuildContext context, String localizedOption) {
    final service = CreativeBriefLocalizationService(context);
    return service.getEnglishOption(localizedOption);
  }

  /// Convert user-selected localized category back to English for storage
  /// This ensures internal storage always uses English
  String getEnglishCategoryFromLocalized(BuildContext context, String localizedCategory) {
    final service = CreativeBriefLocalizationService(context);
    return service.getEnglishCategory(localizedCategory);
  }
}
