import 'package:atella/Data/Models/brief_questions_model.dart';
import 'package:atella/Modules/creative_brief/controllers/creative_brief_controller.dart';
import 'package:atella/Modules/creative_brief/Views/Widgets/selection_chip_widget.dart';
import 'package:atella/Modules/creative_brief/Views/Widgets/categorized_chips_widget.dart';
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
            // Show custom text input at bottom when custom is selected
            if (controller.isCustomSelectedForCurrentQuestion() && controller.currentQuestion.type == 'chips') {
              return _buildBottomCustomInput();
            }
            // Show bottom input area only for text questions (not chip questions)
            if (controller.shouldShowBottomInput && controller.currentQuestion.type == 'text') {
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
        padding: const EdgeInsets.only(top: 32, bottom: 20),
        itemCount: controller.questionsToShow,
        itemBuilder: (context, index) {
          final question = controller.questions[index];
          final isAnswered = controller.isQuestionAnswered(question.id);
          final isCurrentQuestion = index == controller.currentQuestionIndex;
          final shouldShowInput = controller.showLastTwoQuestions && 
                                 question.type == 'text' && 
                                 !isAnswered;

          // Debug prints
          if (isCurrentQuestion) {
            print('Current question: ${question.id}');
            print('Is Custom Selected: ${controller.isCustomSelectedForCurrentQuestion()}');
            print('Is Answered: $isAnswered');
            print('Question Type: ${question.type}');
          }

          return Column(
            children: [
              _buildQuestionItem(
                question, 
                isAnswered, 
                isCurrentQuestion, 
                shouldShowInput
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
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              color: Colors.black,
              border: Border.all(color: const Color(0xFFE0E0E0), width: 2),
              borderRadius: BorderRadius.only(
                topLeft: Radius.circular(4.r),
                topRight: Radius.circular(24.r),
                bottomLeft: Radius.circular(24.r),
                bottomRight: Radius.circular(24.r),
              ),
            ),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Expanded(
                  child: Text(question.question, style: qTextStyle16400),
                ),
                const SizedBox(width: 12),
                if (isAnswered)
                  Image.asset('assets/images/tick.png', height: 16, width: 16),
              ],
            ),
          ),
          const SizedBox(height: 16),
          if (question.type == 'chips')
            _buildChipOptions(question, isAnswered)
          else if (question.type == 'chips_categorized')
            _buildCategorizedChipOptions(question, isAnswered)
          else if (question.type == 'multi_part_color')
            _buildMultiPartColorSelection(question, isAnswered)
          else if (question.type == 'image')
            _buildImageUploadForQuestion(question, isAnswered)
          else if (question.type == 'text' && isCurrentQuestion && !controller.showLastTwoQuestions)
            _buildTextInputForQuestion(question)
          else if (shouldShowInput)
            _buildTextInputForQuestion(question),
          if (isAnswered && question.type == 'text')
            _buildAnsweredText(question),
          // Show custom answer if answered with custom text
          if (isAnswered && question.type == 'chips')
            _buildCustomAnswerDisplay(question),
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

  // Display custom answer
  Widget _buildCustomAnswerDisplay(BriefQuestion question) {
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
  }

  Widget _buildChipOptions(BriefQuestion question, bool isAnswered) {
    return Obx(() {
      // Recalculate isAnswered inside Obx to ensure reactivity
      final isQuestionAnswered = controller.isQuestionAnswered(question.id);
      final answer = controller.getAnswer(question.id);

      return Wrap(
        children: question.options.map((option) {
          final isSelected = controller.isOptionSelected(option);

          // Debug for Custom option
          if (option == 'Custom') {
            print('Custom chip - isSelected: $isSelected, isAnswered: $isQuestionAnswered');
          }

          if (isQuestionAnswered) {
            // Show final answered state for answered questions (with edit capability)
            final isAnswerSelected = answer?.selectedOptions.contains(option) ?? false;
            return GestureDetector(
              onTap: isAnswerSelected ? () {
                // Allow editing of answered questions
                controller.editAnswer(question.id);
              } : null,
              child: Container(
                margin: const EdgeInsets.only(right: 12, bottom: 8),
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                decoration: BoxDecoration(
                  color: isAnswerSelected
                      ? AppColors.buttonColor
                      : const Color(0xFFF5F5F5),
                  borderRadius: BorderRadius.circular(20),
                  border: isAnswerSelected
                      ? null
                      : Border.all(color: const Color(0xFFE0E0E0)),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      option,
                      style: TextStyle(
                        color: isAnswerSelected ? Colors.white : const Color(0xFF999999),
                        fontSize: 14,
                        fontWeight: isAnswerSelected ? FontWeight.w500 : FontWeight.w400,
                      ),
                    ),
                    if (isAnswerSelected)
                      ...[
                        SizedBox(width: 4.w),
                        Icon(
                          Icons.edit,
                          size: 14.0, // Fixed size instead of .w
                          color: Colors.white,
                        ),
                      ],
                  ],
                ),
              ),
            );
          } else {
            // Show interactive chips for unanswered questions
            return SelectionChipWidget(
              text: option,
              isSelected: isSelected,
              onTap: () {
                print('Chip tapped: $option'); // Debug
                controller.selectOption(option, forQuestionId: question.id);
              },
            );
          }
        }).toList(),
      );
    });
  }

  Widget _buildCategorizedChipOptions(BriefQuestion question, bool isAnswered) {
    if (question.categories == null) {
      return const SizedBox.shrink();
    }

    return Obx(() {
      // Recalculate isAnswered inside Obx to ensure reactivity
      final isQuestionAnswered = controller.isQuestionAnswered(question.id);
      final answer = controller.getAnswer(question.id);
      final selectedOption = answer?.selectedOptions.isNotEmpty == true
          ? answer!.selectedOptions.first
          : null;

      print('=== CATEGORIZED CHIPS REBUILD ===');
      print('Question: ${question.id}');
      print('Is answered: $isQuestionAnswered');
      print('Selected option: $selectedOption');

      if (isQuestionAnswered) {
        // Show categorized view  chiwith edit icon on selectedp
        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: question.categories!.entries.map((category) {
            return Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Category title
                Padding(
                  padding: EdgeInsets.only(bottom: 12.h, top: 8.h),
                  child: Text(
                    category.key,
                    style: TextStyle(
                      fontSize: 14.sp,
                      fontWeight: FontWeight.w600,
                      color: const Color(0xFF666666),
                    ),
                  ),
                ),
                // Category chips
                Wrap(
                  spacing: 8.w,
                  runSpacing: 8.h,
                  children: category.value.map((option) {
                    final isAnswerSelected = selectedOption == option;
                    return GestureDetector(
                      onTap: isAnswerSelected ? () {
                        controller.editAnswer(question.id);
                      } : null,
                      child: Container(
                        padding: EdgeInsets.symmetric(horizontal: 20.w, vertical: 12.h),
                        decoration: BoxDecoration(
                          color: isAnswerSelected
                              ? AppColors.buttonColor
                              : const Color(0xFFF5F5F5),
                          borderRadius: BorderRadius.circular(25.r),
                          border: Border.all(
                            color: isAnswerSelected
                                ? Colors.transparent
                                : const Color(0xFFE0E0E0),
                            width: 1,
                          ),
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Text(
                              option,
                              style: TextStyle(
                                fontSize: 14.sp,
                                fontWeight: FontWeight.w500,
                                color: isAnswerSelected
                                    ? Colors.white
                                    : const Color(0xFF999999),
                              ),
                            ),
                            if (isAnswerSelected) ...[
                              SizedBox(width: 4.w),
                              Icon(
                                Icons.edit,
                                size: 14.0,
                                color: Colors.white,
                              ),
                            ],
                          ],
                        ),
                      ),
                    );
                  }).toList(),
                ),
                SizedBox(height: 16.h),
              ],
            );
          }).toList(),
        );
      } else {
        // Show interactive categorized chips for unanswered questions
        // Get the selected option from temporary selections
        final tempSelected = controller.tempSelections[question.id];

        return CategorizedChipsWidget(
          categories: question.categories!,
          selectedOption: tempSelected,
          onOptionSelected: (option) {
            controller.selectOption(option, forQuestionId: question.id);
          },
        );
      }
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
              await Future.delayed(const Duration(milliseconds: 500)); // Wait for submission
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
                    padding: EdgeInsets.symmetric(horizontal: 24.w, vertical: 12.h),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(20.r),
                      side: BorderSide(color: const Color(0xFFE0E0E0), width: 1.5),
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

  Widget _buildMultiPartColorSelection(BriefQuestion question, bool isAnswered) {
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
          Padding(
            padding: EdgeInsets.only(bottom: 12.h, top: 8.h),
            child: Text(
              'Prints',
              style: TextStyle(
                fontSize: 14.sp,
                fontWeight: FontWeight.w600,
                color: const Color(0xFF666666),
              ),
            ),
          ),
          Wrap(
            spacing: 8.w,
            runSpacing: 8.h,
            children: (question.categories!['Prints'] ?? []).map((print) {
              final isSelected = selectedPrint == print;
              return GestureDetector(
                onTap: isQuestionAnswered
                  ? (isSelected ? () => controller.editAnswer(question.id) : null)
                  : () => controller.selectPrint(print),
                child: Container(
                  padding: EdgeInsets.symmetric(horizontal: 20.w, vertical: 12.h),
                  decoration: BoxDecoration(
                    color: isSelected ? AppColors.buttonColor : const Color(0xFFF5F5F5),
                    borderRadius: BorderRadius.circular(25.r),
                    border: Border.all(
                      color: isSelected ? Colors.transparent : const Color(0xFFE0E0E0),
                      width: 1,
                    ),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(
                        print,
                        style: TextStyle(
                          fontSize: 14.sp,
                          fontWeight: FontWeight.w500,
                          color: isSelected ? Colors.white : (isQuestionAnswered ? const Color(0xFF999999) : const Color(0xFF333333)),
                        ),
                      ),
                      if (isSelected && isQuestionAnswered) ...[
                        SizedBox(width: 4.w),
                        Icon(
                          Icons.edit,
                          size: 14.0,
                          color: Colors.white,
                        ),
                      ],
                    ],
                  ),
                ),
              );
            }).toList(),
          ),
          SizedBox(height: 16.h),

          // Part 3: Techniques
          Padding(
            padding: EdgeInsets.only(bottom: 12.h, top: 8.h),
            child: Text(
              'Techniques',
              style: TextStyle(
                fontSize: 14.sp,
                fontWeight: FontWeight.w600,
                color: const Color(0xFF666666),
              ),
            ),
          ),
          Wrap(
            spacing: 8.w,
            runSpacing: 8.h,
            children: (question.categories!['Techniques'] ?? []).map((technique) {
              final isSelected = selectedTechnique == technique;
              return GestureDetector(
                onTap: isQuestionAnswered
                  ? (isSelected ? () => controller.editAnswer(question.id) : null)
                  : () => controller.selectTechnique(technique),
                child: Container(
                  padding: EdgeInsets.symmetric(horizontal: 20.w, vertical: 12.h),
                  decoration: BoxDecoration(
                    color: isSelected ? AppColors.buttonColor : const Color(0xFFF5F5F5),
                    borderRadius: BorderRadius.circular(25.r),
                    border: Border.all(
                      color: isSelected ? Colors.transparent : const Color(0xFFE0E0E0),
                      width: 1,
                    ),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(
                        technique,
                        style: TextStyle(
                          fontSize: 14.sp,
                          fontWeight: FontWeight.w500,
                          color: isSelected ? Colors.white : (isQuestionAnswered ? const Color(0xFF999999) : const Color(0xFF333333)),
                        ),
                      ),
                      if (isSelected && isQuestionAnswered) ...[
                        SizedBox(width: 4.w),
                        Icon(
                          Icons.edit,
                          size: 14.0,
                          color: Colors.white,
                        ),
                      ],
                    ],
                  ),
                ),
              );
            }).toList(),
          ),
          SizedBox(height: 16.h),
        ],
      );
    });
  }

}