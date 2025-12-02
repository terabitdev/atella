import 'package:atella/Modules/creative_brief/Views/Widgets/selection_chip_widget.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

class CategorizedChipsWidget extends StatelessWidget {
  final Map<String, List<String>> categories;
  final String? selectedOption;
  final Function(String, String) onOptionSelected; // Now includes categoryName
  final String questionId; // Add questionId to check custom selection
  final String
  customSelectedForCategory; // Observable value for custom selection

  const CategorizedChipsWidget({
    Key? key,
    required this.categories,
    required this.selectedOption,
    required this.onOptionSelected,
    required this.questionId,
    required this.customSelectedForCategory,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: categories.entries.map((category) {
        return _buildCategorySection(
          categoryName: category.key,
          options: category.value,
        );
      }).toList(),
    );
  }

  Widget _buildCategorySection({
    required String categoryName,
    required List<String> options,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Category title
        Padding(
          padding: EdgeInsets.only(bottom: 12.h, top: 8.h),
          child: Text(
            categoryName,
            style: TextStyle(
              fontSize: 14.sp,
              fontWeight: FontWeight.w600,
              color: const Color(0xFF666666),
            ),
          ),
        ),
        // Category options as chips
        Wrap(
          spacing: 8.w,
          runSpacing: 8.h,
          children: options.map((option) {
            // Check if this option is selected (either directly or as Custom for this category)
            // Access the observable value directly to make it reactive
            final customKey = '$questionId:$categoryName';

            bool isSelected = false;
            if (option == 'Custom') {
              // Check if custom is selected for this category (either from temp state or saved answer)
              isSelected =
                  customSelectedForCategory == customKey ||
                  selectedOption == '$categoryName:Custom';
            } else {
              // Regular option - check both formats: "option" and "categoryName:option"
              isSelected =
                  selectedOption == option ||
                  selectedOption == '$categoryName:$option';
            }

            return SelectionChipWidget(
              text: option,
              isSelected: isSelected,
              onTap: () => onOptionSelected(option, categoryName),
            );
          }).toList(),
        ),
        SizedBox(height: 16.h),
      ],
    );
  }
}
