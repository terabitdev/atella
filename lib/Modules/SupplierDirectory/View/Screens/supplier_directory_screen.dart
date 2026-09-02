import 'package:atella/Data/Models/supplier_model.dart';
import 'package:atella/Modules/SupplierDirectory/Controllers/supplier_directory_controller.dart';
import 'package:atella/Routes/app_routes.dart';
import 'package:atella/Widgets/app_header.dart';
import 'package:atella/core/themes/app_fonts.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';

class SupplierDirectoryScreen extends StatelessWidget {
  // Embedded directly as the Factory tab body (no route push happens for
  // it there), so there's nothing for its back button to pop back to —
  // popping bubbles up and blanks the tab host screen behind it. When this
  // screen is instead pushed as its own route (from a saved design or a
  // generated tech pack's "Send to Manufacture"), the back button works
  // normally and must stay.
  final bool showBackButton;

  const SupplierDirectoryScreen({super.key, this.showBackButton = true});

  @override
  Widget build(BuildContext context) {
    final controller = Get.find<SupplierDirectoryController>();

    return Scaffold(
      body: SafeArea(
        child: Padding(
          padding: EdgeInsets.only(left: 20.w, right: 20.w, bottom: 20.h),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              GlobalHeader(
                title: 'Manufacturing Partners',
                showBackButton: showBackButton,
              ),
              SizedBox(height: 16.h),
              Container(
                height: 50.h,
                decoration: BoxDecoration(
                  color: const Color.fromRGBO(236, 239, 246, 1),
                  borderRadius: BorderRadius.circular(6.r),
                ),
                child: TextField(
                  controller: controller.searchController,
                  onChanged: controller.onSearchChanged,
                  style: osTextStyle165002,
                  decoration: InputDecoration(
                    hintText: 'Search by name, specialty, or country',
                    hintStyle: osTextStyle165002,
                    prefixIcon: const Icon(Icons.search),
                    border: InputBorder.none,
                    contentPadding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 12.h),
                  ),
                ),
              ),
              SizedBox(height: 16.h),
              Expanded(
                child: Obx(() {
                  if (controller.isLoading.value) {
                    return const Center(child: CircularProgressIndicator());
                  }
                  final suppliers = controller.filteredSuppliers;
                  if (suppliers.isEmpty) {
                    return Center(
                      child: Text(
                        'No manufacturing partners available yet.',
                        style: ssTitleTextTextStyle14400,
                      ),
                    );
                  }
                  return ListView.separated(
                    itemCount: suppliers.length,
                    separatorBuilder: (_, __) => SizedBox(height: 12.h),
                    itemBuilder: (context, index) {
                      final supplier = suppliers[index];
                      return _SupplierCard(
                        supplier: supplier,
                        onTap: () => Get.toNamed(
                          AppRoutes.supplierDetail,
                          arguments: {
                            'supplierId': supplier.id,
                            ...controller.techPackArgs,
                          },
                        ),
                      );
                    },
                  );
                }),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _SupplierCard extends StatelessWidget {
  final SupplierModel supplier;
  final VoidCallback onTap;

  const _SupplierCard({required this.supplier, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: EdgeInsets.all(12.w),
        decoration: BoxDecoration(
          border: Border.all(color: const Color(0xFFE9E9E9)),
          borderRadius: BorderRadius.circular(12.r),
        ),
        child: Row(
          children: [
            ClipRRect(
              borderRadius: BorderRadius.circular(10.r),
              child: (supplier.logoUrl != null && supplier.logoUrl!.isNotEmpty)
                  ? CachedNetworkImage(
                      imageUrl: supplier.logoUrl!,
                      width: 56.w,
                      height: 56.w,
                      fit: BoxFit.cover,
                    )
                  : Container(
                      width: 56.w,
                      height: 56.w,
                      color: const Color(0xFFF4F4F4),
                      child: Icon(Icons.factory_outlined, color: Colors.grey[500]),
                    ),
            ),
            SizedBox(width: 14.w),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(supplier.companyName, style: gsTextStyle16600),
                  if (supplier.specialty != null && supplier.specialty!.isNotEmpty) ...[
                    SizedBox(height: 4.h),
                    Text(supplier.specialty!, style: ssTitleTextTextStyle14400),
                  ],
                  if (supplier.originCountry != null && supplier.originCountry!.isNotEmpty) ...[
                    SizedBox(height: 2.h),
                    Text(supplier.originCountry!, style: ssTitleTextTextStyle14400.copyWith(color: Colors.grey[500])),
                  ],
                ],
              ),
            ),
            Icon(Icons.chevron_right, color: Colors.grey[400]),
          ],
        ),
      ),
    );
  }
}
