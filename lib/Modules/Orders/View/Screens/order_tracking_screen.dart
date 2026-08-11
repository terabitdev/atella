import 'package:atella/Modules/Auth/View/Widgets/auth_textfield.dart';
import 'package:atella/Modules/Orders/Controllers/order_tracking_controller.dart';
import 'package:atella/Widgets/app_header.dart';
import 'package:atella/Widgets/custom_roundbutton.dart';
import 'package:atella/core/themes/app_colors.dart';
import 'package:atella/core/themes/app_fonts.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';

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

          final statusColor = _statusColor(order.status);
          final shipping = order.shipping;

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
                    color: statusColor.withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(20.r),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Container(
                        width: 8.w,
                        height: 8.w,
                        decoration: BoxDecoration(color: statusColor, shape: BoxShape.circle),
                      ),
                      SizedBox(width: 8.w),
                      Text(
                        _statusLabels[order.status] ?? order.status,
                        style: TextStyle(color: statusColor, fontWeight: FontWeight.w600, fontSize: 13.sp),
                      ),
                    ],
                  ),
                ),
                SizedBox(height: 20.h),

                // ── Order summary ──────────────────────────────────────
                _SectionCard(
                  children: [
                    Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Expanded(
                          child: Text(
                            controller.isSupplierView ? order.userName : order.companyName,
                            style: loginTextTextStyle22700,
                          ),
                        ),
                        Text(
                          '\$${order.amountTotalDisplay.toStringAsFixed(2)}',
                          style: loginTextTextStyle22700,
                        ),
                      ],
                    ),
                    SizedBox(height: 4.h),
                    Text(
                      controller.isSupplierView ? 'Customer' : 'Supplier',
                      style: ssTitleTextTextStyle14400.copyWith(color: Colors.grey[500]),
                    ),
                    if (order.description != null && order.description!.isNotEmpty) ...[
                      SizedBox(height: 14.h),
                      Container(height: 1, color: const Color(0xFFF0F0F0)),
                      SizedBox(height: 14.h),
                      Text(order.description!, style: gsTextStyle16400),
                    ],
                    if (order.quantity != null) ...[
                      SizedBox(height: 12.h),
                      _InfoRow(icon: Icons.inventory_2_outlined, label: 'Quantity', value: '${order.quantity} units'),
                    ],
                    SizedBox(height: 12.h),
                    _InfoRow(
                      icon: Icons.calendar_today_outlined,
                      label: 'Order placed',
                      value: order.createdAt != null ? DateFormat('MMM d, yyyy').format(order.createdAt!) : '—',
                    ),
                    if (order.paidAt != null) ...[
                      SizedBox(height: 12.h),
                      _InfoRow(
                        icon: Icons.check_circle_outline,
                        label: 'Paid on',
                        value: DateFormat('MMM d, yyyy').format(order.paidAt!),
                      ),
                    ],
                  ],
                ),

                // ── Shipping ────────────────────────────────────────────
                if (shipping != null) ...[
                  SizedBox(height: 20.h),
                  Text('Shipping details', style: gsTextStyle16600),
                  SizedBox(height: 10.h),
                  _SectionCard(
                    children: [
                      _InfoRow(icon: Icons.person_outline, label: 'Recipient', value: shipping.name),
                      SizedBox(height: 12.h),
                      _InfoRow(
                        icon: Icons.location_on_outlined,
                        label: 'Address',
                        value: [
                          shipping.addressLine1,
                          if (shipping.addressLine2 != null && shipping.addressLine2!.isNotEmpty)
                            shipping.addressLine2,
                          '${shipping.city}, ${shipping.state} ${shipping.postalCode}',
                          shipping.country,
                        ].join('\n'),
                      ),
                      SizedBox(height: 12.h),
                      _InfoRow(icon: Icons.phone_outlined, label: 'Phone', value: shipping.phone),
                    ],
                  ),
                ],

                // ── Tracking ────────────────────────────────────────────
                if (order.trackingNumber != null) ...[
                  SizedBox(height: 20.h),
                  Text('Tracking', style: gsTextStyle16600),
                  SizedBox(height: 10.h),
                  _SectionCard(
                    children: [
                      if (order.trackingCarrier != null && order.trackingCarrier!.isNotEmpty) ...[
                        _InfoRow(icon: Icons.local_shipping_outlined, label: 'Carrier', value: order.trackingCarrier!),
                        SizedBox(height: 12.h),
                      ],
                      _InfoRow(icon: Icons.confirmation_number_outlined, label: 'Tracking number', value: order.trackingNumber!),
                      if (order.shippedAt != null) ...[
                        SizedBox(height: 12.h),
                        _InfoRow(
                          icon: Icons.calendar_today_outlined,
                          label: 'Shipped on',
                          value: DateFormat('MMM d, yyyy').format(order.shippedAt!),
                        ),
                      ],
                    ],
                  ),
                ],

                if (controller.isSupplierView && order.status == 'paid') ...[
                  SizedBox(height: 28.h),
                  Text('Mark as shipped', style: gsTextStyle16600),
                  SizedBox(height: 14.h),
                  AuthTextField(label: 'Tracking number or tracking link', controller: controller.trackingNumberController),
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

/// Bordered white card used to group related order fields.
class _SectionCard extends StatelessWidget {
  final List<Widget> children;
  const _SectionCard({required this.children});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: EdgeInsets.all(16.w),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12.r),
        border: Border.all(color: const Color(0xFFE9E9E9)),
      ),
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: children),
    );
  }
}

/// A label + icon + value row, used for shipping/tracking/summary fields so
/// entered data reads as structured fields instead of one text blob.
class _InfoRow extends StatelessWidget {
  final IconData icon;
  final String label;
  final String value;
  const _InfoRow({required this.icon, required this.label, required this.value});

  @override
  Widget build(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Icon(icon, size: 18.sp, color: Colors.grey[500]),
        SizedBox(width: 10.w),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(label, style: ssTitleTextTextStyle14400.copyWith(color: Colors.grey[500])),
              SizedBox(height: 2.h),
              Text(value, style: gsTextStyle16400),
            ],
          ),
        ),
      ],
    );
  }
}
