// ignore_for_file: public_member_api_docs, sort_constructors_first
import 'package:atella/core/themes/app_fonts.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:atella/Data/Models/manufacturer_model.dart';
import 'package:atella/Data/services/test_email_service.dart';
import 'package:atella/modules/tech_pack/controllers/tech_pack_ready_controller.dart';

class ManufacturerSuggestionCard extends StatelessWidget {
  final Manufacturer manufacturer;
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
              Icon(Icons.location_on, color: Color.fromARGB(199, 5, 1, 1), size: 20.w),
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
            const SizedBox(width: 8),
            TextButton(
              onPressed: () async {
                Navigator.of(context).pop();
                // Test email with attachments
                await _sendTestEmail();
              },
              child: Text('Test with Images',style: cstTextTextStyle16500,),
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
            width: 1.w,
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

  Future<void> _sendTestEmail() async {
    try {
      // Show loading snackbar
      Get.showSnackbar(
        const GetSnackBar(
          title: 'Sending AI-Powered Email',
          message: 'Generating personalized email with tech pack PDF...',
          duration: Duration(seconds: 3),
          backgroundColor: Colors.black,
          
        ),
      );

      // Try to get actual tech pack images
      List<String> imagePaths = [];
      
      try {
        final techPackController = Get.find<TechPackReadyController>();
        
        // Get all three images: selected design + 2 tech pack images
        List<String> allImages = [];
        
        // 1. Add selected design image first
        if (techPackController.selectedDesignImage.isNotEmpty) {
          allImages.add(techPackController.selectedDesignImage);
          print('📎 Added selected design image');
        }
        
        // 2. Add generated tech pack images (limit to 2)
        if (techPackController.hasGeneratedImages) {
          final techPackImages = techPackController.generatedImages;
          for (int i = 0; i < techPackImages.length && i < 2; i++) {
            allImages.add(techPackImages[i]);
          }
          print('📎 Added ${techPackImages.length.clamp(0, 2)} tech pack images');
        }
        
        imagePaths = allImages;
        print('📎 Total images to attach: ${imagePaths.length}');
      } catch (e) {
        print('📎 Could not find tech pack controller, using sample images: $e');
      }
      
      // Fallback to sample images if no tech pack images
      if (imagePaths.isEmpty) {
      }

      // Extract tech pack data for AI generation
      Map<String, dynamic> techPackData = {};
      try {
        final techPackController = Get.find<TechPackReadyController>();
        techPackData = {
          'mainFabric': techPackController.techPackSummary.split('Materials: ')[1].split('\\n')[0],
          'primaryColor': techPackController.techPackSummary.split('Colors: ')[1].split('\\n')[0],
          'sizeRange': techPackController.techPackSummary.split('Sizes: ')[1].split('\\n')[0],
          'quantity': techPackController.techPackSummary.split('Quantity: ')[1].split('\\n')[0],
          'costPerPiece': techPackController.techPackSummary.split('Target Cost: ')[1].split('\\n')[0],
          'deliveryDate': techPackController.techPackSummary.split('Delivery: ')[1].split('\\n')[0],
        };
        print('📋 Tech pack data extracted for AI generation');
      } catch (e) {
        // Use sample data for testing
        techPackData = {
          'mainFabric': 'Cotton blend',
          'primaryColor': 'Navy blue',
          'sizeRange': 'S-XL',
          'quantity': '500 pieces',
          'costPerPiece': '\$15-20',
          'deliveryDate': '30 days',
        };
      }

      // Send AI-powered email with PDF attachment
      bool success = false;
      if (imagePaths.isNotEmpty) {
        success = await EmailJSDebugService.sendAIPoweredEmailWithPDF(
          toEmail: 'mdaniyalkhan783@gmail.com',
          manufacturerName: manufacturer.name,
          manufacturerLocation: manufacturer.location,
          techPackData: techPackData,
          userCompanyName: 'Atelia Fashion',
          imagePaths: imagePaths,
        );
      } else {
        // Fallback with sample data if no images available
        success = await EmailJSDebugService.sendAIPoweredEmailWithPDF(
          toEmail: 'mdaniyalkhan783@gmail.com',
          manufacturerName: manufacturer.name,
          manufacturerLocation: manufacturer.location,
          techPackData: techPackData,
          userCompanyName: 'Atelia Fashion',
          imagePaths: ['data:image/jpeg;base64,/9j/4AAQSkZJRgABA...'], // Sample base64
        );
      }

      // Show result
      if (success) {
        Get.showSnackbar(
          GetSnackBar(
            title: 'AI Email Sent Successfully!',
            message: imagePaths.isNotEmpty
              ? 'Sent personalized AI email with PDF containing ${imagePaths.length} tech pack images to mdaniyalkhan783@gmail.com'
              : 'Sent AI-powered email with sample data to mdaniyalkhan783@gmail.com',
            duration: const Duration(seconds: 5),
            backgroundColor: Colors.black,
          ),
        );
      } else {
        Get.showSnackbar(
          const GetSnackBar(
            title: 'AI Email Failed',
            message: 'Failed to send AI-powered email. Check console for error details.',
            duration: Duration(seconds: 5),
            backgroundColor: Colors.red,
          ),
        );
      }
    } catch (e) {
      Get.showSnackbar(
        GetSnackBar(
          title: 'Error',
          message: 'Exception occurred: $e',
          duration: const Duration(seconds: 5),
          backgroundColor: Colors.red,
        ),
      );
    }
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