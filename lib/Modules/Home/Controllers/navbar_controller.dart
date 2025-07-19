import 'package:atella/Modules/Home/View/Screens/create_screen.dart';
import 'package:atella/Modules/Home/View/Screens/home_screen.dart';
import 'package:atella/Modules/Home/View/Screens/profile_screen.dart';
import 'package:get/get.dart';

class NavBarController extends GetxController {
  final Rx<int> selectedindex = 0.obs;

  final Screens = [
    const HomeScreen(),
    const CreateScreen(),
    const ProfileScreen(),
  ];
}
