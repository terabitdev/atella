// ignore_for_file: public_member_api_docs, sort_constructors_first
import 'package:atella/core/themes/app_fonts.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:atella/Data/Models/manufacturer_model.dart';

class ManufacturerSuggestionCard extends StatelessWidget {
  final Manufacturer manufacturer;
  final VoidCallback onViewProfile;
  final VoidCallback? onSendEmail;
  final bool isLoadingEmail;
  const ManufacturerSuggestionCard({
    super.key,
    required this.manufacturer,
    required this.onViewProfile,
    this.onSendEmail,
    this.isLoadingEmail = false,
  });
  @override
  Widget build(BuildContext context) {
    return Container(
      margin: EdgeInsets.symmetric(vertical: 10.h),
      padding: EdgeInsets.all(18.r),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(18.r),
        border: Border.all(color: const Color(0xFFE0E0E0)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            manufacturer.name,
            style: TextStyle(fontWeight: FontWeight.w700, fontSize: 20.sp),
          ),
          SizedBox(height: 8.h),
          Row(
            children: [
              Icon(Icons.location_on, color: Color(0xFFFF2D55), size: 20.w),
              SizedBox(width: 4.w),
              Expanded(
                child: Text(manufacturer.location, style: TextStyle(fontSize: 15.sp)),
              ),
            ],
          ),
          SizedBox(height: 16.h),
          Row(
            children: [
              Expanded(
                child: OutlinedButton(
                  onPressed: isLoadingEmail ? null : onSendEmail,
                  style: OutlinedButton.styleFrom(
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8.r),
                    ),
                    side: const BorderSide(color: Colors.black, width: 1),
                    padding: EdgeInsets.symmetric(vertical: 12.h),
                  ),
                  child: isLoadingEmail 
                    ? SizedBox(
                        width: 16.w,
                        height: 16.h,
                        child: const CircularProgressIndicator(
                          strokeWidth: 2,
                          color: Colors.black,
                        ),
                      )
                    : const Text(
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
    );
  }

  void _showContactDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text(
            'Contact ${manufacturer.name}',
            style: TextStyle(fontWeight: FontWeight.w700, fontSize: 18.sp),
          ),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildContactItem(
                icon: Icons.phone,
                label: 'Phone',
                value: manufacturer.phoneNumber ?? 'Not available',
                onTap: manufacturer.phoneNumber != null 
                  ? () => _launchUrl(manufacturer.phoneNumber!)
                  : () => Get.snackbar('Error', 'Phone number not available'),
                isAvailable: manufacturer.phoneNumber != null,
              ),
              SizedBox(height: 12.h),
              _buildContactItem(
                icon: Icons.email,
                label: 'Email',
                value: manufacturer.email ?? 'Not available',
                onTap: manufacturer.email != null 
                  ? () => _launchUrl(manufacturer.email!)
                  : () => Get.snackbar('Error', 'Email not available'),
                isAvailable: manufacturer.email != null,
              ),
              SizedBox(height: 12.h),
              _buildContactItem(
                icon: Icons.language,
                label: 'Website',
                value: manufacturer.website ?? 'Not available',
                onTap: manufacturer.website != null 
                  ? () => _launchUrl(manufacturer.website!)
                  : () => Get.snackbar('Error', 'Website not available'),
                isAvailable: manufacturer.website != null,
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: Text('Close',style: cstTextTextStyle16500,),
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
          color: isAvailable ? const Color(0xFFF5F5F5) : const Color(0xFFFAFAFA),
          borderRadius: BorderRadius.circular(8.r),
          border: isAvailable ? null : Border.all(
            color: const Color(0xFFE0E0E0),
            width: 1,
          ),
        ),
        child: Row(
          children: [
            Icon(
              icon, 
              size: 20.w, 
              color: isAvailable ? const Color(0xFF333333) : const Color(0xFF999999),
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
                      color: isAvailable ? const Color(0xFF333333) : const Color(0xFF999999),
                      fontWeight: isAvailable ? FontWeight.w600 : FontWeight.w400,
                      fontStyle: isAvailable ? FontStyle.normal : FontStyle.italic,
                    ),
                  ),
                ],
              ),
            ),
            if (isAvailable)
              Icon(Icons.arrow_forward_ios, size: 16.w, color: const Color(0xFF666666))
            else
              Icon(Icons.info_outline, size: 16.w, color: const Color(0xFF999999)),
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
  } else if (RegExp(r'^[\d\s\-\+]+$').hasMatch(input)) {
    // Phone
    uri = Uri(scheme: 'tel', path: input);
  } else {
    // Website
    uri = Uri.parse(
      input.startsWith('http') ? input : 'https://$input',
    );
  }

  if (!await launchUrl(uri, mode: LaunchMode.externalApplication)) {
    throw Exception('Could not launch $uri');
  }
}
}
