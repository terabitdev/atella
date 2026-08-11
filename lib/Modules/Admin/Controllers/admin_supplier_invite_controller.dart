import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import 'package:image_picker/image_picker.dart';
import 'package:atella/Data/Models/supplier_model.dart';
import 'package:atella/core/utils/app_snackbar.dart';
import 'package:atella/services/firebase/services/supplier_admin_service.dart';

class AdminSupplierInviteController extends GetxController {
  final SupplierAdminService _service = SupplierAdminService();

  final companyNameController = TextEditingController();
  final emailController = TextEditingController();
  final specialtyController = TextEditingController();
  final originCountryController = TextEditingController();
  final descriptionController = TextEditingController();

  final RxString logoLocalPath = ''.obs;
  final RxBool isSubmitting = false.obs;

  /// Which pending invite's link is currently expanded/visible in the list.
  /// Persisted here (not a one-shot banner) so a generated link stays
  /// re-viewable and copyable for as long as the invite is still pending.
  final RxString expandedInviteId = ''.obs;

  Stream<List<SupplierInviteModel>> get invitesStream => _service.streamInvites();

  void toggleExpanded(String inviteId) {
    expandedInviteId.value = expandedInviteId.value == inviteId ? '' : inviteId;
  }

  Future<void> pickLogo() async {
    try {
      final picker = ImagePicker();
      final image = await picker.pickImage(source: ImageSource.gallery, imageQuality: 85);
      if (image != null) {
        logoLocalPath.value = image.path;
      }
    } catch (e) {
      showAppSnackbar('Error', 'Failed to pick image', backgroundColor: Colors.red, colorText: Colors.white);
    }
  }

  void removeLogo() => logoLocalPath.value = '';

  Future<void> sendInvite() async {
    final companyName = companyNameController.text.trim();
    final email = emailController.text.trim();

    if (companyName.isEmpty) {
      showAppSnackbar('Missing info', 'Company name is required', backgroundColor: Colors.red, colorText: Colors.white);
      return;
    }
    if (email.isEmpty || !GetUtils.isEmail(email)) {
      showAppSnackbar('Missing info', 'Enter a valid contact email', backgroundColor: Colors.red, colorText: Colors.white);
      return;
    }

    isSubmitting.value = true;
    try {
      String? logoUrl;
      if (logoLocalPath.value.isNotEmpty) {
        logoUrl = await _service.uploadSupplierLogo(logoLocalPath.value);
      }

      final result = await _service.createSupplierInvite(
        companyName: companyName,
        email: email,
        specialty: specialtyController.text.trim().isEmpty ? null : specialtyController.text.trim(),
        originCountry: originCountryController.text.trim().isEmpty ? null : originCountryController.text.trim(),
        description: descriptionController.text.trim().isEmpty ? null : descriptionController.text.trim(),
        logoUrl: logoUrl,
      );

      expandedInviteId.value = result['inviteId'] as String? ?? '';

      _clearForm();
      showAppSnackbar('Invite created', 'Copy the link below and send it to the manufacturer', backgroundColor: Colors.black, colorText: Colors.white);
    } catch (e) {
      showAppSnackbar('Error', 'Failed to create invite: ${e.toString()}', backgroundColor: Colors.red, colorText: Colors.white);
    } finally {
      isSubmitting.value = false;
    }
  }

  Future<void> copyInviteLink(String link) async {
    await Clipboard.setData(ClipboardData(text: link));
    showAppSnackbar('Copied', 'Invite link copied to clipboard', backgroundColor: Colors.black, colorText: Colors.white);
  }

  Future<void> revokeInvite(String inviteId) async {
    try {
      await _service.revokeSupplierInvite(inviteId);
      showAppSnackbar('Revoked', 'Invite has been revoked', backgroundColor: Colors.black, colorText: Colors.white);
    } catch (e) {
      showAppSnackbar('Error', 'Failed to revoke invite', backgroundColor: Colors.red, colorText: Colors.white);
    }
  }

  void _clearForm() {
    companyNameController.clear();
    emailController.clear();
    specialtyController.clear();
    originCountryController.clear();
    descriptionController.clear();
    logoLocalPath.value = '';
  }

  @override
  void onClose() {
    companyNameController.dispose();
    emailController.dispose();
    specialtyController.dispose();
    originCountryController.dispose();
    descriptionController.dispose();
    super.onClose();
  }
}
