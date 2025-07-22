// 4. Final Details Screen
// lib/Modules/FinalDetails/Views/Screens/final_details_screen.dart
import 'package:atella/Data/Models/brief_questions_model.dart';
import 'package:atella/Modules/CreativeBrief/Views/Widgets/text_input_send_widget.dart';
import 'package:atella/Modules/FinalDetails/Views/Widgets/custom_check_boxes_widget.dart';
import 'package:atella/Modules/FinalDetails/Views/Widgets/custom_generate_round_button_widget.dart';
import 'package:atella/Modules/FinalDetails/controllers/final_detail_controller.dart';
import 'package:atella/Widgets/custom_roundbutton.dart';
import 'package:atella/core/constants/app_iamges.dart';
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
    SystemChrome.setSystemUIOverlayStyle(
      const SystemUiOverlayStyle(
        statusBarColor: Colors.transparent,
        statusBarIconBrightness: Brightness.dark,
        statusBarBrightness: Brightness.light,
      ),
    );

    return Scaffold(
      backgroundColor: const Color(0xFFFAFAFA),
      body: SafeArea(
        child: Column(
          children: [
            // Header
            _buildHeader(),

            // Main Content
            Expanded(
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 24),
                child: _buildQuestionsList(),
              ),
            ),

            // Loading Dots (show until last question)
            _buildLoadingDots(),

            // // Bottom Input Field (for all questions)
            // _buildBottomInputField(),

            // Generate Button (only when all completed)
            _buildBottomButton(),
          ],
        ),
      ),
    );
  }

  Widget _buildHeader() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
      child: Column(
        children: [
          Row(
            children: [
              // Back Button
              GestureDetector(
                onTap: Get.back,
                child: Icon(
                  Icons.arrow_back_ios_new,
                  size: 20.sp,
                  color: Colors.black,
                ),
              ),

              const Spacer(),

              // Title with underline
              Column(
                children: [
                  Text(
                    'Final Details',
                    style: QTextStyle14600.copyWith(
                      color: AppColors.buttonColor,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Container(
                    width: 40,
                    height: 3,
                    decoration: BoxDecoration(
                      color: AppColors.buttonColor,
                      borderRadius: BorderRadius.circular(2),
                    ),
                  ),
                ],
              ),

              const Spacer(),
              const SizedBox(width: 40),
            ],
          ),

          const SizedBox(height: 24),

          // Timestamp
          Obx(
            () => Text(
              controller.currentTime,
              style: const TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w400,
                color: Color(0xFF999999),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildQuestionsList() {
    return GetBuilder<FinalDetailsController>(
      builder: (controller) => ListView.builder(
        padding: const EdgeInsets.only(top: 32, bottom: 20),
        itemCount:
            controller.currentQuestionIndex +
            1, // Show only current + previous questions
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
          // Section Title (for first 3 questions)
          if (index < 3) _buildSectionTitle(question.id),

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
                  child: Text(question.question, style: QTextStyle16400),
                ),
                const SizedBox(width: 12),
                if (isAnswered)
                  Image.asset('assets/images/tick.png', height: 16, width: 16),
              ],
            ),
          ),

          const SizedBox(height: 16),

          // Answer Options
          if (question.type == 'checkbox')
            _buildCheckboxOptions(question, isAnswered, isCurrentQuestion)
          else if (question.type == 'text')
            _buildTextInput(question, isAnswered, isCurrentQuestion),
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
              // Handle "Other: ?" option specially
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
        final isSelected =
            controller.isOptionSelected(question.id, option) ||
            controller.answers[question.id]?.selectedOptions.any(
                  (opt) => opt.startsWith('Other:'),
                ) ==
                true;

        return Column(
          children: [
            CustomCheckboxWidget(
              text: option,
              isSelected: isSelected,
              onTap: () {
                controller.toggleOption(question.id, option);
                // Immediately advance when "Other: ?" is clicked in question 3
                if (question.id == 'desired_features' && option == 'Other: ?') {
                  // The toggleOption method will handle the advancement
                }
              },
              allowMultiple: question.allowMultiple,
            ),

            // Show text input when "Other" is selected and we're still on this question
            if (isSelected && controller.currentQuestion.id == question.id) ...[
              const SizedBox(height: 8),
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 16,
                  vertical: 8,
                ),
                decoration: BoxDecoration(
                  color: const Color(0xFFF8F8F8),
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: const Color(0xFFE0E0E0)),
                ),
                child: Row(
                  children: [
                    Expanded(
                      child: TextField(
                        controller: controller.otherFeaturesController,
                        decoration: const InputDecoration(
                          hintText: 'Type your custom feature...',
                          hintStyle: TextStyle(
                            color: Color(0xFF999999),
                            fontSize: 14,
                          ),
                          border: InputBorder.none,
                          contentPadding: EdgeInsets.symmetric(vertical: 8),
                        ),
                        style: const TextStyle(
                          fontSize: 14,
                          color: Color(0xFF333333),
                        ),
                      ),
                    ),
                    const SizedBox(width: 12),
                    GestureDetector(
                      onTap: () => controller.submitOtherFeature(
                        controller.otherFeaturesController.text,
                      ),
                      child: Container(
                        width: 32,
                        height: 32,
                        decoration: const BoxDecoration(
                          gradient: LinearGradient(
                            colors: [Color(0xFF8B5FE6), Color(0xFF7B5AC7)],
                          ),
                          shape: BoxShape.circle,
                        ),
                        child: const Icon(
                          Icons.send_rounded,
                          color: Colors.white,
                          size: 16,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ],
        );
      },
    );
  }

  Widget _buildTextInput(
    BriefQuestion question,
    bool isAnswered,
    bool isCurrentQuestion,
  ) {
    return GetBuilder<FinalDetailsController>(
      builder: (controller) {
        if (isAnswered && !controller.isEditing(question.id)) {
          final answer = controller.getAnswer(question.id);
          return Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: const Color(0xFFF0F0F0),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Text(
                  answer?.textInput ?? '',
                  style: const TextStyle(
                    fontSize: 14,
                    color: Color(0xFF333333),
                  ),
                ),
              ),
              const SizedBox(height: 12),
              GestureDetector(
                onTap: () => controller.enableEditing(question.id),
                child: Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 16,
                    vertical: 8,
                  ),
                  decoration: BoxDecoration(
                    color: const Color(0xFF8B5FE6).withOpacity(0.1),
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(color: const Color(0xFF8B5FE6)),
                  ),
                  child: const Text(
                    'Edit Answer',
                    style: TextStyle(
                      fontSize: 12,
                      color: Color(0xFF8B5FE6),
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ),
              ),
            ],
          );
        }

        return Column(
          children: [
            TextInputWithSend(
              controller: controller.customInputController,
              placeholder: 'Lorem Ipsum',
              onSend: () => controller.submitTextAnswer(
                question.id,
                controller.customInputController,
              ),
              isLoading: controller.isLoading,
            ),
            if (controller.isEditing(question.id)) ...[
              const SizedBox(height: 8),
              GestureDetector(
                onTap: () => controller.cancelEditing(question.id),
                child: Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 16,
                    vertical: 8,
                  ),
                  decoration: BoxDecoration(
                    color: const Color(0xFFF5F5F5),
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(color: const Color(0xFFE0E0E0)),
                  ),
                  child: const Text(
                    'Cancel',
                    style: TextStyle(
                      fontSize: 12,
                      color: Color(0xFF666666),
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ),
              ),
            ],
          ],
        );
      },
    );
  }

  Widget _buildBottomButton() {
    return GetBuilder<FinalDetailsController>(
      builder: (controller) {
        // Show button when on last question OR all questions are completed
        if (controller.currentQuestionIndex >=
            controller.questions.length - 1) {
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
        return const SizedBox(height: 80); // Space when button not shown
      },
    );
  }

  Widget _buildLoadingDots() {
    return GetBuilder<FinalDetailsController>(
      builder: (controller) {
        // Don't show dots on last question
        if (controller.currentQuestionIndex >=
            controller.questions.length - 1) {
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
                margin: const EdgeInsets.symmetric(horizontal: 4),
                decoration: const BoxDecoration(
                  color: Color(0xFF8B5FE6),
                  shape: BoxShape.circle,
                ),
              );
            }),
          ),
        );
      },
    );
  }

  // Widget _buildBottomInputField() {
  //   return GetBuilder<FinalDetailsController>(
  //     builder: (controller) {
  //       final currentQuestion = controller.currentQuestion;

  //       // Show bottom input field for all questions
  //       return Padding(
  //         padding: const EdgeInsets.all(24),
  //         child: Container(
  //           padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
  //           decoration: BoxDecoration(
  //             color: const Color(0xFFF8F8F8),
  //             borderRadius: BorderRadius.circular(12),
  //             border: Border.all(color: const Color(0xFFE0E0E0)),
  //           ),
  //           child: Row(
  //             children: [
  //               Expanded(
  //                 child: TextField(
  //                   controller: controller.customInputController,
  //                   decoration: const InputDecoration(
  //                     hintText: 'Lorem Ipsum',
  //                     hintStyle: TextStyle(
  //                       color: Color(0xFF999999),
  //                       fontSize: 14,
  //                     ),
  //                     border: InputBorder.none,
  //                     contentPadding: EdgeInsets.symmetric(vertical: 8),
  //                   ),
  //                   style: const TextStyle(
  //                     fontSize: 14,
  //                     color: Color(0xFF333333),
  //                   ),
  //                 ),
  //               ),
  //               const SizedBox(width: 12),
  //               GestureDetector(
  //                 onTap: () {
  //                   if (controller.customInputController.text
  //                       .trim()
  //                       .isNotEmpty) {
  //                     // For text questions, submit as text answer
  //                     if (currentQuestion.type == 'text') {
  //                       controller.submitTextAnswer(
  //                         currentQuestion.id,
  //                         controller.customInputController,
  //                       );
  //                     } else {
  //                       // For checkbox questions, treat as custom option
  //                       controller.toggleOption(
  //                         currentQuestion.id,
  //                         'Custom: ${controller.customInputController.text.trim()}',
  //                       );
  //                       controller.customInputController.clear();
  //                     }
  //                   }
  //                 },
  //                 child: Container(
  //                   width: 36,
  //                   height: 36,
  //                   decoration: const BoxDecoration(
  //                     gradient: LinearGradient(
  //                       colors: [Color(0xFF8B5FE6), Color(0xFF7B5AC7)],
  //                     ),
  //                     shape: BoxShape.circle,
  //                   ),
  //                   child: controller.isLoading
  //                       ? const SizedBox(
  //                           width: 16,
  //                           height: 16,
  //                           child: CircularProgressIndicator(
  //                             color: Colors.white,
  //                             strokeWidth: 2,
  //                           ),
  //                         )
  //                       : const Icon(
  //                           Icons.send_rounded,
  //                           color: Colors.white,
  //                           size: 18,
  //                         ),
  //                 ),
  //               ),
  //             ],
  //           ),
  //         ),
  //       );
  //     },
  //   );
  // }
}
