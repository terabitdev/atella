import 'package:atella/Modules/SupplierDirectory/Controllers/supplier_detail_controller.dart';
import 'package:atella/Routes/app_routes.dart';
import 'package:atella/Widgets/app_header.dart';
import 'package:atella/Widgets/custom_roundbutton.dart';
import 'package:atella/core/themes/app_colors.dart';
import 'package:atella/core/themes/app_fonts.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';

class SupplierDetailScreen extends StatelessWidget {
  const SupplierDetailScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final controller = Get.find<SupplierDetailController>();

    return Scaffold(
      body: SafeArea(
        child: Obx(() {
          if (controller.isLoading.value) {
            return const Center(child: CircularProgressIndicator());
          }

          final supplier = controller.supplier.value;
          if (supplier == null) {
            return Center(
              child: Padding(
                padding: EdgeInsets.symmetric(horizontal: 24.w),
                child: Text("This supplier couldn't be found.", style: gsTextStyle16600),
              ),
            );
          }

          return SingleChildScrollView(
            padding: EdgeInsets.symmetric(horizontal: 20.w, vertical: 20.h),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const GlobalHeader(title: 'Supplier Profile'),
                SizedBox(height: 20.h),

                Center(
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(16.r),
                    child: (supplier.logoUrl != null && supplier.logoUrl!.isNotEmpty)
                        ? CachedNetworkImage(
                            imageUrl: supplier.logoUrl!,
                            width: 96.w,
                            height: 96.w,
                            fit: BoxFit.cover,
                          )
                        : Container(
                            width: 96.w,
                            height: 96.w,
                            color: const Color(0xFFF4F4F4),
                            child: Icon(Icons.factory_outlined, size: 36.sp, color: Colors.grey[500]),
                          ),
                  ),
                ),
                SizedBox(height: 16.h),
                Center(child: Text(supplier.companyName, style: loginTextTextStyle22700)),
                SizedBox(height: 20.h),

                if (supplier.specialty != null && supplier.specialty!.isNotEmpty)
                  _InfoRow(label: 'Specialty', value: supplier.specialty!),
                if (supplier.originCountry != null && supplier.originCountry!.isNotEmpty)
                  _InfoRow(label: 'Origin', value: supplier.originCountry!),
                if (supplier.description != null && supplier.description!.isNotEmpty) ...[
                  SizedBox(height: 12.h),
                  Text('About', style: gsTextStyle16600),
                  SizedBox(height: 6.h),
                  Text(supplier.description!, style: ssTitleTextTextStyle14400),
                ],

                SizedBox(height: 32.h),

                Obx(
                  () => Column(
                    children: [
                      RoundButton(
                        title: controller.hasSent.value
                            ? 'Sent ✓'
                            : (controller.isSending.value ? 'Sending...' : 'Send Tech Pack'),
                        color: controller.hasSent.value ? Colors.grey : AppColors.buttonColor,
                        isloading: controller.isSending.value,
                        onTap: (controller.isSending.value || controller.hasSent.value)
                            ? null
                            : controller.onSendPressed,
                      ),
                      if (controller.hasSent.value && controller.conversationId.value.isNotEmpty) ...[
                        SizedBox(height: 12.h),
                        RoundButton(
                          title: 'Message Supplier',
                          color: AppColors.buttonColor,
                          isloading: false,
                          onTap: () => Get.toNamed(
                            AppRoutes.chat,
                            arguments: {'conversationId': controller.conversationId.value},
                          ),
                        ),
                      ],
                    ],
                  ),
                ),
                SizedBox(height: 40.h),
              ],
            ),
          );
        }),
      ),
    );
  }
}

class _InfoRow extends StatelessWidget {
  final String label;
  final String value;
  const _InfoRow({required this.label, required this.value});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.only(bottom: 10.h),
      child: Row(
        children: [
          SizedBox(
            width: 90.w,
            child: Text(label, style: ssTitleTextTextStyle14400.copyWith(color: Colors.grey[500])),
          ),
          Expanded(child: Text(value, style: gsTextStyle16400)),
        ],
      ),
    );
  }
}
