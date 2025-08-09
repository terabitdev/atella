import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

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
                borderRadius: BorderRadius.circular(12.r),
              ),
              side: const BorderSide(color: Colors.black, width: 1),
              padding: EdgeInsets.symmetric(vertical: 16.h),
            ),
            child: isSaving 
              ? SizedBox(
                  width: 20.w,
                  height: 20.h,
                  child: CircularProgressIndicator(
                    strokeWidth: 2,
                    valueColor: AlwaysStoppedAnimation<Color>(Color(0xFF222222)),
                  ),
                )
              : Text(
                  'Save',
                  style: TextStyle(
                    fontWeight: FontWeight.w600,
                    color: Color(0xFF222222),
                    fontSize: 16.sp,
                  ),
                ),
          ),
        ),
        SizedBox(width: 16.w),
        Expanded(
          child: OutlinedButton(
            onPressed: onExport,
            style: OutlinedButton.styleFrom(
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12.r),
              ),
              side: const BorderSide(color: Colors.black, width: 1),
              padding: EdgeInsets.symmetric(vertical: 16.h),
            ),
            child: isExporting 
              ? SizedBox(
                  width: 20.w,
                  height: 20.h,
                  child: CircularProgressIndicator(
                    strokeWidth: 2,
                    valueColor: AlwaysStoppedAnimation<Color>(Color(0xFF222222)),
                  ),
                )
              : Text(
                  'Export',
                  style: TextStyle(
                    fontWeight: FontWeight.w600,
                    color: Color(0xFF222222),
                    fontSize: 16.sp,
                  ),
                ),
          ),
        ),
      ],
    );
  }
}
