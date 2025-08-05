import 'package:atella/Modules/Home/Controllers/profile_controller.dart';
import 'package:atella/Widgets/app_header.dart';
import 'package:atella/Widgets/setting_card.dart';
import 'package:atella/core/constants/app_images.dart';
import 'package:atella/core/themes/app_fonts.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_svg/svg.dart';
import 'package:get/get.dart';

class SettingScreen extends StatefulWidget {
  const SettingScreen({super.key});

  @override
  State<SettingScreen> createState() => _SettingScreenState();
}

class _SettingScreenState extends State<SettingScreen> {
  final ProfileController controller = Get.put(ProfileController());
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Padding(
          padding: EdgeInsets.symmetric(horizontal: 24.w),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Header
              GlobalHeader(title: 'Settings'),
              SizedBox(height: 40.h),
              SettingCard(
                title: 'Personal Information',
                leadingIcon: SvgPicture.asset(personalInfo, height: 24.h, width: 24.w),
                onTap: () {
                  Get.toNamed('/profile');
                },
              ),
              SettingCard(
                title: 'Subscription Plan',
                leadingIcon: SvgPicture.asset(subscriptionPlan, height: 24.h, width: 24.w),
                onTap: () {
                  Get.toNamed('/subscribe');
                },
              ),
              SettingCard(
                title: 'Terms and Conditions',
                leadingIcon: SvgPicture.asset(termsAndConditions, height: 24.h, width: 24.w),
                onTap: () {
                  // Get.toNamed('/terms');
                },
              ),
              SettingCard(
                title: 'Privacy Policy',
                leadingIcon: SvgPicture.asset(privacyPolicy, height: 24.h, width: 24.w),
                onTap: () {
                  // Get.toNamed('/privacy');
                },
              ),
              SettingCard(
                title: 'Logout',
                leadingIcon: SvgPicture.asset(logout, height: 24.h, width: 24.w),
                onTap: () {
                  showDialog(
                    context: context,
                    builder: (context) {
                      return AlertDialog(
                        title: Text('Logout',style: lLastTextStyle16700,),
                        content: Text('Are you sure you want to logout?',style: lLastTextStyle16500,),
                        actions: [
                          TextButton(
                            onPressed: () {
                              Navigator.of(context).pop(); // Close the dialog
                            },
                            child: Text('No',style: lLastTextStyle16500,),
                          ),
                          TextButton(
                            onPressed: () {
                            controller.logout();
                            },
                            child: Text('Yes',style: lLastTextStyle16500,),
                          ),
                        ],
                      );
                    },
                  );
                  // Get.toNamed('/logout');
                },
              ),
            ],
          ),
        ),
      ),
    );
  }
}
