import 'package:flutter/material.dart';

class SaveExportButtonRow extends StatelessWidget {
  final VoidCallback? onSave;
  final VoidCallback? onExport;
  final bool isSaving;
  final bool isExporting;
  
  const SaveExportButtonRow({
    super.key,
    required this.onSave,
    required this.onExport,
    this.isSaving = false,
    this.isExporting = false,
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
            child: isSaving 
              ? const SizedBox(
                  width: 20,
                  height: 20,
                  child: CircularProgressIndicator(
                    strokeWidth: 2,
                    valueColor: AlwaysStoppedAnimation<Color>(Color(0xFF222222)),
                  ),
                )
              : const Text(
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
            child: isExporting 
              ? const SizedBox(
                  width: 20,
                  height: 20,
                  child: CircularProgressIndicator(
                    strokeWidth: 2,
                    valueColor: AlwaysStoppedAnimation<Color>(Color(0xFF222222)),
                  ),
                )
              : const Text(
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
