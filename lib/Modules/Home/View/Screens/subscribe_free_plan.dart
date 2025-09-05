import 'package:atella/Widgets/custom_roundbutton.dart';
import 'package:atella/core/themes/app_fonts.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import '../../Controllers/subscribe_controller.dart';

class SubscribeFreePlan extends StatelessWidget {
  const SubscribeFreePlan({super.key});

  @override
  Widget build(BuildContext context) {
    final SubscribeController controller = Get.find<SubscribeController>();
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
                  Text('Free', style: ssTitleTextTextStyle208001),
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
                                          "Free/Month",
                                          style: sfpsTitleTextTextStyle18600,
                                        ),
                                        SizedBox(height: 4.h),
                                        Text(
                                          "Features include:",
                                          style: sfpsTitleTextTextStyle14400,
                                        ),
                                        SizedBox(height: 8.h),
                                        // Design counter
                                        Obx(() {
                                          final subscription = controller.currentSubscription.value;
                                          if (subscription != null && subscription.subscriptionPlan == 'FREE') {
                                            return Text(
                                              'Designs: ${subscription.designCounterDisplay}',
                                              style: TextStyle(
                                                fontSize: 14.sp,
                                                color: subscription.remainingDesigns > 0
                                                    ? Colors.white
                                                    : Colors.red[300],
                                                fontWeight: FontWeight.w600,
                                              ),
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
                                "Perfect to test, imagine, and create freely.",
                                style: sfpsTitleTextTextStyle14500,
                                textAlign: TextAlign.center,
                              ),
                            ),
                            SizedBox(height: 24.h),
                            
                            // Features List
                            _buildFeatureItem("Up to 10 3D designs / month"),
                            SizedBox(height: 16.h),
                            _buildFeatureItem("3D Visualization included"),
                            SizedBox(height: 16.h),
                            _buildFeatureItem("No techpack generation",isAvailable: false),
                            SizedBox(height: 16.h),
                            _buildFeatureItem("No PDF export", isAvailable: false ),
                            SizedBox(height: 16.h),
                            _buildFeatureItem("No access to manufacturers", isAvailable: false),
                            SizedBox(height: 40.h),
                          ],
                        ),
                      ),
                    ),
                    
                    // Bottom Section with Button and Terms
                    Column(
                      children: [
                        // Upgrade message
                        Container(
                          width: double.infinity,
                          padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 12.h),
                          margin: EdgeInsets.only(bottom: 16.h),
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(12.r),
                          ),
                          child: Text(
                            "You can upgrade your plan to generate tech PDF's and access to manufacturers",
                            style: sfpsTitleTextTextStyle14500,
                            textAlign: TextAlign.center,
                          ),
                        ),
                        RoundButton(
                          title: "Upgrade plan", 
                          onTap: () {
                            Get.back();
                          }, 
                          color: Colors.black, 
                          isloading: false
                        ),
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

  Widget _buildFeatureItem(String feature, {bool isAvailable = true}) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          width: 20.w,
          height: 20.h,
          decoration: BoxDecoration(
            color: isAvailable ? Colors.black : Colors.red,
            shape: BoxShape.circle,
          ),
          child: Icon(
            isAvailable ? Icons.check : Icons.close,
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