import 'package:atella/modules/home/Controllers/navbar_controller.dart';
import 'package:atella/core/constants/app_images.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_svg/svg.dart';
import 'package:get/get.dart';

class CustomNavigationBar extends StatefulWidget {
  const CustomNavigationBar({super.key});

  @override
  State<CustomNavigationBar> createState() => _CustomNavigationBarState();
}

class _CustomNavigationBarState extends State<CustomNavigationBar> {
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
                  height: 25.h,
                  width: 25.w,
                ),
                label: 'Home',
              ),
              NavigationDestination(
                icon: SvgPicture.asset(
                  controller.selectedindex.value == 1
                      ? createColorIcon
                      : createIcon,
                  height: 25.h,
                  width: 25.w,
                ),
                label: 'Create',
              ),
              NavigationDestination(
                icon: SvgPicture.asset(
                  controller.selectedindex.value == 2
                      ? favouriteColorIcon
                      : favouriteIcon,
                  height: 25.h,
                  width: 25.w,
                ),
                label: 'Favourite',
              ),
              NavigationDestination(
                icon: SvgPicture.asset(
                  controller.selectedindex.value == 3
                      ? settingsFill
                      : settings,
                  height: 25.h,
                  width: 25.w,
                ),
                label: 'Settings',
              ),
            ],
          ),
        ),
      ),
    );
  }
}
