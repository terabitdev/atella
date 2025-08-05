import 'package:atella/Data/Models/brief_questions_model.dart';
import 'package:atella/Modules/RefiningConcept/controllers/refining_concept_controller.dart';
import 'package:atella/Modules/CreativeBrief/Views/Widgets/selection_chip_widget.dart';
import 'package:atella/Modules/CreativeBrief/Views/Widgets/text_input_send_widget.dart';
import 'package:atella/Widgets/custom_roundbutton.dart';
import 'package:atella/Widgets/questionare_app_header.dart';
import 'package:atella/core/themes/app_colors.dart';
import 'package:atella/core/themes/app_fonts.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';

class RefiningBriefScreen extends GetView<RefiningConceptController> {
  const RefiningBriefScreen({super.key});

  @override
  Widget build(BuildContext context) {
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
            title: 'Refining the Concept',
            timeTextGetter: () => controller.currentTime,
            titleStyle: qTextStyle14600,
            onBack: () => Get.back()
          ),
          Expanded(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 24),
              child: _buildQuestionsList(),
            ),
          ),
      
          // Loading Dots (only for non-last questions)
          _buildLoadingDots(),
          Obx(() {
            final isLastTwoQuestions = controller.currentQuestionIndex >= 5;
            final allQuestionsAnswered =
                controller.answers.length >= controller.questions.length;
      
            if (allQuestionsAnswered) {
              return _buildBottomButton();
            }
            if (isLastTwoQuestions) {
              return const SizedBox.shrink();
            }
            return _buildBottomInputArea();
          }),
        ],
      ),
    );
  }

  Widget _buildQuestionsList() {
    return GetBuilder<RefiningConceptController>(
      builder: (controller) => ListView.builder(
        padding: const EdgeInsets.only(top: 32, bottom: 20),
        itemCount: controller.currentQuestionIndex >= 5
            ? controller
                  .questions
                  .length // Show all questions after question 5
            : controller.currentQuestionIndex +
                  1, // Show progressive questions for 1-5
        itemBuilder: (context, index) {
          final question = controller.questions[index];
          final isAnswered = controller.isQuestionAnswered(question.id);
          final isCurrentQuestion = index == controller.currentQuestionIndex;

          return _buildQuestionItem(
            question,
            isAnswered,
            isCurrentQuestion,
            index,
          );
        },
      ),
    );
  }

  Widget _buildQuestionItem(
    BriefQuestion question,
    bool isAnswered,
    bool isCurrentQuestion,
    int index,
  ) {
    return Container(
      margin: const EdgeInsets.only(bottom: 32),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Question Bubble
          Container(
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              border: Border.all(color: const Color(0xFFE0E0E0), width: 2),
              color: Colors.black,
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
                // Checkmark for answered questions
                if (isAnswered)
                  Image.asset('assets/images/tick.png', height: 16, width: 16),
              ],
            ),
          ),

          const SizedBox(height: 16),

          // Answer Options
          if (question.type == 'chips')
            _buildChipOptions(question, isAnswered, isCurrentQuestion)
        ],
      ),
    );
  }

  Widget _buildChipOptions(
    BriefQuestion question,
    bool isAnswered,
    bool isCurrentQuestion,
  ) {
    return GetBuilder<RefiningConceptController>(
      builder: (controller) {
        if (isAnswered) {
          // Show answered options with selected one highlighted
          final answer = controller.getAnswer(question.id);
          return Wrap(
            children: question.options.map((option) {
              final isSelected =
                  answer?.selectedOptions.contains(option) ?? false;
              return Container(
                margin: const EdgeInsets.only(right: 12, bottom: 8),
                padding: const EdgeInsets.symmetric(
                  horizontal: 16,
                  vertical: 8,
                ),
                decoration: BoxDecoration(
                  color: isSelected
                      ? AppColors.buttonColor
                      : const Color(0xFFF5F5F5),
                  borderRadius: BorderRadius.circular(20),
                  border: isSelected
                      ? null
                      : Border.all(color: const Color(0xFFE0E0E0)),
                ),
                child: Text(
                  option,
                  style: TextStyle(
                    color: isSelected ? Colors.white : const Color(0xFF999999),
                    fontSize: 14,
                    fontWeight: isSelected ? FontWeight.w500 : FontWeight.w400,
                  ),
                ),
              );
            }).toList(),
          );
        } else {
          // Show interactive options for current question
          return Wrap(
            children: question.options.map((option) {
              return SelectionChipWidget(
                text: option,
                isSelected: controller.isOptionSelected(option),
                onTap: () => controller.selectOption(option),
              );
            }).toList(),
          );
        }
      },
    );
  }
  Widget _buildLoadingDots() {
    return GetBuilder<RefiningConceptController>(
      builder: (controller) {
        // Don't show dots after question 5 (when all questions are visible)
        if (controller.currentQuestionIndex >= 5) {
          return const SizedBox.shrink();
        }

        return Container(
          padding: const EdgeInsets.symmetric(vertical: 20),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: List.generate(3, (index) {
              return Container(
                width: 8,
                height: 8,
                margin: EdgeInsets.symmetric(horizontal: 4),
                decoration: BoxDecoration(
                  color: AppColors.buttonColor,
                  shape: BoxShape.circle,
                ),
              );
            }),
          ),
        );
      },
    );
  }
  Widget _buildBottomInputArea() {
    return GetBuilder<RefiningConceptController>(
      builder: (controller) {
        final currentQuestion = controller.currentQuestion;

        // Show bottom input for all questions except the last two (index 5 and 6)
        if (controller.currentQuestionIndex < 5 &&
            !controller.isQuestionAnswered(currentQuestion.id)) {
          return TextInputWithSend(
            controller: currentQuestion.id == 'colors'
                ? controller.colorController
                : controller.fabricController,
            placeholder: 'Type something... ',
            onSend: () => controller.submitTextAnswer(
              currentQuestion.id,
              currentQuestion.id == 'colors'
                  ? controller.colorController
                  : controller.fabricController,
            ),
            isLoading: controller.isTextLoading,
          );
        }
        return const SizedBox.shrink();
      },
    );
  }
  Widget _buildBottomButton() {
    return Padding(
      padding: const EdgeInsets.all(24.0),
      child: RoundButton(title: 'Next Steps', onTap: (){
         Get.toNamed(
                    '/final_detail_onboard',
                  ); 
      }, color: AppColors.buttonColor, isloading: false),
    );
  }
}
