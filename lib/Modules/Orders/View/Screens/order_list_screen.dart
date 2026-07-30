import 'package:atella/Data/Models/order_model.dart';
import 'package:atella/Modules/Orders/Controllers/order_list_controller.dart';
import 'package:atella/Routes/app_routes.dart';
import 'package:atella/Widgets/app_header.dart';
import 'package:atella/core/themes/app_fonts.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';

class OrderListScreen extends StatelessWidget {
  const OrderListScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final controller = Get.find<OrderListController>();

    return Scaffold(
      body: SafeArea(
        child: Padding(
          padding: EdgeInsets.symmetric(horizontal: 20.w, vertical: 20.h),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const GlobalHeader(title: 'My Orders'),
              SizedBox(height: 16.h),
              Expanded(
                child: Obx(() {
                  if (controller.isLoading.value) {
                    return const Center(child: CircularProgressIndicator());
                  }
                  if (controller.orders.isEmpty) {
                    return Center(child: Text('No orders yet.', style: ssTitleTextTextStyle14400));
                  }
                  return ListView.separated(
                    itemCount: controller.orders.length,
                    separatorBuilder: (_, __) => SizedBox(height: 10.h),
                    itemBuilder: (context, index) {
                      final order = controller.orders[index];
                      return _OrderTile(order: order);
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

class _OrderTile extends StatelessWidget {
  final OrderModel order;
  const _OrderTile({required this.order});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () => Get.toNamed(AppRoutes.orderTracking, arguments: {'orderId': order.id}),
      child: Container(
        padding: EdgeInsets.all(12.w),
        decoration: BoxDecoration(
          border: Border.all(color: const Color(0xFFE9E9E9)),
          borderRadius: BorderRadius.circular(12.r),
        ),
        child: Row(
          children: [
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(order.companyName, style: gsTextStyle16600),
                  SizedBox(height: 4.h),
                  Text(
                    '${order.type == 'sample' ? 'Sample' : 'Production'} · \$${order.amountTotalDisplay.toStringAsFixed(2)}',
                    style: ssTitleTextTextStyle14400,
                  ),
                ],
              ),
            ),
            Text(order.status, style: ssTitleTextTextStyle14400.copyWith(color: Colors.grey[500])),
          ],
        ),
      ),
    );
  }
}
