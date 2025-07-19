import 'package:atella/core/constants/app_iamges.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import '../../../../core/themes/app_colors.dart';
import '../../../../core/themes/app_fonts.dart';
import '../../../../Widgets/custom_roundbutton.dart';
import '../Widgets/search_widget.dart';
import '../../Controllers/home_controller.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final HomeController controller = Get.put(HomeController());

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      resizeToAvoidBottomInset: true,
      backgroundColor: Colors.white,
      body: SafeArea(
        child: Padding(
          padding: EdgeInsets.symmetric(horizontal: 24.w),
          child: SingleChildScrollView(
            child: Column(
              children: [
                SizedBox(height: 20.h),

                SizedBox(width: 16.w),
                Center(
                  child: Image.asset(
                    logo,
                    height: 60.h,
                    width: 60.w,
                    fit: BoxFit.cover,
                  ),
                ),

                Align(
                  alignment: Alignment.centerLeft,
                  child: Container(
                    width: 48.w,
                    height: 48.w,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: Colors.grey.shade200,
                    ),
                    child: Image.asset(
                      imageUrlIcon,
                      fit: BoxFit.cover,
                      height: 35.w,
                      width: 35.w,
                    ),
                  ),
                ),

                SizedBox(height: 24.h),
                SearchWidget(
                  controller: controller.searchController,
                  onChanged: controller.onSearchChanged,
                ),

                SizedBox(height: 32.h),
                Image.asset(emptyImage, height: 200.h, width: 200.w),
                SizedBox(height: 25.h),
                Text(
                  'Turn your ideas into reality start your',
                  style: OSTextStyle165003,
                  textAlign: TextAlign.center,
                ),
                SizedBox(height: 4.h),
                Text(
                  'first design today',
                  style: OSTextStyle165003,
                  textAlign: TextAlign.center,
                ),

                SizedBox(height: 27.h),
                RoundButton(
                  title: 'Start New Project',
                  onTap: controller.startNewProject,
                  color: AppColors.splashcolor,
                  isloading: false,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
