import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:atella/Data/Models/supplier_model.dart';
import 'package:atella/core/utils/app_snackbar.dart';
import 'package:atella/services/firebase/services/messaging_service.dart';
import 'package:atella/services/firebase/services/supplier_submission_service.dart';
import 'package:atella/services/analytics/appsflyer_analytics_service.dart';

class SupplierDetailController extends GetxController {
  final SupplierSubmissionService _service = SupplierSubmissionService();
  final MessagingService _messagingService = MessagingService();

  final Rxn<SupplierModel> supplier = Rxn<SupplierModel>();
  final RxBool isLoading = true.obs;
  final RxBool isSending = false.obs;
  final RxBool hasSent = false.obs;
  final RxString conversationId = ''.obs;

  late final String supplierId;
  String? techPackId;
  String? techPackProjectName;
  String? techPackImageUrl;

  @override
  void onInit() {
    super.onInit();
    final args = Get.arguments;
    final map = args is Map<String, dynamic> ? args : <String, dynamic>{};

    supplierId = map['supplierId'] as String? ?? '';
    techPackId = map['techPackId'] as String?;
    techPackProjectName = map['techPackProjectName'] as String?;
    techPackImageUrl = map['techPackImageUrl'] as String?;

    _load();
  }

  Future<void> _load() async {
    isLoading.value = true;
    supplier.value = await _service.getSupplier(supplierId);
    isLoading.value = false;
  }

  Future<void> sendTechPack() async {
    if (techPackId == null) {
      showAppSnackbar('No tech pack selected', 'Open this supplier from a tech pack to send it.', backgroundColor: Colors.red, colorText: Colors.white);
      return;
    }

    isSending.value = true;
    try {
      final submissionId = await _service.sendTechPackToSupplier(
        supplierId: supplierId,
        techPackId: techPackId!,
        techPackProjectName: techPackProjectName,
        techPackImageUrl: techPackImageUrl,
      );
      conversationId.value = await _messagingService.getOrCreateConversation(submissionId);
      await _messagingService.sendTechPackSharedMessage(
        conversationId.value,
        techPackProjectName: techPackProjectName,
        techPackImageUrl: techPackImageUrl,
      );
      hasSent.value = true;
      showAppSnackbar('Sent!', 'Your tech pack has been sent to ${supplier.value?.companyName ?? "the supplier"}.', backgroundColor: Colors.black, colorText: Colors.white);
      AppsFlyerAnalyticsService().trackContactedManufacturer();
    } catch (e) {
      showAppSnackbar('Error', 'Failed to send tech pack. Please try again.', backgroundColor: Colors.red, colorText: Colors.white);
    } finally {
      isSending.value = false;
    }
  }
}
