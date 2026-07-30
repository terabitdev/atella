import 'package:atella/Modules/Admin/Controllers/admin_supplier_invite_controller.dart';
import 'package:get/get.dart';

class AdminSupplierInviteBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut<AdminSupplierInviteController>(() => AdminSupplierInviteController());
  }
}
