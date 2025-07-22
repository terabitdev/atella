import 'package:atella/Modules/Home/Controllers/navbar_controller.dart';
import 'package:atella/core/constants/app_images.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_svg/svg.dart';
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
                icon: SvgPicture.asset(
                  controller.selectedindex.value == 0 ? homeColorIcon : home,
                  height: 30.h,
                  width: 30.w,
                ),
                label: 'Home',
              ),
              NavigationDestination(
                icon: SvgPicture.asset(
                  controller.selectedindex.value == 1
                      ? createColorIcon
                      : createIcon,
                  height: 30.h,
                  width: 30.w,
                ),
                label: 'Create',
              ),
              NavigationDestination(
                icon: SvgPicture.asset(
                  controller.selectedindex.value == 2
                      ? profileColorIcon
                      : profileIcon,
                  height: 30.h,
                  width: 30.w,
                ),
                label: 'Profile',
              ),
            ],
          ),
        ),
      ),
    );
  }
}
