import 'package:atella/Modules/SupplierDirectory/Controllers/supplier_detail_controller.dart';
import 'package:atella/Modules/SupplierDirectory/Controllers/supplier_directory_controller.dart';
import 'package:get/get.dart';

class SupplierDirectoryBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut<SupplierDirectoryController>(() => SupplierDirectoryController());
  }
}

class SupplierDetailBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut<SupplierDetailController>(() => SupplierDetailController());
  }
}
