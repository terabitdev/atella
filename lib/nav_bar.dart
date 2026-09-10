import 'package:atella/Modules/Home/Controllers/navbar_controller.dart';
import 'package:atella/Modules/SupplierDirectory/Controllers/supplier_directory_controller.dart';
import 'package:atella/core/constants/app_images.dart';
import 'package:atella/core/themes/app_colors.dart';
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
  void initState() {
    super.initState();
    // SupplierDirectoryScreen (embedded below as a tab body, not reached via
    // Get.toNamed) expects Get.find<SupplierDirectoryController>() to
    // already be registered — normally done by SupplierDirectoryBinding when
    // this screen is navigated to as its own route, which doesn't happen
    // here. Shared with any screen pushed on top of this tab (e.g. "Send to
    // Manufacturing Partner" from a saved design), so it must be permanent —
    // otherwise GetX can dispose it (and its searchController) whenever this
    // nav bar route is torn down/rebuilt elsewhere, crashing the still-active
    // pushed screen's TextField with "used after disposed".
    if (!Get.isRegistered<SupplierDirectoryController>(
      tag: NavBarController.factoryControllerTag,
    )) {
      Get.put(
        SupplierDirectoryController(),
        tag: NavBarController.factoryControllerTag,
        permanent: true,
      );
    }
  }

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
            height: 80.h,
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
                icon: Icon(
                  Icons.factory_outlined,
                  size: 25.sp,
                  color: controller.selectedindex.value == 3
                      ? AppColors.buttonColor
                      : Colors.grey,
                ),
                label: 'Factory',
              ),
              NavigationDestination(
                icon: SvgPicture.asset(
                  controller.selectedindex.value == 4 ? settingsFill : settings,
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
