// subscribe_binding.dart
import 'package:get/get.dart';
import 'package:atella/Modules/Home/controllers/subscribe_controller.dart';

class SubscribeBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut<SubscribeController>(() => SubscribeController());
  }
}
