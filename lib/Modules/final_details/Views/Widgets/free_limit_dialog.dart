import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:atella/core/themes/app_fonts.dart';
import 'package:atella/l10n/generated/app_localizations.dart';

class FreeUserLimitDialog extends StatelessWidget {
  final VoidCallback onClose;

  const FreeUserLimitDialog({super.key, required this.onClose});

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;

    return Dialog(
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(20.r),
      ),
      backgroundColor: Colors.white,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          // Top accent strip with icon
          Container(
            width: double.infinity,
            decoration: BoxDecoration(
              color: Colors.black,
              borderRadius: BorderRadius.only(
                topLeft: Radius.circular(20.r),
                topRight: Radius.circular(20.r),
              ),
            ),
            padding: EdgeInsets.symmetric(vertical: 28.h),
            child: Icon(
              Icons.hourglass_bottom_rounded,
              size: 48.h,
              color: Colors.white,
            ),
          ),

          // Content
          Padding(
            padding: EdgeInsets.fromLTRB(24.w, 24.h, 24.w, 28.h),
            child: Column(
              children: [
                // Title
                Text(
                  l10n.freeUserLimitTitle,
                  style: ssTitleTextTextStyle186004,
                  textAlign: TextAlign.center,
                ),
                SizedBox(height: 12.h),

                // Body
                Text(
                  l10n.freeUserLimitBody,
                  style: ssTitleTextTextStyle144005.copyWith(
                    height: 1.5,
                    color: Colors.grey[700],
                  ),
                  textAlign: TextAlign.center,
                ),
                SizedBox(height: 8.h),

                // CTA website line
                Text(
                  l10n.freeUserLimitCta,
                  style: ssTitleTextTextStyle144005.copyWith(
                    height: 1.5,
                    color: Colors.black,
                    fontWeight: FontWeight.w600,
                  ),
                  textAlign: TextAlign.center,
                ),
                SizedBox(height: 24.h),

                // Dismiss button
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    onPressed: onClose,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.black,
                      foregroundColor: Colors.white,
                      padding: EdgeInsets.symmetric(vertical: 14.h),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(10.r),
                      ),
                      elevation: 0,
                    ),
                    child: Text(
                      l10n.gotIt,
                      style: ssTitleTextTextStyle144005.copyWith(
                        fontSize: 15.sp,
                        fontWeight: FontWeight.w600,
                        color: Colors.white,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
