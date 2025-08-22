import 'package:atella/Data/Models/subscription_plan.dart';
import 'package:atella/core/themes/app_fonts.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import '../../Controllers/subscribe_controller.dart';

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
    // Reset to current plan when screen loads
    WidgetsBinding.instance.addPostFrameCallback((_) {
      controller.resetToCurrentPlan();
    });
  }

  @override
  Widget build(BuildContext context) {
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
                    onTap: () => Get.back(),
                    child: Image.asset(
                      'assets/images/Arrow_Left.png',
                      height: 40.h,
                      width: 40.w,
                    ),
                  ),
                  SizedBox(width: 8.w),
                  Text('Subscribe', style: ssTitleTextTextStyle208001),
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
                        "Choose Your Plan",
                        style: ssTitleTextTextStyle327002,
                      ),
                      SizedBox(height: 12.h),
                      Text(
                        'Start for free. Upgrade anytime.',
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
                          ),
                          SizedBox(height: 16.h),
                          _buildPlanCard(
                            plan: SubscriptionPlan.starterPlan,
                            isSelected: controller.selectedPlan.value == 'STARTER' || controller.selectedPlan.value == 'STARTER_YEARLY',
                            onTap: () {
                              Get.toNamed("/subscribe_starter");
                            },
                          ),
                          SizedBox(height: 16.h),
                          _buildPlanCard(
                            plan: SubscriptionPlan.proPlan,
                            isSelected: controller.selectedPlan.value == 'PRO' || controller.selectedPlan.value == 'PRO_YEARLY',
                            onTap: () {
                              Get.toNamed("/subscribe_pro");
                            },
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
    );
  }

  Widget _buildPlanCard({
    required SubscriptionPlan plan,
    required bool isSelected,
    required VoidCallback onTap,
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
                      'Current',
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
                'Free',
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
                          '€${plan.price}/Month',
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
                              ? '€99/Year'
                              : '€249/Year',
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
            // Show remaining techpacks for Starter plan users (monthly and yearly)
            if (plan.type == SubscriptionPlanType.STARTER && isSelected)
              Obx(() {
                final subscription = controller.currentSubscription.value;
                if (subscription != null && (subscription.subscriptionPlan == 'STARTER' || subscription.subscriptionPlan == 'STARTER_YEARLY')) {
                  final extraTechpacks = subscription.extraTechpacksPurchased;
                  final totalAvailable = subscription.totalAllowedTechpacks;
                  
                  // Use appropriate techpack counter based on billing period
                  final isYearly = subscription.billingPeriod == 'YEARLY' || subscription.subscriptionPlan.contains('YEARLY');
                  final techpacksUsed = isYearly ? subscription.techpacksUsedThisYear : subscription.techpacksUsedThisMonth;
                  final periodText = isYearly ? 'year' : 'month';
                  
                  return Padding(
                    padding: EdgeInsets.only(top: 6.h),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Techpacks: $techpacksUsed/$totalAvailable this $periodText',
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
            // Show techpacks info for Pro plan users (monthly and yearly)
            if (plan.type == SubscriptionPlanType.PRO && isSelected)
              Obx(() {
                final subscription = controller.currentSubscription.value;
                if (subscription != null && (subscription.subscriptionPlan == 'PRO' || subscription.subscriptionPlan == 'PRO_YEARLY')) {
                  final extraTechpacks = subscription.extraTechpacksPurchased;
                  final totalAvailable = subscription.totalAllowedTechpacks;
                  
                  // Use appropriate techpack counter based on billing period
                  final isYearly = subscription.billingPeriod == 'YEARLY' || subscription.subscriptionPlan.contains('YEARLY');
                  final techpacksUsed = isYearly ? subscription.techpacksUsedThisYear : subscription.techpacksUsedThisMonth;
                  final periodText = isYearly ? 'year' : 'month';
                  
                  return Padding(
                    padding: EdgeInsets.only(top: 6.h),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Techpacks: $techpacksUsed/$totalAvailable',
                          style: TextStyle(
                            fontSize: 12.sp,
                            color: subscription.remainingTechpacks > 0
                                ? Colors.black
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
                      'Designs: ${subscription.designCounterDisplay}',
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