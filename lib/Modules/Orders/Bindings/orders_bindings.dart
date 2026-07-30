import 'package:atella/Modules/Orders/Controllers/order_checkout_controller.dart';
import 'package:atella/Modules/Orders/Controllers/order_list_controller.dart';
import 'package:atella/Modules/Orders/Controllers/order_tracking_controller.dart';
import 'package:atella/Modules/Orders/Controllers/sample_order_form_controller.dart';
import 'package:get/get.dart';

class SampleOrderFormBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut<SampleOrderFormController>(() => SampleOrderFormController());
  }
}

class OrderCheckoutBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut<OrderCheckoutController>(() => OrderCheckoutController());
  }
}

class OrderTrackingBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut<OrderTrackingController>(() => OrderTrackingController());
  }
}

class OrderListBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut<OrderListController>(() => OrderListController());
  }
}
