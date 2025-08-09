import 'package:atella/Modules/TechPack/controllers/manufacturer_suggestion_controller.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';

class SegmentedTabSwitcher extends StatelessWidget {
  final ManufacturerSuggestionController controller;

  const SegmentedTabSwitcher({super.key, required this.controller});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.symmetric(horizontal: 18.w, vertical: 18.h),
      child: Container(
        height: 48.h,
        decoration: BoxDecoration(
          color: const Color.fromRGBO(236, 239, 246, 1),
          borderRadius: BorderRadius.circular(24.r),
        ),
        child: Row(
          children: [
            // Recommended Manufacturers
            GestureDetector(
              onTap: () => controller.tabIndex.value = 0,
              child: Obx(
                () => Container(
                  height: 48.h,
                  decoration: BoxDecoration(
                    color: controller.tabIndex.value == 0
                        ? Colors.black
                        : const Color.fromRGBO(236, 239, 246, 1),
                    borderRadius: BorderRadius.only(
                      topLeft: Radius.circular(24.r),
                      bottomLeft: Radius.circular(24.r),
                      topRight: Radius.circular(24.r),
                      bottomRight: Radius.circular(24.r),
                    ),
                  ),
                  alignment: Alignment.center,
                  child: Padding(
                    padding: EdgeInsets.all(8.r),
                    child: Text(
                      'Recommended Manufacturers',
                      style: TextStyle(
                        fontSize: 14.sp,
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
                    height: 48.h,
                    decoration: BoxDecoration(
                      color: controller.tabIndex.value == 1
                          ? Colors.black
                          : const Color.fromRGBO(236, 239, 246, 1),
                      borderRadius: BorderRadius.only(
                        topLeft: Radius.circular(24.r),
                        bottomLeft: Radius.circular(24.r),
                        topRight: Radius.circular(24.r),
                        bottomRight: Radius.circular(24.r),
                      ),
                    ),
                    alignment: Alignment.center,
                    child: Padding(
                      padding: EdgeInsets.all(8.r),
                      child: Text(
                        'Custom',
                        style: TextStyle(
                          fontSize: 14.sp,
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
