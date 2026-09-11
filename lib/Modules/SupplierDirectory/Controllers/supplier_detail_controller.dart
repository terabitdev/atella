import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:atella/Data/Models/supplier_model.dart';
import 'package:atella/Data/Models/tech_pack_model.dart';
import 'package:atella/Modules/SupplierDirectory/View/Widgets/manufacturer_upgrade_dialog.dart';
import 'package:atella/Routes/app_routes.dart';
import 'package:atella/core/utils/app_snackbar.dart';
import 'package:atella/services/PaymentService/subscription_manager_service.dart';
import 'package:atella/services/firebase/services/messaging_service.dart';
import 'package:atella/services/firebase/techpack/tech_pack_service.dart';
import 'package:atella/services/firebase/services/supplier_submission_service.dart';
import 'package:atella/services/analytics/appsflyer_analytics_service.dart';

class SupplierDetailController extends GetxController {
  final SupplierSubmissionService _service = SupplierSubmissionService();
  final MessagingService _messagingService = MessagingService();
  final SubscriptionManagerService _subscriptionService = SubscriptionManagerService();

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

  /// Send button entry point. Gates on subscription first (Freemium users
  /// can view supplier profiles but not contact them), then resolves which
  /// tech pack to send — either the one already carried forward from a
  /// tech-pack-first flow, or one the user picks now (when reached via the
  /// Factory tab, which has no tech pack context yet).
  Future<void> onSendPressed() async {
    final canSend = await _subscriptionService.canUsePremiumFeature('manufacturers');
    if (!canSend) {
      final context = Get.context;
      if (context != null) {
        showDialog(context: context, builder: (_) => const ManufacturerUpgradeDialog());
      }
      return;
    }

    if (techPackId == null) {
      final picked = await Get.toNamed(AppRoutes.myDesigns, arguments: {'selectionMode': true});
      if (picked is! TechPackModel) return;
      techPackId = picked.id;
      techPackProjectName = picked.projectName;
      techPackImageUrl = picked.displayImage;
    }

    await sendTechPack();
  }

  Future<void> sendTechPack() async {
    if (techPackId == null) {
      showAppSnackbar('No tech pack selected', 'Open this supplier from a tech pack to send it.', backgroundColor: Colors.red, colorText: Colors.white);
      return;
    }

    isSending.value = true;
    try {
      // Snapshot the full tech pack (all images, collection, etc.) now,
      // while we're still on the owner's own account — the shared chat
      // message carries this snapshot so the supplier can view/download/
      // share every image without needing read access to the owner's data.
      final fullTechPack = await TechPackService.getTechPackById(techPackId!);

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
        techPackId: techPackId,
        techPackSnapshot: fullTechPack?.toMap(),
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
