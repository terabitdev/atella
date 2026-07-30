import 'package:atella/Modules/Auth/View/Widgets/auth_textfield.dart';
import 'package:atella/Modules/Orders/Controllers/order_checkout_controller.dart';
import 'package:atella/Widgets/app_header.dart';
import 'package:atella/Widgets/custom_roundbutton.dart';
import 'package:atella/core/themes/app_colors.dart';
import 'package:atella/core/themes/app_fonts.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';

class OrderCheckoutScreen extends StatelessWidget {
  const OrderCheckoutScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final controller = Get.find<OrderCheckoutController>();

    return Scaffold(
      body: SafeArea(
        child: Obx(() {
          if (controller.isLoading.value) {
            return const Center(child: CircularProgressIndicator());
          }

          final order = controller.order.value;
          if (order == null) {
            return Center(
              child: Text("This order couldn't be found.", style: gsTextStyle16600),
            );
          }

          if (order.status != 'awaiting_payment') {
            return Center(
              child: Padding(
                padding: EdgeInsets.symmetric(horizontal: 24.w),
                child: Text('This order has already been paid.', style: gsTextStyle16600, textAlign: TextAlign.center),
              ),
            );
          }

          return SingleChildScrollView(
            padding: EdgeInsets.symmetric(horizontal: 20.w, vertical: 20.h),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const GlobalHeader(title: 'Checkout'),
                SizedBox(height: 20.h),

                Container(
                  width: double.infinity,
                  padding: EdgeInsets.all(14.w),
                  decoration: BoxDecoration(
                    color: const Color(0xFFF8F9FA),
                    borderRadius: BorderRadius.circular(12.r),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(order.companyName, style: gsTextStyle16600),
                      if (order.description != null) ...[
                        SizedBox(height: 6.h),
                        Text(order.description!, style: ssTitleTextTextStyle14400),
                      ],
                      SizedBox(height: 10.h),
                      Text(
                        '\$${order.amountTotalDisplay.toStringAsFixed(2)}',
                        style: loginTextTextStyle22700,
                      ),
                    ],
                  ),
                ),
                SizedBox(height: 28.h),

                Text('Shipping details', style: gsTextStyle16600),
                SizedBox(height: 16.h),
                AuthTextField(label: 'Full name', controller: controller.nameController),
                SizedBox(height: 14.h),
                AuthTextField(label: 'Address line 1', controller: controller.addressLine1Controller),
                SizedBox(height: 14.h),
                AuthTextField(label: 'Address line 2 (optional)', controller: controller.addressLine2Controller),
                SizedBox(height: 14.h),
                Row(
                  children: [
                    Expanded(child: AuthTextField(label: 'City', controller: controller.cityController)),
                    SizedBox(width: 12.w),
                    Expanded(child: AuthTextField(label: 'State', controller: controller.stateController)),
                  ],
                ),
                SizedBox(height: 14.h),
                Row(
                  children: [
                    Expanded(child: AuthTextField(label: 'Postal code', controller: controller.postalCodeController)),
                    SizedBox(width: 12.w),
                    Expanded(child: AuthTextField(label: 'Country', controller: controller.countryController)),
                  ],
                ),
                SizedBox(height: 14.h),
                AuthTextField(label: 'Phone', controller: controller.phoneController),
                SizedBox(height: 28.h),

                Obx(
                  () => RoundButton(
                    title: controller.isPaying.value
                        ? 'Processing...'
                        : 'Pay \$${order.amountTotalDisplay.toStringAsFixed(2)}',
                    color: AppColors.buttonColor,
                    isloading: controller.isPaying.value,
                    onTap: controller.isPaying.value ? null : controller.payNow,
                  ),
                ),
                SizedBox(height: 24.h),
              ],
            ),
          );
        }),
      ),
    );
  }
}
