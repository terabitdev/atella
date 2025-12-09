import 'package:atella/Modules/Home/View/Widgets/profile_textField.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import '../../../../core/themes/app_colors.dart';
import '../../../../Widgets/app_header.dart';
import '../../../../Widgets/custom_roundbutton.dart';
import '../../../auth/View/Widgets/auth_textfield.dart';
import '../../Controllers/profile_controller.dart';
import 'package:atella/core/themes/app_fonts.dart';
import 'package:atella/services/analytics/posthog_analytics_service.dart';

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({super.key});

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
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
              GlobalHeader(title: 'Edit Profile', onBack: () => Get.back()),

              SizedBox(height: 40.h),

              // Form Fields
              // Full Name
              AuthTextField(
                label: 'Full Name',
                controller: controller.fullNameController,
              ),

              SizedBox(height: 20.h),

              ProfileTextfield(label: 'Email', controller: controller.emailController, enabled: false),

              SizedBox(height: 24.h),

              // ============================================================
              // FEATURE FLAG EXAMPLE: show_analytics_toggle
              // ============================================================
              // This demonstrates how to use PostHog feature flags to
              // conditionally show/hide UI elements.
              //
              // To create this flag in PostHog Dashboard:
              // 1. Go to Feature Flags → New feature flag
              // 2. Key: "show_analytics_toggle"
              // 3. Set rollout to 100% (or target specific users/cohorts)
              // 4. Save
              //
              // The flag defaults to TRUE if not found (safe fallback).
              // ============================================================
              FutureBuilder<bool>(
                future: PostHogAnalyticsService().isFeatureEnabled('show_analytics_toggle'),
                builder: (context, snapshot) {
                  // Debug: Log feature flag status
                  if (kDebugMode) {
                    debugPrint('PostHog Feature Flag [show_analytics_toggle]: '
                        'connectionState=${snapshot.connectionState}, '
                        'data=${snapshot.data}, '
                        'error=${snapshot.error}');
                  }

                  // Default to showing the toggle if flag check fails or is loading
                  final showToggle = snapshot.data ?? true;

                  if (!showToggle) {
                    return const SizedBox.shrink();
                  }

                  return Obx(() => Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Expanded(
                            child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  'Allow analytics',
                                  style: gsTextStyle16600,
                                ),
                                SizedBox(height: 6.h),
                                Text(
                                    'We record sessions to improve your experience. Turn this off to stop all analytics and recordings.',
                                    style: uiTextTextStyle13500.copyWith(
                                      color: Colors.grey[600],
                                    ),
                                  ),
                              ],
                              ),
                            ),
                            SizedBox(width: 28.w),
                          Switch(
                            activeColor: Colors.white,
                            activeTrackColor:
                                AppColors.buttonColor.withOpacity(0.25),
                            inactiveThumbColor: Colors.white,
                            inactiveTrackColor: Colors.grey.shade300,
                            thumbColor: WidgetStateProperty.resolveWith(
                              (states) =>
                                  states.contains(WidgetState.selected)
                                      ? AppColors.buttonColor
                                      : Colors.white,
                            ),
                            value: controller.analyticsOptIn.value,
                            onChanged: controller.toggleAnalyticsOptIn,
                          ),
                        ],
                      ));
                },
              ),

              Spacer(),
              Obx(
                () => RoundButton(
                  title: 'Update',
                  onTap: controller.updateProfile,
                  color: AppColors.buttonColor,
                  isloading: controller.isLoading.value,
                ),
              ),
              SizedBox(height: 40.h),
            ],
          ),
        ),
      ),
    );
  }
}
