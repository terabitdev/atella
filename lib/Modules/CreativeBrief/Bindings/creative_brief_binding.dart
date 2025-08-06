import 'package:atella/firebase/services/design_data_service.dart';
import 'package:get/get.dart';
import '../controllers/creative_brief_controller.dart';

class CreativeBriefBinding extends Bindings {
  @override
  void dependencies() {
     Get.put<DesignDataService>(DesignDataService(), permanent: true);
    Get.lazyPut<CreativeBriefController>(() => CreativeBriefController());
  }
}
