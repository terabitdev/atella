import 'package:atella/Modules/SupplierAccount/Controllers/supplier_home_controller.dart';
import 'package:get/get.dart';

class SupplierHomeBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut<SupplierHomeController>(() => SupplierHomeController());
  }
}
