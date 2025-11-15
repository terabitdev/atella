import 'package:atella/Data/api/openai_service.dart';
import 'package:atella/Modules/Home/Controllers/profile_controller.dart';
import 'package:atella/Widgets/setting_card.dart';
import 'package:atella/core/themes/app_fonts.dart';
import 'package:atella/services/manufacture_services/manufacturer_firebase_service.dart';
import 'package:atella/services/manufacture_services/manufacturer_service.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';

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
      backgroundColor: Colors.black,
      body: SafeArea(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Padding(
              padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 12.h),
              child: Row(
                children: [
                  SizedBox(width: 8.w),
                  Text('Settings', style: ssTitleTextTextStyle208001),
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
                        title: 'Personal Information',
                        onTap: () {
                          Get.toNamed('/profile');
                        },
                      ),
                      SettingCard(
                        title: 'Subscription Plan',
                        onTap: () {
                          Get.toNamed('/subscribe');
                        },
                      ),
                      SettingCard(
                        title: 'Terms of use',
                        onTap: () {
                          // Get.toNamed('/terms');
                        },
                      ),
                      SettingCard(
                        title: 'Privacy Policy',
                        onTap: () {
                          // Get.toNamed('/terms');
                        },
                      ),
                      SettingCard(
                        title: 'Logout',
                        onTap: () {
                          showDialog(
                            context: context,
                            builder: (context) {
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
                                        "Are you sure you want to logout?",
                                        textAlign: TextAlign.center,
                                        style: lLastTextStyle16500,
                                      ),
                                      const SizedBox(height: 24),
                                      Row(
                                        children: [
                                          Expanded(
                                            child: OutlinedButton(
                                              style: OutlinedButton.styleFrom(
                                                foregroundColor: Colors.black,
                                                side: BorderSide(
                                                  color: Colors.black,
                                                ),
                                              ),
                                              onPressed: () {
                                                Navigator.of(context).pop();
                                              },
                                              child: Text(
                                                "Cancel",
                                                style: lLastTextStyle16500,
                                              ),
                                            ),
                                          ),
                                          const SizedBox(width: 8),
                                          Expanded(
                                            child: ElevatedButton(
                                              style: ElevatedButton.styleFrom(
                                                backgroundColor: Colors.black,
                                                foregroundColor: Colors.white,
                                              ),
                                              onPressed: () {
                                                controller.logout();
                                              },
                                              child: Text(
                                                "Logout",
                                                style: lLastTextStyle16500
                                                    .copyWith(
                                                      color: Colors.white,
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
}
