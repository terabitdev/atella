import 'package:atella/core/themes/app_fonts.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:atella/l10n/generated/app_localizations.dart';

class LimitExceededDialog extends StatefulWidget {
  final Future<void> Function() onGetExtraDesigns;
  final VoidCallback onUpgradePlan;
  final VoidCallback onMaybeLater;
  final bool isPaidUser; // true for STARTER/PRO users, false for FREE users

  const LimitExceededDialog({
    Key? key,
    required this.onGetExtraDesigns,
    required this.onUpgradePlan,
    required this.onMaybeLater,
    this.isPaidUser = false, // Default to false (FREE user)
  }) : super(key: key);

  @override
  State<LimitExceededDialog> createState() => _LimitExceededDialogState();
}

class _LimitExceededDialogState extends State<LimitExceededDialog> {
  bool _isLoading = false;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;

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
              l10n.fdDialogLimitExceeded,
              style: ssTitleTextTextStyle186004,
            ),
            SizedBox(height: 12.h),
            // Message (conditional based on user type)
            Text(
              widget.isPaidUser ? l10n.fdDialogLimitMessage : l10n.fdDialogLimitMessageFree,
              style: ssTitleTextTextStyle144005,
              textAlign: TextAlign.center,
            ),
            SizedBox(height: 24.h),
            // Buttons
            Column(
              children: [
                // Get Extra Designs Button (only show for paid users)
                if (widget.isPaidUser) ...[
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton(
                      onPressed: _isLoading
                          ? null
                          : () async {
                              setState(() => _isLoading = true);
                              await widget.onGetExtraDesigns();
                              if (mounted) setState(() => _isLoading = false);
                            },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.black,
                        foregroundColor: Colors.white,
                        padding: EdgeInsets.symmetric(vertical: 12.h, horizontal: 16.w),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(8.r),
                        ),
                      ),
                      child: _isLoading
                          ? const SizedBox(
                              width: 20,
                              height: 20,
                              child: CircularProgressIndicator(
                                color: Colors.white,
                                strokeWidth: 2.5,
                              ),
                            )
                          : Text(
                              l10n.fdDialogGetExtraDesigns,
                              style: ssTitleTextTextStyle14400.copyWith(
                                fontSize: 16.sp,
                                fontWeight: FontWeight.w600,
                                color: Colors.white,
                              ),
                              textAlign: TextAlign.center,
                            ),
                    ),
                  ),
                  SizedBox(height: 12.h),
                ],
                // Upgrade Plan Button
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    onPressed: widget.onUpgradePlan,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.black,
                      foregroundColor: Colors.white,
                      padding: EdgeInsets.symmetric(vertical: 12.h, horizontal: 16.w),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8.r),
                      ),
                    ),
                    child: Text(
                      l10n.fdDialogUpgradePlan,
                      style: ssTitleTextTextStyle14400.copyWith(
                        fontSize: 16.sp,
                        fontWeight: FontWeight.w600,
                        color: Colors.white,
                      ),
                      textAlign: TextAlign.center,
                    ),
                  ),
                ),
                SizedBox(height: 12.h),
                // Maybe Later Button
                TextButton(
                  onPressed: widget.onMaybeLater,
                  child: Text(
                    l10n.fdDialogMaybeLater,
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
