// ignore_for_file: public_member_api_docs, sort_constructors_first
import 'package:atella/core/themes/app_colors.dart';
import 'package:atella/core/themes/app_fonts.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:get/get.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:atella/Data/Models/new_manufacturer_model.dart';
import 'package:atella/Modules/tech_pack/controllers/manufacturer_suggestion_controller.dart';

class ManufacturerSuggestionCard extends StatelessWidget {
  final NewManufacturer manufacturer;
  final VoidCallback onViewProfile;
  final VoidCallback? onSendEmail;

  const ManufacturerSuggestionCard({
    super.key,
    required this.manufacturer,
    required this.onViewProfile,
    this.onSendEmail,
  });

  @override
  Widget build(BuildContext context) {
    final controller = Get.find<ManufacturerSuggestionController>();

    return Container(
      margin: EdgeInsets.symmetric(vertical: 10.h),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(18.r),
        border: Border.all(color: const Color(0xFFE0E0E0)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Main card content
          Padding(
            padding: EdgeInsets.all(18.r),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Company name
                Text(
                  manufacturer.companyName,
                  style: TextStyle(
                    fontWeight: FontWeight.w700,
                    fontSize: 20.sp,
                  ),
                ),
                SizedBox(height: 8.h),

                // Location (Country)
                Row(
                  children: [
                    Icon(
                      Icons.location_on,
                      color: const Color.fromARGB(199, 5, 1, 1),
                      size: 20.w,
                    ),
                    SizedBox(width: 4.w),
                    Expanded(
                      child: Text(
                        manufacturer.country,
                        style: TextStyle(fontSize: 15.sp),
                      ),
                    ),
                  ],
                ),

                // Products they make (if available)
                if (manufacturer.products.isNotEmpty) ...[
                  SizedBox(height: 12.h),
                  Wrap(
                    spacing: 6.w,
                    runSpacing: 6.h,
                    children: manufacturer.products.take(4).map((product) {
                      return Container(
                        padding: EdgeInsets.symmetric(
                          horizontal: 10.w,
                          vertical: 4.h,
                        ),
                        decoration: BoxDecoration(
                          color: AppColors.buttonColor.withValues(alpha: 0.1),
                          borderRadius: BorderRadius.circular(12.r),
                        ),
                        child: Text(
                          product,
                          style: TextStyle(
                            fontSize: 11.sp,
                            color: AppColors.buttonColor,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      );
                    }).toList(),
                  ),
                ],

                SizedBox(height: 16.h),

                // Action buttons
                Row(
                  children: [
                    Expanded(
                      child: OutlinedButton(
                        onPressed: onSendEmail,
                        style: OutlinedButton.styleFrom(
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(8.r),
                          ),
                          side: const BorderSide(color: Colors.black, width: 1),
                          padding: EdgeInsets.symmetric(vertical: 12.h),
                        ),
                        child: const Text(
                          'Send via Email',
                          style: TextStyle(
                            color: Colors.black,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),
                    ),
                    SizedBox(width: 12.w),
                    Expanded(
                      child: OutlinedButton(
                        onPressed: () => _showContactDialog(context),
                        style: OutlinedButton.styleFrom(
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(8.r),
                          ),
                          side: const BorderSide(color: Colors.black, width: 1),
                          padding: EdgeInsets.symmetric(vertical: 12.h),
                        ),
                        child: const Text(
                          'Contact',
                          style: TextStyle(
                            color: Colors.black,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),

          // Expandable section
          Obx(() {
            final isExpanded = controller.isCardExpanded(manufacturer.id);
            return Column(
              children: [
                // Expand/Collapse button
                InkWell(
                  onTap: () => controller.toggleCardExpansion(manufacturer.id),
                  child: Container(
                    padding: EdgeInsets.symmetric(vertical: 12.h),
                    decoration: BoxDecoration(
                      color: const Color(0xFFF8F8F8),
                      border: Border(
                        top: BorderSide(
                          color: const Color(0xFFE0E0E0),
                          width: 1,
                        ),
                      ),
                      borderRadius: BorderRadius.only(
                        bottomLeft: Radius.circular(isExpanded ? 0 : 18.r),
                        bottomRight: Radius.circular(isExpanded ? 0 : 18.r),
                      ),
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text(
                          isExpanded ? 'Hide Details' : 'More Details',
                          style: TextStyle(
                            fontSize: 13.sp,
                            fontWeight: FontWeight.w500,
                            color: const Color(0xFF666666),
                          ),
                        ),
                        SizedBox(width: 4.w),
                        Icon(
                          isExpanded
                              ? Icons.keyboard_arrow_up
                              : Icons.keyboard_arrow_down,
                          size: 20.w,
                          color: const Color(0xFF666666),
                        ),
                      ],
                    ),
                  ),
                ),

                // Expanded content
                if (isExpanded)
                  Container(
                    width: double.infinity,
                    padding: EdgeInsets.all(16.r),
                    decoration: BoxDecoration(
                      color: const Color(0xFFFAFAFA),
                      borderRadius: BorderRadius.only(
                        bottomLeft: Radius.circular(18.r),
                        bottomRight: Radius.circular(18.r),
                      ),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // MOQ
                        _buildDetailRow(
                          icon: Icons.inventory_2_outlined,
                          label: 'Minimum Order Quantity',
                          value: manufacturer.moq,
                        ),

                        // Certifications
                        if (manufacturer.hasCertifications) ...[
                          SizedBox(height: 12.h),
                          _buildDetailRow(
                            icon: Icons.verified_outlined,
                            label: 'Certifications',
                            value: manufacturer.certificationsDisplay,
                          ),
                        ],

                        // All Products
                        if (manufacturer.products.isNotEmpty) ...[
                          SizedBox(height: 12.h),
                          _buildDetailRow(
                            icon: Icons.checkroom_outlined,
                            label: 'Products & Capabilities',
                            value: manufacturer.productsDisplay,
                          ),
                        ],
                      ],
                    ),
                  ),
              ],
            );
          }),
        ],
      ),
    );
  }

  Widget _buildDetailRow({
    required IconData icon,
    required String label,
    required String value,
    bool isLink = false,
    VoidCallback? onTap,
  }) {
    final content = Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Icon(icon, size: 18.w, color: const Color(0xFF666666)),
        SizedBox(width: 10.w),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                label,
                style: TextStyle(
                  fontSize: 11.sp,
                  color: const Color(0xFF999999),
                  fontWeight: FontWeight.w500,
                ),
              ),
              SizedBox(height: 2.h),
              Text(
                value,
                style: TextStyle(
                  fontSize: 13.sp,
                  color: isLink
                      ? AppColors.buttonColor
                      : const Color(0xFF333333),
                  fontWeight: FontWeight.w500,
                  decoration: isLink ? TextDecoration.underline : null,
                ),
              ),
            ],
          ),
        ),
        if (isLink)
          Icon(Icons.open_in_new, size: 16.w, color: AppColors.buttonColor),
      ],
    );

    if (onTap != null) {
      return InkWell(onTap: onTap, child: content);
    }
    return content;
  }

  String _formatInstagramHandle(String instagram) {
    // Extract handle from URL if it's a full URL
    if (instagram.contains('instagram.com/')) {
      final parts = instagram.split('instagram.com/');
      if (parts.length > 1) {
        String handle = parts[1].replaceAll('/', '').trim();
        return '@$handle';
      }
    }
    return instagram;
  }

  void _showContactDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16.r),
          ),
          title: Text(
            'Contact ${manufacturer.companyName}',
            style: TextStyle(fontWeight: FontWeight.w700, fontSize: 18.sp),
          ),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Email
              _buildContactItem(
                icon: Icons.email,
                label: 'Email',
                value: manufacturer.email ?? 'Not available',
                onTap: manufacturer.hasEmail
                    ? () => _launchUrl(manufacturer.email!)
                    : () => Get.snackbar(
                        'Error',
                        'Email not available',
                        duration: const Duration(milliseconds: 1500),
                      ),
                isAvailable: manufacturer.hasEmail,
              ),
              SizedBox(height: 12.h),

              // Website
              _buildContactItem(
                icon: Icons.language,
                label: 'Website',
                value: manufacturer.website ?? 'Not available',
                onTap: manufacturer.hasWebsite
                    ? () => _launchUrl(manufacturer.website!)
                    : () => Get.snackbar(
                        'Error',
                        'Website not available',
                        duration: const Duration(milliseconds: 1500),
                      ),
                isAvailable: manufacturer.hasWebsite,
              ),

              // Instagram - only show if available
              if (manufacturer.hasInstagram) ...[
                SizedBox(height: 12.h),
                _buildInstagramContactItem(
                  label: 'Instagram',
                  value: _formatInstagramHandle(manufacturer.instagram!),
                  onTap: () => _launchUrl(manufacturer.instagram!),
                ),
              ],
            ],
          ),
          actionsPadding: EdgeInsets.only(right: 8.w, bottom: 4.h),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: Text('Close', style: cstTextTextStyle16500),
            ),
          ],
        );
      },
    );
  }

  Widget _buildContactItem({
    required IconData icon,
    required String label,
    required String value,
    required VoidCallback? onTap,
    required bool isAvailable,
  }) {
    return InkWell(
      onTap: onTap,
      child: Container(
        padding: EdgeInsets.all(12.r),
        decoration: BoxDecoration(
          color: isAvailable
              ? const Color(0xFFF5F5F5)
              : const Color(0xFFFAFAFA),
          borderRadius: BorderRadius.circular(8.r),
          border: isAvailable
              ? null
              : Border.all(color: const Color(0xFFE0E0E0), width: 1.w),
        ),
        child: Row(
          children: [
            Icon(
              icon,
              size: 20.w,
              color: isAvailable
                  ? const Color(0xFF333333)
                  : const Color(0xFF999999),
            ),
            SizedBox(width: 12.w),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    label,
                    style: TextStyle(
                      fontSize: 12.sp,
                      color: const Color(0xFF666666),
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                  Text(
                    value,
                    style: TextStyle(
                      fontSize: 14.sp,
                      color: isAvailable
                          ? const Color(0xFF333333)
                          : const Color(0xFF999999),
                      fontWeight: isAvailable
                          ? FontWeight.w600
                          : FontWeight.w400,
                      fontStyle: isAvailable
                          ? FontStyle.normal
                          : FontStyle.italic,
                    ),
                  ),
                ],
              ),
            ),
            if (isAvailable)
              Icon(
                Icons.arrow_forward_ios,
                size: 16.w,
                color: const Color(0xFF666666),
              )
            else
              Icon(
                Icons.info_outline,
                size: 16.w,
                color: const Color(0xFF999999),
              ),
          ],
        ),
      ),
    );
  }

  Widget _buildInstagramContactItem({
    required String label,
    required String value,
    required VoidCallback onTap,
  }) {
    return InkWell(
      onTap: onTap,
      child: Container(
        padding: EdgeInsets.all(12.r),
        decoration: BoxDecoration(
          color: const Color(0xFFF5F5F5),
          borderRadius: BorderRadius.circular(8.r),
        ),
        child: Row(
          children: [
            SvgPicture.asset(
              'assets/images/instagram_icon.svg',
              width: 18.w,
              height: 18.w,
            ),
            SizedBox(width: 12.w),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    label,
                    style: TextStyle(
                      fontSize: 12.sp,
                      color: const Color(0xFF666666),
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                  Text(
                    value,
                    style: TextStyle(
                      fontSize: 14.sp,
                      color: const Color(0xFF333333),
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ],
              ),
            ),
            Icon(
              Icons.arrow_forward_ios,
              size: 16.w,
              color: const Color(0xFF666666),
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _launchUrl(String input) async {
    Uri uri;

    if (input.contains('@') && !input.startsWith('http')) {
      // Email
      uri = Uri(scheme: 'mailto', path: input);
    } else if (input.contains('instagram.com')) {
      // Instagram
      uri = Uri.parse(input.startsWith('http') ? input : 'https://$input');
    } else {
      // Website
      uri = Uri.parse(input.startsWith('http') ? input : 'https://$input');
    }

    if (!await launchUrl(uri, mode: LaunchMode.externalApplication)) {
      Get.snackbar(
        'Error',
        'Could not open link',
        duration: const Duration(milliseconds: 1500),
      );
    }
  }
}
