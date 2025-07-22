import 'package:atella/Modules/TechPack/controllers/manufacturer_suggestion_controller.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

class SegmentedTabSwitcher extends StatelessWidget {
  final ManufacturerSuggestionController controller;

  const SegmentedTabSwitcher({super.key, required this.controller});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 18),
      child: Container(
        height: 48,
        decoration: BoxDecoration(
          color: const Color.fromRGBO(236, 239, 246, 1),
          borderRadius: BorderRadius.circular(24),
        ),
        child: Row(
          children: [
            // Recommended Manufacturers
            GestureDetector(
              onTap: () => controller.tabIndex.value = 0,
              child: Obx(
                () => Container(
                  height: 48,
                  decoration: BoxDecoration(
                    color: controller.tabIndex.value == 0
                        ? Colors.black
                        : const Color.fromRGBO(236, 239, 246, 1),
                    borderRadius: const BorderRadius.only(
                      topLeft: Radius.circular(24),
                      bottomLeft: Radius.circular(24),
                      topRight: Radius.circular(24),
                      bottomRight: Radius.circular(24),
                    ),
                  ),
                  alignment: Alignment.center,
                  child: Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: Text(
                      'Recommended Manufacturers',
                      style: TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w600,
                        color: controller.tabIndex.value == 0
                            ? Colors.white
                            : Colors.black,
                      ),
                      textAlign: TextAlign.center,
                    ),
                  ),
                ),
              ),
            ),

            // Custom
            Expanded(
              child: GestureDetector(
                onTap: () => controller.tabIndex.value = 1,
                child: Obx(
                  () => Container(
                    height: 48,
                    decoration: BoxDecoration(
                      color: controller.tabIndex.value == 1
                          ? Colors.black
                          : const Color.fromRGBO(236, 239, 246, 1),
                      borderRadius: const BorderRadius.only(
                        topLeft: Radius.circular(24),
                        bottomLeft: Radius.circular(24),
                        topRight: Radius.circular(24),
                        bottomRight: Radius.circular(24),
                      ),
                    ),
                    alignment: Alignment.center,
                    child: Padding(
                      padding: const EdgeInsets.all(8.0),
                      child: Text(
                        'Custom',
                        style: TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.w600,
                          color: controller.tabIndex.value == 1
                              ? Colors.white
                              : Colors.black,
                        ),
                      ),
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
