import 'package:get/get.dart';
import '../controllers/tech_pack_details_controller.dart';

class TechPackBinding extends Bindings {
  @override
  void dependencies() {
    // Use lazyPut with fenix: true to keep controller alive even when removed from memory
    Get.lazyPut<TechPackDetailsController>(
      () => TechPackDetailsController(),
      fenix: true, // This recreates the controller when accessed after disposal
    );
  }
}