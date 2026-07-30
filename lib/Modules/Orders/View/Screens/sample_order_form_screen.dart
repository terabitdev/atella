import 'package:atella/Modules/Auth/View/Widgets/auth_textfield.dart';
import 'package:atella/Modules/Orders/Controllers/sample_order_form_controller.dart';
import 'package:atella/Widgets/app_header.dart';
import 'package:atella/Widgets/custom_roundbutton.dart';
import 'package:atella/core/themes/app_colors.dart';
import 'package:atella/core/themes/app_fonts.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';

class SampleOrderFormScreen extends StatelessWidget {
  const SampleOrderFormScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final controller = Get.find<SampleOrderFormController>();

    return Scaffold(
      body: SafeArea(
        child: SingleChildScrollView(
          padding: EdgeInsets.symmetric(horizontal: 20.w, vertical: 20.h),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const GlobalHeader(title: 'Sample Order Form'),
              SizedBox(height: 16.h),
              Text(
                'Set a price for this sample. Atella takes a 10% commission — the rest is transferred to your Stripe account once the designer pays.',
                style: ssTitleTextTextStyle14400,
              ),
              SizedBox(height: 24.h),

              Text('Price', style: authLableTextTextStyle14400),
              SizedBox(height: 6.h),
              TextField(
                controller: controller.amountController,
                keyboardType: const TextInputType.numberWithOptions(decimal: true),
                inputFormatters: [FilteringTextInputFormatter.allow(RegExp(r'^\d*\.?\d{0,2}'))],
                style: authLableTextTextStyle144001,
                decoration: InputDecoration(
                  hintText: '0.00',
                  prefixText: '\$ ',
                  hintStyle: authLableTextTextStyle144002,
                  enabledBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(6.r),
                    borderSide: const BorderSide(color: Color.fromRGBO(233, 233, 233, 1), width: 1.2),
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(6.r),
                    borderSide: BorderSide(color: AppColors.buttonColor, width: 1.5),
                  ),
                  contentPadding: EdgeInsets.symmetric(vertical: 16.h, horizontal: 12.w),
                ),
              ),
              SizedBox(height: 20.h),

              AuthTextField(label: 'Description (optional)', controller: controller.descriptionController),
              SizedBox(height: 28.h),

              Obx(
                () => RoundButton(
                  title: controller.isSubmitting.value ? 'Sending...' : 'Send Order Form',
                  color: AppColors.buttonColor,
                  isloading: controller.isSubmitting.value,
                  onTap: controller.isSubmitting.value ? null : controller.submit,
                ),
              ),
              SizedBox(height: 24.h),
            ],
          ),
        ),
      ),
    );
  }
}
