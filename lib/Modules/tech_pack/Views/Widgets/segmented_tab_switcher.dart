import 'package:atella/Modules/tech_pack/controllers/manufacturer_suggestion_controller.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:atella/l10n/generated/app_localizations.dart';

class SegmentedTabSwitcher extends StatelessWidget {
  final ManufacturerSuggestionController controller;

  const SegmentedTabSwitcher({super.key, required this.controller});

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    return Padding(
      padding: EdgeInsets.symmetric(horizontal: 18.w, vertical: 18.h),
      child: Container(
        height: 64.h,
        decoration: BoxDecoration(
          color: const Color.fromRGBO(236, 239, 246, 1),
          borderRadius: BorderRadius.circular(24.r),
        ),
        child: Row(
          children: [
            // Recommended Manufacturers
            Expanded(
              child: GestureDetector(
                onTap: () => controller.switchToTab(0),
                child: Obx(
                  () => Container(
                    height: 64.h,
                    decoration: BoxDecoration(
                      color: controller.tabIndex.value == 0
                          ? Colors.black
                          : const Color.fromRGBO(236, 239, 246, 1),
                      borderRadius: BorderRadius.circular(24.r),
                    ),
                    alignment: Alignment.center,
                    child: Padding(
                      padding: EdgeInsets.symmetric(horizontal: 12.w),
                      child: Text(
                        l10n.tpRecommendedManufacturers,
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
            ),

            // Custom
            Expanded(
              child: GestureDetector(
                onTap: () => controller.switchToTab(1),
                child: Obx(
                  () => Container(
                    height: 64.h,
                    decoration: BoxDecoration(
                      color: controller.tabIndex.value == 1
                          ? Colors.black
                          : const Color.fromRGBO(236, 239, 246, 1),
                      borderRadius: BorderRadius.circular(24.r),
                    ),
                    alignment: Alignment.center,
                    child: Padding(
                      padding: EdgeInsets.symmetric(horizontal: 12.w),
                      child: Text(
                        l10n.tpCustomTab,
                        style: TextStyle(
                          fontSize: 13.sp,
                          fontWeight: FontWeight.w600,
                          color: controller.tabIndex.value == 1
                              ? Colors.white
                              : Colors.black,
                        ),
                        textAlign: TextAlign.center,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
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
