import 'package:atella/Data/Models/subscription_plan.dart';
import 'package:atella/core/themes/app_fonts.dart';
import 'package:atella/l10n/generated/app_localizations.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import '../../Controllers/subscribe_controller.dart';
import 'package:atella/core/widgets/tap_tracking_wrapper.dart';

class SubscribeScreen extends StatefulWidget {
  const SubscribeScreen({super.key});

  @override
  State<SubscribeScreen> createState() => _SubscribeScreenState();
}

class _SubscribeScreenState extends State<SubscribeScreen> {
  final SubscribeController controller = Get.find<SubscribeController>();

  @override
  void initState() {
    super.initState();
    // Refresh subscription data and reset to current plan when screen loads
    WidgetsBinding.instance.addPostFrameCallback((_) {
      controller.loadCurrentSubscription();
    });
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    return Scaffold(
      backgroundColor: Colors.black,
      body: TapTrackingWrapper(
        screenName: 'SubscribeScreen',
        child: SafeArea(
        child: Column(
          children: [
            Padding(
              padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 12.h),
              child: Row(
                children: [
                  InkWell(
                    onTap: () {
                      // Check if there's a route to go back to
                      if (Get.previousRoute.isNotEmpty && Get.previousRoute != '/subscribe') {
                        Get.back();
                      } else {
                        // Go to Settings tab (index 4) in nav_bar
                        Get.offAllNamed('/nav_bar', arguments: {'initialIndex': 4});
                      }
                    },
                    child: Image.asset(
                      'assets/images/Arrow_Left.png',
                      height: 40.h,
                      width: 40.w,
                    ),
                  ),
                  SizedBox(width: 8.w),
                  Text(l10n.subscribe, style: ssTitleTextTextStyle208001),
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
                child: SingleChildScrollView(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      SizedBox(height: 16.h),
                      Text(
                        l10n.chooseYourPlan,
                        style: ssTitleTextTextStyle327002,
                      ),
                      SizedBox(height: 12.h),
                      Text(
                        l10n.startForFree,
                        style:ssTitleTextTextStyle124003,
                      ),
                      SizedBox(height: 40.h),
                      Image.asset('assets/images/subscribe.png', height: 200.h),
                      SizedBox(height: 40.h),
                      Obx(() => Column(
                        children: [
                          _buildPlanCard(
                            plan: SubscriptionPlan.freePlan,
                            isSelected: controller.selectedPlan.value == 'FREE',
                            onTap: () {
                              Get.toNamed("/subscribe_free");
                            },
                            l10n: l10n,
                          ),
                          SizedBox(height: 16.h),
                          _buildPlanCard(
                            plan: SubscriptionPlan.starterPlan,
                            isSelected: controller.selectedPlan.value == 'STARTER' || controller.selectedPlan.value == 'STARTER_YEARLY',
                            onTap: () {
                              Get.toNamed("/subscribe_starter");
                            },
                            l10n: l10n,
                          ),
                          SizedBox(height: 16.h),
                          _buildPlanCard(
                            plan: SubscriptionPlan.proPlan,
                            isSelected: controller.selectedPlan.value == 'PRO' || controller.selectedPlan.value == 'PRO_YEARLY',
                            onTap: () {
                              Get.toNamed("/subscribe_pro");
                            },
                            l10n: l10n,
                          ),
                        ],
                      )),
                    ],
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
      ),
    );
  }

  Widget _buildPlanCard({
    required SubscriptionPlan plan,
    required bool isSelected,
    required VoidCallback onTap,
    required AppLocalizations l10n,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: double.infinity,
        padding: EdgeInsets.symmetric(horizontal: 20.w, vertical: 20.h),
        decoration: BoxDecoration(
          color: Color.fromRGBO(236, 239, 246, 1),
          borderRadius: BorderRadius.circular(12.r),
          border: isSelected 
              ? Border.all(color: Colors.black, width: 2)
              : null,
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Expanded(
                  child: Text(
                    plan.displayName,
                    style: vsTextStyle20800,
                  ),
                ),
                if (isSelected)
                  Container(
                    padding: EdgeInsets.symmetric(horizontal: 8.w, vertical: 4.h),
                    decoration: BoxDecoration(
                      color: Colors.black,
                      borderRadius: BorderRadius.circular(12.r),
                    ),
                    child: Text(
                      l10n.current,
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 12.sp,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ),
              ],
            ),
            SizedBox(height: 4.h),
            // Pricing display
            if (plan.price == 0)
              Text(
                l10n.free,
                style: TextStyle(
                  fontSize: 14.sp,
                  color: Colors.grey[600],
                ),
              )
            else
              Obx(() {
                final subscription = controller.currentSubscription.value;
                bool isUserOnThisPlan = isSelected;
                bool isYearlyUser = subscription?.billingPeriod == 'YEARLY' || 
                                   (subscription?.subscriptionPlan.contains('YEARLY') ?? false);
                
                return Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Monthly pricing row
                    Row(
                      children: [
                        Text(
                          '€${plan.price}${l10n.perMonth}',
                          style: TextStyle(
                            fontSize: 14.sp,
                            color: Colors.grey[600],
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                        if (isUserOnThisPlan && !isYearlyUser) ...[
                          SizedBox(width: 6.w),
                          Icon(
                            Icons.check,
                            color: Colors.black,
                            size: 16.sp,
                          ),
                        ],
                      ],
                    ),
                    SizedBox(height: 2.h),
                    // Yearly pricing row
                    Row(
                      children: [
                        Text(
                          plan.type == SubscriptionPlanType.STARTER
                              ? '€149${l10n.perYear}'
                              : '€349${l10n.perYear}',
                          style: TextStyle(
                            fontSize: 12.sp,
                            color: Colors.grey[600],
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                        if (isUserOnThisPlan && isYearlyUser) ...[
                          SizedBox(width: 6.w),
                          Icon(
                            Icons.check,
                            color: Colors.black,
                            size: 14.sp,
                          ),
                        ],
                      ],
                    ),
                  ],
                );
              }),
            // Show design and techpack usage for Starter plan users (monthly and yearly)
            if (plan.type == SubscriptionPlanType.STARTER && isSelected)
              Obx(() {
                final subscription = controller.currentSubscription.value;
                if (subscription != null && (subscription.subscriptionPlan == 'STARTER' || subscription.subscriptionPlan == 'STARTER_YEARLY')) {
                  return Padding(
                    padding: EdgeInsets.only(top: 6.h),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // Design usage counter
                        Text(
                          l10n.designsUsed(
                            subscription.designsUsedCount,
                            subscription.designsTotalCount,
                          ),
                          style: TextStyle(
                            fontSize: 12.sp,
                            color: subscription.remainingDesigns > 0
                                ? Colors.grey[700]
                                : Colors.red[600],
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                        SizedBox(height: 4.h),
                        // Techpack usage counter
                        Text(
                          l10n.techpacksUsed(
                            subscription.techpacksUsedCount,
                            subscription.techpacksTotalCount,
                          ),
                          style: TextStyle(
                            fontSize: 12.sp,
                            color: subscription.remainingTechpacks > 0
                                ? Colors.grey[700]
                                : Colors.red[600],
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ],
                    ),
                  );
                }
                return SizedBox.shrink();
              }),
            // Show design and techpack usage for Pro plan users (monthly and yearly)
            if (plan.type == SubscriptionPlanType.PRO && isSelected)
              Obx(() {
                final subscription = controller.currentSubscription.value;
                if (subscription != null && (subscription.subscriptionPlan == 'PRO' || subscription.subscriptionPlan == 'PRO_YEARLY')) {
                  return Padding(
                    padding: EdgeInsets.only(top: 6.h),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // Design usage counter
                        Text(
                          l10n.designsUsed(
                            subscription.designsUsedCount,
                            subscription.designsTotalCount,
                          ),
                          style: TextStyle(
                            fontSize: 12.sp,
                            color: subscription.remainingDesigns > 0
                                ? Colors.grey[700]
                                : Colors.red[600],
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                        SizedBox(height: 4.h),
                        // Techpack usage counter
                        Text(
                          l10n.techpacksUsed(
                            subscription.techpacksUsedCount,
                            subscription.techpacksTotalCount,
                          ),
                          style: TextStyle(
                            fontSize: 12.sp,
                            color: subscription.remainingTechpacks > 0
                                ? Colors.grey[700]
                                : Colors.red[600],
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ],
                    ),
                  );
                }
                return SizedBox.shrink();
              }),
            // Show design counter for Free plan users
            if (plan.type == SubscriptionPlanType.FREE && isSelected)
              Obx(() {
                final subscription = controller.currentSubscription.value;
                if (subscription != null && subscription.subscriptionPlan == 'FREE') {
                  return Padding(
                    padding: EdgeInsets.only(top: 6.h),
                    child: Text(
                      l10n.designsUsed(
                        subscription.designsUsedCount,
                        subscription.designsTotalCount,
                      ),
                      style: TextStyle(
                        fontSize: 12.sp,
                        color: subscription.remainingDesigns > 0
                            ? Colors.grey[700]
                            : Colors.red[600],
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  );
                }
                return SizedBox.shrink();
              }),
          ],
        ),
      ),
    );
  }
}