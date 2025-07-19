import 'package:get/get.dart';
import '../controllers/creative_brief_controller.dart';

class CreativeBriefBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut<CreativeBriefController>(() => CreativeBriefController());
  }
}
