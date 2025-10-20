import 'package:atella/Modules/creative_brief/Views/Widgets/selection_chip_widget.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

class CategorizedChipsWidget extends StatelessWidget {
  final Map<String, List<String>> categories;
  final String? selectedOption;
  final Function(String) onOptionSelected;

  const CategorizedChipsWidget({
    Key? key,
    required this.categories,
    required this.selectedOption,
    required this.onOptionSelected,
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
            final isSelected = selectedOption == option;
            return SelectionChipWidget(
              text: option,
              isSelected: isSelected,
              onTap: () => onOptionSelected(option),
            );
          }).toList(),
        ),
        SizedBox(height: 16.h),
      ],
    );
  }
}
