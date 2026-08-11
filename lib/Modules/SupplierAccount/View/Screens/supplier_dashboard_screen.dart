import 'package:atella/Data/Models/order_model.dart';
import 'package:atella/Data/Models/supplier_submission_model.dart';
import 'package:atella/Modules/SupplierAccount/Controllers/supplier_home_controller.dart';
import 'package:atella/Routes/app_routes.dart';
import 'package:atella/Widgets/custom_roundbutton.dart';
import 'package:atella/core/themes/app_colors.dart';
import 'package:atella/core/themes/app_fonts.dart';
import 'package:atella/services/firebase/services/orders_service.dart';
import 'package:atella/services/firebase/services/supplier_submission_service.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';

/// Supplier bottom-nav tab 1 of 4 — greeting, Stripe payout status, and a
/// glance at recent orders + tech pack submissions.
class SupplierDashboardScreen extends StatelessWidget {
  const SupplierDashboardScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final controller = Get.find<SupplierHomeController>();

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
                child: Text(
                  "We couldn't find a supplier profile linked to this account.",
                  textAlign: TextAlign.center,
                  style: gsTextStyle16600,
                ),
              ),
            );
          }

          return SingleChildScrollView(
            padding: EdgeInsets.symmetric(horizontal: 20.w, vertical: 24.h),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('Welcome back', style: ssTitleTextTextStyle14400.copyWith(color: Colors.grey[500])),
                SizedBox(height: 4.h),
                Text(supplier.companyName, style: loginTextTextStyle22700),
                SizedBox(height: 24.h),
                _OnboardingStatusCard(controller: controller),
                SizedBox(height: 32.h),

                Text('Recent orders', style: gsTextStyle16600),
                SizedBox(height: 12.h),
                _RecentOrders(supplierOwnerUid: supplier.ownerUid ?? ''),

                SizedBox(height: 32.h),
                Text('Recent tech pack submissions', style: gsTextStyle16600),
                SizedBox(height: 12.h),
                _RecentSubmissions(supplierId: supplier.id),
                SizedBox(height: 24.h),
              ],
            ),
          );
        }),
      ),
    );
  }
}

class _OnboardingStatusCard extends StatelessWidget {
  final SupplierHomeController controller;
  const _OnboardingStatusCard({required this.controller});

  @override
  Widget build(BuildContext context) {
    final supplier = controller.supplier.value!;
    final complete = supplier.payoutsEnabled;

    return Container(
      width: double.infinity,
      padding: EdgeInsets.all(16.w),
      decoration: BoxDecoration(
        color: complete ? const Color(0xFFEFFAF0) : const Color(0xFFFFF8E8),
        borderRadius: BorderRadius.circular(12.r),
        border: Border.all(color: complete ? Colors.green.shade200 : Colors.orange.shade200),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(
                complete ? Icons.check_circle : Icons.info_outline,
                color: complete ? Colors.green : Colors.orange,
                size: 20.sp,
              ),
              SizedBox(width: 8.w),
              Text(
                complete ? 'Payouts enabled' : 'Payout setup required',
                style: gsTextStyle16600,
              ),
            ],
          ),
          SizedBox(height: 8.h),
          Text(
            complete
                ? 'Stripe has verified your account — you can now receive payments through Atella.'
                : 'Complete Stripe onboarding so you can receive payments for sample and production orders.',
            style: ssTitleTextTextStyle14400,
          ),
          if (!complete) ...[
            SizedBox(height: 14.h),
            Obx(
              () => RoundButton(
                title: controller.isLaunchingOnboarding.value ? 'Opening...' : 'Complete Stripe Onboarding',
                color: AppColors.buttonColor,
                isloading: controller.isLaunchingOnboarding.value,
                onTap: controller.isLaunchingOnboarding.value ? null : controller.startStripeOnboarding,
              ),
            ),
          ],
        ],
      ),
    );
  }
}

class _RecentOrders extends StatelessWidget {
  final String supplierOwnerUid;
  const _RecentOrders({required this.supplierOwnerUid});

  @override
  Widget build(BuildContext context) {
    if (supplierOwnerUid.isEmpty) {
      return Text('No orders yet.', style: ssTitleTextTextStyle14400.copyWith(color: Colors.grey[500]));
    }

    return StreamBuilder<List<OrderModel>>(
      stream: OrdersService().streamOrdersAsSupplier(supplierOwnerUid, limit: 5),
      builder: (context, snapshot) {
        if (!snapshot.hasData) {
          return const Padding(
            padding: EdgeInsets.symmetric(vertical: 12),
            child: Center(child: CircularProgressIndicator()),
          );
        }
        final orders = snapshot.data!;
        if (orders.isEmpty) {
          return Text('No orders yet.', style: ssTitleTextTextStyle14400.copyWith(color: Colors.grey[500]));
        }
        return Column(
          children: orders.map((order) => _OrderRow(order: order)).toList(),
        );
      },
    );
  }
}

class _OrderRow extends StatelessWidget {
  final OrderModel order;
  const _OrderRow({required this.order});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () => Get.toNamed(AppRoutes.orderTracking, arguments: {'orderId': order.id}),
      child: Container(
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
                  Text(order.userName, style: gsTextStyle16400),
                  SizedBox(height: 4.h),
                  Text(
                    '${order.type == 'sample' ? 'Sample' : 'Production'} · \$${order.amountTotalDisplay.toStringAsFixed(2)}',
                    style: ssTitleTextTextStyle14400.copyWith(color: Colors.grey[500]),
                  ),
                ],
              ),
            ),
            Text(order.status, style: ssTitleTextTextStyle14400),
          ],
        ),
      ),
    );
  }
}

class _RecentSubmissions extends StatelessWidget {
  final String supplierId;
  const _RecentSubmissions({required this.supplierId});

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<List<SupplierSubmissionModel>>(
      stream: SupplierSubmissionService().streamSubmissionsForSupplier(supplierId),
      builder: (context, snapshot) {
        if (!snapshot.hasData) {
          return const Padding(
            padding: EdgeInsets.symmetric(vertical: 12),
            child: Center(child: CircularProgressIndicator()),
          );
        }
        final submissions = snapshot.data!;
        if (submissions.isEmpty) {
          return Text('No tech pack submissions yet.', style: ssTitleTextTextStyle14400.copyWith(color: Colors.grey[500]));
        }
        return Column(
          children: submissions.map((s) => _SubmissionRow(submission: s)).toList(),
        );
      },
    );
  }
}

class _SubmissionRow extends StatelessWidget {
  final SupplierSubmissionModel submission;
  const _SubmissionRow({required this.submission});

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
          ClipRRect(
            borderRadius: BorderRadius.circular(8.r),
            child: (submission.techPackImageUrl != null && submission.techPackImageUrl!.isNotEmpty)
                ? CachedNetworkImage(
                    imageUrl: submission.techPackImageUrl!,
                    width: 44.w,
                    height: 44.w,
                    fit: BoxFit.cover,
                  )
                : Container(
                    width: 44.w,
                    height: 44.w,
                    color: const Color(0xFFF4F4F4),
                    child: Icon(Icons.description_outlined, color: Colors.grey[500], size: 20.sp),
                  ),
          ),
          SizedBox(width: 12.w),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(submission.techPackProjectName ?? 'Tech Pack', style: gsTextStyle16400),
                if (submission.createdAt != null) ...[
                  SizedBox(height: 4.h),
                  Text(
                    DateFormat('MMM d, yyyy').format(submission.createdAt!),
                    style: ssTitleTextTextStyle14400.copyWith(color: Colors.grey[500]),
                  ),
                ],
              ],
            ),
          ),
        ],
      ),
    );
  }
}
