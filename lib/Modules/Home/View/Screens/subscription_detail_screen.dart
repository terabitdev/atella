import 'package:atella/Modules/Home/Controllers/subscription_detail_controller.dart';
import 'package:atella/core/themes/app_fonts.dart';
import 'package:atella/l10n/generated/app_localizations.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:lottie/lottie.dart';

class SubscriptionDetailScreen extends StatelessWidget {
  const SubscriptionDetailScreen({super.key});

  @override
  Widget build(BuildContext context) {
    // Lazily create the controller when entering this screen.
    final controller = Get.put(SubscriptionDetailController());
    final l10n = AppLocalizations.of(context)!;

    return Scaffold(
      backgroundColor: Colors.black,
      body: SafeArea(
        child: Obx(() {
          if (controller.isLoading.value) {
            return Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Full header — identical to the loaded state
                Padding(
                  padding: EdgeInsets.symmetric(
                    horizontal: 16.w,
                    vertical: 12.h,
                  ),
                  child: Row(
                    children: [
                      GestureDetector(
                        behavior: HitTestBehavior.opaque,
                        onTap: () => Get.back(),
                        child: Icon(
                          Icons.arrow_back_ios,
                          color: Colors.white,
                          size: 20.sp,
                        ),
                      ),
                      SizedBox(width: 12.w),
                      Expanded(
                        child: Text(
                          l10n.subscriptionDetailTitle,
                          style: ssTitleTextTextStyle208001,
                        ),
                      ),
                    ],
                  ),
                ),
                // White section with Lottie centred
                Expanded(
                  child: Container(
                    width: double.infinity,
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.only(
                        topLeft: Radius.circular(30.r),
                        topRight: Radius.circular(30.r),
                      ),
                    ),
                    child: Center(
                      child: Lottie.asset(
                        'assets/lottie/Loading_dots.json',
                        width: 100.w,
                        height: 100.h,
                        fit: BoxFit.cover,
                      ),
                    ),
                  ),
                ),
              ],
            );
          }

          final sub = controller.subscription.value;
          if (sub == null) {
            return Center(
              child: Text(
                l10n.subscriptionDetailTitle,
                style: ssTitleTextTextStyle186004.copyWith(color: Colors.white),
              ),
            );
          }

          final hasTechPacks = !sub.subscriptionPlan.startsWith('FREE');
          final designUsed = sub.designsGeneratedThisMonth;
          final designTotal = sub.getTotalAllowedDesigns();
          final techUsed = sub.techpacksUsedThisMonth;
          final techTotal = sub.totalAllowedTechpacks;
          final renewalText = controller.getFormattedRenewalDate(l10n);

          return Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // ── Black header ──────────────────────────────────────────
              Padding(
                padding: EdgeInsets.symmetric(
                  horizontal: 16.w,
                  vertical: 12.h,
                ),
                child: Row(
                  children: [
                    GestureDetector(
                      behavior: HitTestBehavior.opaque,
                      onTap: () => Get.back(),
                      child: Icon(
                        Icons.arrow_back_ios,
                        color: Colors.white,
                        size: 20.sp,
                      ),
                    ),
                    SizedBox(width: 12.w),
                    Expanded(
                      child: Text(
                        l10n.subscriptionDetailTitle,
                        style: ssTitleTextTextStyle208001,
                      ),
                    ),
                  ],
                ),
              ),


              // ── White scrollable section ───────────────────────────────
              Expanded(
                child: Container(
                  width: double.infinity,
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.only(
                      topLeft: Radius.circular(30.r),
                      topRight: Radius.circular(30.r),
                    ),
                  ),
                  child: SingleChildScrollView(
                    padding: EdgeInsets.symmetric(
                      horizontal: 24.w,
                      vertical: 28.h,
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // ── Plan Details section ────────────────────────
                        Text(
                          l10n.planDetails,
                          style: ssTitleTextTextStyle186004,
                        ),
                        SizedBox(height: 12.h),
                        Container(
                          width: double.infinity,
                          padding: EdgeInsets.all(16.r),
                          decoration: BoxDecoration(
                            color: Colors.grey[50],
                            borderRadius: BorderRadius.circular(12.r),
                            border: Border.all(color: Colors.grey.shade200),
                          ),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              _DetailRow(
                                label: controller.getPlanDisplayName(l10n),
                                value: controller.getBillingLabel(l10n),
                              ),
                              if (renewalText.isNotEmpty) ...[
                                Divider(
                                  height: 24.h,
                                  color: Colors.grey.shade200,
                                ),
                                Text(
                                  renewalText,
                                  style: ssTitleTextTextStyle144005.copyWith(
                                    color: Colors.grey[600],
                                  ),
                                ),
                              ],
                            ],
                          ),
                        ),

                        SizedBox(height: 28.h),

                        // ── Usage section ───────────────────────────────
                        Text(
                          l10n.usageThisMonth,
                          style: ssTitleTextTextStyle186004,
                        ),
                        SizedBox(height: 12.h),

                        // Designs usage
                        _UsageCard(
                          label: l10n.designsLabel,
                          used: designUsed,
                          total: designTotal,
                        ),

                        if (hasTechPacks) ...[
                          SizedBox(height: 12.h),
                          _UsageCard(
                            label: l10n.techPacksLabel,
                            used: techUsed,
                            total: techTotal,
                          ),
                        ],

                        SizedBox(height: 40.h),

                        // ── Upgrade hint ────────────────────────────────
                        Text(
                          l10n.subscriptionDetailUpgradeHint,
                          style: ssTitleTextTextStyle144005.copyWith(
                            color: Colors.grey[600],
                            fontSize: 13.sp,
                          ),
                          textAlign: TextAlign.center,
                        ),

                        SizedBox(height: 16.h),

                        // ── Cancel subscription button ──────────────────
                        SizedBox(
                          width: double.infinity,
                          child: Obx(
                            () => OutlinedButton(
                              onPressed: controller.isCancelling.value
                                  ? null
                                  : () =>
                                      _showCancelConfirmDialog(context, l10n, controller),
                              style: OutlinedButton.styleFrom(
                                foregroundColor: Colors.red,
                                side: const BorderSide(color: Colors.red),
                                padding:
                                    EdgeInsets.symmetric(vertical: 14.h),
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(10.r),
                                ),
                              ),
                              child: controller.isCancelling.value
                                  ? const SizedBox(
                                      width: 20,
                                      height: 20,
                                      child: CircularProgressIndicator(
                                        color: Colors.red,
                                        strokeWidth: 2.5,
                                      ),
                                    )
                                  : Text(
                                      l10n.cancelSubscription,
                                      style: ssTitleTextTextStyle144005.copyWith(
                                        fontSize: 15.sp,
                                        fontWeight: FontWeight.w600,
                                        color: Colors.red,
                                      ),
                                    ),
                            ),
                          ),
                        ),

                        SizedBox(height: 20.h),
                      ],
                    ),
                  ),
                ),
              ),
            ],
          );
        }),
      ),
    );
  }

  void _showCancelConfirmDialog(
    BuildContext context,
    AppLocalizations l10n,
    SubscriptionDetailController controller,
  ) {
    String? selectedReason;
    final otherReasonController = TextEditingController();

    Get.dialog(
      StatefulBuilder(
        builder: (context, setState) {
          final reasons = [
            l10n.tooExpensive,
            l10n.notUsingEnough,
            l10n.missingFeatures,
            l10n.foundBetterAlternative,
            l10n.technicalIssues,
            l10n.other,
          ];

          return AlertDialog(
            title: Text(
              l10n.cancelSubscriptionTitle,
              style: ssTitleTextTextStyle186004.copyWith(color: Colors.black),
            ),
            content: SingleChildScrollView(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    l10n.cancelSubscriptionMessage,
                    style: ssTitleTextTextStyle144005.copyWith(
                      color: Colors.black,
                    ),
                  ),
                  const SizedBox(height: 16),
                  ...reasons.map(
                    (reason) => RadioListTile<String>(
                      title: Text(
                        reason,
                        style: ssTitleTextTextStyle144005.copyWith(
                          color: Colors.black,
                        ),
                      ),
                      value: reason,
                      groupValue: selectedReason,
                      onChanged: (value) =>
                          setState(() => selectedReason = value),
                      contentPadding: EdgeInsets.zero,
                      dense: true,
                    ),
                  ),
                  if (selectedReason == l10n.other)
                    Padding(
                      padding: const EdgeInsets.only(top: 8),
                      child: TextField(
                        controller: otherReasonController,
                        decoration: const InputDecoration(
                          border: OutlineInputBorder(),
                          contentPadding: EdgeInsets.symmetric(
                            horizontal: 12,
                            vertical: 8,
                          ),
                        ),
                      ),
                    ),
                ],
              ),
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.of(Get.overlayContext!).pop(),
                child: Text(
                  l10n.keepSubscription,
                  style: ssTitleTextTextStyle144005.copyWith(
                    color: Colors.black,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
              TextButton(
                style: TextButton.styleFrom(foregroundColor: Colors.red),
                onPressed: () async {
                  final reason = selectedReason == l10n.other
                      ? otherReasonController.text.isNotEmpty
                            ? otherReasonController.text
                            : l10n.other
                      : selectedReason;
                  Navigator.of(Get.overlayContext!).pop();
                  final success =
                      await controller.cancelSubscription(reason: reason);
                  if (success) {
                    Get.snackbar(
                      '',
                      l10n.subscriptionCancelledSuccess,
                      snackPosition: SnackPosition.TOP,
                      backgroundColor: Colors.black,
                      colorText: Colors.white,
                      duration: const Duration(seconds: 3),
                    );
                    Get.back();
                  } else {
                    Get.snackbar(
                      '',
                      l10n.subscriptionCancelError,
                      snackPosition: SnackPosition.TOP,
                      backgroundColor: Colors.red,
                      colorText: Colors.white,
                      duration: const Duration(seconds: 3),
                    );
                  }
                },
                child: Text(
                  l10n.cancelSubscription,
                  style: ssTitleTextTextStyle144005.copyWith(
                    color: Colors.red,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ],
          );
        },
      ),
    );
  }
}

// ── Reusable sub-widgets ───────────────────────────────────────────────────────

class _DetailRow extends StatelessWidget {
  final String label;
  final String value;

  const _DetailRow({required this.label, required this.value});

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          label,
          style: ssTitleTextTextStyle144005.copyWith(
            fontWeight: FontWeight.w600,
            color: Colors.black,
          ),
        ),
        Text(
          value,
          style: ssTitleTextTextStyle144005.copyWith(color: Colors.grey[600]),
        ),
      ],
    );
  }
}

class _UsageCard extends StatelessWidget {
  final String label;
  final int used;
  final int total;

  const _UsageCard({
    required this.label,
    required this.used,
    required this.total,
  });

  @override
  Widget build(BuildContext context) {
    final double progress = total > 0 ? (used / total).clamp(0.0, 1.0) : 0.0;
    final bool nearLimit = progress >= 0.8;

    return Container(
      padding: EdgeInsets.all(16.r),
      decoration: BoxDecoration(
        color: Colors.grey[50],
        borderRadius: BorderRadius.circular(12.r),
        border: Border.all(color: Colors.grey.shade200),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                label,
                style: ssTitleTextTextStyle144005.copyWith(
                  fontWeight: FontWeight.w600,
                  color: Colors.black,
                ),
              ),
              Text(
                '$used / $total',
                style: ssTitleTextTextStyle144005.copyWith(
                  color: nearLimit ? Colors.red : Colors.grey[600],
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),
          SizedBox(height: 10.h),
          ClipRRect(
            borderRadius: BorderRadius.circular(4.r),
            child: LinearProgressIndicator(
              value: progress,
              minHeight: 6.h,
              backgroundColor: Colors.grey.shade200,
              valueColor: AlwaysStoppedAnimation<Color>(
                nearLimit ? Colors.red : Colors.black,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
