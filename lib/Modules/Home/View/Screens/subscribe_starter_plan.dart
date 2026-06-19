// DISABLED — Apple compliance (no in-app payment UI)
/*
import 'package:atella/core/themes/app_fonts.dart';
import 'package:atella/l10n/generated/app_localizations.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:url_launcher/url_launcher.dart';
import '../../Controllers/subscribe_controller.dart';

import 'package:atella/core/utils/app_snackbar.dart';
class SubscribeStarterPlan extends StatefulWidget {
  const SubscribeStarterPlan({super.key});

  @override
  State<SubscribeStarterPlan> createState() => _SubscribeStarterPlanState();
}

class _SubscribeStarterPlanState extends State<SubscribeStarterPlan> {
  final SubscribeController controller = Get.find<SubscribeController>();

  @override
  void initState() {
    super.initState();
    // Refresh subscription data when screen loads
    WidgetsBinding.instance.addPostFrameCallback((_) {
      controller.loadCurrentSubscription();
    });
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    return Scaffold(
      backgroundColor: Colors.black,
      body: SafeArea(
        child: Column(
          children: [
            Padding(
              padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 12.h),
              child: Row(
                children: [
                  InkWell(
                    onTap: () => Navigator.of(context).pop(),
                    child: Image.asset(
                      'assets/images/Arrow_Left.png',
                      height: 40.h,
                      width: 40.w,
                    ),
                  ),
                  SizedBox(width: 8.w),
                  Text(l10n.starter, style: ssTitleTextTextStyle208001),
                ],
              ),
            ),
            SizedBox(height: 34.h),
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
                padding: EdgeInsets.symmetric(horizontal: 24.w, vertical: 16.h),
                child: Column(
                  children: [
                    Expanded(
                      child: SingleChildScrollView(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.center,
                          children: [
                            SizedBox(height: 16.h),
                            // Billing Period Toggle
                            Container(
                              width: double.infinity,
                              padding: EdgeInsets.all(4.h),
                              decoration: BoxDecoration(
                                color: Colors.grey[200],
                                borderRadius: BorderRadius.circular(8.r),
                              ),
                              child: Obx(
                                () => IntrinsicHeight(
                                  child: Row(
                                    children: [
                                      Expanded(
                                        child: GestureDetector(
                                          onTap: () {
                                            if (controller
                                                .isYearlyBilling
                                                .value) {
                                              controller.toggleBillingPeriod();
                                            }
                                          },
                                          child: Container(
                                            padding: EdgeInsets.symmetric(
                                              vertical: 10.h,
                                              horizontal: 6.w,
                                            ),
                                            decoration: BoxDecoration(
                                              color:
                                                  !controller
                                                      .isYearlyBilling
                                                      .value
                                                  ? Colors.black
                                                  : Colors.transparent,
                                              borderRadius:
                                                  BorderRadius.circular(6.r),
                                            ),
                                            child: Center(
                                              child: Text(
                                                l10n.monthly,
                                                textAlign: TextAlign.center,
                                                style: TextStyle(
                                                  color:
                                                      !controller
                                                          .isYearlyBilling
                                                          .value
                                                      ? Colors.white
                                                      : Colors.grey[600],
                                                  fontSize: 13.sp,
                                                  fontWeight: FontWeight.w600,
                                                  height: 1.2,
                                                ),
                                              ),
                                            ),
                                          ),
                                        ),
                                      ),
                                      Expanded(
                                        child: GestureDetector(
                                          onTap: () {
                                            if (!controller
                                                .isYearlyBilling
                                                .value) {
                                              controller.toggleBillingPeriod();
                                            }
                                          },
                                          child: Container(
                                            padding: EdgeInsets.symmetric(
                                              vertical: 10.h,
                                              horizontal: 6.w,
                                            ),
                                            decoration: BoxDecoration(
                                              color:
                                                  controller
                                                      .isYearlyBilling
                                                      .value
                                                  ? Colors.black
                                                  : Colors.transparent,
                                              borderRadius:
                                                  BorderRadius.circular(6.r),
                                            ),
                                            child: Center(
                                              child: Text(
                                                l10n.yearlySavePercent,
                                                textAlign: TextAlign.center,
                                                style: TextStyle(
                                                  color:
                                                      controller
                                                          .isYearlyBilling
                                                          .value
                                                      ? Colors.white
                                                      : Colors.grey[600],
                                                  fontSize: 13.sp,
                                                  fontWeight: FontWeight.w600,
                                                  height: 1.2,
                                                ),
                                              ),
                                            ),
                                          ),
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                            ),
                            SizedBox(height: 16.h),
                            // Plan Header Container
                            Container(
                              width: double.infinity,
                              padding: EdgeInsets.all(16.h),
                              decoration: BoxDecoration(
                                color: Colors.black,
                                borderRadius: BorderRadius.circular(12.r),
                              ),
                              child: Row(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Expanded(
                                    child: Column(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: [
                                        Obx(
                                          () => Text(
                                            controller.isYearlyBilling.value
                                                ? l10n.starterYearlyPrice
                                                : l10n.starterMonthlyPrice,
                                            style: sfpsTitleTextTextStyle18600,
                                          ),
                                        ),
                                        SizedBox(height: 4.h),
                                        Text(
                                          l10n.featuresInclude,
                                          style: sfpsTitleTextTextStyle14400,
                                        ),
                                        SizedBox(height: 15.h),
                                        // Display current usage counters for Starter plan
                                        Obx(() {
                                          final subscription = controller
                                              .currentSubscription
                                              .value;
                                          if (subscription != null &&
                                              (subscription.subscriptionPlan ==
                                                      'STARTER' ||
                                                  subscription
                                                          .subscriptionPlan ==
                                                      'STARTER_YEARLY')) {
                                            return Column(
                                              crossAxisAlignment:
                                                  CrossAxisAlignment.start,
                                              children: [
                                                // Design usage counter
                                                Text(
                                                  l10n.designsUsed(
                                                    subscription
                                                        .designsUsedCount,
                                                    subscription
                                                        .designsTotalCount,
                                                  ),
                                                  style: TextStyle(
                                                    fontSize: 14.sp,
                                                    color:
                                                        subscription
                                                                .remainingDesigns >
                                                            0
                                                        ? Colors.white
                                                        : Colors.red[300],
                                                    fontWeight: FontWeight.w600,
                                                  ),
                                                ),
                                                SizedBox(height: 8.h),
                                                // Techpack usage counter
                                                Text(
                                                  l10n.techpacksUsed(
                                                    subscription
                                                        .techpacksUsedCount,
                                                    subscription
                                                        .techpacksTotalCount,
                                                  ),
                                                  style: TextStyle(
                                                    fontSize: 14.sp,
                                                    color:
                                                        subscription
                                                                .remainingTechpacks >
                                                            0
                                                        ? Colors.white
                                                        : Colors.red[300],
                                                    fontWeight: FontWeight.w600,
                                                  ),
                                                ),
                                              ],
                                            );
                                          }
                                          return SizedBox.shrink();
                                        }),
                                      ],
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            SizedBox(height: 16.h),
                            Container(
                              width: double.infinity,
                              padding: EdgeInsets.symmetric(
                                horizontal: 16.w,
                                vertical: 12.h,
                              ),
                              decoration: BoxDecoration(
                                color: const Color(0xFFF5F5F5),
                                borderRadius: BorderRadius.circular(12.r),
                              ),
                              child: Text(
                                l10n.idealForLaunching,
                                style: sfpsTitleTextTextStyle14500,
                                textAlign: TextAlign.center,
                              ),
                            ),
                            SizedBox(height: 24.h),

                            // Features List
                            Obx(
                              () => Column(
                                children: [
                                  _buildFeatureItem(l10n.starterDesignLimit),
                                  SizedBox(height: 16.h),
                                  _buildFeatureItem(
                                    controller.isYearlyBilling.value
                                        ? l10n.techpacksPerMonthYearly(2, 24)
                                        : l10n.techpacksPerMonth(2),
                                  ),
                                  SizedBox(height: 16.h),
                                  _buildFeatureItem(l10n.customPdfExport),
                                  SizedBox(height: 16.h),
                                  _buildFeatureItem(l10n.accessToManufacturers),
                                ],
                              ),
                            ),
                            SizedBox(height: 40.h),
                          ],
                        ),
                      ),
                    ),

                    // Bottom Section with Button and Terms
                    Column(
                      children: [
                        Obx(() {
                          final currentPlan = controller
                              .currentSubscription
                              .value
                              ?.subscriptionPlan;
                          final isYearly = controller.isYearlyBilling.value;

                          // Check EXACT match based on selected tab
                          final expectedPlan = isYearly
                              ? 'STARTER_YEARLY'
                              : 'STARTER';
                          bool isExactCurrentPlan = currentPlan == expectedPlan;

                          // Check if user has the opposite billing period for same tier

                          // Check if user has any other active subscription (PRO plans)

                          return Column(
                            children: [
                              // COMMENTED OUT: In-app subscribe button removed - Users subscribe via website
                              // Subscribe functionality now exclusively at https://atelia.app/
                              /*
                              // Main action button
                              InkWell(
                                onTap: (controller.isLoading.value || isExactCurrentPlan || hasOppositeBillingPeriod || hasOtherSubscription) ? null : () {
                                  controller.subscribeToPlan(controller.getStarterPlan());
                                },
                                child: Container(
                                  height: 50.h,
                                  width: 375.w,
                                  decoration: BoxDecoration(
                                    color: (controller.isLoading.value || isExactCurrentPlan || hasOppositeBillingPeriod || hasOtherSubscription) ? Colors.grey[400] : Colors.black,
                                    borderRadius: BorderRadius.circular(10.r),
                                  ),
                                  child: Center(
                                    child: controller.isLoading.value
                                        ? SizedBox(
                                            height: 20.h,
                                            width: 20.w,
                                            child: CircularProgressIndicator(
                                              color: Colors.white,
                                              strokeWidth: 2,
                                            ),
                                          )
                                        : Text(
                                            isExactCurrentPlan
                                                ? l10n.currentPlan
                                                : hasOppositeBillingPeriod
                                                    ? (isYearly ? l10n.cancelMonthlyPlanFirst : l10n.cancelYearlyPlanFirst)
                                                : hasOtherSubscription
                                                    ? l10n.cancelSubscriptionFirst
                                                    : l10n.start,
                                            style: TextStyle(
                                              color: Colors.white,
                                              fontSize: 16.sp,
                                              fontWeight: FontWeight.w600,
                                            ),
                                          ),
                                  ),
                                ),
                              ),
                              */

                              // Cancel subscription button for current Starter users
                              if (isExactCurrentPlan) ...[
                                SizedBox(height: 16.h),
                                InkWell(
                                  onTap:
                                      controller.isCancellingSubscription.value
                                      ? null
                                      : () {
                                          _showCancelConfirmationDialog();
                                        },
                                  child: Container(
                                    height: 50.h,
                                    width: 375.w,
                                    decoration: BoxDecoration(
                                      color:
                                          controller
                                              .isCancellingSubscription
                                              .value
                                          ? Colors.grey[400]
                                          : Colors.red,
                                      borderRadius: BorderRadius.circular(10.r),
                                    ),
                                    child: Center(
                                      child:
                                          controller
                                              .isCancellingSubscription
                                              .value
                                          ? SizedBox(
                                              height: 20.h,
                                              width: 20.w,
                                              child: CircularProgressIndicator(
                                                color: Colors.white,
                                                strokeWidth: 2,
                                              ),
                                            )
                                          : Text(
                                              l10n.cancelSubscription,
                                              style: TextStyle(
                                                color: Colors.white,
                                                fontSize: 16.sp,
                                                fontWeight: FontWeight.w600,
                                              ),
                                            ),
                                    ),
                                  ),
                                ),
                              ],
                            ],
                          );
                        }),
                        SizedBox(height: 16.h),

                        // Subscribe on Web button
                        InkWell(
                          onTap: () async {
                            final Uri webPaymentUrl = Uri.parse(
                              'https://atelia.app/',
                            );
                            if (!await launchUrl(
                              webPaymentUrl,
                              mode: LaunchMode.externalApplication,
                            )) {
                              showAppSnackbar(
                                'Error',
                                'Could not open payment page',
                                snackPosition: SnackPosition.BOTTOM,
                                backgroundColor: Colors.red,
                                colorText: Colors.white,
                              );
                            }
                          },
                          child: Container(
                            height: 50.h,
                            width: 375.w,
                            decoration: BoxDecoration(
                              border: Border.all(color: Colors.black, width: 2),
                              borderRadius: BorderRadius.circular(10.r),
                            ),
                            child: Center(
                              child: Text(
                                AppLocalizations.of(context)!.learnMore,
                                style: TextStyle(
                                  color: Colors.black,
                                  fontSize: 16.sp,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                            ),
                          ),
                        ),
                        SizedBox(height: 16.h),
                      ],
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildFeatureItem(String feature) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          width: 20.w,
          height: 20.h,
          decoration: const BoxDecoration(
            color: Colors.black,
            shape: BoxShape.circle,
          ),
          child: Icon(Icons.check, color: Colors.white, size: 14.sp),
        ),
        SizedBox(width: 12.w),
        Expanded(child: Text(feature, style: sfpsTitleTextTextStyle14500)),
      ],
    );
  }

  List<String> _getLocalizedReasons(AppLocalizations l10n) {
    return [
      l10n.tooExpensive,
      l10n.notUsingEnough,
      l10n.missingFeatures,
      l10n.foundBetterAlternative,
      l10n.technicalIssues,
      l10n.other,
    ];
  }

  void _showCancelConfirmationDialog() {
    String? selectedReason;
    final otherReasonController = TextEditingController();

    Get.dialog(
      StatefulBuilder(
        builder: (context, setState) {
          final l10n = AppLocalizations.of(context)!;
          final localizedReasons = _getLocalizedReasons(l10n);

          return AlertDialog(
            title: Text(
              l10n.cancelSubscriptionTitle,
              style: sfpsTitleTextTextStyle18600.copyWith(color: Colors.black),
            ),
            content: SingleChildScrollView(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    l10n.cancelSubscriptionMessage,
                    style: ssTitleTextTextStyle14400.copyWith(
                      color: Colors.black,
                    ),
                  ),
                  SizedBox(height: 16),
                  ...localizedReasons.map(
                    (reason) => RadioListTile<String>(
                      title: Text(
                        reason,
                        style: ssTitleTextTextStyle14400.copyWith(
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
                      padding: EdgeInsets.only(top: 8),
                      child: TextField(
                        controller: otherReasonController,
                        decoration: InputDecoration(
                          hintText: l10n.pleaseSpecify,
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
                  style: ssTitleTextTextStyle14400.copyWith(
                    color: Colors.black,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
              TextButton(
                onPressed: () {
                  final reason = selectedReason == l10n.other
                      ? otherReasonController.text.isNotEmpty
                            ? otherReasonController.text
                            : l10n.other
                      : selectedReason;
                  Navigator.of(Get.overlayContext!).pop();
                  controller.cancelSubscription(reason: reason);
                },
                style: TextButton.styleFrom(foregroundColor: Colors.red),
                child: Text(
                  l10n.cancelSubscription,
                  style: ssTitleTextTextStyle14400.copyWith(
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
*/
