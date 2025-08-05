import 'package:atella/core/themes/app_fonts.dart';
import 'package:flutter/material.dart';

class ReusableDropdownField<T> extends StatelessWidget {
  final String label;
  final T? value;
  final List<T> items;
  final void Function(T?)? onChanged;
  final String Function(T) itemLabel;
  final EdgeInsetsGeometry? margin;

  const ReusableDropdownField({
    super.key,
    required this.label,
    required this.value,
    required this.items,
    required this.onChanged,
    required this.itemLabel,
    this.margin,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: margin,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(label, style: ddTextTextStyle16500),
          const SizedBox(height: 8),
          DropdownButtonFormField<T>(
            value: value,
            items: items
                .map(
                  (e) =>
                      DropdownMenuItem<T>(value: e, child: Text(itemLabel(e))),
                )
                .toList(),
            onChanged: onChanged,
            decoration: InputDecoration(
              filled: true,
              fillColor: Color.fromRGBO(236, 239, 246, 1),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: BorderSide.none,
              ),
              contentPadding: const EdgeInsets.symmetric(
                vertical: 14,
                horizontal: 16,
              ),
            ),
            style: ddTextTextStyle14400,
            icon: const Icon(Icons.keyboard_arrow_down_rounded),
          ),
        ],
      ),
    );
  }
}
