import 'package:atella/Data/Models/brief_questions_model.dart';
import 'package:atella/Modules/RefiningConcept/controllers/refining_concept_controller.dart';
import 'package:atella/Modules/CreativeBrief/Views/Widgets/selection_chip_widget.dart';
import 'package:atella/Modules/CreativeBrief/Views/Widgets/text_input_send_widget.dart';
import 'package:atella/Widgets/custom_roundbutton.dart';
import 'package:atella/core/themes/app_fonts.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';

class RefiningBriefScreen extends GetView<RefiningConceptController> {
  const RefiningBriefScreen({Key? key}) : super(key: key);

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

            // Main Content - Scrollable Questions List
            Expanded(
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 24),
                child: _buildQuestionsList(),
              ),
            ),

            // Loading Dots (only for non-last questions)
            _buildLoadingDots(),

            // Bottom Input Area (only for questions 1-5)
            _buildBottomInputArea(),

            // Next Steps Button (only show when completed)
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
                child: Container(
                  width: 34.w,
                  height: 34.w,
                  decoration: BoxDecoration(
                    color: Colors.grey.shade100,
                    borderRadius: BorderRadius.circular(8.r),
                  ),
                  child: Icon(
                    Icons.arrow_back_ios_new,
                    size: 20.sp,
                    color: Colors.black,
                  ),
                ),
              ),

              const Spacer(),

              // Title with underline
              Column(
                children: [
                  Text('Refining the Concept', style: QTextStyle14600),
                  const SizedBox(height: 4),
                  Container(
                    width: 40,
                    height: 3,
                    decoration: BoxDecoration(
                      color: const Color(0xFF8B5FE6),
                      borderRadius: BorderRadius.circular(2),
                    ),
                  ),
                ],
              ),

              const Spacer(),

              const SizedBox(width: 40), // Balance the back button
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
              color: const Color.fromARGB(129, 247, 247, 247),
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
          else if (question.type == 'text' &&
              index >= 5) // Questions 6 and 7 (index 5 and 6)
            _buildTextInputForQuestion(question, isAnswered, isCurrentQuestion),
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
                      ? Color.fromRGBO(139, 134, 254, 1)
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

  Widget buildAnsweredTextContent(BriefQuestion question) {
    final answer = controller.getAnswer(question.id);
    if (answer?.textInput != null) {
      return Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: const Color(0xFFF0F0F0),
          borderRadius: BorderRadius.circular(12),
        ),
        child: Text(
          answer!.textInput!,
          style: const TextStyle(fontSize: 14, color: Color(0xFF333333)),
        ),
      );
    }
    return const SizedBox.shrink();
  }

  Widget _buildTextInputForQuestion(
    BriefQuestion question,
    bool isAnswered,
    bool isCurrentQuestion,
  ) {
    return GetBuilder<RefiningConceptController>(
      builder: (controller) {
        final textController = question.id == 'colors'
            ? controller.colorController
            : controller.fabricController;

        // If question is answered and not being edited, show the answer with option to edit
        if (isAnswered && !controller.isEditing(question.id)) {
          final answer = controller.getAnswer(question.id);
          return Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Show the answered text
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
              // Show edit button
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

        // Show text input for current questions, future questions, or when editing
        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            TextInputWithSend(
              controller: textController,
              placeholder: 'Lorem Ipsum',
              onSend: () {
                print(
                  'TextInputWithSend onSend called for question: ${question.id}',
                );
                print('Text content: "${textController.text.trim()}"');
                if (textController.text.trim().isNotEmpty) {
                  print(
                    'Calling submitTextAnswer for question: ${question.id}',
                  );
                  controller.submitTextAnswer(question.id, textController);
                } else {
                  print('Text is empty, not submitting');
                }
              },
              isLoading: controller.isTextLoading,
            ),
            // Show cancel button if editing
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
                margin: const EdgeInsets.symmetric(horizontal: 4),
                decoration: BoxDecoration(
                  color: const Color(0xFF8B5FE6),
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
          return Padding(
            padding: const EdgeInsets.all(24),
            child: TextInputWithSend(
              controller: currentQuestion.id == 'colors'
                  ? controller.colorController
                  : controller.fabricController,
              placeholder: 'Lorem Ipsum',
              onSend: () => controller.submitTextAnswer(
                currentQuestion.id,
                currentQuestion.id == 'colors'
                    ? controller.colorController
                    : controller.fabricController,
              ),
              isLoading: controller.isTextLoading,
            ),
          );
        }
        return const SizedBox.shrink();
      },
    );
  }

  Widget _buildBottomButton() {
    return GetBuilder<RefiningConceptController>(
      builder: (controller) {
        // Show button when all questions are visible (after question 5) and first 5 questions are answered
        if (controller.currentQuestionIndex >= 5 &&
            controller.answers.length >= 5) {
          return Padding(
            padding: const EdgeInsets.all(24),
            child: RoundButton(
              title: 'Next Steps',
              onTap: () {
                // Navigate to next screen
                Get.toNamed('/next_screen'); // Update this route as needed
              },
              color: const Color(0xFF8B5FE6),
              isloading: false,
            ),
          );
        }
        return const SizedBox.shrink();
      },
    );
  }
}
