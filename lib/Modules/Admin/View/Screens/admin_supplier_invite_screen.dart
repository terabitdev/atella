import 'package:atella/Data/Models/supplier_model.dart';
import 'package:atella/Modules/Admin/Controllers/admin_supplier_invite_controller.dart';
import 'package:atella/Modules/Auth/View/Widgets/auth_textfield.dart';
import 'package:atella/Modules/creative_brief/Views/Widgets/image_upload_container.dart';
import 'package:atella/Widgets/app_header.dart';
import 'package:atella/Widgets/custom_roundbutton.dart';
import 'package:atella/core/themes/app_colors.dart';
import 'package:atella/core/themes/app_fonts.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';

class AdminSupplierInviteScreen extends StatelessWidget {
  const AdminSupplierInviteScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final controller = Get.find<AdminSupplierInviteController>();

    return Scaffold(
      body: SafeArea(
        child: SingleChildScrollView(
          padding: EdgeInsets.symmetric(horizontal: 20.w, vertical: 24.h),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const GlobalHeader(title: 'Invite a Manufacturer'),
              SizedBox(height: 24.h),
              Text(
                'Supplier accounts are invite-only. Fill in their profile below — '
                'they can only sign up using the private link this generates.',
                style: ssTitleTextTextStyle14400,
              ),
              SizedBox(height: 24.h),

              Obx(
                () => ImageUploadContainer(
                  initialImage: controller.logoLocalPath.value.isEmpty
                      ? null
                      : controller.logoLocalPath.value,
                  placeholder: 'Upload company logo (optional)',
                  onImageSelected: (path) {
                    if (path == null) {
                      controller.removeLogo();
                    } else {
                      controller.logoLocalPath.value = path;
                    }
                  },
                ),
              ),
              SizedBox(height: 20.h),

              AuthTextField(label: 'Company name', controller: controller.companyNameController),
              SizedBox(height: 16.h),
              AuthTextField(label: 'Contact email', controller: controller.emailController),
              SizedBox(height: 16.h),
              AuthTextField(label: 'Specialty (optional)', controller: controller.specialtyController),
              SizedBox(height: 16.h),
              AuthTextField(label: 'Origin country (optional)', controller: controller.originCountryController),
              SizedBox(height: 16.h),
              AuthTextField(label: 'Description (optional)', controller: controller.descriptionController),
              SizedBox(height: 24.h),

              Obx(
                () => RoundButton(
                  title: controller.isSubmitting.value ? 'Sending invite...' : 'Create & Send Invite',
                  color: AppColors.buttonColor,
                  isloading: controller.isSubmitting.value,
                  onTap: controller.isSubmitting.value ? null : controller.sendInvite,
                ),
              ),

              Obx(() {
                final link = controller.lastInviteLink.value;
                if (link.isEmpty) return const SizedBox.shrink();
                return Padding(
                  padding: EdgeInsets.only(top: 20.h),
                  child: Container(
                    width: double.infinity,
                    padding: EdgeInsets.all(14.w),
                    decoration: BoxDecoration(
                      color: const Color(0xFFF8F9FA),
                      borderRadius: BorderRadius.circular(10.r),
                      border: Border.all(color: const Color(0xFFE0E0E0)),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text('Invite link', style: gsTextStyle16600),
                        SizedBox(height: 6.h),
                        SelectableText(link, style: ssTitleTextTextStyle14400),
                        SizedBox(height: 10.h),
                        GestureDetector(
                          onTap: () => controller.copyInviteLink(link),
                          child: Text('Copy link', style: forgotTextTextStyle16500),
                        ),
                      ],
                    ),
                  ),
                );
              }),

              SizedBox(height: 32.h),
              Text('Sent invites', style: gsTextStyle16600),
              SizedBox(height: 12.h),
              StreamBuilder<List<SupplierInviteModel>>(
                stream: controller.invitesStream,
                builder: (context, snapshot) {
                  if (!snapshot.hasData) {
                    return const Padding(
                      padding: EdgeInsets.symmetric(vertical: 20),
                      child: Center(child: CircularProgressIndicator()),
                    );
                  }
                  final invites = snapshot.data!;
                  if (invites.isEmpty) {
                    return Text('No invites sent yet.', style: ssTitleTextTextStyle14400);
                  }
                  return Column(
                    children: invites
                        .map((invite) => _InviteTile(invite: invite, controller: controller))
                        .toList(),
                  );
                },
              ),
              SizedBox(height: 40.h),
            ],
          ),
        ),
      ),
    );
  }
}

class _InviteTile extends StatelessWidget {
  final SupplierInviteModel invite;
  final AdminSupplierInviteController controller;

  const _InviteTile({required this.invite, required this.controller});

  Color _statusColor() {
    switch (invite.status) {
      case 'accepted':
        return Colors.green;
      case 'revoked':
      case 'expired':
        return Colors.red;
      default:
        return Colors.orange;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: EdgeInsets.only(bottom: 10.h),
      padding: EdgeInsets.symmetric(horizontal: 14.w, vertical: 12.h),
      decoration: BoxDecoration(
        border: Border.all(color: const Color(0xFFE9E9E9)),
        borderRadius: BorderRadius.circular(10.r),
      ),
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(invite.email, style: gsTextStyle16400),
                SizedBox(height: 4.h),
                Text(
                  invite.status,
                  style: ssTitleTextTextStyle14400.copyWith(
                    color: _statusColor(),
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
            ),
          ),
          if (invite.status == 'pending')
            TextButton(
              onPressed: () => controller.revokeInvite(invite.id),
              child: const Text('Revoke', style: TextStyle(color: Colors.red)),
            ),
        ],
      ),
    );
  }
}
