import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:atella/core/themes/app_fonts.dart';
import 'package:atella/l10n/generated/app_localizations.dart';

class FreeUserLimitDialog extends StatefulWidget {
  final VoidCallback onClose;

  /// If provided, a "Get Designs" buy button is shown above the dismiss
  /// button. The callback should trigger the RevenueCat purchase flow.
  final Future<void> Function()? onGetExtraDesigns;

  const FreeUserLimitDialog({
    super.key,
    required this.onClose,
    this.onGetExtraDesigns,
  });

  @override
  State<FreeUserLimitDialog> createState() => _FreeUserLimitDialogState();
}

class _FreeUserLimitDialogState extends State<FreeUserLimitDialog> {
  bool _isLoading = false;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;

    return Dialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(Icons.warning_amber_rounded, size: 60.h, color: Colors.red),
            SizedBox(height: 16.h),

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

            Column(
              children: [
                // Get Designs button — only shown when callback is provided
                if (widget.onGetExtraDesigns != null) ...[
                  _OrDivider(),
                  SizedBox(height: 12.h),
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton(
                      onPressed: _isLoading
                          ? null
                          : () async {
                              setState(() => _isLoading = true);
                              await widget.onGetExtraDesigns!();
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
                        elevation: 0,
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
                              l10n.fdDialogGetDesigns,
                              style: ssTitleTextTextStyle144005.copyWith(
                                fontSize: 15.sp,
                                fontWeight: FontWeight.w600,
                                color: Colors.white,
                              ),
                            ),
                    ),
                  ),
                  SizedBox(height: 12.h),
                ],

                // Maybe Later button
                TextButton(
                  onPressed: widget.onClose,
                  child: Text(
                    l10n.fdDialogMaybeLater,
                    style: ssTitleTextTextStyle144005.copyWith(
                      fontSize: 15.sp,
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
