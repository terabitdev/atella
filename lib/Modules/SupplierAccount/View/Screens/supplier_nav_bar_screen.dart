import 'package:atella/Modules/SupplierAccount/Controllers/supplier_nav_bar_controller.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';

/// Supplier equivalent of `lib/nav_bar.dart` — same bottom NavigationBar
/// pattern, 4 tabs instead of the customer app's 4.
class SupplierNavBarScreen extends StatelessWidget {
  const SupplierNavBarScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final controller = Get.put(SupplierNavBarController());

    return Scaffold(
      body: Obx(() => controller.screens[controller.selectedIndex.value]),
      bottomNavigationBar: Obx(
        () => Container(
          color: Colors.white,
          child: NavigationBar(
            backgroundColor: Colors.transparent,
            elevation: 0,
            height: 80.h,
            selectedIndex: controller.selectedIndex.value,
            onDestinationSelected: (index) {
              controller.selectedIndex.value = index;
            },
            indicatorColor: Colors.transparent,
            destinations: [
              NavigationDestination(
                icon: Icon(
                  Icons.dashboard_outlined,
                  color: controller.selectedIndex.value == 0 ? Colors.black : Colors.grey,
                ),
                selectedIcon: const Icon(Icons.dashboard, color: Colors.black),
                label: 'Dashboard',
              ),
              NavigationDestination(
                icon: Icon(
                  Icons.chat_bubble_outline,
                  color: controller.selectedIndex.value == 1 ? Colors.black : Colors.grey,
                ),
                selectedIcon: const Icon(Icons.chat_bubble, color: Colors.black),
                label: 'Messages',
              ),
              NavigationDestination(
                icon: Icon(
                  Icons.receipt_long_outlined,
                  color: controller.selectedIndex.value == 2 ? Colors.black : Colors.grey,
                ),
                selectedIcon: const Icon(Icons.receipt_long, color: Colors.black),
                label: 'Orders',
              ),
              NavigationDestination(
                icon: Icon(
                  Icons.person_outline,
                  color: controller.selectedIndex.value == 3 ? Colors.black : Colors.grey,
                ),
                selectedIcon: const Icon(Icons.person, color: Colors.black),
                label: 'Profile',
              ),
            ],
          ),
        ),
      ),
    );
  }
}
