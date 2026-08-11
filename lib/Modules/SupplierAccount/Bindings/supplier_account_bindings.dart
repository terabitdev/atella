import 'package:atella/Modules/Messaging/Controllers/conversation_list_controller.dart';
import 'package:atella/Modules/Orders/Controllers/order_list_controller.dart';
import 'package:atella/Modules/SupplierAccount/Controllers/supplier_home_controller.dart';
import 'package:get/get.dart';

/// Provides every controller the supplier bottom-nav tabs need, since each
/// tab widget calls Get.find directly (no per-tab route/binding — same
/// pattern as the customer app's nav_bar.dart).
class SupplierNavBarBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut<SupplierHomeController>(() => SupplierHomeController());
    Get.lazyPut<ConversationListController>(() => ConversationListController());
    Get.lazyPut<OrderListController>(() => OrderListController(forceAsSupplier: true));
  }
}
