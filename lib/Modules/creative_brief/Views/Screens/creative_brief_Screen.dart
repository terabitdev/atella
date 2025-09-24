import 'package:atella/Data/Models/brief_questions_model.dart';
import 'package:atella/Modules/creative_brief/controllers/creative_brief_controller.dart';
import 'package:atella/Modules/creative_brief/Views/Widgets/selection_chip_widget.dart';
import 'package:atella/Modules/creative_brief/Views/Widgets/text_input_send_widget.dart';
import 'package:atella/Modules/creative_brief/Views/Widgets/image_upload_container.dart';
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
      final answer = controller.getAnswer(question.id);
      
      return Wrap(
        children: question.options.map((option) {
          final isSelected = controller.isOptionSelected(option);
          
          // Debug for Custom option
          if (option == 'Custom') {
            print('Custom chip - isSelected: $isSelected, isAnswered: $isAnswered');
          }
          
          if (isAnswered) {
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
                controller.selectOption(option);
              },
            );
          }
        }).toList(),
      );
    });
  }

  Widget _buildTextInputForQuestion(BriefQuestion question) {
    final textController = question.id == 'colors'
        ? controller.colorController
        : controller.fabricController;
        
    String hintText = 'Lorem';
    if (controller.showLastTwoQuestions) {
      hintText = question.id == 'colors' 
          ? 'Enter preferred colors...' 
          : 'Enter fabric preferences...';
    }
        
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
      return TextInputWithSend(
        controller: currentQuestion.id == 'colors'
            ? controller.colorController
            : controller.fabricController,
        placeholder: 'Type something...',
        onSend: () {
          final answer = controller.getAnswer(currentQuestion.id);
          if (!controller.isOptionSelected('') &&
              (answer?.selectedOptions.isEmpty ?? true)) {
            Get.snackbar('Error', 'Please select an option before proceeding.');
            return;
          }
          controller.submitTextAnswer(
            currentQuestion.id,
            currentQuestion.id == 'colors'
                ? controller.colorController
                : controller.fabricController,
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
            
            // Submit fabrics answer if entered and not already saved
            if (controller.fabricController.text.trim().isNotEmpty && 
                !controller.isQuestionAnswered('fabrics')) {
              controller.submitTextAnswer('fabrics', controller.fabricController);
              await Future.delayed(const Duration(milliseconds: 500)); // Wait for submission
            }
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
    return Obx(() {
      final currentImage = question.id == 'inspiration' ? controller.inspirationImage : '';
      
      return ImageUploadContainer(
        onImageSelected: (imagePath) {
          if (question.id == 'inspiration') {
            controller.selectImage(imagePath);
          }
        },
        initialImage: currentImage.isNotEmpty ? currentImage : null,
        placeholder: 'Upload your visual inspiration',
      );
    });
  }

}