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
                            isSelected: controller.selectedPlan.value == 'STARTER',
                            onTap: () {
                              Get.toNamed("/subscribe_starter");
                            },
                          ),
                          SizedBox(height: 16.h),
                          _buildPlanCard(
                            plan: SubscriptionPlan.proPlan,
                            isSelected: controller.selectedPlan.value == 'PRO',
                            onTap: () {
                              Get.toNamed("/subscribe_pro");
                            },
                          ),
                        ],
                      )),
                      SizedBox(height: 40.h),
                      
                      // Action Buttons
                      Obx(() => controller.currentSubscription.value != null && 
                              controller.currentSubscription.value!.subscriptionPlan != 'FREE'
                          ? Column(
                              children: [
                                Container(
                                  width: double.infinity,
                                  height: 50.h,
                                  child: ElevatedButton(
                                    onPressed: (controller.isLoading.value || controller.isCancellingSubscription.value) ? null : () {
                                      _showChangeConfirmationDialog();
                                    },
                                    style: ElevatedButton.styleFrom(
                                      backgroundColor: Colors.black,
                                      shape: RoundedRectangleBorder(
                                        borderRadius: BorderRadius.circular(12.r),
                                      ),
                                    ),
                                    child: Text(
                                      'Change Plan',
                                      style: TextStyle(
                                        color: Colors.white,
                                        fontSize: 16.sp,
                                        fontWeight: FontWeight.w600,
                                      ),
                                    ),
                                  ),
                                ),
                                SizedBox(height: 12.h),
                                Container(
                                  width: double.infinity,
                                  height: 50.h,
                                  child: ElevatedButton(
                                    onPressed: (controller.isLoading.value || controller.isCancellingSubscription.value) ? null : () {
                                      _showCancelConfirmationDialog();
                                    },
                                    style: ElevatedButton.styleFrom(
                                      backgroundColor: Colors.red,
                                      shape: RoundedRectangleBorder(
                                        borderRadius: BorderRadius.circular(12.r),
                                      ),
                                    ),
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
                                            'Cancel Subscription',
                                            style: TextStyle(
                                              color: Colors.white,
                                              fontSize: 16.sp,
                                              fontWeight: FontWeight.w600,
                                            ),
                                          ),
                                  ),
                                ),
                              ],
                            )
                          : SizedBox.shrink()),
                      SizedBox(height: 20.h),
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
                    style: TextStyle(
                      fontSize: 18.sp,
                      fontWeight: FontWeight.w600,
                      color: Colors.black,
                    ),
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
            Text(
              plan.price == 0 ? 'Free' : '€${plan.price}/Month',
              style: TextStyle(
                fontSize: 14.sp,
                color: Colors.grey[600],
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _showChangeConfirmationDialog() {
    Get.dialog(
      AlertDialog(
        title: Text('Change Plan', style: sfpsTitleTextTextStyle18600.copyWith(color: Colors.black)),
        content: Text('To change your plan, you need to cancel your current subscription first, then select a new plan.', style: ssTitleTextTextStyle14400.copyWith(color: Colors.black)),
        actions: [
          TextButton(
            onPressed: () => Get.back(),
            child: Text('Cancel', style: ssTitleTextTextStyle14400.copyWith(color: Colors.black, fontWeight: FontWeight.bold)),
          ),
          TextButton(
            onPressed: () {
              Get.back();
              _showCancelConfirmationDialog();
            },
            child: Text('Continue', style: ssTitleTextTextStyle14400.copyWith(color: Colors.black, fontWeight: FontWeight.bold)),
          ),
        ],
      ),
    );
  }

  void _showCancelConfirmationDialog() {
    Get.dialog(
      AlertDialog(
        title: Text('Cancel Subscription',style: sfpsTitleTextTextStyle18600.copyWith(color: Colors.black),),
        content: Text('Are you sure you want to cancel your subscription? You will lose access to premium features.',style: ssTitleTextTextStyle14400.copyWith(color: Colors.black),),
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