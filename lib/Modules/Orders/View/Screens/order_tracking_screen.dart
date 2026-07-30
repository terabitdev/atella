import 'package:atella/Modules/Auth/View/Widgets/auth_textfield.dart';
import 'package:atella/Modules/Orders/Controllers/order_tracking_controller.dart';
import 'package:atella/Widgets/app_header.dart';
import 'package:atella/Widgets/custom_roundbutton.dart';
import 'package:atella/core/themes/app_colors.dart';
import 'package:atella/core/themes/app_fonts.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';

class OrderTrackingScreen extends StatelessWidget {
  const OrderTrackingScreen({super.key});

  static const _statusLabels = {
    'awaiting_payment': 'Awaiting payment',
    'paid': 'Paid — preparing',
    'shipped': 'Shipped',
    'delivered': 'Delivered',
    'cancelled': 'Cancelled',
    'refunded': 'Refunded',
  };

  Color _statusColor(String status) {
    switch (status) {
      case 'paid':
        return Colors.blue;
      case 'shipped':
      case 'delivered':
        return Colors.green;
      case 'cancelled':
      case 'refunded':
        return Colors.red;
      default:
        return Colors.orange;
    }
  }

  @override
  Widget build(BuildContext context) {
    final controller = Get.find<OrderTrackingController>();

    return Scaffold(
      body: SafeArea(
        child: Obx(() {
          if (controller.isLoading.value) {
            return const Center(child: CircularProgressIndicator());
          }

          final order = controller.order.value;
          if (order == null) {
            return Center(child: Text("This order couldn't be found.", style: gsTextStyle16600));
          }

          return SingleChildScrollView(
            padding: EdgeInsets.symmetric(horizontal: 20.w, vertical: 20.h),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                GlobalHeader(title: order.type == 'sample' ? 'Sample Order' : 'Production Order'),
                SizedBox(height: 20.h),

                Container(
                  padding: EdgeInsets.symmetric(horizontal: 12.w, vertical: 8.h),
                  decoration: BoxDecoration(
                    color: _statusColor(order.status).withOpacity(0.1),
                    borderRadius: BorderRadius.circular(20.r),
                  ),
                  child: Text(
                    _statusLabels[order.status] ?? order.status,
                    style: TextStyle(color: _statusColor(order.status), fontWeight: FontWeight.w600),
                  ),
                ),
                SizedBox(height: 20.h),

                Text(order.companyName, style: gsTextStyle16600),
                SizedBox(height: 4.h),
                Text('\$${order.amountTotalDisplay.toStringAsFixed(2)}', style: loginTextTextStyle22700),
                if (order.description != null) ...[
                  SizedBox(height: 8.h),
                  Text(order.description!, style: ssTitleTextTextStyle14400),
                ],

                if (order.shipping != null) ...[
                  SizedBox(height: 24.h),
                  Text('Shipping to', style: gsTextStyle16600),
                  SizedBox(height: 8.h),
                  Text(
                    '${order.shipping!.name}\n${order.shipping!.addressLine1}'
                    '${order.shipping!.addressLine2 != null ? '\n${order.shipping!.addressLine2}' : ''}\n'
                    '${order.shipping!.city}, ${order.shipping!.state} ${order.shipping!.postalCode}\n'
                    '${order.shipping!.country}\n${order.shipping!.phone}',
                    style: ssTitleTextTextStyle14400,
                  ),
                ],

                if (order.trackingNumber != null) ...[
                  SizedBox(height: 24.h),
                  Text('Tracking', style: gsTextStyle16600),
                  SizedBox(height: 8.h),
                  Text(
                    '${order.trackingCarrier != null ? '${order.trackingCarrier} — ' : ''}${order.trackingNumber}',
                    style: ssTitleTextTextStyle14400,
                  ),
                ],

                if (controller.isSupplierView && order.status == 'paid') ...[
                  SizedBox(height: 28.h),
                  Text('Mark as shipped', style: gsTextStyle16600),
                  SizedBox(height: 14.h),
                  AuthTextField(label: 'Tracking number', controller: controller.trackingNumberController),
                  SizedBox(height: 14.h),
                  AuthTextField(label: 'Carrier (optional)', controller: controller.trackingCarrierController),
                  SizedBox(height: 20.h),
                  Obx(
                    () => RoundButton(
                      title: controller.isMarkingShipped.value ? 'Saving...' : 'Mark as Shipped',
                      color: AppColors.buttonColor,
                      isloading: controller.isMarkingShipped.value,
                      onTap: controller.isMarkingShipped.value ? null : controller.markShipped,
                    ),
                  ),
                ],
                SizedBox(height: 24.h),
              ],
            ),
          );
        }),
      ),
    );
  }
}
