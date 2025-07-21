import 'package:atella/core/themes/app_fonts.dart';
import 'package:flutter/material.dart';

class CustomCheckboxWidget extends StatelessWidget {
  final String text;
  final bool isSelected;
  final VoidCallback onTap;
  final bool allowMultiple;

  const CustomCheckboxWidget({
    Key? key,
    required this.text,
    required this.isSelected,
    required this.onTap,
    this.allowMultiple = true,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        margin: const EdgeInsets.only(bottom: 8),
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(color: Colors.transparent),
        child: Row(
          children: [
            // Custom Checkbox
            Container(
              width: 20,
              height: 20,
              decoration: BoxDecoration(
                color: isSelected
                    ? const Color.fromRGBO(139, 134, 254, 1)
                    : Colors.transparent,
                border: Border.all(
                  color: isSelected
                      ? const Color.fromRGBO(139, 134, 254, 1)
                      : const Color.fromRGBO(204, 204, 204, 1),
                  width: 2,
                ),
                borderRadius: BorderRadius.circular(4),
              ),
              child: isSelected
                  ? const Icon(Icons.check, color: Colors.white, size: 14)
                  : null,
            ),

            const SizedBox(width: 12),

            // Text
            Expanded(child: Text(text, style: CBTextStyle12400)),
          ],
        ),
      ),
    );
  }
}
