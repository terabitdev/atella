import 'package:atella/Modules/RefiningConcept/controllers/refining_concept_controller.dart';
import 'package:get/get.dart';

class RefiningConceptBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut<RefiningConceptController>(() => RefiningConceptController());
  }
}
