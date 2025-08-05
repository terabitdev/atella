import 'package:atella/core/themes/app_fonts.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';

class SubscribeScreen extends StatelessWidget {
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
                            GestureDetector(
                              onTap: () => Get.toNamed("/subscribe_free"),
                              child: Container(
                                width: double.infinity,
                                padding: EdgeInsets.all(16.h),
                                decoration: BoxDecoration(
                                  color: Colors.grey.shade100,
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
                                          Text(
                                            "Free/Month",
                                            style: ssTitleTextTextStyle186004,
                                          ),
                                          SizedBox(height: 4.h),
                                          Text(
                                            "Features include:",
                                            style: ssTitleTextTextStyle144005,
                                          ),
                                        ],
                                      ),
                                    ),
                                    SizedBox(
                                      width: 10.w,
                                    ), // Add spacing between text and badge
                                    Container(
                                      padding: EdgeInsets.symmetric(
                                        horizontal: 10.w,
                                        vertical: 4.h,
                                      ),
                                      decoration: BoxDecoration(
                                        color: Colors.black,
                                        borderRadius: BorderRadius.circular(
                                          20.r,
                                        ),
                                      ),
                                      child: Text(
                                        "Best Value",
                                        style: TextStyle(
                                          color: Colors.white,
                                          fontSize: 10.sp,
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ),
                            SizedBox(height: 12.h),
                            GestureDetector(
                              onTap: () => Get.toNamed("/subscribe_starter"),
                              child: Container(
                                width: double.infinity,
                                padding: EdgeInsets.all(16.h),
                                decoration: BoxDecoration(
                                  color: Colors.grey.shade100,
                                  borderRadius: BorderRadius.circular(12.r),
                                ),
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      "Starter €9.99/Month",
                                      style: ssTitleTextTextStyle186004,
                                    ),
                                    Text(
                                      "Features include:",
                                      style: ssTitleTextTextStyle144005,
                                    ),
                                  ],
                                ),
                              ),
                            ),
                            SizedBox(height:12.h),
                             GestureDetector(
                              onTap: () => Get.toNamed("/subscribe_pro"),
                              child: Container(
                                width: double.infinity,
                                padding: EdgeInsets.all(16.h),
                                decoration: BoxDecoration(
                                  color: Colors.grey.shade100,
                                  borderRadius: BorderRadius.circular(12.r),
                                  
                                ),
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      "Monthly",
                                      style: ssTitleTextTextStyle186004,
                                    ),
                                    Text(
                                      "Features include:",
                                      style: ssTitleTextTextStyle144005,
                                    ),
                                  ],
                                ),
                              ),
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
}
