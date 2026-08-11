import 'package:firebase_auth/firebase_auth.dart';
import 'package:get/get.dart';
import 'package:atella/Data/Models/order_model.dart';
import 'package:atella/services/firebase/services/orders_service.dart';

class OrderListController extends GetxController {
  final OrdersService _service = OrdersService();

  /// When set, overrides the `Get.arguments`-based detection below — needed
  /// when this controller is put explicitly for a statically-embedded tab
  /// (e.g. the supplier bottom nav bar) rather than reached via navigation.
  final bool? forceAsSupplier;

  OrderListController({this.forceAsSupplier});

  final RxList<OrderModel> orders = <OrderModel>[].obs;
  final RxBool isLoading = true.obs;
  late final bool asSupplier;

  @override
  void onInit() {
    super.onInit();
    final args = Get.arguments;
    asSupplier = forceAsSupplier ?? (args is Map && args['asSupplier'] == true);

    final uid = FirebaseAuth.instance.currentUser?.uid;
    if (uid == null) {
      isLoading.value = false;
      return;
    }

    final stream = asSupplier ? _service.streamOrdersAsSupplier(uid) : _service.streamOrdersAsBuyer(uid);
    stream.listen((list) {
      orders.assignAll(list);
      isLoading.value = false;
    });
  }
}
