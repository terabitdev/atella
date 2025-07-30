import 'package:atella/Data/Models/brief_questions_model.dart';
import 'package:atella/Modules/CreativeBrief/controllers/creative_brief_controller.dart';
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

class CreativeBriefScreen extends GetView<CreativeBriefController> {
  const CreativeBriefScreen({Key? key}) : super(key: key);

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
            title: 'Creative Brief',
            timeTextGetter: () => controller.currentTime,
            titleStyle: QTextStyle14600,
            onBack: () => Get.back(),
          ),
          Expanded(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 24),
              child: _buildQuestionsList(),
            ),
          ),
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
    return Obx(
      () => ListView.builder(
        padding: const EdgeInsets.only(top: 32, bottom: 20),
        itemCount: controller.currentQuestionIndex + 1,
        itemBuilder: (context, index) {
          final question = controller.questions[index];
          final isAnswered = controller.isQuestionAnswered(question.id);
          final isCurrentQuestion = index == controller.currentQuestionIndex;

          return _buildQuestionItem(question, isAnswered, isCurrentQuestion);
        },
      ),
    );
  }

  Widget _buildQuestionItem(
    BriefQuestion question,
    bool isAnswered,
    bool isCurrentQuestion,
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
                  child: Text(question.question, style: QTextStyle16400),
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
          else if (question.type == 'text' && isCurrentQuestion)
            _buildTextInputForQuestion(question),
          if (isAnswered && question.type == 'text')
            _buildAnsweredText(question),
        ],
      ),
    );
  }

  Widget _buildChipOptions(BriefQuestion question, bool isAnswered) {
    return Obx(() {
      final answer = controller.getAnswer(question.id);
      return Wrap(
        children: question.options.map((option) {
          final isSelected = answer?.selectedOptions.contains(option) ?? false;
          if (isAnswered) {
            return Container(
              margin: const EdgeInsets.only(right: 12, bottom: 8),
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
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
          } else {
            return SelectionChipWidget(
              text: option,
              isSelected: controller.isOptionSelected(option),
              onTap: () => controller.selectOption(option),
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
    // return TextInputWithSend(
    //   controller: textController,
    //   placeholder: 'Enter your answer here...',
    //   onSend: () {
    //     if (textController.text.trim().isNotEmpty) {
    //       controller.submitTextAnswer(question.id, textController);
    //     }
    //   },
    //   isLoading: controller.isTextLoading,
    // );
    return SizedBox(
      height: 45.h,
      child: TextField(
            controller: textController,
            style: AuthLableTextTextStyle144001,
            decoration: InputDecoration(
              filled: true,
              fillColor: Color.fromRGBO(236, 239, 246, 1),
              hintText:'Lorem',
              hintStyle: AuthLableTextTextStyle144002,
              enabledBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12.r),
                borderSide: const BorderSide(
                  color: Color.fromRGBO(233, 233, 233, 1), // Light gray
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
    return RoundButton(
      title: 'Next Steps',
      onTap: () {
        // Add any validation if needed before navigating
        Get.toNamed('/refine_concept');
      },
      color: AppColors.buttonColor,
      isloading: false,
    );
  }
}

Widget _buildLoadingDots() {
  return GetBuilder<CreativeBriefController>(
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
