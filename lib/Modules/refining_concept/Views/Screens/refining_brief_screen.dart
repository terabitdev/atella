import 'package:atella/l10n/generated/app_localizations.dart';
import 'package:atella/Data/Models/brief_questions_model.dart';
import 'package:atella/Modules/refining_concept/controllers/refining_concept_controller.dart';
import 'package:atella/Modules/creative_brief/Views/Widgets/text_input_send_widget.dart';
import 'package:atella/Widgets/custom_roundbutton.dart';
import 'package:atella/Widgets/questionare_app_header.dart';
import 'package:atella/core/themes/app_colors.dart';
import 'package:atella/core/themes/app_fonts.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:lottie/lottie.dart';

class RefiningBriefScreen extends GetView<RefiningConceptController> {
  const RefiningBriefScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    SystemChrome.setSystemUIOverlayStyle(
      const SystemUiOverlayStyle(
        statusBarColor: Colors.transparent,
        statusBarIconBrightness: Brightness.dark,
        statusBarBrightness: Brightness.light,
      ),
    );

    return Scaffold(
      backgroundColor: const Color(0xFFFAFAFA),
      body: Column(
        children: [
          AppHeader(
            title: l10n.rcRefiningTheConcept,
            timeTextGetter: () => controller.currentTime,
            titleStyle: qTextStyle14600,
            onBack: () => Navigator.of(context).pop(),
            padding: const EdgeInsets.only(
              left: 20.0,
              right: 20.0,
              top: 54.0,
              bottom: 25.0,
            ),
          ),
          Expanded(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 24),
              child: _buildQuestionsList(),
            ),
          ),
          Obx(() {
            // IMPORTANT: Check for custom input fields FIRST before checking if all questions are answered
            // This allows editing custom inputs even after all questions are completed

            // Show categorized custom input when a category custom is selected (for ANY question, not just current)
            final customInfo = controller.getAnyCustomSelectedCategory();
            if (customInfo != null) {
              return _buildBottomCategorizedCustomInput(
                l10n,
                customInfo['questionId']!,
                customInfo['categoryName']!,
              );
            }

            // Show custom input if custom is selected for ANY regular chip question
            final customQuestionId = controller.getAnyCustomSelectedQuestion();
            if (customQuestionId != null) {
              return _buildBottomCustomInput(l10n);
            }

            // Show button when all questions are answered (temporary selections will auto-confirm)
            final allQuestionsAnswered =
                controller.answers.length >= controller.questions.length;
            if (allQuestionsAnswered) {
              return _buildBottomButton(l10n);
            }

            return const SizedBox.shrink();
          }),
        ],
      ),
    );
  }

  Widget _buildQuestionsList() {
    return Obx(
      () => ListView.builder(
        padding: const EdgeInsets.only(top: 0, bottom: 20),
        itemCount: controller.questionsToShow,
        itemBuilder: (context, index) {
          final question = controller.questions[index];
          final isAnswered = controller.isQuestionAnswered(question.id);
          final isCurrentQuestion = index == controller.currentQuestionIndex;

          // Debug prints
          if (index == 0) {
            // Only debug first question to avoid spam
            print(
              'Question ${question.id}: isAnswered=$isAnswered, isCurrentQuestion=$isCurrentQuestion',
            );
            print('Answer count: ${controller.answers.length}');
            print('Temp selections: ${controller.tempSelections}');
          }

          // Debug prints
          if (isCurrentQuestion) {
            print('Current question: ${question.id}');
            print(
              'Is Custom Selected: ${controller.isCustomSelectedForCurrentQuestion()}',
            );
            print('Is Answered: $isAnswered');
            print('Question Type: ${question.type}');
          }

          return Column(
            children: [
              _buildQuestionItem(context, question, index),
              // Show animation below current unanswered question's answers
              if (controller.shouldShowAnimationAfterQuestion(index))
                _buildLottieAnimation(),
            ],
          );
        },
      ),
    );
  }

  Widget _buildLottieAnimation() {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 20),
      child: Center(
        child: Lottie.asset(
          'assets/lottie/Loading_dots.json',
          width: 100.w,
          height: 100.h,
          fit: BoxFit.contain,
          repeat: true,
          animate: true,
        ),
      ),
    );
  }

  // Display custom answer - matching creative brief style
  Widget _buildCustomAnswerDisplay(BriefAnswer? answer) {
    if (answer?.textInput != null && answer!.textInput!.isNotEmpty) {
      return GestureDetector(
        onTap: () {
          // Allow user to edit the custom answer by re-selecting Custom
          controller.editCustomAnswer(answer.questionId, answer.textInput!);
        },
        child: Container(
          margin: EdgeInsets.only(top: 8.h, left: 8.w),
          padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 8.h),
          decoration: BoxDecoration(
            color: AppColors.buttonColor,
            borderRadius: BorderRadius.circular(20.r),
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Flexible(
                child: Text(
                  answer.textInput!,
                  style: TextStyle(
                    fontSize: 14.sp,
                    color: Colors.white,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ),
              SizedBox(width: 8.w),
              Icon(
                Icons.edit,
                size: 16.sp,
                color: Colors.white.withValues(alpha: 0.8),
              ),
            ],
          ),
        ),
      );
    }
    return const SizedBox.shrink();
  }

  Widget _buildQuestionItem(BuildContext context, BriefQuestion question, int index) {
    final isAnswered = controller.isQuestionAnswered(question.id);
    final answer = controller.getAnswer(question.id);

    return Container(
      margin: const EdgeInsets.only(bottom: 32),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Question Bubble - matching creative brief design EXACTLY
          Container(
            padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 14.h),
            decoration: BoxDecoration(
              color: const Color(0xFFF8F9FA),
              borderRadius: BorderRadius.circular(12.r),
              border: Border.all(
                color: isAnswered
                    ? AppColors.buttonColor.withValues(alpha: 0.3)
                    : const Color(0xFFE8E8E8),
                width: 1.5,
              ),
            ),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Expanded(
                  child: Text(
                    // Display localized question text, but question.id remains in English internally
                    controller.getLocalizedQuestionText(context, question.id),
                    style: TextStyle(
                      fontSize: 15.sp,
                      fontWeight: FontWeight.w600,
                      color: const Color(0xFF2C2C2C),
                      height: 1.5,
                      letterSpacing: -0.2,
                    ),
                  ),
                ),
                if (isAnswered) ...[
                  SizedBox(width: 12.w),
                  Container(
                    padding: const EdgeInsets.all(5),
                    decoration: BoxDecoration(
                      color: AppColors.buttonColor,
                      shape: BoxShape.circle,
                    ),
                    child: const Icon(
                      Icons.check,
                      color: Colors.white,
                      size: 14,
                    ),
                  ),
                ],
              ],
            ),
          ),

          SizedBox(height: 16.h),

          // Answer Options
          if (question.type == 'chips')
            _buildChipOptions(context, question, isAnswered, answer),

          // Answer Options for categorized chips
          if (question.type == 'chips_categorized')
            _buildCategorizedChipOptions(context, question, isAnswered, answer),

          // Show custom answer if answered with custom text
          // ONLY for regular chips (not categorized - those show custom within categories)
          if (isAnswered && question.type == 'chips')
            _buildCustomAnswerDisplay(answer),
        ],
      ),
    );
  }

  Widget _buildChipOptions(
    BuildContext context,
    BriefQuestion question,
    bool isAnswered,
    BriefAnswer? answer,
  ) {
    // For multi-select questions, show all selected options
    if (question.allowMultiple) {
      return Obx(() {
        // Get the latest answer from controller to ensure reactivity
        final latestAnswer = controller.getAnswer(question.id);
        final selectedOptions = controller.tempMultiSelections.isNotEmpty
            ? controller.tempMultiSelections.toList()
            : (latestAnswer?.selectedOptions ?? []);

        return _buildExpandableMultiSelectSection(
          context: context,
          questionId: question.id,
          options: question.options,
          selectedOptions: selectedOptions,
          onTap: (option) =>
              controller.selectOption(option, forQuestionId: question.id),
          isAnswered: isAnswered,
        );
      });
    }

    // For single-select questions, use expandable section
    return Obx(() {
      // Get the latest answer from controller to ensure reactivity
      final latestAnswer = controller.getAnswer(question.id);
      final selectedOptions = latestAnswer?.selectedOptions ?? [];

      return _buildExpandableChipSection(
        context: context,
        questionId: question.id,
        options: question.options,
        selectedOptions: selectedOptions,
        onTap: (option) =>
            controller.selectOption(option, forQuestionId: question.id),
        isAnswered: isAnswered,
      );
    });
  }

  Widget _buildCategorizedChipOptions(
    BuildContext context,
    BriefQuestion question,
    bool isAnswered,
    BriefAnswer? answer,
  ) {
    if (question.categories == null) {
      return const SizedBox.shrink();
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: question.categories!.entries.map((category) {
        return _buildCategorySection(
          context: context,
          categoryName: category.key,
          options: category.value,
          question: question,
          isAnswered: isAnswered,
          answer: answer,
        );
      }).toList(),
    );
  }

  Widget _buildCategorySection({
    required BuildContext context,
    required String categoryName,
    required List<String> options,
    required BriefQuestion question,
    required bool isAnswered,
    required BriefAnswer? answer,
  }) {
    return _buildExpandableCategorizedSection(
      context: context,
      questionId: question.id,
      categoryName: categoryName,
      options: options,
      answer: answer,
      onTap: (option) {
        controller.selectCategorizedOption(question.id, categoryName, option);
      },
      isAnswered: isAnswered,
    );
  }

  // Expandable categorized section - matching creative brief behavior
  // Expandable categorized section - matching creative brief behavior
  Widget _buildExpandableCategorizedSection({
    required BuildContext context,
    required String questionId,
    required String categoryName,
    required List<String> options,
    required BriefAnswer? answer,
    required Function(String) onTap,
    required bool isAnswered,
  }) {
    final categoryKey = '${questionId}_$categoryName';

    // Get selected option for this category - check both temp and final selections
    String? getSelectedValue() {
      // First check temp categorized selections
      final tempCatSelection = controller.getTempSelectionForCategory(
        categoryName,
      );
      if (tempCatSelection != null) {
        if (questionId == 'specific_features') {
          print('[$categoryName] Temp selection found: $tempCatSelection');
        }
        return tempCatSelection;
      }

      // Then check final answer
      if (answer?.selectedOptions.isNotEmpty == true) {
        for (final opt in answer!.selectedOptions) {
          if (opt.startsWith('$categoryName:')) {
            final value = opt.substring('$categoryName:'.length);
            if (questionId == 'specific_features') {
              print('[$categoryName] Final selection found: $value');
            }
            return value;
          }
        }
      }
      if (questionId == 'specific_features') {
        print('[$categoryName] No selection found');
      }
      return null;
    }

    // Get custom text for category
    String? getCustomText() {
      final textInput = answer?.textInput;
      if (textInput == null || textInput.isEmpty) {
        if (questionId == 'specific_features') {
          print('[$categoryName] No textInput');
        }
        return null;
      }

      if (questionId == 'specific_features') {
        print('[$categoryName] Checking textInput: $textInput');
      }

      if (textInput.contains('|||')) {
        final parts = textInput.split('|||');
        for (final part in parts) {
          final separatorIndex = part.indexOf(':');
          if (separatorIndex != -1) {
            final key = part.substring(0, separatorIndex);
            final value = part.substring(separatorIndex + 1);
            if (key == categoryName) {
              if (questionId == 'specific_features') {
                print('[$categoryName] Custom text found (multi): $value');
              }
              return value;
            }
          }
        }
      } else if (textInput.contains(':')) {
        final separatorIndex = textInput.indexOf(':');
        if (separatorIndex != -1) {
          final key = textInput.substring(0, separatorIndex);
          final value = textInput.substring(separatorIndex + 1);
          if (key == categoryName) {
            if (questionId == 'specific_features') {
              print('[$categoryName] Custom text found (single): $value');
            }
            return value;
          }
        }
      }
      if (questionId == 'specific_features') {
        print('[$categoryName] No custom text found for this category');
      }
      return null;
    }

    return Obx(() {
      final isExpanded = controller.expandedCategories[categoryKey] ?? false;
      final selectedValue = getSelectedValue();
      final customTextForCategory = getCustomText();
      final hasSelection = selectedValue != null;

      if (questionId == 'specific_features') {
        print('=== CHECKING 2ND QUESTION: $categoryName ===');
        print('Selected Value: $selectedValue');
        print('Custom Text: $customTextForCategory');
        print('Has Selection: $hasSelection');
        print('Answer selectedOptions: ${answer?.selectedOptions}');
        print('Answer textInput: ${answer?.textInput}');
      }

      return Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Category title
          Padding(
            padding: EdgeInsets.only(bottom: 8.h, top: 8.h),
            child: Text(
              // Display localized category name, but categoryName remains in English internally
              controller.getLocalizedCategoryName(context, categoryName),
              style: TextStyle(
                fontSize: 14.sp,
                fontWeight: FontWeight.w600,
                color: const Color(0xFF666666),
              ),
            ),
          ),
          // Show selected + 2 more options when collapsed (like creative brief - no isAnswered check)
          if (hasSelection && !isExpanded)
            Wrap(
              spacing: 6.w,
              runSpacing: 6.h,
              children: [
                // Selected option chip - clicking allows direct selection change
                GestureDetector(
                  onTap: () => onTap(selectedValue),
                  child: Container(
                    padding: EdgeInsets.symmetric(
                      horizontal: 14.w,
                      vertical: 8.h,
                    ),
                    decoration: BoxDecoration(
                      color: AppColors.buttonColor,
                      borderRadius: BorderRadius.circular(20.r),
                    ),
                    child: Text(
                      // Display localized option, but selectedValue remains in English internally
                      controller.getLocalizedOption(context, selectedValue),
                      style: TextStyle(
                        fontSize: 13.sp,
                        fontWeight: FontWeight.w500,
                        color: Colors.white,
                      ),
                    ),
                  ),
                ),
                // 2 more unselected options - clicking selects them directly
                ...options.where((opt) => opt != selectedValue).take(2).map((
                  option,
                ) {
                  return GestureDetector(
                    onTap: () => onTap(option),
                    child: Container(
                      padding: EdgeInsets.symmetric(
                        horizontal: 14.w,
                        vertical: 8.h,
                      ),
                      decoration: BoxDecoration(
                        color: const Color(0xFFF5F5F5),
                        borderRadius: BorderRadius.circular(20.r),
                        border: Border.all(
                          color: const Color(0xFFE0E0E0),
                          width: 1,
                        ),
                      ),
                      child: Text(
                        // Display localized option, but option remains in English internally
                        controller.getLocalizedOption(context, option),
                        style: TextStyle(
                          fontSize: 13.sp,
                          fontWeight: FontWeight.w500,
                          color: const Color(0xFF333333),
                        ),
                      ),
                    ),
                  );
                }),
                // Expand arrow if there are more options
                if (options.length > 3)
                  GestureDetector(
                    onTap: () {
                      controller.expandCategory(categoryKey);
                    },
                    child: Container(
                      padding: EdgeInsets.all(8.w),
                      decoration: BoxDecoration(
                        color: const Color(0xFFF5F5F5),
                        shape: BoxShape.circle,
                        border: Border.all(color: const Color(0xFFE0E0E0)),
                      ),
                      child: Icon(
                        Icons.keyboard_arrow_down,
                        size: 18,
                        color: const Color(0xFF666666),
                      ),
                    ),
                  ),
              ],
            )
          else
            // Show expandable list (3 options initially)
            Wrap(
              spacing: 6.w,
              runSpacing: 6.h,
              children: [
                ...(isExpanded ? options : options.take(3).toList()).map((
                  option,
                ) {
                  bool isSelected = false;

                  if (option == 'Custom') {
                    // Check both temp state AND saved answer
                    isSelected =
                        controller.isCustomSelectedForCategory(
                          questionId,
                          categoryName,
                        ) ||
                        (selectedValue == 'Custom');
                  } else {
                    // Check temp selection OR saved answer
                    isSelected =
                        controller.getTempSelectionForCategory(categoryName) ==
                            option ||
                        selectedValue == option;
                  }

                  return GestureDetector(
                    onTap: () {
                      onTap(option);
                    },
                    child: Container(
                      padding: EdgeInsets.symmetric(
                        horizontal: 14.w,
                        vertical: 8.h,
                      ),
                      decoration: BoxDecoration(
                        color: isSelected
                            ? AppColors.buttonColor
                            : const Color(0xFFF5F5F5),
                        borderRadius: BorderRadius.circular(20.r),
                        border: Border.all(
                          color: isSelected
                              ? Colors.transparent
                              : const Color(0xFFE0E0E0),
                          width: 1,
                        ),
                      ),
                      child: Text(
                        // Display localized option, but option remains in English internally
                        controller.getLocalizedOption(context, option),
                        style: TextStyle(
                          fontSize: 13.sp,
                          fontWeight: FontWeight.w500,
                          color: isSelected
                              ? Colors.white
                              : const Color(0xFF333333),
                        ),
                      ),
                    ),
                  );
                }),
                // Show expand/collapse button if there are more than 3 options
                if (options.length > 3)
                  GestureDetector(
                    onTap: () {
                      controller.toggleCategory(categoryKey);
                    },
                    child: Container(
                      padding: EdgeInsets.all(8.w),
                      decoration: BoxDecoration(
                        color: const Color(0xFFF5F5F5),
                        shape: BoxShape.circle,
                        border: Border.all(color: const Color(0xFFE0E0E0)),
                      ),
                      child: Icon(
                        isExpanded
                            ? Icons.keyboard_arrow_up
                            : Icons.keyboard_arrow_down,
                        size: 18,
                        color: const Color(0xFF666666),
                      ),
                    ),
                  ),
              ],
            ),
          // Show custom text within category section (no isAnswered check needed)
          if (selectedValue == 'Custom' &&
              customTextForCategory != null &&
              customTextForCategory.isNotEmpty) ...[
            SizedBox(height: 8.h),
            GestureDetector(
              onTap: () {
                // Allow user to edit the categorized custom answer
                final textController = controller.specificFeaturesCustomController;
                controller.editCategorizedCustomAnswer(
                  questionId,
                  categoryName,
                  customTextForCategory,
                  textController,
                );
              },
              child: Container(
                margin: EdgeInsets.only(left: 8.w),
                padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 8.h),
                decoration: BoxDecoration(
                  color: AppColors.buttonColor,
                  borderRadius: BorderRadius.circular(20.r),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Flexible(
                      child: Text(
                        customTextForCategory,
                        style: TextStyle(
                          fontSize: 14.sp,
                          color: Colors.white,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ),
                    SizedBox(width: 8.w),
                    Icon(
                      Icons.edit,
                      size: 16.sp,
                      color: Colors.white.withValues(alpha: 0.8),
                    ),
                  ],
                ),
              ),
            ),
          ],
          SizedBox(height: 16.h),
        ],
      );
    });
  }

  Widget _buildBottomCustomInput(AppLocalizations l10n) {
    return Obx(() {
      // FIXED: Only show custom input when custom is selected
      if (controller.isCustomSelectedForCurrentQuestion()) {
        return Container(
          padding: EdgeInsets.all(24.w),
          child: TextInputWithSend(
            controller: controller.customController,
            placeholder: l10n.rcEnterYourCustomAnswer,
            onSend: () {
              controller.submitCustomAnswer();
            },
            isLoading: controller.isTextLoading,
          ),
        );
      }
      return const SizedBox.shrink();
    });
  }

  Widget _buildBottomCategorizedCustomInput(
    AppLocalizations l10n,
    String questionId,
    String categoryName,
  ) {
    TextEditingController? textController;
    VoidCallback? onSend;

    if (questionId == 'specific_features') {
      textController = controller.specificFeaturesCustomController;
      onSend = () {
        controller.submitCategorizedCustomAnswer(
          questionId,
          categoryName,
          textController!,
        );
      };
    }

    if (textController == null || onSend == null) {
      return const SizedBox.shrink();
    }

    return Container(
      padding: EdgeInsets.all(24.w),
      child: TextInputWithSend(
        controller: textController,
        placeholder: l10n.rcEnterCustomCategory(categoryName.toLowerCase()),
        onSend: onSend,
        isLoading: controller.isTextLoading,
      ),
    );
  }

  Widget _buildBottomButton(AppLocalizations l10n) {
    return Padding(
      padding: const EdgeInsets.all(24.0),
      child: RoundButton(
        title: l10n.rcGenerateDesign,
        onTap: () {
          controller.proceedToDesignGeneration();
        },
        color: AppColors.buttonColor,
        isloading: false,
      ),
    );
  }

  // Expandable chip section for single-select chip options - matching creative brief behavior
  // Expandable chip section for single-select chip options - matching creative brief behavior
  Widget _buildExpandableChipSection({
    required BuildContext context,
    required String questionId,
    required List<String> options,
    required List<String> selectedOptions,
    required Function(String) onTap,
    required bool isAnswered,
  }) {
    final categoryKey = questionId;

    return Obx(() {
      final isExpanded = controller.expandedCategories[categoryKey] ?? false;

      // Check temp selections first for immediate display
      String? selectedValue;
      if (controller.tempSelections.containsKey(questionId)) {
        selectedValue = controller.tempSelections[questionId];
      } else if (selectedOptions.isNotEmpty) {
        selectedValue = selectedOptions.first;
      }

      final hasSelection = selectedValue != null;

      // Show selected + 2 more options when collapsed (like creative brief - no isAnswered check)
      if (hasSelection && !isExpanded) {
        return Wrap(
          spacing: 6.w,
          runSpacing: 6.h,
          children: [
            // Selected option chip - clicking allows direct selection change
            GestureDetector(
              onTap: () => onTap(selectedValue!),
              child: Container(
                padding: EdgeInsets.symmetric(horizontal: 14.w, vertical: 8.h),
                decoration: BoxDecoration(
                  color: AppColors.buttonColor,
                  borderRadius: BorderRadius.circular(20.r),
                ),
                child: Text(
                  // Display localized option, but selectedValue remains in English internally
                  controller.getLocalizedOption(context, selectedValue),
                  style: TextStyle(
                    fontSize: 13.sp,
                    fontWeight: FontWeight.w500,
                    color: Colors.white,
                  ),
                ),
              ),
            ),
            // 2 more unselected options - clicking selects them directly
            ...options.where((opt) => opt != selectedValue).take(2).map((
              option,
            ) {
              return GestureDetector(
                onTap: () => onTap(option),
                child: Container(
                  padding: EdgeInsets.symmetric(
                    horizontal: 14.w,
                    vertical: 8.h,
                  ),
                  decoration: BoxDecoration(
                    color: const Color(0xFFF5F5F5),
                    borderRadius: BorderRadius.circular(20.r),
                    border: Border.all(
                      color: const Color(0xFFE0E0E0),
                      width: 1,
                    ),
                  ),
                  child: Text(
                    // Display localized option, but option remains in English internally
                    controller.getLocalizedOption(context, option),
                    style: TextStyle(
                      fontSize: 13.sp,
                      fontWeight: FontWeight.w500,
                      color: const Color(0xFF333333),
                    ),
                  ),
                ),
              );
            }),
            // Expand arrow if there are more options
            if (options.length > 3)
              GestureDetector(
                onTap: () {
                  controller.expandCategory(categoryKey);
                },
                child: Container(
                  padding: EdgeInsets.all(8.w),
                  decoration: BoxDecoration(
                    color: const Color(0xFFF5F5F5),
                    shape: BoxShape.circle,
                    border: Border.all(color: const Color(0xFFE0E0E0)),
                  ),
                  child: Icon(
                    Icons.keyboard_arrow_down,
                    size: 18,
                    color: const Color(0xFF666666),
                  ),
                ),
              ),
          ],
        );
      }

      // Show expandable list (3 options initially)
      final displayOptions = isExpanded ? options : options.take(3).toList();

      return Wrap(
        spacing: 6.w,
        runSpacing: 6.h,
        children: [
          ...displayOptions.map((option) {
            final isSelected = controller.isOptionSelected(
              option,
              forQuestionId: questionId,
            );

            return GestureDetector(
              onTap: () {
                onTap(option);
              },
              child: Container(
                padding: EdgeInsets.symmetric(horizontal: 14.w, vertical: 8.h),
                decoration: BoxDecoration(
                  color: isSelected
                      ? AppColors.buttonColor
                      : const Color(0xFFF5F5F5),
                  borderRadius: BorderRadius.circular(20.r),
                  border: Border.all(
                    color: isSelected
                        ? Colors.transparent
                        : const Color(0xFFE0E0E0),
                    width: 1,
                  ),
                ),
                child: Text(
                  // Display localized option, but option remains in English internally
                  controller.getLocalizedOption(context, option),
                  style: TextStyle(
                    fontSize: 13.sp,
                    fontWeight: FontWeight.w500,
                    color: isSelected ? Colors.white : const Color(0xFF333333),
                  ),
                ),
              ),
            );
          }),
          // Show expand/collapse button if there are more than 3 options
          if (options.length > 3)
            GestureDetector(
              onTap: () {
                controller.toggleCategory(categoryKey);
              },
              child: Container(
                padding: EdgeInsets.all(8.w),
                decoration: BoxDecoration(
                  color: const Color(0xFFF5F5F5),
                  shape: BoxShape.circle,
                  border: Border.all(color: const Color(0xFFE0E0E0)),
                ),
                child: Icon(
                  isExpanded
                      ? Icons.keyboard_arrow_up
                      : Icons.keyboard_arrow_down,
                  size: 18,
                  color: const Color(0xFF666666),
                ),
              ),
            ),
        ],
      );
    });
  }

  // Expandable section for multi-select questions - matching creative brief behavior
  // Expandable section for multi-select questions - matching creative brief behavior
  Widget _buildExpandableMultiSelectSection({
    required BuildContext context,
    required String questionId,
    required List<String> options,
    required List<String> selectedOptions,
    required Function(String) onTap,
    required bool isAnswered,
  }) {
    final categoryKey = questionId;

    return Obx(() {
      final isExpanded = controller.expandedCategories[categoryKey] ?? false;
      final hasSelection = selectedOptions.isNotEmpty;

      // Show ALL selected + 2 unselected when collapsed (like creative brief - no isAnswered check)
      if (hasSelection && !isExpanded) {
        final unselectedOptions = options
            .where((opt) => !selectedOptions.contains(opt))
            .take(2)
            .toList();

        return Wrap(
          spacing: 6.w,
          runSpacing: 6.h,
          children: [
            // ALL selected option chips - clicking toggles them
            ...selectedOptions.map((selectedValue) {
              return GestureDetector(
                onTap: () => onTap(selectedValue),
                child: Container(
                  padding: EdgeInsets.symmetric(
                    horizontal: 14.w,
                    vertical: 8.h,
                  ),
                  decoration: BoxDecoration(
                    color: AppColors.buttonColor,
                    borderRadius: BorderRadius.circular(20.r),
                  ),
                  child: Text(
                    // Display localized option, but selectedValue remains in English internally
                    controller.getLocalizedOption(context, selectedValue),
                    style: TextStyle(
                      fontSize: 13.sp,
                      fontWeight: FontWeight.w500,
                      color: Colors.white,
                    ),
                  ),
                ),
              );
            }),
            // 2 more unselected options - clicking selects them
            ...unselectedOptions.map((option) {
              return GestureDetector(
                onTap: () => onTap(option),
                child: Container(
                  padding: EdgeInsets.symmetric(
                    horizontal: 14.w,
                    vertical: 8.h,
                  ),
                  decoration: BoxDecoration(
                    color: const Color(0xFFF5F5F5),
                    borderRadius: BorderRadius.circular(20.r),
                    border: Border.all(
                      color: const Color(0xFFE0E0E0),
                      width: 1,
                    ),
                  ),
                  child: Text(
                    // Display localized option, but option remains in English internally
                    controller.getLocalizedOption(context, option),
                    style: TextStyle(
                      fontSize: 13.sp,
                      fontWeight: FontWeight.w500,
                      color: const Color(0xFF333333),
                    ),
                  ),
                ),
              );
            }),
            // Expand arrow if there are more options
            if (options.length > selectedOptions.length + 2)
              GestureDetector(
                onTap: () => controller.expandCategory(categoryKey),
                child: Container(
                  padding: EdgeInsets.all(8.w),
                  decoration: BoxDecoration(
                    color: const Color(0xFFF5F5F5),
                    shape: BoxShape.circle,
                    border: Border.all(color: const Color(0xFFE0E0E0)),
                  ),
                  child: Icon(
                    Icons.keyboard_arrow_down,
                    size: 18,
                    color: const Color(0xFF666666),
                  ),
                ),
              ),
          ],
        );
      }

      // Show expandable list (3 options initially)
      final displayOptions = isExpanded ? options : options.take(3).toList();

      return Wrap(
        spacing: 6.w,
        runSpacing: 6.h,
        children: [
          ...displayOptions.map((option) {
            final isSelected = selectedOptions.contains(option);

            return GestureDetector(
              onTap: () {
                onTap(option);
              },
              child: Container(
                padding: EdgeInsets.symmetric(horizontal: 14.w, vertical: 8.h),
                decoration: BoxDecoration(
                  color: isSelected
                      ? AppColors.buttonColor
                      : const Color(0xFFF5F5F5),
                  borderRadius: BorderRadius.circular(20.r),
                  border: Border.all(
                    color: isSelected
                        ? Colors.transparent
                        : const Color(0xFFE0E0E0),
                    width: 1,
                  ),
                ),
                child: Text(
                  // Display localized option, but option remains in English internally
                  controller.getLocalizedOption(context, option),
                  style: TextStyle(
                    fontSize: 13.sp,
                    fontWeight: FontWeight.w500,
                    color: isSelected ? Colors.white : const Color(0xFF333333),
                  ),
                ),
              ),
            );
          }),
          // Show expand/collapse button if there are more than 3 options
          if (options.length > 3)
            GestureDetector(
              onTap: () {
                controller.toggleCategory(categoryKey);
              },
              child: Container(
                padding: EdgeInsets.all(8.w),
                decoration: BoxDecoration(
                  color: const Color(0xFFF5F5F5),
                  shape: BoxShape.circle,
                  border: Border.all(color: const Color(0xFFE0E0E0)),
                ),
                child: Icon(
                  isExpanded
                      ? Icons.keyboard_arrow_up
                      : Icons.keyboard_arrow_down,
                  size: 18,
                  color: const Color(0xFF666666),
                ),
              ),
            ),
        ],
      );
    });
  }
}
