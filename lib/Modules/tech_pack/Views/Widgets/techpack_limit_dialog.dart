import 'package:atella/core/themes/app_fonts.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:atella/l10n/generated/app_localizations.dart';

class TechpackLimitDialog extends StatefulWidget {
  /// If non-null, the "Get Extra Techpacks" buy button is shown.
  /// Pass null to hide the button (e.g. when no purchase is available).
  final Future<void> Function()? onGetExtraTechpacks;
  final VoidCallback onMaybeLater;
  final bool isPaidUser; // controls CTA text (paid vs free wording)
  final String title;
  final String message;
  /// On iOS, the live localized price string from RevenueCat (e.g. "$5.99").
  /// When provided it overrides the hardcoded price in the button label.
  /// Null on Android or when the fetch failed — falls back to localisation.
  final String? techpackPriceString;

  const TechpackLimitDialog({
    super.key,
    this.onGetExtraTechpacks,
    required this.onMaybeLater,
    required this.title,
    required this.message,
    this.isPaidUser = false,
    this.techpackPriceString,
  });

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
            Icon(Icons.warning_amber_rounded, size: 60.h, color: Colors.red),
            SizedBox(height: 16.h),
            Text(
              widget.title,
              style: ssTitleTextTextStyle186004,
              textAlign: TextAlign.center,
            ),
            SizedBox(height: 12.h),
            Text(
              widget.message,
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
                // Get Extra Techpacks Button — shown whenever a purchase callback is provided
                if (widget.onGetExtraTechpacks != null) ...[
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
                              widget.isPaidUser
                                  ? (widget.techpackPriceString != null
                                      ? l10n.tpDialogExtraTechpackOptionWithPrice(widget.techpackPriceString!)
                                      : l10n.tpDialogExtraTechpackOption)
                                  : (widget.techpackPriceString != null
                                      ? l10n.tpDialogGetTechpackOptionWithPrice(widget.techpackPriceString!)
                                      : l10n.tpDialogGetTechpackOption),
                              style: ssTitleTextTextStyle14400.copyWith(
                                fontSize: 16.sp,
                                fontWeight: FontWeight.w600,
                                color: Colors.white,
                              ),
                              textAlign: TextAlign.center,
                              softWrap: true,
                            ),
                    ),
                  ),
                  SizedBox(height: 12.h),
                ],
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
