import 'package:atella/Modules/Home/Controllers/navbar_controller.dart';
import 'package:atella/core/constants/app_iamges.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';

class Custom_NavigationBar extends StatefulWidget {
  const Custom_NavigationBar({super.key});

  @override
  State<Custom_NavigationBar> createState() => _Custom_NavigationBarState();
}

class _Custom_NavigationBarState extends State<Custom_NavigationBar> {
  final controller = Get.put(NavBarController());

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Obx(() => controller.Screens[controller.selectedindex.value]),
      bottomNavigationBar: Obx(
        () => Container(
          color: Colors.white,
          child: NavigationBar(
            backgroundColor: Colors.transparent,
            elevation: 0,
            height: 60.h,
            selectedIndex: controller.selectedindex.value,
            onDestinationSelected: (index) {
              controller.selectedindex.value = index;
            },
            indicatorColor: Colors.transparent, // Optional highlight effect
            destinations: [
              NavigationDestination(
                icon: Image.asset(homeIcon, height: 30.h),
                label: 'Home',
              ),
              NavigationDestination(
                icon: Image.asset(createIcon, height: 30.h),
                label: 'Create',
              ),
              NavigationDestination(
                icon: Image.asset(profileIcon, height: 30.h),
                label: 'Profile',
              ),
            ],
          ),
        ),
      ),
    );
  }
}
