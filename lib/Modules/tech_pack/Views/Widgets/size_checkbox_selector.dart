import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';

class SizeCheckboxSelector extends StatelessWidget {
  final List<String> sizes;
  final RxList<String> selectedSizes;
  final Function(String) onSizeToggle;

  const SizeCheckboxSelector({
    super.key,
    required this.sizes,
    required this.selectedSizes,
    required this.onSizeToggle,
  });

  @override
  Widget build(BuildContext context) {
    return Obx(
      () => Wrap(
        spacing: 8.w,
        runSpacing: 8.h,
        children: sizes.map((size) {
          final isSelected = selectedSizes.contains(size);
          return GestureDetector(
            onTap: () => onSizeToggle(size),
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 200),
              padding: EdgeInsets.symmetric(horizontal: 12.w, vertical: 8.h),
              decoration: BoxDecoration(
                color: isSelected ? Colors.white : const Color(0xFFE3E1FB),
                borderRadius: BorderRadius.circular(8.r),
                border: Border.all(
                  color: isSelected ? Colors.black : const Color(0xFFE3E1FB),
                  width: 1.5,
                ),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  // Checkbox icon
                  AnimatedContainer(
                    duration: const Duration(milliseconds: 200),
                    width: 16.w,
                    height: 16.h,
                    decoration: BoxDecoration(
                      color: isSelected ? Colors.white : Colors.transparent,
                      borderRadius: BorderRadius.circular(3.r),
                      border: Border.all(
                        color: isSelected ? Colors.black : Colors.grey[600]!,
                        width: 1.5,
                      ),
                    ),
                    child: isSelected
                        ? Icon(Icons.check, size: 11.sp, color: Colors.black)
                        : null,
                  ),
                  SizedBox(width: 6.w),
                  // Size label
                  Text(
                    size,
                    style: TextStyle(
                      fontSize: 14.sp,
                      fontWeight: FontWeight.normal,
                      color: Colors.black,
                    ),
                  ),
                ],
              ),
            ),
          );
        }).toList(),
      ),
    );
  }
}
