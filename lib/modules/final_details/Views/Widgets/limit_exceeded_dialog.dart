import 'package:atella/core/themes/app_fonts.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

class LimitExceededDialog extends StatelessWidget {
  final VoidCallback onGetExtraDesigns;
  final VoidCallback onUpgradePlan;
  final VoidCallback onMaybeLater;

  const LimitExceededDialog({
    Key? key,
    required this.onGetExtraDesigns,
    required this.onUpgradePlan,
    required this.onMaybeLater,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Dialog(
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
      ),
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // Alert Icon
            Icon(
              Icons.warning_amber_rounded,
              size: 60.h,
              color: Colors.red,
            ),
            SizedBox(height: 16.h),
            // Title
            Text(
              'Limit Exceeded',
              style: ssTitleTextTextStyle186004,
            ),
            SizedBox(height: 12.h),
            // Message
            Text(
              'You have exceeded your limit for this month. You can pay €3.99 for 20 extra designs or upgrade your plan to Starter or Pro.',
              style: ssTitleTextTextStyle144005,
              textAlign: TextAlign.center,
            ),
            SizedBox(height: 24.h),
            // Buttons
            Column(
              children: [
                // Get Extra Designs Button
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    onPressed: onGetExtraDesigns,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.black,
                      foregroundColor: Colors.white,
                      padding: EdgeInsets.symmetric(vertical: 12.h),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8.r),
                      ),
                    ),
                    child: Text(
                      'Get Extra Designs (€3.99)',
                      style: ssTitleTextTextStyle14400.copyWith(
                        fontSize: 16.sp,
                        fontWeight: FontWeight.w600,
                        color: Colors.white,
                      ),
                    ),
                  ),
                ),
                SizedBox(height: 12.h),
                // Upgrade Plan Button
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    onPressed: onUpgradePlan,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.black,
                      foregroundColor: Colors.white,
                      padding: EdgeInsets.symmetric(vertical: 12.h),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8.r),
                      ),
                    ),
                    child: Text(
                      'Upgrade Plan',
                      style:  ssTitleTextTextStyle14400.copyWith(
                        fontSize: 16.sp,
                        fontWeight: FontWeight.w600,
                        color: Colors.white,
                      ),
                    ),
                  ),
                ),
                SizedBox(height: 12.h),
                // Maybe Later Button
                TextButton(
                  onPressed: onMaybeLater,
                  child: Text(
                    'Maybe Later',
                    style: ssTitleTextTextStyle14400.copyWith(
                        fontSize: 16.sp,
                        fontWeight: FontWeight.w600,
                        color: Colors.grey[600],
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