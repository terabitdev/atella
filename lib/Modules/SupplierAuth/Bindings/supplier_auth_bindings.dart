import 'package:atella/Modules/SupplierAuth/Controllers/supplier_invite_signup_controller.dart';
import 'package:get/get.dart';

class SupplierInviteSignupBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut<SupplierInviteSignupController>(() => SupplierInviteSignupController());
  }
}
