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
import 'package:lottie/lottie.dart';

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
          Obx(() {
            final allQuestionsAnswered =
                controller.answers.length >= controller.questions.length;
      
            if (allQuestionsAnswered) {
              return _buildBottomButton();
            }
            // FIXED: Only show bottom input if custom is selected
            if (controller.isCustomSelectedForCurrentQuestion()) {
              return _buildBottomInputArea();
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
        padding: const EdgeInsets.only(top: 32, bottom: 20),
        itemCount: controller.questionsToShow,
        itemBuilder: (context, index) {
          final question = controller.questions[index];
          final isAnswered = controller.isQuestionAnswered(question.id);
          final isCurrentQuestion = index == controller.currentQuestionIndex;

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
                index,
              ),
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
            _buildChipOptions(question, isAnswered, isCurrentQuestion),
          
          // Show custom answer if answered with custom text
          if (isAnswered && question.type == 'chips')
            _buildCustomAnswerDisplay(question),
        ],
      ),
    );
  }

  Widget _buildChipOptions(
    BriefQuestion question,
    bool isAnswered,
    bool isCurrentQuestion,
  ) {
    return Obx(() {
      if (isAnswered) {
        // Show answered options with selected one highlighted
        final answer = controller.getAnswer(question.id);
        return Wrap(
          children: question.options.map((option) {
            final isSelected = answer?.selectedOptions.contains(option) ?? false;
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
            final isSelected = controller.isOptionSelected(option);
            
            // Debug for Custom option
            if (option == 'Custom') {
              print('Custom chip - isSelected: $isSelected, isAnswered: $isAnswered');
            }
            
            return SelectionChipWidget(
              text: option,
              isSelected: isSelected,
              onTap: () {
                print('Chip tapped: $option'); // Debug
                controller.selectOption(option);
              },
            );
          }).toList(),
        );
      }
    });
  }

  Widget _buildBottomInputArea() {
    return Obx(() {
      // FIXED: Only show custom input when custom is selected
      if (controller.isCustomSelectedForCurrentQuestion()) {
        print('Showing custom input at bottom'); // Debug
        return TextInputWithSend(
          controller: controller.customController,
          placeholder: 'Enter your custom answer...',
          onSend: () {
            print('Custom send from bottom input'); // Debug
            controller.submitCustomAnswer();
          },
          isLoading: controller.isTextLoading,
        );
      }
      return const SizedBox.shrink();
    });
  }

  Widget _buildBottomButton() {
    return Padding(
      padding: const EdgeInsets.all(24.0),
      child: RoundButton(
        title: 'Next Steps', 
        onTap: (){
          controller.proceedToNextScreen(); 
        }, 
        color: AppColors.buttonColor, 
        isloading: false
      ),
    );
  }
}