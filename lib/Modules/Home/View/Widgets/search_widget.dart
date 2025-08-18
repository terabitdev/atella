import 'package:atella/core/constants/app_images.dart';
import 'package:atella/core/themes/app_colors.dart';
import 'package:atella/modules/home/Controllers/home_controller.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import '../../../../core/themes/app_fonts.dart';

class SearchWidget extends StatelessWidget {
  final TextEditingController controller;
  final Function(String) onChanged;
  final VoidCallback? onClear;
  final FocusNode? focusNode;

  const SearchWidget({
    super.key,
    required this.controller,
    required this.onChanged,
    this.onClear,
    this.focusNode,
  });

  @override
  Widget build(BuildContext context) {
    // Safely get the controller
    final HomeController? homeController = Get.isRegistered<HomeController>() 
        ? Get.find<HomeController>() 
        : null;
    
    if (homeController == null) {
      // Return a basic text field if controller is not available
      return Container(
        height: 56.h,
        decoration: BoxDecoration(
          color: const Color.fromRGBO(236, 239, 246, 1),
          borderRadius: BorderRadius.circular(6.r),
        ),
        child: TextField(
          controller: controller,
          onChanged: onChanged,
          style: osTextStyle165002,
          decoration: InputDecoration(
            hintText: 'Search Designs',
            hintStyle: osTextStyle165002,
            border: InputBorder.none,
            contentPadding: EdgeInsets.symmetric(
              horizontal: 16.w,
              vertical: 12.h,
            ),
          ),
        ),
      );
    }
    
    final FocusNode searchFocusNode = focusNode ?? FocusNode();
    
    return Obx(() {
      final isFocused = homeController.searchQuery.value.isNotEmpty;
      final hasText = homeController.searchQuery.value.isNotEmpty;
      
      return Container(
        height: 56.h,
        decoration: BoxDecoration(
          color: const Color.fromRGBO(236, 239, 246, 1),
          borderRadius: BorderRadius.circular(6.r),
          border: Border.all(
            color: isFocused ? AppColors.buttonColor : Colors.transparent,
            width: 2.w,
          ),
        ),
        child: TextField(
          controller: controller,
          focusNode: searchFocusNode,
          onChanged: onChanged,
          style: osTextStyle165002,
          decoration: InputDecoration(
            hintText: 'Search Designs',
            hintStyle: osTextStyle165002,
            prefixIcon: Padding(
              padding: EdgeInsets.all(12.w),
              child: Image.asset(
                searchIcon, // Your image asset
                height: 20.h,
                width: 20.w,
                fit: BoxFit.contain,
              ),
            ),
            suffixIcon: hasText
                ? GestureDetector(
                    onTap: () {
                      controller.clear();
                      searchFocusNode.unfocus(); // Unfocus the text field
                      if (onClear != null) {
                        onClear!();
                      }
                    },
                    child: Icon(Icons.clear, size: 20.sp, color: Colors.grey),
                  )
                : const SizedBox.shrink(),
            border: InputBorder.none,
            contentPadding: EdgeInsets.symmetric(
              horizontal: 16.w,
              vertical: 12.h,
            ),
          ),
        ),
      );
    });
  }
}
