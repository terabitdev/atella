import 'package:atella/Modules/Home/Controllers/profile_controller.dart';
import 'package:atella/Widgets/setting_card.dart';
import 'package:atella/core/themes/app_fonts.dart';
import 'package:atella/core/themes/app_colors.dart';
import 'package:atella/core/constants/app_images.dart';
import 'package:atella/l10n/generated/app_localizations.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:atella/core/controllers/locale_controller.dart';

class SettingScreen extends StatefulWidget {
  const SettingScreen({super.key});

  @override
  State<SettingScreen> createState() => _SettingScreenState();
}

class _SettingScreenState extends State<SettingScreen> {
  final ProfileController controller = Get.put(ProfileController());
  // Use Get.put to ensure LocaleController is available, or reuse existing one
  final LocaleController localeController = Get.put(
    LocaleController(),
    permanent: true,
  );
  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    return Scaffold(
      backgroundColor: Colors.black,
      resizeToAvoidBottomInset: false,
      body: SafeArea(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Padding(
              padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 12.h),
              child: Row(
                children: [
                  SizedBox(width: 8.w),
                  Expanded(
                    child: Text(
                      l10n.settings,
                      style: ssTitleTextTextStyle208001,
                    ),
                  ),
                  Builder(
                    builder: (context) {
                      // Get current locale from context (reflects phone language changes)
                      final currentLocale = Localizations.localeOf(
                        context,
                      ).languageCode;
                      final isFrench = currentLocale == 'fr';

                      return GestureDetector(
                        onTap: () => _showLanguageDialog(context, l10n),
                        child: Container(
                          padding: EdgeInsets.symmetric(
                            horizontal: 12.w,
                            vertical: 8.h,
                          ),
                          decoration: BoxDecoration(
                            color: Colors.white.withValues(alpha: 0.15),
                            borderRadius: BorderRadius.circular(20.r),
                            border: Border.all(
                              color: Colors.white.withValues(alpha: 0.3),
                              width: 1,
                            ),
                          ),
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Icon(
                                Icons.language,
                                size: 18.sp,
                                color: Colors.white,
                              ),
                              SizedBox(width: 6.w),
                              Text(
                                isFrench ? 'FR' : 'EN',
                                style: TextStyle(
                                  fontSize: 13.sp,
                                  fontWeight: FontWeight.w600,
                                  color: Colors.white,
                                ),
                              ),
                            ],
                          ),
                        ),
                      );
                    },
                  ),
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
                child: Padding(
                  padding: EdgeInsets.symmetric(
                    horizontal: 24.w,
                    vertical: 30.h,
                  ),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.start,
                    children: [
                      SettingCard(
                        title: l10n.personalInformation,
                        onTap: () {
                          Get.toNamed('/profile');
                        },
                      ),
                      SettingCard(
                        title: l10n.subscriptionPlan,
                        onTap: () {
                          Get.toNamed('/subscribe');
                        },
                      ),
                      SettingCard(
                        title: l10n.termsAndConditions,
                        onTap: () {
                          Get.toNamed('/terms');
                        },
                      ),
                      SettingCard(
                        title: l10n.privacyPolicy,
                        onTap: () {
                          Get.toNamed('/privacy');
                        },
                      ),
                      SettingCard(
                        title: l10n.deleteAccount,
                        textColor: Colors.red,
                        onTap: () {
                          _showDeleteAccountDialog(context, l10n);
                        },
                      ),
                      SettingCard(
                        title: l10n.logout,
                        onTap: () {
                          showDialog(
                            context: context,
                            builder: (dialogContext) {
                              return Dialog(
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(12),
                                ),
                                child: Padding(
                                  padding: const EdgeInsets.symmetric(
                                    vertical: 20,
                                    horizontal: 16,
                                  ),
                                  child: Column(
                                    mainAxisSize: MainAxisSize.min,
                                    children: [
                                      Text(
                                        l10n.logoutConfirmation,
                                        textAlign: TextAlign.center,
                                        style: lLastTextStyle16500,
                                      ),
                                      const SizedBox(height: 24),
                                      IntrinsicHeight(
                                        child: Row(
                                          children: [
                                            Expanded(
                                              child: OutlinedButton(
                                                style: OutlinedButton.styleFrom(
                                                  foregroundColor: Colors.black,
                                                  side: BorderSide(
                                                    color: Colors.black,
                                                  ),
                                                  padding: EdgeInsets.symmetric(
                                                    vertical: 12,
                                                    horizontal: 12,
                                                  ),
                                                ),
                                                onPressed: () {
                                                  Navigator.of(
                                                    dialogContext,
                                                  ).pop();
                                                },
                                                child: Text(
                                                  l10n.cancel,
                                                  textAlign: TextAlign.center,
                                                  style: lLastTextStyle16500
                                                      .copyWith(
                                                        fontSize: 14,
                                                        height: 1.2,
                                                      ),
                                                ),
                                              ),
                                            ),
                                            const SizedBox(width: 8),
                                            Expanded(
                                              child: ElevatedButton(
                                                style: ElevatedButton.styleFrom(
                                                  backgroundColor: Colors.black,
                                                  foregroundColor: Colors.white,
                                                  padding: EdgeInsets.symmetric(
                                                    vertical: 12,
                                                    horizontal: 12,
                                                  ),
                                                ),
                                                onPressed: () {
                                                  controller.logout();
                                                },
                                                child: Text(
                                                  l10n.logout,
                                                  textAlign: TextAlign.center,
                                                  style: lLastTextStyle16500
                                                      .copyWith(
                                                        color: Colors.white,
                                                        fontSize: 14,
                                                        height: 1.2,
                                                      ),
                                                ),
                                              ),
                                            ),
                                          ],
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              );
                            },
                          );
                        },
                      ),
                      // // Button to check database stats
                      // ElevatedButton(
                      //   onPressed: () async {
                      //     final firebaseService = ManufacturerFirebaseService();
                      //     final stats = await firebaseService
                      //         .getManufacturerCountByCountry();
                      //     print('📊 MANUFACTURER STATISTICS:');
                      //     stats.forEach((country, count) {
                      //       print('  $country: $count manufacturers');
                      //     });
                      //     print('Total countries: ${stats.length}');
                      //     if (stats.isNotEmpty) {
                      //       print(
                      //         'Total manufacturers: ${stats.values.reduce((a, b) => a + b)}',
                      //       );
                      //     }
                      //   },
                      //   child: Text('Check Database Stats'),
                      // ),
                      // SizedBox(height: 10),
                      // // Button to generate small-brand manufacturers
                      // ElevatedButton(
                      //   style: ElevatedButton.styleFrom(
                      //     backgroundColor: Colors.green,
                      //     foregroundColor: Colors.white,
                      //   ),
                      //   onPressed: () async {
                      //     // Load API key from .env file if not already in secure storage
                      //     String? apiKey = await OpenAIService.getApiKey();

                      //     if (apiKey == null || apiKey.isEmpty) {
                      //       // Try to get from .env file
                      //       final envKey = dotenv.env['OPENAI_API_KEY'];
                      //       if (envKey != null && envKey.isNotEmpty) {
                      //         await OpenAIService.setApiKey(envKey);
                      //         print('✅ Loaded API key from .env file');
                      //         apiKey = envKey;
                      //       } else {
                      //         print('⚠️ OpenAI API key not found in .env file!');
                      //         print('📝 Please add OPENAI_API_KEY to your .env file');
                      //         return;
                      //       }
                      //     }

                      //     print('🚀 Starting manufacturer generation...');
                      //     print('✅ API key found');

                      //     // ALL 51 countries from your database
                      //     final countries = [
                      //       // Already done - commenting out
                      //       // 'Pakistan',
                      //       // 'India',
                      //       // 'China',
                      //       // 'Bangladesh',
                      //       // 'Turkey',
                      //       // 'Italy',
                      //       // 'Portugal',
                      //       // 'Spain',
                      //       // 'Vietnam',
                      //       // 'USA',

                      //       // Remaining 41 countries
                      //       'Finland',
                      //       'Sweden',
                      //       'Germany',
                      //       'Switzerland',
                      //       'United Arab Emirates',
                      //       'Egypt',
                      //       'Greece',
                      //       'Indonesia',
                      //       'Czech Republic',
                      //       'Australia',
                      //       'Norway',
                      //       'Denmark',
                      //       'Sri Lanka',
                      //       'Romania',
                      //       'UK',
                      //       'Brazil',
                      //       'Canada',
                      //       'South Africa',
                      //       'Morocco',
                      //       'Jordan',
                      //       'France',
                      //       'Mexico',
                      //       'Hungary',
                      //       'Poland',
                      //       'Israel',
                      //       'Belgium',
                      //       'South Korea',
                      //       'Philippines',
                      //       'Netherlands',
                      //       'Japan',
                      //       'Nepal',
                      //       'Lebanon',
                      //       'Kuwait',
                      //       'Austria',
                      //       'Malaysia',
                      //       'Thailand',
                      //       'Oman',
                      //       'Singapore',
                      //       'Qatar',
                      //       'Kenya',
                      //       'Ghana',
                      //     ];

                      //     final firebaseService = ManufacturerFirebaseService();
                      //     final result = await firebaseService
                      //         .generateSmallBrandManufacturers(
                      //       countries: countries,
                      //       manufacturersPerCountry: 5,
                      //     );

                      //     print('\n📋 GENERATION RESULTS:');
                      //     print('   Success: ${result['success']}');
                      //     print('   Total Added: ${result['totalAdded']}');
                      //     print('   Total Failed: ${result['totalFailed']}');
                      //     print('   Country Results: ${result['countryResults']}');
                      //   },
                      //   child: Text('Generate Small-Brand Manufacturers'),
                      // ),
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

  void _showLanguageDialog(BuildContext context, AppLocalizations l10n) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return Dialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(20.r),
          ),
          child: Container(
            padding: EdgeInsets.all(24.r),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(20.r),
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Row(
                  children: [
                    Icon(
                      Icons.language,
                      color: AppColors.buttonColor,
                      size: 24.sp,
                    ),
                    SizedBox(width: 12.w),
                    Expanded(
                      child: Text(
                        l10n.selectLanguage,
                        style: TextStyle(
                          fontSize: 20.sp,
                          fontWeight: FontWeight.w700,
                          color: Colors.black,
                        ),
                      ),
                    ),
                  ],
                ),
                SizedBox(height: 24.h),
                // Use context locale for selection state
                Builder(
                  builder: (ctx) {
                    final currentLocale = Localizations.localeOf(
                      ctx,
                    ).languageCode;
                    return Column(
                      children: [
                        _buildLanguageOption(
                          context: context,
                          languageCode: 'en',
                          languageName: 'English',
                          flag: '🇬🇧',
                          isSelected: currentLocale == 'en',
                        ),
                        SizedBox(height: 12.h),
                        _buildLanguageOption(
                          context: context,
                          languageCode: 'fr',
                          languageName: 'Français',
                          flag: '🇫🇷',
                          isSelected: currentLocale == 'fr',
                        ),
                      ],
                    );
                  },
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildLanguageOption({
    required BuildContext context,
    required String languageCode,
    required String languageName,
    required String flag,
    required bool isSelected,
  }) {
    return InkWell(
      onTap: () async {
        await localeController.changeLocale(Locale(languageCode));
        if (context.mounted) {
          Navigator.of(context).pop();
        }
      },
      borderRadius: BorderRadius.circular(12.r),
      child: Container(
        padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 14.h),
        decoration: BoxDecoration(
          color: isSelected
              ? AppColors.buttonColor.withValues(alpha: 0.1)
              : Colors.grey.shade50,
          borderRadius: BorderRadius.circular(12.r),
          border: Border.all(
            color: isSelected ? AppColors.buttonColor : Colors.grey.shade300,
            width: isSelected ? 2 : 1,
          ),
        ),
        child: Row(
          children: [
            Text(flag, style: TextStyle(fontSize: 28.sp)),
            SizedBox(width: 16.w),
            Expanded(
              child: Text(
                languageName,
                style: TextStyle(
                  fontSize: 16.sp,
                  fontWeight: isSelected ? FontWeight.w600 : FontWeight.w500,
                  color: isSelected ? AppColors.buttonColor : Colors.black87,
                ),
              ),
            ),
            if (isSelected)
              Icon(
                Icons.check_circle,
                color: AppColors.buttonColor,
                size: 24.sp,
              )
            else
              Icon(
                Icons.circle_outlined,
                color: Colors.grey.shade400,
                size: 24.sp,
              ),
          ],
        ),
      ),
    );
  }

  void _showDeleteAccountDialog(BuildContext context, AppLocalizations l10n) {
    showDialog(
      context: context,
      builder: (BuildContext dialogContext) {
        return Dialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(20.r),
          ),
          child: Container(
            padding: EdgeInsets.all(24.r),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(20.r),
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                // Warning Icon
                Icon(Icons.warning_rounded, color: Colors.red, size: 60.sp),
                SizedBox(height: 20.h),

                // Title
                Text(
                  l10n.deleteAccountTitle,
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontSize: 20.sp,
                    fontWeight: FontWeight.w700,
                    color: Colors.black,
                  ),
                ),
                SizedBox(height: 16.h),

                // Warning Message
                Text(
                  l10n.deleteAccountWarning,
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontSize: 14.sp,
                    fontWeight: FontWeight.w500,
                    color: Colors.black87,
                    height: 1.5,
                  ),
                ),
                SizedBox(height: 24.h),

                // Action Buttons
                Column(
                  children: [
                    SizedBox(
                      width: double.infinity,
                      child: ElevatedButton(
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.red,
                          foregroundColor: Colors.white,
                          padding: EdgeInsets.symmetric(
                            vertical: 16.h,
                            horizontal: 20.w,
                          ),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12.r),
                          ),
                        ),
                        onPressed: () {
                          Navigator.of(dialogContext).pop();
                          _confirmDeleteAccount(context, l10n);
                        },
                        child: Text(
                          l10n.confirmDelete,
                          textAlign: TextAlign.center,
                          style: TextStyle(
                            fontSize: 15.sp,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),
                    ),
                    SizedBox(height: 12.h),
                    SizedBox(
                      width: double.infinity,
                      child: OutlinedButton(
                        style: OutlinedButton.styleFrom(
                          foregroundColor: Colors.black,
                          side: BorderSide(color: Colors.grey.shade300),
                          padding: EdgeInsets.symmetric(
                            vertical: 16.h,
                            horizontal: 20.w,
                          ),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12.r),
                          ),
                        ),
                        onPressed: () {
                          Navigator.of(dialogContext).pop();
                        },
                        child: Text(
                          l10n.cancelDelete,
                          textAlign: TextAlign.center,
                          style: TextStyle(
                            fontSize: 15.sp,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  void _confirmDeleteAccount(BuildContext context, AppLocalizations l10n) {
    if (controller.isGoogleUser()) {
      // Show Google confirmation dialog
      _showGoogleConfirmationDialog(context, l10n);
    } else if (controller.isAppleUser()) {
      // Show Apple confirmation dialog
      _showAppleConfirmationDialog(context, l10n);
    } else {
      // Navigate to password screen for email/password users
      Get.toNamed('/delete-account-password');
    }
  }

  void _showGoogleConfirmationDialog(
    BuildContext context,
    AppLocalizations l10n,
  ) {
    showDialog(
      context: context,
      builder: (BuildContext dialogContext) {
        return Dialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(20.r),
          ),
          child: Container(
            padding: EdgeInsets.all(24.r),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(20.r),
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                // Google Icon
                Image.asset(googleIcon, width: 48.w, height: 48.h),
                SizedBox(height: 20.h),

                // Title
                Text(
                  l10n.confirmWithGoogle,
                  style: TextStyle(
                    fontSize: 20.sp,
                    fontWeight: FontWeight.w700,
                    color: Colors.black,
                  ),
                ),
                SizedBox(height: 12.h),

                // Message
                Text(
                  l10n.signInWithGoogleToConfirm,
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontSize: 14.sp,
                    fontWeight: FontWeight.w500,
                    color: Colors.black87,
                  ),
                ),
                SizedBox(height: 24.h),

                // Action Buttons
                Column(
                  children: [
                    SizedBox(
                      width: double.infinity,
                      child: Obx(
                        () => ElevatedButton(
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.red,
                            foregroundColor: Colors.white,
                            padding: EdgeInsets.symmetric(
                              vertical: 16.h,
                              horizontal: 20.w,
                            ),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12.r),
                            ),
                          ),
                          onPressed: controller.isDeletingAccount.value
                              ? null
                              : () async {
                                  await controller.deleteAccountWithGoogle();
                                },
                          child: controller.isDeletingAccount.value
                              ? SizedBox(
                                  width: 20.w,
                                  height: 20.h,
                                  child: CircularProgressIndicator(
                                    strokeWidth: 2,
                                    valueColor: AlwaysStoppedAnimation<Color>(
                                      Colors.white,
                                    ),
                                  ),
                                )
                              : Text(
                                  l10n.continueWithGoogle,
                                  textAlign: TextAlign.center,
                                  style: TextStyle(
                                    fontSize: 15.sp,
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),
                        ),
                      ),
                    ),
                    SizedBox(height: 12.h),
                    SizedBox(
                      width: double.infinity,
                      child: OutlinedButton(
                        style: OutlinedButton.styleFrom(
                          foregroundColor: Colors.black,
                          side: BorderSide(color: Colors.grey.shade300),
                          padding: EdgeInsets.symmetric(
                            vertical: 16.h,
                            horizontal: 20.w,
                          ),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12.r),
                          ),
                        ),
                        onPressed: () {
                          Navigator.of(dialogContext).pop();
                        },
                        child: Text(
                          l10n.cancelDelete,
                          textAlign: TextAlign.center,
                          style: TextStyle(
                            fontSize: 15.sp,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  void _showAppleConfirmationDialog(
    BuildContext context,
    AppLocalizations l10n,
  ) {
    showDialog(
      context: context,
      builder: (BuildContext dialogContext) {
        return Dialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(20.r),
          ),
          child: Container(
            padding: EdgeInsets.all(24.r),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(20.r),
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                // Apple Icon
                Icon(
                  Icons.apple,
                  size: 48.sp,
                  color: Colors.black,
                ),
                SizedBox(height: 20.h),

                // Title
                Text(
                  l10n.confirmWithApple,
                  style: TextStyle(
                    fontSize: 20.sp,
                    fontWeight: FontWeight.w700,
                    color: Colors.black,
                  ),
                ),
                SizedBox(height: 12.h),

                // Message
                Text(
                  l10n.signInWithAppleToConfirm,
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontSize: 14.sp,
                    fontWeight: FontWeight.w500,
                    color: Colors.black87,
                  ),
                ),
                SizedBox(height: 24.h),

                // Action Buttons
                Column(
                  children: [
                    SizedBox(
                      width: double.infinity,
                      child: Obx(
                        () => ElevatedButton(
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.red,
                            foregroundColor: Colors.white,
                            padding: EdgeInsets.symmetric(
                              vertical: 16.h,
                              horizontal: 20.w,
                            ),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12.r),
                            ),
                          ),
                          onPressed: controller.isDeletingAccount.value
                              ? null
                              : () async {
                                  await controller.deleteAccountWithApple();
                                },
                          child: controller.isDeletingAccount.value
                              ? SizedBox(
                                  width: 20.w,
                                  height: 20.h,
                                  child: CircularProgressIndicator(
                                    strokeWidth: 2,
                                    valueColor: AlwaysStoppedAnimation<Color>(
                                      Colors.white,
                                    ),
                                  ),
                                )
                              : Text(
                                  l10n.continueWithApple,
                                  textAlign: TextAlign.center,
                                  style: TextStyle(
                                    fontSize: 15.sp,
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),
                        ),
                      ),
                    ),
                    SizedBox(height: 12.h),
                    SizedBox(
                      width: double.infinity,
                      child: OutlinedButton(
                        style: OutlinedButton.styleFrom(
                          foregroundColor: Colors.black,
                          side: BorderSide(color: Colors.grey.shade300),
                          padding: EdgeInsets.symmetric(
                            vertical: 16.h,
                            horizontal: 20.w,
                          ),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12.r),
                          ),
                        ),
                        onPressed: () {
                          Navigator.of(dialogContext).pop();
                        },
                        child: Text(
                          l10n.cancelDelete,
                          textAlign: TextAlign.center,
                          style: TextStyle(
                            fontSize: 15.sp,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}
