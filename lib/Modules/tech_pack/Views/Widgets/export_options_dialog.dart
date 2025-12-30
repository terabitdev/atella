import 'package:atella/core/themes/app_fonts.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:atella/l10n/generated/app_localizations.dart';
import 'export_options_controller.dart';

class ExportOptionsDialog extends StatelessWidget {
  final Function(ExportType exportType) onExport;

  const ExportOptionsDialog({
    super.key,
    required this.onExport,
  });

  @override
  Widget build(BuildContext context) {
    final controller = Get.put(ExportOptionsController());
    final l10n = AppLocalizations.of(context)!;

    return Dialog(
      backgroundColor: Colors.white,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16.r),
      ),
      child: Padding(
        padding: EdgeInsets.all(24.w),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              l10n.tpwExportOptions,
              style: sfpsTitleTextTextStyle18600.copyWith(
                color: Colors.black,
                fontSize: 20.sp,
              ),
            ),
            SizedBox(height: 8.h),
            Text(
              l10n.tpwSelectExportFormat,
              style: ssTitleTextTextStyle14400.copyWith(
                color: Colors.grey[600],
                fontSize: 14.sp,
              ),
            ),
            SizedBox(height: 24.h),

            // PDF with logo option
            Obx(
              () => InkWell(
                onTap: controller.selectPdfWithLogo,
                child: Row(
                  children: [
                    Container(
                      width: 24.w,
                      height: 24.h,
                      decoration: BoxDecoration(
                        color: controller.isPdfWithLogo ? Colors.black : Colors.transparent,
                        border: Border.all(
                          color: Colors.black,
                          width: 2,
                        ),
                        borderRadius: BorderRadius.circular(4.r),
                      ),
                      child: controller.isPdfWithLogo
                          ? Icon(
                              Icons.check,
                              color: Colors.white,
                              size: 18.sp,
                            )
                          : null,
                    ),
                    SizedBox(width: 12.w),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            l10n.tpwPdfWithLogo,
                            style: ssTitleTextTextStyle14400.copyWith(
                              color: Colors.black,
                              fontSize: 16.sp,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                          SizedBox(height: 4.h),
                          Text(
                            l10n.tpwIncludesAtellaBranding,
                            style: ssTitleTextTextStyle14400.copyWith(
                              color: Colors.grey[600],
                              fontSize: 12.sp,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),

            SizedBox(height: 20.h),

            // Neutral PDF option
            Obx(
              () => InkWell(
                onTap: controller.selectNeutralPdf,
                child: Row(
                  children: [
                    Container(
                      width: 24.w,
                      height: 24.h,
                      decoration: BoxDecoration(
                        color: controller.isNeutralPdf ? Colors.black : Colors.transparent,
                        border: Border.all(
                          color: Colors.black,
                          width: 2,
                        ),
                        borderRadius: BorderRadius.circular(4.r),
                      ),
                      child: controller.isNeutralPdf
                          ? Icon(
                              Icons.check,
                              color: Colors.white,
                              size: 18.sp,
                            )
                          : null,
                    ),
                    SizedBox(width: 12.w),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            l10n.tpwNeutralPdf,
                            style: ssTitleTextTextStyle14400.copyWith(
                              color: Colors.black,
                              fontSize: 16.sp,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                          SizedBox(height: 4.h),
                          Text(
                            l10n.tpwCleanPdfWithoutBranding,
                            style: ssTitleTextTextStyle14400.copyWith(
                              color: Colors.grey[600],
                              fontSize: 12.sp,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),

            SizedBox(height: 20.h),

            // Word export option
            Obx(
              () => InkWell(
                onTap: controller.selectWord,
                child: Row(
                  children: [
                    Container(
                      width: 24.w,
                      height: 24.h,
                      decoration: BoxDecoration(
                        color: controller.isWord ? Colors.black : Colors.transparent,
                        border: Border.all(
                          color: Colors.black,
                          width: 2,
                        ),
                        borderRadius: BorderRadius.circular(4.r),
                      ),
                      child: controller.isWord
                          ? Icon(
                              Icons.check,
                              color: Colors.white,
                              size: 18.sp,
                            )
                          : null,
                    ),
                    SizedBox(width: 12.w),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            l10n.tpwEditableFormatWord,
                            style: ssTitleTextTextStyle14400.copyWith(
                              color: Colors.black,
                              fontSize: 16.sp,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                          SizedBox(height: 4.h),
                          Text(
                            l10n.tpwEditableWordDocument,
                            style: ssTitleTextTextStyle14400.copyWith(
                              color: Colors.grey[600],
                              fontSize: 12.sp,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),

            SizedBox(height: 32.h),

            // Buttons
            Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                TextButton(
                  onPressed: () => Navigator.of(context).pop(),
                  child: Text(
                    l10n.tpwCancel,
                    style: ssTitleTextTextStyle14400.copyWith(
                      color: Colors.grey[600],
                      fontSize: 16.sp,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
                SizedBox(width: 16.w),
                ElevatedButton(
                  onPressed: () {
                    // Just call onExport, dialog will be closed by the callback
                    onExport(controller.selectedExportType.value);
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.black,
                    foregroundColor: Colors.white,
                    padding: EdgeInsets.symmetric(
                      horizontal: 24.w,
                      vertical: 12.h,
                    ),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8.r),
                    ),
                  ),
                  child: Text(
                    l10n.tpwOk,
                    style: ssTitleTextTextStyle14400.copyWith(
                      color: Colors.white,
                      fontSize: 16.sp,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
