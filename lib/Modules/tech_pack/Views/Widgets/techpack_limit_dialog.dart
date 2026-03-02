import 'package:atella/core/themes/app_fonts.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:atella/l10n/generated/app_localizations.dart';

class TechpackLimitDialog extends StatefulWidget {
  final Future<void> Function() onGetExtraTechpacks;
  final VoidCallback onUpgradePlan;
  final VoidCallback onMaybeLater;
  final bool
  isPaidUser; // true for STARTER/PRO/STUDIO users, false for FREE users
  final String title;
  final String message;

  const TechpackLimitDialog({
    Key? key,
    required this.onGetExtraTechpacks,
    required this.onUpgradePlan,
    required this.onMaybeLater,
    required this.title,
    required this.message,
    this.isPaidUser = false,
  }) : super(key: key);

  @override
  State<TechpackLimitDialog> createState() => _TechpackLimitDialogState();
}

class _TechpackLimitDialogState extends State<TechpackLimitDialog> {
  bool _isLoading = false;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;

    return Dialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // Alert Icon
            Icon(Icons.warning_amber_rounded, size: 60.h, color: Colors.red),
            SizedBox(height: 16.h),
            // Title
            Text(
              widget.title,
              style: ssTitleTextTextStyle186004,
              textAlign: TextAlign.center,
            ),
            SizedBox(height: 12.h),
            // Message
            Text(
              widget.message,
              style: ssTitleTextTextStyle144005,
              textAlign: TextAlign.center,
            ),
            SizedBox(height: 24.h),
            // Buttons
            Column(
              children: [
                // Get Extra Techpacks Button (only show for paid users)
                if (widget.isPaidUser) ...[
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton(
                      onPressed: _isLoading
                          ? null
                          : () async {
                              setState(() => _isLoading = true);
                              await widget.onGetExtraTechpacks();
                              if (mounted) setState(() => _isLoading = false);
                            },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.black,
                        foregroundColor: Colors.white,
                        padding: EdgeInsets.symmetric(
                          vertical: 12.h,
                          horizontal: 16.w,
                        ),
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
                              l10n.tpDialogExtraTechpackOption,
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
                      padding: EdgeInsets.symmetric(
                        vertical: 12.h,
                        horizontal: 16.w,
                      ),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8.r),
                      ),
                    ),
                    child: Text(
                      l10n.tpDialogUpgradeNow,
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
                    l10n.tpMaybeLater,
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
