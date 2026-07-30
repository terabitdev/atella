import 'dart:async';

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:image_picker/image_picker.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:atella/Data/Models/supplier_model.dart';
import 'package:atella/core/utils/app_snackbar.dart';
import 'package:atella/services/firebase/services/auth_service.dart';
import 'package:atella/services/firebase/services/supplier_account_service.dart';

class SupplierHomeController extends GetxController {
  final SupplierAccountService _service = SupplierAccountService();
  final AuthService _authService = AuthService();

  final Rxn<SupplierModel> supplier = Rxn<SupplierModel>();
  final RxBool isLoading = true.obs;
  final RxBool isSaving = false.obs;
  final RxBool isLaunchingOnboarding = false.obs;

  final companyNameController = TextEditingController();
  final specialtyController = TextEditingController();
  final originCountryController = TextEditingController();
  final descriptionController = TextEditingController();
  final RxString logoLocalPath = ''.obs;

  StreamSubscription<SupplierModel?>? _subscription;
  String? _supplierId;
  bool _formPopulated = false;

  @override
  void onInit() {
    super.onInit();
    _init();
  }

  Future<void> _init() async {
    final supplierId = await _service.mySupplierId;
    if (supplierId == null) {
      isLoading.value = false;
      return;
    }
    _supplierId = supplierId;

    _subscription = _service.streamSupplier(supplierId).listen((model) {
      supplier.value = model;
      isLoading.value = false;

      // Only pre-fill the edit form once, so a live update from the
      // Connect webhook doesn't clobber text the supplier is mid-typing.
      if (!_formPopulated && model != null) {
        companyNameController.text = model.companyName;
        specialtyController.text = model.specialty ?? '';
        originCountryController.text = model.originCountry ?? '';
        descriptionController.text = model.description ?? '';
        _formPopulated = true;
      }
    });
  }

  Future<void> pickLogo() async {
    try {
      final picker = ImagePicker();
      final image = await picker.pickImage(source: ImageSource.gallery, imageQuality: 85);
      if (image != null) logoLocalPath.value = image.path;
    } catch (e) {
      showAppSnackbar('Error', 'Failed to pick image', backgroundColor: Colors.red, colorText: Colors.white);
    }
  }

  Future<void> saveProfile() async {
    if (_supplierId == null) return;

    isSaving.value = true;
    try {
      String? logoUrl;
      if (logoLocalPath.value.isNotEmpty) {
        logoUrl = await _service.uploadLogo(_supplierId!, logoLocalPath.value);
      }

      await _service.updateProfile(
        _supplierId!,
        companyName: companyNameController.text.trim(),
        specialty: specialtyController.text.trim(),
        originCountry: originCountryController.text.trim(),
        description: descriptionController.text.trim(),
        logoUrl: logoUrl,
      );

      logoLocalPath.value = '';
      showAppSnackbar('Saved', 'Your profile has been updated', backgroundColor: Colors.black, colorText: Colors.white);
    } catch (e) {
      showAppSnackbar('Error', 'Failed to save profile', backgroundColor: Colors.red, colorText: Colors.white);
    } finally {
      isSaving.value = false;
    }
  }

  Future<void> startStripeOnboarding() async {
    isLaunchingOnboarding.value = true;
    try {
      final url = await _service.createConnectOnboardingLink();
      final uri = Uri.parse(url);
      if (!await launchUrl(uri, mode: LaunchMode.externalApplication)) {
        showAppSnackbar('Error', 'Could not open the Stripe onboarding page', backgroundColor: Colors.red, colorText: Colors.white);
      }
    } catch (e) {
      showAppSnackbar('Error', 'Failed to start Stripe onboarding', backgroundColor: Colors.red, colorText: Colors.white);
    } finally {
      isLaunchingOnboarding.value = false;
    }
  }

  Future<void> logout() async {
    await _authService.signOut();
    Get.offAllNamed('/login');
  }

  @override
  void onClose() {
    _subscription?.cancel();
    companyNameController.dispose();
    specialtyController.dispose();
    originCountryController.dispose();
    descriptionController.dispose();
    super.onClose();
  }
}
