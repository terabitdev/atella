// Modified FinalDetailsScreen with custom text field behavior
import 'package:atella/Data/Models/brief_questions_model.dart';
import 'package:atella/Modules/CreativeBrief/Views/Widgets/text_input_send_widget.dart';
import 'package:atella/Modules/FinalDetails/Views/Widgets/custom_check_boxes_widget.dart';
import 'package:atella/Modules/FinalDetails/Views/Widgets/custom_generate_round_button_widget.dart';
import 'package:atella/Modules/FinalDetails/controllers/final_detail_controller.dart';
import 'package:atella/Widgets/questionare_app_header.dart';
import 'package:atella/core/constants/app_images.dart';
import 'package:atella/core/themes/app_colors.dart';
import 'package:atella/core/themes/app_fonts.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';

class FinalDetailsScreen extends GetView<FinalDetailsController> {
  const FinalDetailsScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {

    return Scaffold(
      resizeToAvoidBottomInset: false,
      backgroundColor: const Color(0xFFFAFAFA),
      body: Column(
        children: [
          AppHeader(
            title: 'Final Details',
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
          // Show custom text field or bottom button based on conditions
          _buildBottomSection(),
        ],
      ),
    );
  }

  Widget _buildBottomSection() {
    return GetBuilder<FinalDetailsController>(
      builder: (controller) {
        // Check if we're on the last question (additional_details text question)
        final isLastQuestion =
            controller.currentQuestionIndex >= controller.questions.length - 1;

        // Check if current question is answered (for desired_features)
        final isCurrentQuestionAnswered = 
            controller.isQuestionAnswered(controller.currentQuestion.id);

        if (isLastQuestion) {
          // Show text input and generate button for the last question (additional_details)
          return Column(
            children: [
              _buildCustomTextField(),
              const SizedBox(height: 16),
              Padding(
                padding: const EdgeInsets.all(24),
                child: GenerateRoundButton(
                  title: 'Generate',
                  onTap: controller.generateDesign,
                  color: AppColors.buttonColor,
                  imagePath: generateIcon,
                  loading: controller.isLoading,
                ),
              ),
            ],
          );
        } else if (isCurrentQuestionAnswered && 
                   controller.currentQuestion.id == 'desired_features') {
          // Show generate button when desired_features is answered (but not "Other")
          return Padding(
            padding: const EdgeInsets.all(24),
            child: GenerateRoundButton(
              title: 'Generate',
              onTap: controller.generateDesign,
              color: AppColors.buttonColor,
              imagePath: generateIcon,
              loading: controller.isLoading,
            ),
          );
        } else {
          // Show text input for other cases
          return _buildTextInput();
        } 
      },
    );
  }

  Widget _buildCustomTextField() {
    return Container(
      padding: const EdgeInsets.all(24),
      child: SizedBox(
        height: 45.h,
        child: TextField(
          controller: controller
              .customInputController, // Use the controller from your existing code
          style: AuthLableTextTextStyle144001,
          decoration: InputDecoration(
            filled: true,
            fillColor: const Color.fromRGBO(236, 239, 246, 1),
            hintText: "Add any additional details...", // You can customize this
            hintStyle: AuthLableTextTextStyle144002,
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
          onSubmitted: (value) {
            // Handle text submission here
            if (value.trim().isNotEmpty) {
              controller.submitTextAnswer(
                controller.currentQuestion.id,
                controller.customInputController,
              );
            }
          },
        ),
      ),
    );
  }

  Widget _buildQuestionsList() {
    return GetBuilder<FinalDetailsController>(
      builder: (controller) => ListView.builder(
        padding: const EdgeInsets.only(top: 32, bottom: 20),
        itemCount: controller.currentQuestionIndex + 1,
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
          if (index < 3) _buildSectionTitle(question.id),
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
                  child: Text(question.question, style: QTextStyle16400),
                ),
                const SizedBox(width: 12),
                if (isAnswered)
                  Image.asset('assets/images/tick.png', height: 16, width: 16),
              ],
            ),
          ),
          const SizedBox(height: 16),
          if (question.type == 'checkbox')
            _buildCheckboxOptions(question, isAnswered, isCurrentQuestion),
        ],
      ),
    );
  }

  Widget _buildSectionTitle(String questionId) {
    String title = '';
    switch (questionId) {
      case 'target_season':
        title = 'Target Season:';
        break;
      case 'target_budget':
        title = 'Target Budget per Piece:';
        break;
      case 'desired_features':
        title = 'Desired Features or Values:';
        break;
    }

    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      child: Text(
        title,
        style: QTextStyle14600.copyWith(color: AppColors.buttonColor),
      ),
    );
  }

  Widget _buildCheckboxOptions(
    BriefQuestion question,
    bool isAnswered,
    bool isCurrentQuestion,
  ) {
    return GetBuilder<FinalDetailsController>(
      builder: (controller) {
        return Column(
          children: [
            ...question.options.map((option) {
              if (option == 'Other: ?') {
                return _buildOtherOption(question, option);
              }

              return CustomCheckboxWidget(
                text: option,
                isSelected: controller.isOptionSelected(question.id, option),
                onTap: () => controller.toggleOption(question.id, option),
                allowMultiple: question.allowMultiple,
              );
            }).toList(),
          ],
        );
      },
    );
  }

  Widget _buildOtherOption(BriefQuestion question, String option) {
    return GetBuilder<FinalDetailsController>(
      builder: (controller) {
        final isSelected = controller.isOptionSelected(question.id, option);

        return CustomCheckboxWidget(
          text: option,
          isSelected: isSelected,
          onTap: () {
            controller.toggleOption(question.id, option);
          },
          allowMultiple: question.allowMultiple,
        );
      },
    );
  }

  Widget _buildTextInput() {
    return Column(
      children: [
        TextInputWithSend(
          controller: controller.customInputController,
          placeholder: 'Type something...',
          onSend: () {
            // Handle text submission
            if (controller.customInputController.text.trim().isNotEmpty) {
              controller.submitTextAnswer(
                controller.currentQuestion.id,
                controller.customInputController,
              );
            }
          },
          isLoading: controller.isLoading,
        ),
      ],
    );
  }
}