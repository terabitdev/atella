import 'package:atella/core/themes/app_fonts.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:atella/Widgets/custom_roundbutton.dart';
import 'package:atella/l10n/generated/app_localizations.dart';

class ViewProfileTechPackScreen extends StatelessWidget {
  const ViewProfileTechPackScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;

    return Scaffold(
      backgroundColor: const Color(0xFFF5F5F5),
      body: SafeArea(
        child: Stack(
          children: [
            Column(
              children: [
                SizedBox(height: 24.h),
                Padding(
                  padding: EdgeInsets.symmetric(horizontal: 16.w),
                  child: Row(
                    children: [
                      InkWell(
                        borderRadius: BorderRadius.circular(24.r),
                        onTap: () => Get.back(),
                        child: Container(
                          width: 40.w,
                          height: 40.h,
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(4.r),
                          ),
                          child: Icon(
                            Icons.arrow_back_ios_new_rounded,
                            size: 20.w,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                SizedBox(height: 24.h),
                Expanded(
                  child: SingleChildScrollView(
                    child: Padding(
                      padding: EdgeInsets.symmetric(horizontal: 16.w),
                      child: Container(
                        width: double.infinity,
                        padding: EdgeInsets.all(24.r),
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(20.r),
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              l10n.vpManufacturerProfile,
                              style: mstTextTextStyle26700,
                            ),
                            SizedBox(height: 24.h),
                            _ProfileSection(
                              title: l10n.vpCompany,
                              value: 'ABC Garments',
                            ),
                            SizedBox(height: 16.h),
                            _ProfileSection(
                              title: l10n.vpLocation,
                              value: 'Los Angeles, CA',
                            ),
                            SizedBox(height: 16.h),
                            _ProfileSection(
                              title: l10n.vpMinimumOrderQuantity,
                              value: 'MO 100 units',
                            ),
                            SizedBox(height: 16.h),
                            _ProfileSection(
                              title: l10n.vpLeadTime,
                              value: '60 days',
                            ),
                            SizedBox(height: 16.h),
                            Text(
                              l10n.vpAbout,
                              style: TextStyle(
                                fontWeight: FontWeight.w700,
                                fontSize: 20.sp,
                              ),
                            ),
                            SizedBox(height: 8.h),
                            Text(
                              'ABC Garments is a full-service clothing manufacturer based in Los Angeles, specializing in high-quality knitwear.',
                              style: TextStyle(
                                fontWeight: FontWeight.w400,
                                fontSize: 16.sp,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                ),
                SizedBox(height: 24.h),
                Padding(
                  padding: EdgeInsets.symmetric(horizontal: 16.w),
                  child: RoundButton(
                    title: l10n.vpContact,
                    onTap: () {},
                    color: Colors.black,
                    isloading: false,
                  ),
                ),
                SizedBox(height: 24.h),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

class _ProfileSection extends StatelessWidget {
  final String title;
  final String value;
  const _ProfileSection({required this.title, required this.value});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(title, style: ptTextTextStyle18700),
        SizedBox(height: 4.h),
        Text(value, style: ptTextTextStyle16400),
      ],
    );
  }
}
