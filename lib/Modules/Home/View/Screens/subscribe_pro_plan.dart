import 'package:atella/core/themes/app_fonts.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import '../../../../models/subscription_plan.dart';
import '../../Controllers/subscribe_controller.dart';

class SubscribeProPlan extends StatefulWidget {
  const SubscribeProPlan({super.key});

  @override
  State<SubscribeProPlan> createState() => _SubscribeProPlanState();
}

class _SubscribeProPlanState extends State<SubscribeProPlan> {
  final SubscribeController controller = Get.find<SubscribeController>();

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
                  Text('Pro', style: ssTitleTextTextStyle208001),
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
                            // Free Plan Header Container
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
                                      crossAxisAlignment: CrossAxisAlignment.start,
                                      children: [
                                        Text(
                                          "Pro €24.99/Month",
                                          style: sfpsTitleTextTextStyle18600,
                                        ),
                                        SizedBox(height: 4.h),
                                        Text(
                                          "Features include:",
                                          style: sfpsTitleTextTextStyle14400,
                                        ),
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
                                "For creators ready to scale their vision.",
                                style: sfpsTitleTextTextStyle14500,
                                textAlign: TextAlign.center,
                              ),
                            ),
                            SizedBox(height: 24.h),
                            
                            // Features List
                            _buildFeatureItem("Unlimited AI-generated designs"),
                            SizedBox(height: 16.h),
                            _buildFeatureItem("Unlimited techpacks"),
                            SizedBox(height: 16.h),
                            _buildFeatureItem("Custom PDF export (includes logo)"),
                            SizedBox(height: 16.h),
                            _buildFeatureItem("Access to a curated list of manufacturers"),
                            SizedBox(height: 16.h),
                            _buildFeatureItem("Priority support"),
                            SizedBox(height: 40.h),
                          ],
                        ),
                      ),
                    ),
                    
                    // Bottom Section with Button and Terms
                    Column(
                      children: [
                       Obx(() {
                          bool hasActiveSubscription = controller.currentSubscription.value != null && 
                                                      controller.currentSubscription.value!.subscriptionPlan != 'FREE';
                          bool isCurrentPlan = controller.currentSubscription.value?.subscriptionPlan == 'PRO';
                          bool isDisabled = controller.isLoading.value || hasActiveSubscription;
                          
                          return InkWell(
                            onTap: isDisabled ? null : () {
                              controller.subscribeToPlan(SubscriptionPlan.proPlan);
                            },
                            child: Container(
                              height: 50.h,
                              width: 375.w,
                              decoration: BoxDecoration(
                                color: isDisabled ? Colors.grey[400] : Colors.black,
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
                                        isCurrentPlan 
                                            ? "Current Plan" 
                                            : hasActiveSubscription 
                                                ? "Cancel subscription first"
                                                : "Start",
                                        style: TextStyle(
                                          color: Colors.white,
                                          fontSize: 16.sp,
                                          fontWeight: FontWeight.w600,
                                        ),
                                      ),
                              ),
                            ),
                          );
                        }),
                        SizedBox(height: 16.h),
                        RichText(
                          textAlign: TextAlign.center,
                          text: TextSpan(
                            style: TextStyle(
                              color: Colors.grey[600],
                              fontSize: 12.sp,
                              height: 1.4,
                            ),
                            children: [
                              TextSpan(text: "By placing this order, you agree to the ",style: ssTitleTextTextStyle124006),
                              TextSpan(
                                text: "Terms of Service",
                                style: ssTitleTextTextStyle124006.copyWith(
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                              TextSpan(text: " and\n", style: ssTitleTextTextStyle124006),
                              TextSpan(
                                text: "Privacy Policy",
                                style: ssTitleTextTextStyle124006.copyWith(
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                              const TextSpan(text: "."),
                            ],
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
          child: Icon(
            Icons.check,
            color: Colors.white,
            size: 14.sp,
          ),
        ),
        SizedBox(width: 12.w),
        Expanded(
          child: Text(
            feature,
            style: sfpsTitleTextTextStyle14500,
          ),
        ),
      ],
    );
  }
}