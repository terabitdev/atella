import 'package:atella/Data/Models/brief_questions_model.dart';
import 'package:atella/Modules/creative_brief/controllers/creative_brief_controller.dart';
import 'package:atella/Modules/creative_brief/Views/Widgets/text_input_send_widget.dart';
import 'package:atella/Modules/creative_brief/Views/Widgets/image_upload_container.dart';
import 'package:atella/Modules/creative_brief/Views/Widgets/multi_image_upload_widget.dart';
import 'package:atella/Modules/creative_brief/Views/Widgets/color_picker_widget.dart';
import 'package:atella/Widgets/custom_roundbutton.dart';
import 'package:atella/Widgets/questionare_app_header.dart';
import 'package:atella/core/themes/app_colors.dart';
import 'package:atella/core/themes/app_fonts.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:lottie/lottie.dart';

class CreativeBriefScreen extends GetView<CreativeBriefController> {
  const CreativeBriefScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Column(
        children: [
          AppHeader(
            title: 'Creative Brief',
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
            // Show button if we're showing last two questions or all questions are answered
            if (controller.shouldShowButton) {
              return _buildBottomButton();
            }
            // Show custom text input at bottom when custom is selected for regular chips
            if (controller.isCustomSelectedForCurrentQuestion() &&
                controller.currentQuestion.type == 'chips') {
              return _buildBottomCustomInput();
            }
            // Show custom text input for categorized questions (for ANY question, not just current)
            final customInfo = controller.getAnyCustomSelectedCategory();
            if (customInfo != null) {
              return _buildBottomCategorizedCustomInput(
                customInfo['questionId']!,
                customInfo['categoryName']!,
              );
            }
            // Show bottom input area only for text questions (not chip questions)
            if (controller.shouldShowBottomInput &&
                controller.currentQuestion.type == 'text') {
              return _buildBottomInputArea();
            }
            // For last two questions, show individual input areas in the list
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
          final shouldShowInput =
              controller.showLastTwoQuestions &&
              question.type == 'text' &&
              !isAnswered;

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
              _buildQuestionItem(
                question,
                isAnswered,
                isCurrentQuestion,
                shouldShowInput,
              ),
              // Custom input is now moved to bottom, so this section is removed
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

  Widget _buildQuestionItem(
    BriefQuestion question,
    bool isAnswered,
    bool isCurrentQuestion,
    bool shouldShowInput,
  ) {
    return Container(
      margin: const EdgeInsets.only(bottom: 32),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 14.h),
            decoration: BoxDecoration(
              color: const Color(0xFFF8F9FA),
              borderRadius: BorderRadius.circular(12.r),
              border: Border.all(
                color: isAnswered
                    ? AppColors.buttonColor.withOpacity(0.3)
                    : const Color(0xFFE8E8E8),
                width: 1.5,
              ),
            ),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Expanded(
                  child: Text(
                    question.question,
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
          if (question.type == 'chips')
            _buildChipOptions(question, isAnswered)
          else if (question.type == 'chips_categorized')
            _buildCategorizedChipOptions(question, isAnswered)
          else if (question.type == 'multi_part_color')
            _buildMultiPartColorSelection(question, isAnswered)
          else if (question.type == 'image')
            _buildImageUploadForQuestion(question, isAnswered)
          else if (question.type == 'text' &&
              isCurrentQuestion &&
              !controller.showLastTwoQuestions)
            _buildTextInputForQuestion(question)
          else if (shouldShowInput)
            _buildTextInputForQuestion(question),
          if (isAnswered && question.type == 'text')
            _buildAnsweredText(question),
          // Show custom answer if answered with custom text
          if (isAnswered && question.type == 'chips')
            _buildCustomAnswerDisplay(question),
          // Show custom answer for categorized chips
          if (isAnswered && question.type == 'chips_categorized')
            _buildCategorizedCustomAnswerDisplay(question),
        ],
      ),
    );
  }

  // Custom text input widget at bottom of screen
  Widget _buildBottomCustomInput() {
    print('Building bottom custom text input'); // Debug
    return Container(
      padding: const EdgeInsets.all(24),
      child: TextInputWithSend(
        controller: controller.customController,
        placeholder: 'Enter your custom answer...',
        onSend: () {
          print('Custom send button pressed'); // Debug
          controller.submitCustomAnswer();
        },
        isLoading: controller.isTextLoading,
      ),
    );
  }

  // Custom text input for categorized questions
  Widget _buildBottomCategorizedCustomInput(
    String questionId,
    String categoryName,
  ) {
    print(
      'Building bottom categorized custom input for $questionId:$categoryName',
    ); // Debug

    // Get the appropriate controller based on question and category
    TextEditingController? textController;
    VoidCallback? onSend;

    if (questionId == 'garment_type') {
      textController = controller.garmentTypeCustomController;
      onSend = () {
        controller.submitCategorizedCustomAnswer(
          questionId,
          categoryName,
          textController!,
        );
      };
    } else if (questionId == 'fabrics') {
      textController = controller.fabricCustomController;
      onSend = () {
        controller.submitCategorizedCustomAnswer(
          questionId,
          categoryName,
          textController!,
        );
      };
    } else if (questionId == 'colors') {
      if (categoryName == 'Prints') {
        textController = controller.printCustomController;
        onSend = () {
          controller.submitColorCustomAnswer(categoryName, textController!);
        };
      } else if (categoryName == 'Techniques') {
        textController = controller.techniqueCustomController;
        onSend = () {
          controller.submitColorCustomAnswer(categoryName, textController!);
        };
      }
    }

    if (textController == null || onSend == null) {
      return const SizedBox.shrink();
    }

    return Container(
      padding: const EdgeInsets.all(24),
      child: TextInputWithSend(
        controller: textController,
        placeholder: 'Enter custom $categoryName...',
        onSend: onSend,
        isLoading: controller.isTextLoading,
      ),
    );
  }

  // Display custom answer
  Widget _buildCustomAnswerDisplay(BriefQuestion question) {
    return Obx(() {
      final answer = controller.getAnswer(question.id);
      if (answer?.textInput != null && answer!.textInput!.isNotEmpty) {
        return Container(
          margin: const EdgeInsets.only(top: 8),
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
          decoration: BoxDecoration(
            color: AppColors.buttonColor,
            borderRadius: BorderRadius.circular(20),
          ),
          child: Text(
            answer.textInput!,
            style: const TextStyle(
              fontSize: 14,
              color: Colors.white,
              fontWeight: FontWeight.w500,
            ),
          ),
        );
      }
      return const SizedBox.shrink();
    });
  }

  Widget _buildCategorizedCustomAnswerDisplay(BriefQuestion question) {
    return Obx(() {
      final answer = controller.getAnswer(question.id);
      // Check if answer has Custom selection (format: "CategoryName:Custom")
      if (answer?.selectedOptions.isNotEmpty == true) {
        final selectedOption = answer!.selectedOptions.first;
        if (selectedOption.endsWith(':Custom') &&
            answer.textInput != null &&
            answer.textInput!.isNotEmpty) {
          return Container(
            margin: const EdgeInsets.only(top: 8, left: 8),
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            decoration: BoxDecoration(
              color: AppColors.buttonColor,
              borderRadius: BorderRadius.circular(20),
            ),
            child: Text(
              answer.textInput!,
              style: const TextStyle(
                fontSize: 14,
                color: Colors.white,
                fontWeight: FontWeight.w500,
              ),
            ),
          );
        }
      }
      return const SizedBox.shrink();
    });
  }

  Widget _buildChipOptions(BriefQuestion question, bool isAnswered) {
    return Obx(() {
      final answer = controller.getAnswer(question.id);
      final selectedOptions = answer?.selectedOptions ?? [];

      return _buildExpandableChipSection(
        questionId: question.id,
        options: question.options,
        selectedOptions: selectedOptions,
        onTap: (option) =>
            controller.selectOption(option, forQuestionId: question.id),
      );
    });
  }

  Widget _buildCategorizedChipOptions(BriefQuestion question, bool isAnswered) {
    if (question.categories == null) {
      return const SizedBox.shrink();
    }

    return Obx(() {
      final answer = controller.getAnswer(question.id);

      return Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: question.categories!.entries.map((category) {
          return _buildExpandableCategorizedSection(
            questionId: question.id,
            categoryName: category.key,
            options: category.value,
            answer: answer,
            onTap: (option) => controller.selectOption(
              option,
              forQuestionId: question.id,
              categoryName: category.key,
            ),
          );
        }).toList(),
      );
    });
  }

  Widget _buildExpandableCategorizedSection({
    required String questionId,
    required String categoryName,
    required List<String> options,
    required BriefAnswer? answer,
    required Function(String) onTap,
  }) {
    final categoryKey = '${questionId}_$categoryName';

    return Obx(() {
      final isExpanded = controller.expandedCategories[categoryKey] ?? false;

      // Get selected option for this category - check both temp and final selections
      String? selectedValue;

      // First check temp selections
      final tempKey = questionId;
      if (controller.tempSelections.containsKey(tempKey)) {
        final tempSelection = controller.tempSelections[tempKey]!;
        if (tempSelection.startsWith('$categoryName:')) {
          selectedValue = tempSelection.substring('$categoryName:'.length);
        }
      }

      // If no temp selection, check final answer
      if (selectedValue == null && answer?.selectedOptions.isNotEmpty == true) {
        for (final opt in answer!.selectedOptions) {
          if (opt.startsWith('$categoryName:')) {
            selectedValue = opt.substring('$categoryName:'.length);
            break;
          }
        }
      }

      final hasSelection = selectedValue != null;

      return Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Category title
          Padding(
            padding: EdgeInsets.only(bottom: 8.h, top: 8.h),
            child: Text(
              categoryName,
              style: TextStyle(
                fontSize: 14.sp,
                fontWeight: FontWeight.w600,
                color: const Color(0xFF666666),
              ),
            ),
          ),
          // Show selected + 2 more options when collapsed
          if (hasSelection && !isExpanded)
            Wrap(
              spacing: 6.w,
              runSpacing: 6.h,
              children: [
                // Selected option chip
                GestureDetector(
                  onTap: () => onTap(selectedValue!),
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
                      selectedValue,
                      style: TextStyle(
                        fontSize: 13.sp,
                        fontWeight: FontWeight.w500,
                        color: Colors.white,
                      ),
                    ),
                  ),
                ),
                // 2 more unselected options
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
                        option,
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
                  final isSelected = selectedValue == option;

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
                        option,
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
          SizedBox(height: 16.h),
        ],
      );
    });
  }

  Widget _buildTextInputForQuestion(BriefQuestion question) {
    // Only colors question should use text input now (fabrics is chips_categorized)
    final textController = controller.colorController;

    String hintText = 'Enter preferred colors...';

    return SizedBox(
      height: 45.h,
      child: TextField(
        controller: textController,
        style: authLableTextTextStyle144001,
        decoration: InputDecoration(
          filled: true,
          fillColor: Color.fromRGBO(236, 239, 246, 1),
          hintText: hintText,
          hintStyle: authLableTextTextStyle144002,
          enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12.r),
            borderSide: const BorderSide(
              color: Color.fromRGBO(233, 233, 233, 1),
              width: 1.2,
            ),
          ),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12.r),
          ),
          contentPadding: EdgeInsets.symmetric(
            vertical: 16.h,
            horizontal: 12.w,
          ),
        ),
      ),
    );
  }

  Widget _buildAnsweredText(BriefQuestion question) {
    final answer = controller.getAnswer(question.id);
    return Container(
      margin: const EdgeInsets.only(right: 12, bottom: 8),
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      decoration: BoxDecoration(
        color: Colors.black,
        borderRadius: BorderRadius.circular(20),
      ),
      child: Text(
        answer?.textInput ?? '',
        style: const TextStyle(fontSize: 14, color: Colors.white),
      ),
    );
  }

  Widget _buildBottomInputArea() {
    return Obx(() {
      final currentQuestion = controller.currentQuestion;
      // Only colors question uses text input at bottom (fabrics is chips_categorized)
      return TextInputWithSend(
        controller: controller.colorController,
        placeholder: 'Enter preferred colors...',
        onSend: () {
          controller.submitTextAnswer(
            currentQuestion.id,
            controller.colorController,
          );
        },
        isLoading: controller.isTextLoading,
      );
    });
  }

  Widget _buildBottomButton() {
    return Container(
      padding: const EdgeInsets.all(24),
      child: RoundButton(
        title: 'Next Steps',
        onTap: () async {
          // Submit any pending text answers before proceeding
          if (controller.showLastTwoQuestions) {
            // Submit colors answer if entered and not already saved
            if (controller.colorController.text.trim().isNotEmpty &&
                !controller.isQuestionAnswered('colors')) {
              controller.submitTextAnswer('colors', controller.colorController);
              await Future.delayed(
                const Duration(milliseconds: 500),
              ); // Wait for submission
            }
            // Note: fabrics is now chips_categorized, not text, so no text submission needed
          }

          // Navigate to next screen with data saving
          controller.proceedToNextScreen();
        },
        color: AppColors.buttonColor,
        isloading: false,
      ),
    );
  }

  Widget _buildImageUploadForQuestion(BriefQuestion question, bool isAnswered) {
    if (question.id == 'inspiration') {
      return Obx(() {
        // Access the observable list to trigger reactivity
        final images = controller.inspirationImages.toList();
        // Check if question is answered reactively
        final questionAnswered = controller.isQuestionAnswered(question.id);

        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Multi-image upload widget
            MultiImageUploadWidget(
              selectedImages: images,
              onImageAdded: (imagePath) {
                controller.addImage(imagePath);
              },
              onImageRemoved: (imagePath) {
                controller.removeImage(imagePath);
              },
              placeholder: 'Upload visual inspiration images (optional)',
            ),

            // Skip button - only show if question is not answered and no images selected
            if (!questionAnswered && images.isEmpty) ...[
              SizedBox(height: 16.h),
              Center(
                child: TextButton(
                  onPressed: () {
                    controller.skipInspirationQuestion();
                  },
                  style: TextButton.styleFrom(
                    padding: EdgeInsets.symmetric(
                      horizontal: 24.w,
                      vertical: 12.h,
                    ),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(20.r),
                      side: BorderSide(
                        color: const Color(0xFFE0E0E0),
                        width: 1.5,
                      ),
                    ),
                  ),
                  child: Text(
                    'Skip - No reference images',
                    style: TextStyle(
                      fontSize: 14.sp,
                      color: const Color(0xFF666666),
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ),
              ),
            ],
          ],
        );
      });
    }

    // Fallback for other image questions (if any)
    return ImageUploadContainer(
      onImageSelected: (imagePath) {
        controller.selectImage(imagePath);
      },
      initialImage: null,
      placeholder: 'Upload image',
    );
  }

  Widget _buildMultiPartColorSelection(
    BriefQuestion question,
    bool isAnswered,
  ) {
    if (question.categories == null) {
      return const SizedBox.shrink();
    }

    return Obx(() {
      // Check if question is answered inside Obx for reactivity
      final isQuestionAnswered = controller.isQuestionAnswered(question.id);
      final selectedColors = controller.selectedColors.toList();
      final selectedPrint = controller.selectedPrint;
      final selectedTechnique = controller.selectedTechnique;

      return Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Part 1: Solid colors with color picker
          ColorPickerWidget(
            selectedColors: selectedColors,
            onColorSelected: (hexCode) {
              controller.addColorFromPicker(hexCode);
            },
            onColorRemoved: (hexCode) {
              controller.removeColor(hexCode);
            },
          ),

          // Part 2: Prints
          _buildExpandableCategory(
            categoryName: 'Prints',
            options: question.categories!['Prints'] ?? [],
            selectedValue: selectedPrint,
            onTap: (option) => controller.selectPrint(option),
            isAnswered: isQuestionAnswered,
            hasCustom:
                controller
                    .getAnswer('colors')
                    ?.selectedOptions
                    .contains('Prints:Custom') ??
                false,
          ),
          // Show custom print text if answered with custom
          if (isQuestionAnswered) ...[
            Obx(() {
              final answer = controller.getAnswer('colors');
              final hasCustomPrint =
                  answer?.selectedOptions.contains('Prints:Custom') ?? false;
              if (hasCustomPrint && answer?.textInput != null) {
                final parts = answer!.textInput!.split('|||');
                final customPrintText = parts.length >= 2 ? parts[1] : '';
                if (customPrintText.isNotEmpty) {
                  return Padding(
                    padding: EdgeInsets.only(top: 8.h),
                    child: Container(
                      margin: EdgeInsets.only(left: 8.w),
                      padding: EdgeInsets.symmetric(
                        horizontal: 16.w,
                        vertical: 8.h,
                      ),
                      decoration: BoxDecoration(
                        color: AppColors.buttonColor,
                        borderRadius: BorderRadius.circular(20.r),
                      ),
                      child: Text(
                        customPrintText,
                        style: TextStyle(
                          fontSize: 14.sp,
                          color: Colors.white,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ),
                  );
                }
              }
              return SizedBox.shrink();
            }),
          ],
          SizedBox(height: 16.h),

          // Part 3: Techniques
          _buildExpandableCategory(
            categoryName: 'Techniques',
            options: question.categories!['Techniques'] ?? [],
            selectedValue: selectedTechnique,
            onTap: (option) => controller.selectTechnique(option),
            isAnswered: isQuestionAnswered,
            hasCustom:
                controller
                    .getAnswer('colors')
                    ?.selectedOptions
                    .contains('Techniques:Custom') ??
                false,
          ),
          // Show custom technique text if answered with custom
          if (isQuestionAnswered) ...[
            Obx(() {
              final answer = controller.getAnswer('colors');
              final hasCustomTechnique =
                  answer?.selectedOptions.contains('Techniques:Custom') ??
                  false;
              if (hasCustomTechnique && answer?.textInput != null) {
                final parts = answer!.textInput!.split('|||');
                final customTechniqueText = parts.length >= 3 ? parts[2] : '';
                if (customTechniqueText.isNotEmpty) {
                  return Padding(
                    padding: EdgeInsets.only(top: 8.h),
                    child: Container(
                      margin: EdgeInsets.only(left: 8.w),
                      padding: EdgeInsets.symmetric(
                        horizontal: 16.w,
                        vertical: 8.h,
                      ),
                      decoration: BoxDecoration(
                        color: AppColors.buttonColor,
                        borderRadius: BorderRadius.circular(20.r),
                      ),
                      child: Text(
                        customTechniqueText,
                        style: TextStyle(
                          fontSize: 14.sp,
                          color: Colors.white,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ),
                  );
                }
              }
              return SizedBox.shrink();
            }),
          ],
          SizedBox(height: 16.h),
        ],
      );
    });
  }

  // Expandable chip section for regular chip options
  // Expandable chip section for regular chip options
  Widget _buildExpandableChipSection({
    required String questionId,
    required List<String> options,
    required List<String> selectedOptions,
    required Function(String) onTap,
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

      // Show selected + 2 more options when collapsed
      if (hasSelection && !isExpanded) {
        return Wrap(
          spacing: 6.w,
          runSpacing: 6.h,
          children: [
            // Selected option chip
            GestureDetector(
              onTap: () => onTap(selectedValue!),
              child: Container(
                padding: EdgeInsets.symmetric(horizontal: 14.w, vertical: 8.h),
                decoration: BoxDecoration(
                  color: AppColors.buttonColor,
                  borderRadius: BorderRadius.circular(20.r),
                ),
                child: Text(
                  selectedValue,
                  style: TextStyle(
                    fontSize: 13.sp,
                    fontWeight: FontWeight.w500,
                    color: Colors.white,
                  ),
                ),
              ),
            ),
            // 2 more unselected options
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
                    option,
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
      } // Show expandable list (3-4 options initially)
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
                  option,
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

  // Expandable category section for prints/techniques
  // Expandable category section for prints/techniques - UPDATED to match refining brief behavior
  Widget _buildExpandableCategory({
    required String categoryName,
    required List<String> options,
    required String? selectedValue,
    required Function(String) onTap,
    required bool isAnswered,
    required bool hasCustom,
  }) {
    final categoryKey = 'colors_$categoryName';

    return Obx(() {
      final isExpanded = controller.expandedCategories[categoryKey] ?? false;
      final hasSelection =
          (selectedValue != null && selectedValue.isNotEmpty) || hasCustom;

      return Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Category title
          Padding(
            padding: EdgeInsets.only(bottom: 8.h, top: 8.h),
            child: Text(
              categoryName,
              style: TextStyle(
                fontSize: 14.sp,
                fontWeight: FontWeight.w600,
                color: const Color(0xFF666666),
              ),
            ),
          ),
          // Show selected + 2 more options when collapsed (NO isAnswered check - matches refining brief)
          if (hasSelection && !isExpanded)
            Wrap(
              spacing: 6.w,
              runSpacing: 6.h,
              children: [
                // Selected option chip - clicking allows direct selection change
                GestureDetector(
                  onTap: () => onTap(hasCustom ? 'Custom' : selectedValue!),
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
                      hasCustom ? 'Custom' : selectedValue!,
                      style: TextStyle(
                        fontSize: 13.sp,
                        fontWeight: FontWeight.w500,
                        color: Colors.white,
                      ),
                    ),
                  ),
                ),
                // 2 more unselected options - clicking selects them directly
                ...options
                    .where(
                      (opt) => opt != (hasCustom ? 'Custom' : selectedValue),
                    )
                    .take(2)
                    .map((option) {
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
                            option,
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
                  final isSelected = hasCustom
                      ? (option == 'Custom')
                      : (selectedValue == option);

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
                        option,
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
        ],
      );
    });
  }
}
