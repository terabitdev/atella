import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:image_picker/image_picker.dart';
import 'package:get/get.dart';
import 'package:atella/l10n/generated/app_localizations.dart';

class MultiImageUploadWidget extends StatelessWidget {
  final List<String> selectedImages;
  final Function(String) onImageAdded;
  final Function(String) onImageRemoved;
  final String placeholder;

  const MultiImageUploadWidget({
    Key? key,
    required this.selectedImages,
    required this.onImageAdded,
    required this.onImageRemoved,
    this.placeholder = 'Upload visual inspiration images (optional)',
  }) : super(key: key);

  Future<void> _pickImageFromGallery(BuildContext context) async {
    final l10n = AppLocalizations.of(context)!;
    try {
      final ImagePicker picker = ImagePicker();
      final XFile? image = await picker.pickImage(source: ImageSource.gallery);

      if (image != null) {
        onImageAdded(image.path);

        Get.snackbar(
          l10n.imageAdded,
          l10n.imageAddedSuccessfully,
          backgroundColor: Colors.black,
          colorText: Colors.white,
          snackPosition: SnackPosition.TOP,
          duration: const Duration(milliseconds: 1500),
        );
      }
    } catch (e) {
      print('Error picking image: $e');
      Get.snackbar(
        l10n.error,
        l10n.failedToPickImage,
        backgroundColor: Colors.red,
        colorText: Colors.white,
        snackPosition: SnackPosition.TOP,
        duration: const Duration(milliseconds: 1500),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Upload button - always visible to add more images
        GestureDetector(
          onTap: () => _pickImageFromGallery(context),
          child: Container(
            width: double.infinity,
            constraints: BoxConstraints(minHeight: 100.h),
            decoration: BoxDecoration(
              color: const Color(0xFFF8F9FA),
              borderRadius: BorderRadius.circular(12.r),
              border: Border.all(
                color: const Color(0xFFE0E0E0),
                width: 1.5,
                style: BorderStyle.solid,
              ),
            ),
            child: Padding(
              padding: EdgeInsets.symmetric(horizontal: 12.w, vertical: 8.h),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    Icons.add_photo_alternate_outlined,
                    size: 28.w,
                    color: const Color(0xFF666666),
                  ),
                  SizedBox(height: 6.h),
                  Text(
                    selectedImages.isEmpty ? placeholder : l10n.addMoreImages,
                    style: TextStyle(
                      fontSize: 14.sp,
                      color: const Color(0xFF666666),
                      fontWeight: FontWeight.w500,
                    ),
                    textAlign: TextAlign.center,
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                  SizedBox(height: 2.h),
                  Text(
                    l10n.tapToSelectFromGallery,
                    style: TextStyle(
                      fontSize: 11.sp,
                      color: const Color(0xFF999999),
                      fontWeight: FontWeight.w400,
                    ),
                    textAlign: TextAlign.center,
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                ],
              ),
            ),
          ),
        ),

        // Display selected images in a grid/wrap
        if (selectedImages.isNotEmpty) ...[
          SizedBox(height: 12.h),
          Wrap(
            spacing: 8.w,
            runSpacing: 8.h,
            children: selectedImages.map((imagePath) {
              return _buildImageContainer(imagePath);
            }).toList(),
          ),
        ],
      ],
    );
  }

  Widget _buildImageContainer(String imagePath) {
    return Stack(
      children: [
        Container(
          width: 100.w,
          height: 100.w,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(12.r),
            border: Border.all(
              color: const Color(0xFFE0E0E0),
              width: 1.5,
            ),
          ),
          child: ClipRRect(
            borderRadius: BorderRadius.circular(12.r),
            child: Image.file(
              File(imagePath),
              fit: BoxFit.cover,
              errorBuilder: (context, error, stackTrace) {
                final l10n = AppLocalizations.of(context)!;
                return Container(
                  color: const Color(0xFFF5F5F5),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(
                        Icons.broken_image,
                        color: const Color(0xFF999999),
                        size: 24.w,
                      ),
                      SizedBox(height: 4.h),
                      Text(
                        l10n.imageError,
                        style: TextStyle(
                          fontSize: 10.sp,
                          color: const Color(0xFF999999),
                        ),
                      ),
                    ],
                  ),
                );
              },
            ),
          ),
        ),
        // Remove button (cross icon)
        Positioned(
          top: 4,
          right: 4,
          child: GestureDetector(
            onTap: () => onImageRemoved(imagePath),
            child: Container(
              width: 24.w,
              height: 24.w,
              decoration: BoxDecoration(
                color: Colors.black.withOpacity(0.7),
                shape: BoxShape.circle,
              ),
              child: Icon(
                Icons.close,
                color: Colors.white,
                size: 14.w,
              ),
            ),
          ),
        ),
      ],
    );
  }
}
