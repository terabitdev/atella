import 'package:atella/core/themes/app_fonts.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import '../../Controllers/subscribe_controller.dart';

class SubscribeStarterPlan extends StatefulWidget {
  const SubscribeStarterPlan({super.key});

  @override
  State<SubscribeStarterPlan> createState() => _SubscribeStarterPlanState();
}

class _SubscribeStarterPlanState extends State<SubscribeStarterPlan> {
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
                  Text('Starter', style: ssTitleTextTextStyle208001),
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
                              child: Obx(() => Row(
                                children: [
                                  Expanded(
                                    child: GestureDetector(
                                      onTap: () {
                                        if (controller.isYearlyBilling.value) {
                                          controller.toggleBillingPeriod();
                                        }
                                      },
                                      child: Container(
                                        padding: EdgeInsets.symmetric(vertical: 12.h),
                                        decoration: BoxDecoration(
                                          color: !controller.isYearlyBilling.value ? Colors.black : Colors.transparent,
                                          borderRadius: BorderRadius.circular(6.r),
                                        ),
                                        child: Text(
                                          'Monthly',
                                          textAlign: TextAlign.center,
                                          style: TextStyle(
                                            color: !controller.isYearlyBilling.value ? Colors.white : Colors.grey[600],
                                            fontSize: 14.sp,
                                            fontWeight: FontWeight.w600,
                                          ),
                                        ),
                                      ),
                                    ),
                                  ),
                                  Expanded(
                                    child: GestureDetector(
                                      onTap: () {
                                        if (!controller.isYearlyBilling.value) {
                                          controller.toggleBillingPeriod();
                                        }
                                      },
                                      child: Container(
                                        padding: EdgeInsets.symmetric(vertical: 12.h),
                                        decoration: BoxDecoration(
                                          color: controller.isYearlyBilling.value ? Colors.black : Colors.transparent,
                                          borderRadius: BorderRadius.circular(6.r),
                                        ),
                                        child: Text(
                                          'Yearly (Save 17%)',
                                          textAlign: TextAlign.center,
                                          style: TextStyle(
                                            color: controller.isYearlyBilling.value ? Colors.white : Colors.grey[600],
                                            fontSize: 14.sp,
                                            fontWeight: FontWeight.w600,
                                          ),
                                        ),
                                      ),
                                    ),
                                  ),
                                ],
                              )),
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
                                      crossAxisAlignment: CrossAxisAlignment.start,
                                      children: [
                                        Obx(() => Text(
                                          controller.getStarterPriceText(),
                                          style: sfpsTitleTextTextStyle18600,
                                        )),
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
                                "Ideal for launching your first productions.",
                                style: sfpsTitleTextTextStyle14500,
                                textAlign: TextAlign.center,
                              ),
                            ),
                            SizedBox(height: 24.h),
                            
                            // Features List
                            Obx(() => Column(
                              children: [
                                _buildFeatureItem(controller.isYearlyBilling.value 
                                  ? "3 techpacks per month (36 total per year)" 
                                  : "3 techpacks per month"),
                                SizedBox(height: 16.h),
                                _buildFeatureItem("Unlimited 3D visualization"),
                                SizedBox(height: 16.h),
                                _buildFeatureItem("Custom PDF export (with user's logo)"),
                                SizedBox(height: 16.h),
                                _buildFeatureItem("Access to manufacturers list"),
                              ],
                            )),
                            SizedBox(height: 40.h),
                          ],
                        ),
                      ),
                    ),
                    
                    // Bottom Section with Button and Terms
                    Column(
                      children: [
                       Obx(() {
                          final currentPlan = controller.currentSubscription.value?.subscriptionPlan;
                          bool isCurrentPlan = currentPlan == 'STARTER' || currentPlan == 'STARTER_YEARLY';
                          bool hasOtherSubscription = currentPlan != null && currentPlan != 'FREE' && !isCurrentPlan;
                          
                          return Column(
                            children: [
                              // Main action button
                              InkWell(
                                onTap: (controller.isLoading.value || isCurrentPlan || hasOtherSubscription) ? null : () {
                                  controller.subscribeToPlan(controller.getStarterPlan());
                                },
                                child: Container(
                                  height: 50.h,
                                  width: 375.w,
                                  decoration: BoxDecoration(
                                    color: (controller.isLoading.value || isCurrentPlan || hasOtherSubscription) ? Colors.grey[400] : Colors.black,
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
                                                : hasOtherSubscription 
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
                              ),
                              
                              // Cancel subscription button for current Starter users
                              if (isCurrentPlan) ...[
                                SizedBox(height: 16.h),
                                InkWell(
                                  onTap: controller.isCancellingSubscription.value ? null : () {
                                    _showCancelConfirmationDialog();
                                  },
                                  child: Container(
                                    height: 50.h,
                                    width: 375.w,
                                    decoration: BoxDecoration(
                                      color: controller.isCancellingSubscription.value ? Colors.grey[400] : Colors.red,
                                      borderRadius: BorderRadius.circular(10.r),
                                    ),
                                    child: Center(
                                      child: controller.isCancellingSubscription.value
                                          ? SizedBox(
                                              height: 20.h,
                                              width: 20.w,
                                              child: CircularProgressIndicator(
                                                color: Colors.white,
                                                strokeWidth: 2,
                                              ),
                                            )
                                          : Text(
                                              "Cancel Subscription",
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

  void _showCancelConfirmationDialog() {
    Get.dialog(
      AlertDialog(
        title: Text('Cancel Subscription',style: sfpsTitleTextTextStyle18600.copyWith(color: Colors.black),),
        content: Text('Are you sure you want to cancel your Starter subscription? You will lose access to premium features.',style: ssTitleTextTextStyle14400.copyWith(color: Colors.black),),
        actions: [
          TextButton(
            onPressed: () => Get.back(),
            child: Text('No, Keep Subscription',style: ssTitleTextTextStyle14400.copyWith(color: Colors.black,fontWeight: FontWeight.bold),),
          ),
          TextButton(
            onPressed: () {
              Get.back();
              controller.cancelSubscription();
            },
            style: TextButton.styleFrom(
              foregroundColor: Colors.red,
            ),
            child: Text('Yes, Cancel',style: ssTitleTextTextStyle14400.copyWith(color: Colors.red,fontWeight: FontWeight.bold),),
          ),
        ],
      ),
    );
  }
}