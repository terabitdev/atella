// subscribe_binding.dart
import 'package:get/get.dart';
import 'package:atella/modules/home/Controllers/subscribe_controller.dart';

class SubscribeBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut<SubscribeController>(() => SubscribeController());
  }
}
