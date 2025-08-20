import 'package:atella/modules/creative_brief/controllers/creative_brief_controller.dart';
import 'package:atella/modules/final_details/controllers/final_detail_controller.dart';
import 'package:atella/modules/refining_concept/controllers/refining_concept_controller.dart';
import 'package:atella/modules/tech_pack/Views/Widgets/outline_genrate_round_button.dart';
import 'package:atella/modules/tech_pack/controllers/generate_tech_pack_controller.dart';
import 'package:atella/Widgets/custom_roundbutton.dart';
import 'package:atella/core/themes/app_fonts.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:atella/Widgets/app_header.dart';
import 'package:google_fonts/google_fonts.dart';
import 'dart:convert';

class GenerateTechPackScreen extends StatelessWidget {
  GenerateTechPackScreen({super.key});

  final controller = Get.put(TechPackController(), permanent: true);

  void showImageDialog(BuildContext context, String base64Image) {
    showDialog(
      context: context,
      barrierDismissible: true,
      builder: (context) {
        return Dialog(
          backgroundColor: Colors.transparent,
          insetPadding: const EdgeInsets.symmetric(
            horizontal: 12,
            vertical: 60,
          ),
          child: Container(
            width: double.infinity,
            height: 500,
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(36),
            ),
            padding: const EdgeInsets.all(8),
            child: ClipRRect(
              borderRadius: BorderRadius.circular(28),
              child: Image.memory(
                base64Decode(base64Image),
                fit: BoxFit.cover,
                errorBuilder: (context, error, stackTrace) {
                  return Container(
                    color: Colors.grey.shade200,
                    child: Center(
                      child: Icon(
                        Icons.error_outline,
                        size: 48,
                        color: Colors.grey.shade400,
                      ),
                    ),
                  );
                },
              ),
            ),
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          Column(
            children: [
              Padding(
                padding: const EdgeInsets.all(24.0),
                child: GlobalHeader(
                  title: 'Design Assistant',
                  onBack: () => Get.back(),
                ),
              ),
              const SizedBox(height: 12),
              Obx(() {
                if (controller.isLoading.value) {
                  return _buildLoadingState();
                } else if (controller.hasError.value) {
                  return _buildErrorState();
                } else {
                  return Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 24.0),
                    child: Text(
                      'Choose your favorite design:',
                      style: GoogleFonts.inter(
                        fontSize: 18,
                        fontWeight: FontWeight.w600,
                        color: const Color(0xFF1A1A1A),
                      ),
                    ),
                  );
                }
              }),
              const SizedBox(height: 20),
              Expanded(
                child: SingleChildScrollView(
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  child: Obx(() {
                    return Column(
                      children: [
                        ...List.generate(3, (index) {
                          if (controller.isLoading.value) {
                            return _buildLoadingCard();
                          } else if (controller.hasError.value) {
                            return _buildErrorCard(index);
                          } else if (controller.generatedImages.isNotEmpty &&
                              index < controller.generatedImages.length) {
                            return _buildDesignImageCard(
                              controller.generatedImages[index],
                              index,
                              context,
                            );
                          } else {
                            return _buildEmptyCard(index);
                          }
                        }),
                        const SizedBox(height: 20),
                        if (!controller.isLoading.value &&
                            !controller.hasError.value)
                          _buildActionButtons(),
                      ],
                    );
                  }),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildLoadingState() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 24.0),
      child: Column(
        children: [
          Text(
            'Creating your designs...',
            style: GoogleFonts.inter(
              fontSize: 18,
              fontWeight: FontWeight.w600,
              color: const Color(0xFF1A1A1A),
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'Please wait while we generate 3 unique designs based on your preferences.',
            textAlign: TextAlign.center,
            style: GoogleFonts.inter(
              fontSize: 14,
              color: const Color(0xFF666666),
            ),
          ),
          const SizedBox(height: 16),
        ],
      ),
    );
  }

  Widget _buildErrorState() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 24.0),
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Colors.red.shade50,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: Colors.red.shade200),
        ),
        child: Column(
          children: [
            Icon(Icons.error_outline, color: Colors.red.shade600, size: 32),
            const SizedBox(height: 8),
            Text(
              'Something went wrong',
              style: GoogleFonts.inter(
                fontSize: 16,
                fontWeight: FontWeight.w600,
                color: Colors.red.shade700,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              controller.errorMessage.value,
              textAlign: TextAlign.center,
              style: GoogleFonts.inter(
                fontSize: 14,
                color: Colors.red.shade600,
              ),
            ),
            const SizedBox(height: 12),
            ElevatedButton(
              onPressed: controller.retryGeneration,
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.red.shade600,
                foregroundColor: Colors.white,
              ),
              child: const Text('Retry'),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildLoadingCard() {
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      height: 180.h,
      decoration: BoxDecoration(
        color: const Color.fromRGBO(236, 239, 246, 1),
        borderRadius: BorderRadius.circular(12.r),
      ),
      child: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Image.asset(
              'assets/images/generate.png',
              width: 60.w,
              height: 64.h,
            ),
            SizedBox(height: 16.h),
            Text('Generating...', style: gsTextStyle17500),
          ],
        ),
      ),
    );
  }

  Widget _buildErrorCard(int index) {
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      height: 280,
      decoration: BoxDecoration(
        color: Colors.grey.shade100,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: Colors.grey.shade300),
      ),
      child: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.image_not_supported_outlined,
              size: 48,
              color: Colors.grey.shade400,
            ),
            const SizedBox(height: 8),
            Text(
              'Design ${index + 1}',
              style: GoogleFonts.inter(
                fontSize: 16,
                color: Colors.grey.shade600,
              ),
            ),
            Text(
              'Failed to generate',
              style: GoogleFonts.inter(
                fontSize: 12,
                color: Colors.grey.shade500,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildEmptyCard(int index) {
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      height: 280,
      decoration: BoxDecoration(
        color: Colors.grey.shade50,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: Colors.grey.shade200),
      ),
      child: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.image_outlined, size: 48, color: Colors.grey.shade300),
            const SizedBox(height: 8),
            Text(
              'Design ${index + 1}',
              style: GoogleFonts.inter(
                fontSize: 16,
                color: Colors.grey.shade400,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildDesignImageCard(
    String base64Image,
    int index,
    BuildContext context,
  ) {
    return Obx(() {
      final isSelected = controller.selectedDesignIndex.value == index;
      return GestureDetector(
        onTap: () {
          controller.selectDesign(index);
          showImageDialog(context, base64Image);
        },
        child: Container(
          margin: const EdgeInsets.only(bottom: 16),
          color: Colors.white,
          child: Column(
            children: [
              Container(
                height: 180.h,
                margin: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(
                    color: isSelected ? const Color(0xFF1A1A1A) : Colors.white,
                    width: 1,
                  ),
                ),
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(20),
                  child: Stack(
                    children: [
                      Image.memory(
                        base64Decode(base64Image),
                        width: double.infinity,
                        height: double.infinity,
                        fit: BoxFit.cover,
                        errorBuilder: (context, error, stackTrace) {
                          return Container(
                            color: Colors.grey.shade200,
                            child: Center(
                              child: Column(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  Icon(
                                    Icons.image_not_supported_outlined,
                                    size: 48,
                                    color: Colors.grey.shade400,
                                  ),
                                  const SizedBox(height: 8),
                                  Text(
                                    'Failed to load image',
                                    style: GoogleFonts.inter(
                                      fontSize: 12,
                                      color: Colors.grey.shade500,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          );
                        },
                      ),
                      if (isSelected)
                        Positioned(
                          top: 8,
                          right: 8,
                          child: Image.asset(
                            'assets/images/tick.png',
                            width: 20,
                            height: 20,
                          ),
                        ),
                      if (!isSelected)
                        Positioned(
                          top: 8,
                          right: 8,
                          child: const Icon(
                            Icons.touch_app,
                            color: Colors.white,
                            size: 20,
                          ),
                        ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      );
    });
  }

  Widget _buildActionButtons() {
    return Column(
      children: [
        Container(
          height: 68.h,
          decoration: BoxDecoration(
            color: const Color.fromRGBO(211, 213, 223, 1),
            borderRadius: BorderRadius.circular(12.r),
          ),
          child: Center(
            child: Text(
              'Would you like to make any changes before I create the final tech pack?',
              textAlign: TextAlign.center,
              style: tpcTextStyle16400.copyWith(color: Colors.black),
            ),
          ),
        ),
        SizedBox(height: 44.h),
        RoundButton(
          title: 'Yes, I\'d like to make changes',
          onTap: (){
            // Reset all questionnaire answers before going back
            if (Get.isRegistered<CreativeBriefController>()) {
              Get.find<CreativeBriefController>().resetAllAnswers();
            }
            if (Get.isRegistered<RefiningConceptController>()) {
              Get.find<RefiningConceptController>().resetAllAnswers();
            }
            if (Get.isRegistered<FinalDetailsController>()) {
              Get.find<FinalDetailsController>().resetAllAnswers();
            }
            // Delete the TechPackController so it will be recreated fresh next time
            if (Get.isRegistered<TechPackController>()) {
              Get.delete<TechPackController>();
            }
            Get.toNamed('/creative_brief');
          },
          color: const Color(0xFF1A1A1A),
          isloading: false,
        ),
        SizedBox(height: 12.h),
        Obx(() {
          final isDesignSelected = controller.selectedDesignIndex.value >= 0;

          return OutlineGenerateRoundButton(
            title: isDesignSelected
                ? 'Continue with Selected Design'
                : 'Please select a design first',
            onTap: isDesignSelected
                ? controller.onContinueWithSelectedDesign
                : () {},
            color: isDesignSelected ? const Color(0xFF1A1A1A) : Colors.grey,
            imagePath: 'assets/images/techpackgenerate.png',
          );
        }),
        SizedBox(height: 24.h),
      ],
    );
  }
}
