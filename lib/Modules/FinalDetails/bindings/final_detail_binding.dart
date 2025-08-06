import 'package:atella/Modules/FinalDetails/controllers/final_detail_controller.dart';
import 'package:atella/firebase/services/design_data_service.dart';
import 'package:get/get.dart';

class FinalDetailsBinding extends Bindings {
  @override
  void dependencies() {
    // Register DesignDataService as a singleton if not already registered
    Get.put<DesignDataService>(DesignDataService(), permanent: true);
    
    Get.lazyPut<FinalDetailsController>(() => FinalDetailsController());
  }
}
