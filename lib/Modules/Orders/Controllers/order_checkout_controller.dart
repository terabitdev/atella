import 'package:flutter/material.dart';
import 'package:flutter_stripe/flutter_stripe.dart';
import 'package:get/get.dart';
import 'package:atella/Data/Models/order_model.dart';
import 'package:atella/Routes/app_routes.dart';
import 'package:atella/core/utils/app_snackbar.dart';
import 'package:atella/services/PaymentService/order_payment_service.dart';
import 'package:atella/services/firebase/services/orders_service.dart';

class OrderCheckoutController extends GetxController {
  final OrdersService _service = OrdersService();
  final OrderPaymentService _paymentService = OrderPaymentService();

  final Rxn<OrderModel> order = Rxn<OrderModel>();
  final RxBool isLoading = true.obs;
  final RxBool isPaying = false.obs;

  final nameController = TextEditingController();
  final addressLine1Controller = TextEditingController();
  final addressLine2Controller = TextEditingController();
  final cityController = TextEditingController();
  final stateController = TextEditingController();
  final postalCodeController = TextEditingController();
  final countryController = TextEditingController();
  final phoneController = TextEditingController();

  late final String orderId;

  @override
  void onInit() {
    super.onInit();
    final args = Get.arguments;
    orderId = (args is Map && args['orderId'] is String) ? args['orderId'] as String : '';
    _load();
  }

  Future<void> _load() async {
    if (orderId.isEmpty) {
      isLoading.value = false;
      return;
    }
    order.value = await _service.getOrder(orderId);
    isLoading.value = false;
  }

  Future<void> payNow() async {
    if (nameController.text.trim().isEmpty ||
        addressLine1Controller.text.trim().isEmpty ||
        cityController.text.trim().isEmpty ||
        postalCodeController.text.trim().isEmpty ||
        countryController.text.trim().isEmpty ||
        phoneController.text.trim().isEmpty) {
      showAppSnackbar('Missing info', 'Please fill in all required shipping fields', backgroundColor: Colors.red, colorText: Colors.white);
      return;
    }

    isPaying.value = true;
    try {
      final shipping = ShippingInfo(
        name: nameController.text.trim(),
        addressLine1: addressLine1Controller.text.trim(),
        addressLine2: addressLine2Controller.text.trim().isEmpty ? null : addressLine2Controller.text.trim(),
        city: cityController.text.trim(),
        state: stateController.text.trim(),
        postalCode: postalCodeController.text.trim(),
        country: countryController.text.trim(),
        phone: phoneController.text.trim(),
      );

      final clientSecret = await _service.createOrderPaymentIntent(orderId: orderId, shipping: shipping);
      await _paymentService.payForOrder(clientSecret);

      showAppSnackbar('Payment successful', 'Your order is being processed', backgroundColor: Colors.black, colorText: Colors.white);
      Get.offNamed(AppRoutes.orderTracking, arguments: {'orderId': orderId});
    } on StripeException catch (e) {
      showAppSnackbar('Payment cancelled', e.error.localizedMessage ?? 'The payment was not completed', backgroundColor: Colors.red, colorText: Colors.white);
    } catch (e) {
      showAppSnackbar('Error', e.toString().replaceFirst('Exception: ', ''), backgroundColor: Colors.red, colorText: Colors.white);
    } finally {
      isPaying.value = false;
    }
  }

  @override
  void onClose() {
    nameController.dispose();
    addressLine1Controller.dispose();
    addressLine2Controller.dispose();
    cityController.dispose();
    stateController.dispose();
    postalCodeController.dispose();
    countryController.dispose();
    phoneController.dispose();
    super.onClose();
  }
}
