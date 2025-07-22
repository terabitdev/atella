import 'package:atella/core/constants/app_images.dart';
import 'package:atella/core/services/splash_services.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({Key? key}) : super(key: key);

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  final SplashServices splashServices = SplashServices();

  @override
  void initState() {
    super.initState();
    splashServices.navigateToHome(context);
  }

  @override
  Widget build(BuildContext context) {
    SystemChrome.setSystemUIOverlayStyle(
      const SystemUiOverlayStyle(
        statusBarColor: Colors.transparent,
        statusBarIconBrightness: Brightness.light,
        statusBarBrightness: Brightness.dark,
      ),
    );

    return Scaffold(
      body: Container(
        width: double.infinity,
        height: double.infinity,
        color: Colors.white,
        child: SafeArea(
          child: Center(
            // 👈 Center the Row vertically and horizontally
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Image.asset(logo, width: 34.w, height: 54.h),
                SizedBox(width: 12.w), // 👈 Space between logo and text
                // Text('Atella', style: SSTextStyle42900),
                Image.asset(
                  'assets/images/title.png',
                  width: 160.w, // Adjust width as needed
                  height: 48.h, // Adjust height as needed
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
