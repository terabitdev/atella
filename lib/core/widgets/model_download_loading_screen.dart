import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

class ModelDownloadLoadingScreen extends StatelessWidget {
  const ModelDownloadLoadingScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      home: Scaffold(
        backgroundColor: Colors.white,
        body: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              // App logo or icon (optional)
              Icon(
                Icons.language,
                size: 80.sp,
                color: Colors.black87,
              ),
              SizedBox(height: 32.h),
              
              // Loading indicator
              SizedBox(
                width: 40.w,
                height: 40.h,
                child: const CircularProgressIndicator(
                  strokeWidth: 3,
                  valueColor: AlwaysStoppedAnimation<Color>(Colors.black87),
                ),
              ),
              SizedBox(height: 24.h),
              
              // Loading text
              Text(
                'Setting things up...',
                style: TextStyle(
                  fontSize: 18.sp,
                  fontWeight: FontWeight.w600,
                  color: Colors.black87,
                ),
              ),
              SizedBox(height: 8.h),
              
              // Subtitle
              Text(
                'Preparing language support',
                style: TextStyle(
                  fontSize: 14.sp,
                  color: Colors.black54,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
