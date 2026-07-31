import 'dart:async';

import 'package:cloud_functions/cloud_functions.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:atella/Data/Models/order_model.dart';
import 'package:atella/core/utils/app_snackbar.dart';
import 'package:atella/services/firebase/services/orders_service.dart';

class OrderTrackingController extends GetxController {
  final OrdersService _service = OrdersService();

  final Rxn<OrderModel> order = Rxn<OrderModel>();
  final RxBool isLoading = true.obs;
  final RxBool isMarkingShipped = false.obs;

  final trackingNumberController = TextEditingController();
  final trackingCarrierController = TextEditingController();

  late final String orderId;
  StreamSubscription<OrderModel?>? _subscription;

  String get currentUid => FirebaseAuth.instance.currentUser?.uid ?? '';
  bool get isSupplierView => order.value != null && order.value!.supplierOwnerUid == currentUid;

  @override
  void onInit() {
    super.onInit();
    final args = Get.arguments;
    orderId = (args is Map && args['orderId'] is String) ? args['orderId'] as String : '';

    if (orderId.isEmpty) {
      isLoading.value = false;
      return;
    }

    _subscription = _service.streamOrder(orderId).listen((model) {
      order.value = model;
      isLoading.value = false;
    });
  }

  Future<void> markShipped() async {
    if (trackingNumberController.text.trim().isEmpty) {
      showAppSnackbar('Missing info', 'Enter a tracking number', backgroundColor: Colors.red, colorText: Colors.white);
      return;
    }

    isMarkingShipped.value = true;
    try {
      await _service.markOrderShipped(
        orderId: orderId,
        trackingNumber: trackingNumberController.text.trim(),
        trackingCarrier: trackingCarrierController.text.trim().isEmpty ? null : trackingCarrierController.text.trim(),
      );
      showAppSnackbar('Marked as shipped', 'The designer has been notified', backgroundColor: Colors.black, colorText: Colors.white);
    } on FirebaseFunctionsException catch (e) {
      debugPrint('markOrderShipped failed: code=${e.code} message=${e.message} details=${e.details}');
      showAppSnackbar('Error', e.message ?? 'Something went wrong (${e.code})', backgroundColor: Colors.red, colorText: Colors.white);
    } catch (e) {
      debugPrint('markOrderShipped failed: $e');
      showAppSnackbar('Error', e.toString().replaceFirst('Exception: ', ''), backgroundColor: Colors.red, colorText: Colors.white);
    } finally {
      isMarkingShipped.value = false;
    }
  }

  @override
  void onClose() {
    _subscription?.cancel();
    trackingNumberController.dispose();
    trackingCarrierController.dispose();
    super.onClose();
  }
}
