import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:atella/Data/Models/supplier_model.dart';
import 'package:atella/services/firebase/services/supplier_submission_service.dart';

class SupplierDirectoryController extends GetxController {
  final SupplierSubmissionService _service = SupplierSubmissionService();

  final searchController = TextEditingController();
  final RxString searchQuery = ''.obs;
  final RxList<SupplierModel> _suppliers = <SupplierModel>[].obs;
  final RxBool isLoading = true.obs;

  // Carried forward to the detail screen so "Send Tech Pack" always knows
  // which tech pack this browsing session started from.
  late final Map<String, dynamic> techPackArgs;

  List<SupplierModel> get filteredSuppliers {
    final query = searchQuery.value.trim().toLowerCase();
    if (query.isEmpty) return _suppliers;
    return _suppliers.where((s) {
      return s.companyName.toLowerCase().contains(query) ||
          (s.specialty?.toLowerCase().contains(query) ?? false) ||
          (s.originCountry?.toLowerCase().contains(query) ?? false);
    }).toList();
  }

  @override
  void onInit() {
    super.onInit();
    final args = Get.arguments;
    techPackArgs = args is Map<String, dynamic> ? args : {};

    _service.streamActiveSuppliers().listen((suppliers) {
      _suppliers.assignAll(suppliers);
      isLoading.value = false;
    });
  }

  void onSearchChanged(String value) => searchQuery.value = value;

  @override
  void onClose() {
    searchController.dispose();
    super.onClose();
  }
}
