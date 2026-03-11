import 'package:atella/core/themes/app_fonts.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:atella/l10n/generated/app_localizations.dart';

class UsageWarningDialog extends StatefulWidget {
  final int usedCount;
  final int totalCount;
  final Future<void> Function() onGetExtraDesigns;
  final VoidCallback onContinue;
  final bool isDesign; // true for designs, false for techpacks
  final bool isPaidUser; // true for STARTER/PRO users, false for FREE users
  final Future<void> Function()? onGetExtraTechpacks;

  const UsageWarningDialog({
    super.key,
    required this.usedCount,
    required this.totalCount,
    required this.onGetExtraDesigns,
    required this.onContinue,
    this.isDesign = true,
    this.isPaidUser = false,
    this.onGetExtraTechpacks,
  });

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
            Icon(
              Icons.info_outline_rounded,
              size: 60.h,
              color: Colors.orange,
            ),
            SizedBox(height: 16.h),
            Text(
              widget.isDesign
                  ? l10n.fdDialog80PercentTitle
                  : l10n.tpDialog80PercentTitle,
              style: ssTitleTextTextStyle186004.copyWith(
                  color: Colors.orange[800]),
              textAlign: TextAlign.center,
            ),
            SizedBox(height: 12.h),
            Text(
              widget.isDesign
                  ? (widget.isPaidUser
                      ? l10n.fdDialog80PercentMessage(
                          widget.usedCount, widget.totalCount)
                      : l10n.fdDialog80PercentMessageFree(
                          widget.usedCount, widget.totalCount))
                  : l10n.tpDialog80PercentMessage(
                      widget.usedCount, widget.totalCount),
              style: ssTitleTextTextStyle144005,
              textAlign: TextAlign.center,
            ),
            SizedBox(height: 8.h),
            // Website CTA — different text for paid vs free users
            Text(
              widget.isPaidUser
                  ? l10n.paidUserUpgradeCta
                  : l10n.freeUserLimitCta,
              style: ssTitleTextTextStyle144005.copyWith(
                fontWeight: FontWeight.w600,
                color: Colors.black,
              ),
              textAlign: TextAlign.center,
            ),
            SizedBox(height: 24.h),
            Column(
              children: [
                // Get Extra Designs Button (only for paid users with designs)
                if (widget.isDesign && widget.isPaidUser) ...[
                  const _OrDivider(),
                  SizedBox(height: 12.h),
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
                        padding: EdgeInsets.symmetric(
                            vertical: 12.h, horizontal: 16.w),
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
                if (!widget.isDesign &&
                    widget.isPaidUser &&
                    widget.onGetExtraTechpacks != null) ...[
                  const _OrDivider(),
                  SizedBox(height: 12.h),
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
                        padding: EdgeInsets.symmetric(
                            vertical: 12.h, horizontal: 16.w),
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
                TextButton(
                  onPressed: widget.onContinue,
                  child: Text(
                    widget.isDesign
                        ? l10n.fdDialog80PercentContinue
                        : l10n.tpDialog80PercentContinue,
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

class _OrDivider extends StatelessWidget {
  const _OrDivider();

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    return Row(
      children: [
        const Expanded(child: Divider(color: Colors.grey)),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 12),
          child: Text(
            l10n.orDivider,
            style: TextStyle(
              color: Colors.grey[500],
              fontWeight: FontWeight.w600,
              fontSize: 12,
            ),
          ),
        ),
        const Expanded(child: Divider(color: Colors.grey)),
      ],
    );
  }
}
