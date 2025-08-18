import 'package:atella/modules/home/View/Screens/create_screen.dart';
import 'package:atella/modules/home/View/Screens/favourite_screen.dart';
import 'package:atella/modules/home/View/Screens/home_screen.dart';
import 'package:atella/modules/home/View/Screens/setting_screen.dart';
import 'package:get/get.dart';

class NavBarController extends GetxController {
  final Rx<int> selectedindex = 0.obs;

  final Screens = [
    const HomeScreen(),
    const CreateScreen(),
    const FavouriteScreen(),
    const SettingScreen(),
  ];
}
