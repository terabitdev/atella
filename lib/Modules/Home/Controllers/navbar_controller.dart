import 'package:atella/Modules/Home/View/Screens/create_screen.dart';
import 'package:atella/Modules/Home/View/Screens/favourite_screen.dart';
import 'package:atella/Modules/Home/View/Screens/home_screen.dart';
import 'package:atella/Modules/Home/View/Screens/setting_screen.dart';
import 'package:atella/Modules/SupplierDirectory/View/Screens/supplier_directory_screen.dart';
import 'package:get/get.dart';

class NavBarController extends GetxController {
  final Rx<int> selectedindex = 0.obs;
  static const String factoryControllerTag = 'factoryDirectoryController';

  final Screens = [
    const HomeScreen(),
    const CreateScreen(),
    const FavouriteScreen(),
    const SupplierDirectoryScreen(
      showBackButton: false,
      controllerTag: factoryControllerTag,
    ),
    const SettingScreen(),
  ];
}
