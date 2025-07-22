import 'package:atella/Modules/TechPack/Views/Screens/edit_project_screen.dart';
import 'package:atella/Modules/TechPack/Views/Screens/recommended_manufacture_screen.dart';
import 'package:atella/core/themes/app_fonts.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:get/get_core/src/get_main.dart';
import '../Widgets/save_export_button_row.dart';
import 'package:atella/Widgets/custom_roundbutton.dart';
import 'package:atella/core/themes/app_colors.dart';

class TechPackReadyScreen extends StatelessWidget {
  const TechPackReadyScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFFDFDFD),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 26, vertical: 26),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    'Your Tech Pack Is \nReady',
                    style: TPRTTextTextStyle28700,
                  ),
                  InkWell(
                    onTap: () => Get.to(EditProjectScreen()),
                    child: Image.asset(
                      'assets/images/edit.png',
                      width: 36.w,
                      height: 36.h,
                    ),
                  ),
                ],
              ),
              SizedBox(height: 13.h),
              Text(
                'Garment: Short-sleeve Shirt',
                style: TPRTTextTextStyle184001,
              ),
              SizedBox(height: 30.h),
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  ClipRRect(
                    borderRadius: BorderRadius.circular(16),
                    child: Image.asset(
                      'assets/images/grid1.png',
                      width: 120,
                      height: 227,
                      fit: BoxFit.cover,
                    ),
                  ),
                  const SizedBox(width: 18),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Key Measurements',
                          style: TPRTTextTextStyle164002,
                        ),
                        const SizedBox(height: 4),
                        const Text(
                          'XS - XL',
                          style: TextStyle(
                            fontSize: 20,
                            fontWeight: FontWeight.w400,
                          ),
                        ),
                        const SizedBox(height: 12),
                        Row(
                          children: [
                            Expanded(
                              child: RoundButton(
                                title: 'Export',
                                onTap: () {},
                                color: AppColors.buttonColor,
                                isloading: false,
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 12),
                        const Text(
                          'Materials',
                          style: TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 18,
                          ),
                        ),
                        const SizedBox(height: 4),
                        const Text(
                          'Main Fabric: 100% Organic Cotton Twill',
                          style: TextStyle(
                            fontWeight: FontWeight.w600,
                            fontSize: 12,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Row(
                          children: [
                            Icon(
                              Icons.check_box_outline_blank_outlined,
                              size: 7,
                              color: Colors.black,
                            ),
                            SizedBox(width: 6),
                            Text(
                              'Lightweight polyester mesh',
                              style: TextStyle(
                                fontWeight: FontWeight.w600,
                                fontSize: 10,
                              ),
                            ),
                          ],
                        ),
                        SizedBox(height: 6),
                        Row(
                          children: [
                            Icon(
                              Icons.check_box_outline_blank_outlined,
                              size: 7,
                              color: Colors.black,
                            ),
                            SizedBox(width: 6),
                            Text(
                              'Metallic (silver), snap buttons',
                              style: TextStyle(
                                fontWeight: FontWeight.w600,
                                fontSize: 10,
                              ),
                            ),
                          ],
                        ),
                        SizedBox(height: 6),
                        Row(
                          children: [
                            Icon(
                              Icons.check_box_outline_blank_outlined,
                              size: 7,
                              color: Colors.black,
                            ),
                            SizedBox(width: 6),
                            Text(
                              'Adjustable waist cord',
                              style: TextStyle(
                                fontWeight: FontWeight.w600,
                                fontSize: 10,
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 18),
              Divider(height: 32, thickness: 1.2, color: Color(0xFFE0E0E0)),
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text(
                          'Construction Details',
                          style: TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 16,
                          ),
                        ),
                        const SizedBox(height: 8),
                        Row(
                          children: [
                            Icon(
                              Icons.check_box_outline_blank,
                              size: 7,
                              color: Colors.black,
                            ),
                            SizedBox(width: 6),
                            Text(
                              'Double stitching',
                              style: TextStyle(
                                fontWeight: FontWeight.w400,
                                fontSize: 13,
                              ),
                            ),
                          ],
                        ),
                        Row(
                          children: [
                            Icon(
                              Icons.check_box_outline_blank,
                              size: 7,
                              color: Colors.black,
                            ),
                            SizedBox(width: 6),
                            Text(
                              'Ribbed cuffs',
                              style: TextStyle(
                                fontWeight: FontWeight.w400,
                                fontSize: 13,
                              ),
                            ),
                          ],
                        ),
                        Row(
                          children: [
                            Icon(
                              Icons.check_box_outline_blank,
                              size: 7,
                              color: Colors.black,
                            ),
                            SizedBox(width: 6),
                            Text(
                              'Kangaroo pocket',
                              style: TextStyle(
                                fontWeight: FontWeight.w400,
                                fontSize: 13,
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(width: 18),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        'Colors',
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 16,
                        ),
                      ),
                      const SizedBox(height: 8),
                      Row(
                        children: [
                          Container(
                            width: 72.w,
                            height: 58.h,
                            decoration: BoxDecoration(
                              color: Color.fromRGBO(217, 163, 65, 1),
                              borderRadius: BorderRadius.circular(4.r),
                            ),
                          ),
                          const SizedBox(width: 8),
                          Container(
                            width: 72.w,
                            height: 58.h,
                            decoration: BoxDecoration(
                              color: Color.fromRGBO(4, 55, 98, 1),
                              borderRadius: BorderRadius.circular(4.r),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 6),
                      Row(
                        children: [
                          const Text(
                            '#D9A341',
                            style: TextStyle(
                              fontSize: 13,
                              color: Color(0xFF444444),
                            ),
                          ),
                          const SizedBox(width: 12),
                          const Text(
                            '#043762',
                            style: TextStyle(
                              fontSize: 13,
                              color: Color(0xFF444444),
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ],
              ),
              const SizedBox(height: 18),
              Divider(height: 32, thickness: 1.2, color: Color(0xFFE0E0E0)),
              const Text(
                'Labeling & Branding',
                style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
              ),
              const SizedBox(height: 8),
              Row(
                children: [
                  Icon(
                    Icons.check_box_outline_blank,
                    size: 7,
                    color: Colors.black,
                  ),
                  SizedBox(width: 6),
                  Text('Embroidered logo'),
                ],
              ),
              Row(
                children: [
                  Icon(
                    Icons.check_box_outline_blank,
                    size: 7,
                    color: Colors.black,
                  ),
                  SizedBox(width: 6),
                  Text('Size: care label'),
                ],
              ),
              Row(
                children: [
                  Icon(
                    Icons.check_box_outline_blank,
                    size: 7,
                    color: Colors.black,
                  ),
                  SizedBox(width: 6),
                  Text('QR code for product authenticity'),
                ],
              ),
              const SizedBox(height: 18),
              Divider(height: 32, thickness: 1.2, color: Color(0xFFE0E0E0)),
              const Text(
                'Production Details',
                style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
              ),
              const SizedBox(height: 8),
              Row(
                children: [
                  Icon(
                    Icons.check_box_outline_blank,
                    size: 7,
                    color: Colors.black,
                  ),
                  SizedBox(width: 6),
                  Text('Target Cost: €38'),
                ],
              ),
              Row(
                children: [
                  Icon(
                    Icons.check_box_outline_blank,
                    size: 7,
                    color: Colors.black,
                  ),
                  SizedBox(width: 6),
                  Text('Quantity: 1,000 Units'),
                ],
              ),
              Row(
                children: [
                  Icon(
                    Icons.check_box_outline_blank,
                    size: 7,
                    color: Colors.black,
                  ),
                  SizedBox(width: 6),
                  Text('Delivery Deadline: Sept 30, 2025'),
                ],
              ),
              const SizedBox(height: 24),
              RoundButton(
                title: 'Get Manufacturer Suggestions',
                onTap: () {
                  // Get.toNamed('/recommended_tech_pack');
                  Get.to(() => const RecommendedManufactureScreen());
                },
                color: AppColors.buttonColor,
                isloading: false,
              ),
              const SizedBox(height: 16),
              SaveExportButtonRow(onSave: () {}, onExport: () {}),
              const SizedBox(height: 30),
            ],
          ),
        ),
      ),
    );
  }
}
