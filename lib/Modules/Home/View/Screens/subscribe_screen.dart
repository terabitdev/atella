import 'package:atella/core/themes/app_fonts.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import '../../Controllers/subscribe_controller.dart';
import '../../../../models/subscription_plan.dart';

class SubscribeScreen extends GetView<SubscribeController> {
  const SubscribeScreen({super.key});

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
                      Text("Choose Your Plan", style: ssTitleTextTextStyle327002),
                      SizedBox(height: 12.h),
                      Text(
                        'Start for free. Upgrade anytime.',
                        style: ssTitleTextTextStyle124003,
                      ),
                      SizedBox(height: 20.h),
                      Image.asset('assets/images/subscribe.png', height: 180.h),
                      SizedBox(height: 20.h),
                    Column(
                          children: [
                            _buildPlanCard(
                              plan: SubscriptionPlan.freePlan,
                              isCurrentPlan: controller.currentSubscription.value?.subscriptionPlan == 'FREE',
                              onTap: () => Get.toNamed("/subscribe_free"),
                              showBadge: true,
                              badgeText: "Current Plan",
                            ),
                            SizedBox(height: 12.h),
                            _buildPlanCard(
                              plan: SubscriptionPlan.starterPlan,
                              isCurrentPlan: controller.currentSubscription.value?.subscriptionPlan == 'STARTER',
                              onTap: () => controller.subscribeToPlan(SubscriptionPlan.starterPlan),
                            ),
                            SizedBox(height:12.h),
                            _buildPlanCard(
                              plan: SubscriptionPlan.proPlan,
                              isCurrentPlan: controller.currentSubscription.value?.subscriptionPlan == 'PRO',
                              onTap: () => controller.subscribeToPlan(SubscriptionPlan.proPlan),
                              showBadge: true,
                              badgeText: "Most Popular",
                            ),
                          ],
                        ),
                      SizedBox(height: 12.h),
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
    required bool isCurrentPlan,
    required VoidCallback onTap,
    bool showBadge = false,
    String? badgeText,
  }) {
    return Obx(() => GestureDetector(
      onTap: controller.isLoading.value ? null : onTap,
      child: Container(
        width: double.infinity,
        padding: EdgeInsets.all(16.h),
        decoration: BoxDecoration(
          color: isCurrentPlan ? Colors.blue.shade50 : Colors.grey.shade100,
          borderRadius: BorderRadius.circular(12.r),
          border: isCurrentPlan
              ? Border.all(color: Colors.blue.shade300, width: 2)
              : null,
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        plan.displayName,
                        style: ssTitleTextTextStyle186004,
                      ),
                      SizedBox(height: 4.h),
                      Text(
                        plan.price == 0
                            ? 'Free'
                            : '€${plan.price.toStringAsFixed(2)}/Month',
                        style: TextStyle(
                          fontSize: 18.sp,
                          fontWeight: FontWeight.bold,
                          color: Colors.black87,
                        ),
                      ),
                    ],
                  ),
                ),
                if (showBadge && badgeText != null)
                  Container(
                    padding: EdgeInsets.symmetric(
                      horizontal: 10.w,
                      vertical: 4.h,
                    ),
                    decoration: BoxDecoration(
                      color: isCurrentPlan ? Colors.blue : Colors.black,
                      borderRadius: BorderRadius.circular(20.r),
                    ),
                    child: Text(
                      badgeText,
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 10.sp,
                      ),
                    ),
                  ),
              ],
            ),
            SizedBox(height: 12.h),
            ...plan.features.map((feature) => Padding(
              padding: EdgeInsets.only(bottom: 6.h),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Icon(
                    feature.contains('No') ? Icons.close : Icons.check,
                    size: 16.sp,
                    color: feature.contains('No') ? Colors.red : Colors.green,
                  ),
                  SizedBox(width: 8.w),
                  Expanded(
                    child: Text(
                      feature,
                      style: TextStyle(
                        fontSize: 13.sp,
                        color: Colors.black87,
                      ),
                    ),
                  ),
                ],
              ),
            )).toList(),
            if (controller.isLoading.value)
              Center(
                child: Padding(
                  padding: EdgeInsets.only(top: 8.h),
                  child: CircularProgressIndicator(strokeWidth: 2),
                ),
              ),
          ],
        ),
      ),
    ));
  }
}
