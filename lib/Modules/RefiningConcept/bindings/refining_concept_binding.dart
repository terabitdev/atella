import 'package:atella/Modules/RefiningConcept/controllers/refining_concept_controller.dart';
import 'package:atella/firebase/services/design_data_service.dart';
import 'package:get/get.dart';

class RefiningConceptBinding extends Bindings {
  @override
  void dependencies() {
     Get.put<DesignDataService>(DesignDataService(), permanent: true);
    Get.lazyPut<RefiningConceptController>(() => RefiningConceptController());
  }
}
