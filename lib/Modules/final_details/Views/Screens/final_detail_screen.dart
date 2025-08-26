// Modified FinalDetailsScreen with custom text field behavior and Lottie animation
import 'package:atella/Data/Models/brief_questions_model.dart';
import 'package:atella/modules/final_details/Views/Widgets/custom_check_boxes_widget.dart';
import 'package:atella/modules/final_details/Views/Widgets/custom_generate_round_button_widget.dart';
import 'package:atella/modules/final_details/controllers/final_detail_controller.dart';
import 'package:atella/Widgets/questionare_app_header.dart';
import 'package:atella/core/constants/app_images.dart';
import 'package:atella/core/themes/app_colors.dart';
import 'package:atella/core/themes/app_fonts.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:lottie/lottie.dart'; // Add this import

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
            titleStyle: qTextStyle14600,
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
    return Obx(() {
        // In edit mode, always show Generate button if answers exist
        if (controller.isEditMode) {
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
        }
        
        // Original logic for new questionnaire mode
        final currentQuestionId = controller.currentQuestion.id;
        final currentQuestionIndex = controller.currentQuestionIndex;
        
        // Check if "Other: ?" is selected in desired_features
        final answer = controller.getAnswer('desired_features');
        final hasSelectedOther = answer?.selectedOptions.contains('Other: ?') ?? false;
        final hasAnyFeatureSelected = answer?.selectedOptions.isNotEmpty ?? false;
        
        // Check if we're on question 4 (additional_details)
        final isOnQuestion4 = currentQuestionId == 'additional_details';
        
        // Check if we're on question 3 (desired_features) - index 2
        final isOnQuestion3 = currentQuestionIndex == 2;

        if (isOnQuestion4 && hasSelectedOther) {
          // Only show generate button for question 4 (no duplicate text field since it's inline)
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
        } else if (isOnQuestion3 && hasAnyFeatureSelected && !hasSelectedOther) {
          // Show generate button when desired_features is answered with any option except "Other"
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
          // Don't show anything for other cases
          return const SizedBox.shrink();
        } 
    });
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
      child: Center(
        child: Lottie.asset(
          'assets/lottie/Loading_dots.json', // Replace with your Lottie file path
          width: 100.h,
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
                  child: Text(question.question, style: qTextStyle16400),
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
          // Add inline text field for question 4 when it's shown
          if (question.id == 'additional_details' && isCurrentQuestion)
            _buildInlineTextField(),
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
        style: qTextStyle14600.copyWith(color: AppColors.buttonColor),
      ),
    );
  }

  Widget _buildCheckboxOptions(
    BriefQuestion question,
    bool isAnswered,
    bool isCurrentQuestion,
  ) {
    return Obx(() {
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
    });
  }

  Widget _buildOtherOption(BriefQuestion question, String option) {
    return Obx(() {
        final isSelected = controller.isOptionSelected(question.id, option);

        return CustomCheckboxWidget(
          text: option,
          isSelected: isSelected,
          onTap: () => controller.toggleOption(question.id, option),
          allowMultiple: question.allowMultiple,
        );
    });
  }

  
  Widget _buildInlineTextField() {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 4.w),
      child: SizedBox(
        height: 45.h,
        child: TextField(
          controller: controller.customInputController,
          style: authLableTextTextStyle144001,
          decoration: InputDecoration(
            filled: true,
            fillColor: const Color.fromRGBO(236, 239, 246, 1),
            hintText: "Type your custom features here...",
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
              borderSide: const BorderSide(
                color: AppColors.buttonColor,
                width: 1.2,
              ),
            ),
            contentPadding: EdgeInsets.symmetric(
              vertical: 12.h,
              horizontal: 12.w,
            ),
          ),
          onSubmitted: (value) {
            if (value.trim().isNotEmpty) {
              controller.submitTextAnswer(
                'additional_details',
                controller.customInputController,
              );
            }
          },
        ),
      ),
    );
  }

}