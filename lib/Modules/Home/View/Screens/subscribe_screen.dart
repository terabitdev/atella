import 'package:atella/Modules/Home/Controllers/subscribe_controller.dart';
import 'package:atella/Widgets/custom_roundbutton.dart';
import 'package:atella/core/themes/app_fonts.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';

class SubscribeScreen extends StatelessWidget {
  const SubscribeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final controller = Get.put(SubscribeController());

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
                  Text('Subscribe', style: SSTitleTextTextStyle208001),
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
                      Text("Get Premium", style: SSTitleTextTextStyle327002),
                      SizedBox(height: 12.h),
                      Text(
                        "Unlock full access to AtellaAI fashion assistant\n"
                        "generate tech packs, get manufacturer suggestions,\n"
                        "and bring your designs to life faster than ever!",
                        textAlign: TextAlign.center,
                        style: SSTitleTextTextStyle124003,
                      ),
                      SizedBox(height: 20.h),
                      Image.asset('assets/images/subscribe.png', height: 180.h),
                      SizedBox(height: 20.h),
                      Obx(
                        () => Column(
                          children: [
                            GestureDetector(
                              onTap: () => controller.selectPlan('annual'),
                              child: Container(
                                width: double.infinity,
                                padding: EdgeInsets.all(16.h),
                                decoration: BoxDecoration(
                                  color: Colors.grey.shade100,
                                  borderRadius: BorderRadius.circular(12.r),
                                  border: Border.all(
                                    color:
                                        controller.selectedPlan.value ==
                                            'annual'
                                        ? Colors.black
                                        : Color.fromRGBO(236, 239, 246, 1),
                                    width: 2,
                                  ),
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
                                            "Annual",
                                            style: SSTitleTextTextStyle186004,
                                          ),
                                          SizedBox(height: 4.h),
                                          Text(
                                            "First 30 days free - Then \$999/Year",
                                            style: SSTitleTextTextStyle144005,
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
                              onTap: () => controller.selectPlan('monthly'),
                              child: Container(
                                width: double.infinity,
                                padding: EdgeInsets.all(16.h),
                                decoration: BoxDecoration(
                                  color: Colors.grey.shade100,
                                  borderRadius: BorderRadius.circular(12.r),
                                  border: Border.all(
                                    color:
                                        controller.selectedPlan.value ==
                                            'monthly'
                                        ? Colors.black
                                        : Colors.transparent,
                                    width: 2,
                                  ),
                                ),
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      "Monthly",
                                      style: SSTitleTextTextStyle186004,
                                    ),
                                    Text(
                                      "First 7 days free - Then \$99/Month",
                                      style: SSTitleTextTextStyle144005,
                                    ),
                                  ],
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                      SizedBox(height: 30.h),
                      RoundButton(
                        title: 'Start 30-day free trial',
                        onTap: () {},
                        color: Colors.black,
                        isloading: false,
                      ),
                      SizedBox(height: 20.h),
                      Text.rich(
                        TextSpan(
                          text: "By placing this order, you agree to the ",
                          style: SSTitleTextTextStyle124006,
                          children: [
                            TextSpan(
                              text: "Terms of Service",
                              style: SSTitleTextTextStyle124006.copyWith(
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            TextSpan(text: " and ", style: SSTitleTextTextStyle124006),
                            TextSpan(
                              text: "Privacy Policy.",
                              style: SSTitleTextTextStyle124006.copyWith(
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ],
                        ),
                        textAlign: TextAlign.center,
                      ),
                      SizedBox(height: 30.h),
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
