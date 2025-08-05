import 'package:flutter/material.dart';

class SaveExportButtonRow extends StatelessWidget {
  final VoidCallback onSave;
  final VoidCallback onExport;
  const SaveExportButtonRow({
    super.key,
    required this.onSave,
    required this.onExport,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Expanded(
          child: OutlinedButton(
            onPressed: onSave,
            style: OutlinedButton.styleFrom(
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
              side: const BorderSide(color: Colors.black, width: 1),
              padding: const EdgeInsets.symmetric(vertical: 16),
            ),
            child: const Text(
              'Save',
              style: TextStyle(
                fontWeight: FontWeight.w600,
                color: Color(0xFF222222),
                fontSize: 16,
              ),
            ),
          ),
        ),
        const SizedBox(width: 16),
        Expanded(
          child: OutlinedButton(
            onPressed: onExport,
            style: OutlinedButton.styleFrom(
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
              side: const BorderSide(color: Colors.black, width: 1),
              padding: const EdgeInsets.symmetric(vertical: 16),
            ),
            child: const Text(
              'Export',
              style: TextStyle(
                fontWeight: FontWeight.w600,
                color: Color(0xFF222222),
                fontSize: 16,
              ),
            ),
          ),
        ),
      ],
    );
  }
}
