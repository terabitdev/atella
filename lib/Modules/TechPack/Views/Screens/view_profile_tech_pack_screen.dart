import 'package:atella/core/themes/app_fonts.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:atella/Widgets/custom_roundbutton.dart';

class ViewProfileTechPackScreen extends StatelessWidget {
  const ViewProfileTechPackScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF5F5F5),
      body: SafeArea(
        child: Stack(
          children: [
            Column(
              children: [
                const SizedBox(height: 24),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  child: Row(
                    children: [
                      InkWell(
                        borderRadius: BorderRadius.circular(24),
                        onTap: () => Get.back(),
                        child: Container(
                          width: 40,
                          height: 40,
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(4),
                          ),
                          child: const Icon(
                            Icons.arrow_back_ios_new_rounded,
                            size: 20,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 24),
                Expanded(
                  child: SingleChildScrollView(
                    child: Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 16),
                      child: Container(
                        width: double.infinity,
                        padding: const EdgeInsets.all(24),
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(20),
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'Manufacturer Profile',
                              style: mstTextTextStyle26700,
                            ),
                            SizedBox(height: 24),
                            _ProfileSection(
                              title: 'Company',
                              value: 'ABC Garments',
                            ),
                            SizedBox(height: 16),
                            _ProfileSection(
                              title: 'Location',
                              value: 'Los Angeles, CA',
                            ),
                            SizedBox(height: 16),
                            _ProfileSection(
                              title: 'Minimum Order Quantity',
                              value: 'MO 100 units',
                            ),
                            SizedBox(height: 16),
                            _ProfileSection(
                              title: 'Lead Time',
                              value: '60 days',
                            ),
                            SizedBox(height: 16),
                            Text(
                              'About',
                              style: TextStyle(
                                fontWeight: FontWeight.w700,
                                fontSize: 20,
                              ),
                            ),
                            SizedBox(height: 8),
                            Text(
                              'ABC Garments is a full-service clothing manufacturer based in Los Angeles, specializing in high-quality knitwear.',
                              style: TextStyle(
                                fontWeight: FontWeight.w400,
                                fontSize: 16,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: 24),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  child: RoundButton(
                    title: 'Contact',
                    onTap: () {},
                    color: Colors.black,
                    isloading: false,
                  ),
                ),
                const SizedBox(height: 24),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

class _ProfileSection extends StatelessWidget {
  final String title;
  final String value;
  const _ProfileSection({required this.title, required this.value});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(title, style: ptTextTextStyle18700),
        const SizedBox(height: 4),
        Text(value, style: ptTextTextStyle16400),
      ],
    );
  }
}
