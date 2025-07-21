import 'package:atella/Modules/TechPack/controllers/generate_tech_pack_controller.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:atella/Modules/TechPack/Views/Widgets/tech_pack_image_card.dart';
import 'package:atella/Modules/TechPack/Views/Widgets/tech_pack_action_container.dart';
import 'package:atella/Widgets/app_header.dart';

class GenerateTechPackScreen extends StatelessWidget {
  GenerateTechPackScreen({super.key});

  final controller = Get.put(TechPackController());

  void onMakeChanges() => Get.back();

  void onContinue(BuildContext context) {
    Get.toNamed('/tech_pack_details_screen');
    Get.snackbar(
      'Tech Pack Generated',
      'Your tech pack has been successfully generated.',
      snackPosition: SnackPosition.BOTTOM,
      colorText: Colors.white,
      duration: const Duration(seconds: 2),
    );
  }

  void showImageDialog(BuildContext context, String imagePath) {
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
              child: Image.asset(imagePath, fit: BoxFit.cover),
            ),
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFFDFDFD),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(24.0),
            child: GlobalHeader(
              title: 'Design Assistant',
              onBack: () => Get.back(),
            ),
          ),
          const SizedBox(height: 12),
          Expanded(
            child: SingleChildScrollView(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: Obx(() {
                return Column(
                  children: [
                    ...List.generate(
                      3,
                      (index) => TechPackImageCard(
                        isLoading: controller.isLoading.value,
                        imagePath: controller.isLoading.value
                            ? null
                            : controller.generatedImages[index],
                        onTap: (!controller.isLoading.value)
                            ? () => showImageDialog(
                                context,
                                controller.generatedImages[index],
                              )
                            : null,
                      ),
                    ),
                    if (!controller.isLoading.value)
                      TechPackActionContainer(
                        onMakeChanges: onMakeChanges,
                        onContinue: () => onContinue(context),
                      ),
                  ],
                );
              }),
            ),
          ),
        ],
      ),
    );
  }
}
