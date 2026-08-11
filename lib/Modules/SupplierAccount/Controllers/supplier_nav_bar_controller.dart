import 'package:atella/Modules/Messaging/View/Screens/conversation_list_screen.dart';
import 'package:atella/Modules/Orders/View/Screens/order_list_screen.dart';
import 'package:atella/Modules/SupplierAccount/View/Screens/supplier_dashboard_screen.dart';
import 'package:atella/Modules/SupplierAccount/View/Screens/supplier_profile_tab_screen.dart';
import 'package:get/get.dart';

class SupplierNavBarController extends GetxController {
  final Rx<int> selectedIndex = 0.obs;

  final screens = const [
    SupplierDashboardScreen(),
    ConversationListScreen(showBackButton: false),
    OrderListScreen(showBackButton: false),
    SupplierProfileTabScreen(),
  ];
}
