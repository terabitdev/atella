import 'package:cloud_functions/cloud_functions.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:atella/core/utils/app_snackbar.dart';
import 'package:atella/services/firebase/services/orders_service.dart';

class SampleOrderFormController extends GetxController {
  final OrdersService _service = OrdersService();

  final amountController = TextEditingController();
  final descriptionController = TextEditingController();
  final RxBool isSubmitting = false.obs;

  late final String conversationId;

  @override
  void onInit() {
    super.onInit();
    final args = Get.arguments;
    conversationId = (args is Map && args['conversationId'] is String) ? args['conversationId'] as String : '';
  }

  Future<void> submit() async {
    final amount = double.tryParse(amountController.text.trim());
    if (amount == null || amount <= 0) {
      showAppSnackbar('Invalid amount', 'Enter a valid sample price', backgroundColor: Colors.red, colorText: Colors.white);
      return;
    }
    if (conversationId.isEmpty) {
      showAppSnackbar('Error', 'No conversation selected', backgroundColor: Colors.red, colorText: Colors.white);
      return;
    }

    isSubmitting.value = true;
    try {
      await _service.createSampleOrderForm(
        conversationId: conversationId,
        amountTotal: (amount * 100).round(),
        description: descriptionController.text.trim().isEmpty ? null : descriptionController.text.trim(),
      );
      showAppSnackbar('Sent', 'Sample order form sent to the designer', backgroundColor: Colors.black, colorText: Colors.white);
      Get.back();
    } on FirebaseFunctionsException catch (e) {
      debugPrint('createSampleOrderForm failed: code=${e.code} message=${e.message} details=${e.details}');
      showAppSnackbar('Error', e.message ?? 'Something went wrong (${e.code})', backgroundColor: Colors.red, colorText: Colors.white);
    } catch (e) {
      debugPrint('createSampleOrderForm failed: $e');
      showAppSnackbar('Error', e.toString().replaceFirst('Exception: ', ''), backgroundColor: Colors.red, colorText: Colors.white);
    } finally {
      isSubmitting.value = false;
    }
  }

  @override
  void onClose() {
    amountController.dispose();
    descriptionController.dispose();
    super.onClose();
  }
}
