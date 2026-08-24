import 'package:atella/core/themes/app_colors.dart';
import 'package:atella/core/themes/app_fonts.dart';
import 'package:atella/core/utils/app_snackbar.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:url_launcher/url_launcher.dart';

/// Shown when a Freemium user taps "Send Tech Pack" on a supplier's
/// profile — contacting manufacturers requires a paid plan, purchased on
/// the website rather than via in-app purchase.
class ManufacturerUpgradeDialog extends StatelessWidget {
  const ManufacturerUpgradeDialog({super.key});

  static const _subscribeUrl = 'https://atelia.app/';

  Future<void> _openSubscribePage() async {
    final uri = Uri.parse(_subscribeUrl);
    if (!await launchUrl(uri, mode: LaunchMode.externalApplication)) {
      showAppSnackbar(
        'Error',
        'Could not open the subscription page',
        backgroundColor: Colors.red,
        colorText: Colors.white,
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Dialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16.r)),
      child: Padding(
        padding: EdgeInsets.all(24.w),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(Icons.workspace_premium_outlined, size: 56.h, color: AppColors.buttonColor),
            SizedBox(height: 16.h),
            Text(
              'Subscribe to Contact Manufacturers',
              style: ssTitleTextTextStyle186004,
              textAlign: TextAlign.center,
            ),
            SizedBox(height: 12.h),
            Text(
              'Sending tech packs to manufacturers is available on paid plans. Subscribe on our website to unlock this feature.',
              style: ssTitleTextTextStyle144005,
              textAlign: TextAlign.center,
            ),
            SizedBox(height: 24.h),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: () {
                  Navigator.of(context).pop();
                  _openSubscribePage();
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.buttonColor,
                  padding: EdgeInsets.symmetric(vertical: 12.h),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8.r)),
                ),
                child: Text(
                  'Subscribe',
                  style: ssTitleTextTextStyle144005.copyWith(color: Colors.white, fontWeight: FontWeight.w600),
                ),
              ),
            ),
            SizedBox(height: 4.h),
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: Text(
                'Not now',
                style: ssTitleTextTextStyle144005.copyWith(color: Colors.grey[600]),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
