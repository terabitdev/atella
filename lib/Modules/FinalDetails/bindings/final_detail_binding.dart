import 'package:atella/Modules/FinalDetails/controllers/final_detail_controller.dart';
import 'package:get/get.dart';

class FinalDetailsBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut<FinalDetailsController>(() => FinalDetailsController());
  }
}
