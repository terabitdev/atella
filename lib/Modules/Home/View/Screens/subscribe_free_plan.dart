import 'package:atella/Widgets/custom_roundbutton.dart';
import 'package:atella/core/themes/app_fonts.dart';
import 'package:atella/l10n/generated/app_localizations.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import '../../Controllers/subscribe_controller.dart';

class SubscribeFreePlan extends StatefulWidget {
  const SubscribeFreePlan({super.key});

  @override
  State<SubscribeFreePlan> createState() => _SubscribeFreePlanState();
}

class _SubscribeFreePlanState extends State<SubscribeFreePlan> {
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
                  Text(l10n.free, style: ssTitleTextTextStyle208001),
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
                                          l10n.freePerMonth,
                                          style: sfpsTitleTextTextStyle18600,
                                        ),
                                        SizedBox(height: 4.h),
                                        Text(
                                          l10n.featuresInclude,
                                          style: sfpsTitleTextTextStyle14400,
                                        ),
                                        SizedBox(height: 8.h),
                                        // Design counter
                                        Obx(() {
                                          // For FREE users, use email-based quota from design_quotas collection
                                          final emailQuota = controller.emailBasedQuota.value;
                                          if (emailQuota != null) {
                                            final designsUsed = emailQuota['designsUsed'] as int? ?? 0;
                                            final monthlyLimit = emailQuota['monthlyLimit'] as int? ?? 3;
                                            final remaining = monthlyLimit - designsUsed;

                                            return Text(
                                              l10n.designsUsed(
                                                designsUsed.toString(),
                                                monthlyLimit.toString(),
                                              ),
                                              style: TextStyle(
                                                fontSize: 14.sp,
                                                color: remaining > 0
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
                                l10n.perfectToTest,
                                style: sfpsTitleTextTextStyle14500,
                                textAlign: TextAlign.center,
                              ),
                            ),
                            SizedBox(height: 24.h),
                            
                            // Features List
                            _buildFeatureItem(l10n.upTo10Designs),
                            SizedBox(height: 16.h),
                            _buildFeatureItem(l10n.visualization3DIncluded),
                            SizedBox(height: 16.h),
                            _buildFeatureItem(l10n.noTechpackGeneration, isAvailable: false),
                            SizedBox(height: 16.h),
                            _buildFeatureItem(l10n.noPdfExport, isAvailable: false),
                            SizedBox(height: 16.h),
                            _buildFeatureItem(l10n.noAccessToManufacturers, isAvailable: false),
                            SizedBox(height: 40.h),
                          ],
                        ),
                      ),
                    ),
                    
                    // Bottom Section with Button
                    Column(
                      children: [
                        RoundButton(
                          title: l10n.upgradePlan,
                          onTap: () {
                            Navigator.of(context).pop();
                          },
                          color: Colors.black,
                          isloading: false,
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