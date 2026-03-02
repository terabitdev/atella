import 'package:atella/core/themes/app_fonts.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:atella/l10n/generated/app_localizations.dart';

class UsageWarningDialog extends StatefulWidget {
  final int usedCount;
  final int totalCount;
  final Future<void> Function() onGetExtraDesigns;
  final VoidCallback onUpgradePlan;
  final VoidCallback onContinue;
  final bool isDesign; // true for designs, false for techpacks
  final bool isPaidUser; // true for STARTER/PRO users, false for FREE users
  final Future<void> Function()? onGetExtraTechpacks; // Optional callback for purchasing extra techpacks

  const UsageWarningDialog({
    Key? key,
    required this.usedCount,
    required this.totalCount,
    required this.onGetExtraDesigns,
    required this.onUpgradePlan,
    required this.onContinue,
    this.isDesign = true,
    this.isPaidUser = false, // Default to false (FREE user)
    this.onGetExtraTechpacks, // Optional parameter for techpack purchases
  }) : super(key: key);

  @override
  State<UsageWarningDialog> createState() => _UsageWarningDialogState();
}

class _UsageWarningDialogState extends State<UsageWarningDialog> {
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
            // Warning Icon
            Icon(
              Icons.info_outline_rounded,
              size: 60.h,
              color: Colors.orange,
            ),
            SizedBox(height: 16.h),
            // Title
            Text(
              widget.isDesign ? l10n.fdDialog80PercentTitle : l10n.tpDialog80PercentTitle,
              style: ssTitleTextTextStyle186004.copyWith(color: Colors.orange[800]),
              textAlign: TextAlign.center,
            ),
            SizedBox(height: 12.h),
            // Message (conditional based on user type)
            Text(
              widget.isDesign
                ? (widget.isPaidUser
                    ? l10n.fdDialog80PercentMessage(widget.usedCount, widget.totalCount)
                    : l10n.fdDialog80PercentMessageFree(widget.usedCount, widget.totalCount))
                : l10n.tpDialog80PercentMessage(widget.usedCount, widget.totalCount),
              style: ssTitleTextTextStyle144005,
              textAlign: TextAlign.center,
            ),
            SizedBox(height: 24.h),
            // Buttons
            Column(
              children: [
                // Get Extra Designs Button (only for paid users with designs)
                if (widget.isDesign && widget.isPaidUser) ...[
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
                // Get Extra Techpacks Button (only for paid users with techpacks)
                if (!widget.isDesign && widget.isPaidUser && widget.onGetExtraTechpacks != null) ...[
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton(
                      onPressed: _isLoading
                          ? null
                          : () async {
                              setState(() => _isLoading = true);
                              await widget.onGetExtraTechpacks!();
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
                // Continue Anyway Button
                TextButton(
                  onPressed: widget.onContinue,
                  child: Text(
                    widget.isDesign ? l10n.fdDialog80PercentContinue : l10n.tpDialog80PercentContinue,
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
