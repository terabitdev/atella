import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import '../Data/Models/tech_pack_model.dart';
import 'dart:convert';

class DesignGridItem extends StatelessWidget {
  final TechPackModel techPack;
  final bool showFavoriteIcon;
  final VoidCallback? onTap;
  final VoidCallback? onFavoriteToggle;

  const DesignGridItem({
    super.key,
    required this.techPack,
    this.showFavoriteIcon = true,
    this.onTap,
    this.onFavoriteToggle,
  });

  Widget _buildImage() {
    final imageUrl = techPack.displayImage;
    
    // Debug: Print the image URL being used
    print('Loading image for ${techPack.projectName}: $imageUrl');
    
    if (imageUrl == null) {
      return Container(
        height: 177.h,
        width: double.infinity,
        color: Colors.grey[200],
        child: Icon(
          Icons.image_not_supported_outlined,
          size: 48.w,
          color: Colors.grey[400],
        ),
      );
    }

    // Check if it's a base64 encoded image or a URL
    if (imageUrl.startsWith('data:image/')) {
      // Base64 image
      try {
        final base64String = imageUrl.split(',')[1];
        final bytes = base64Decode(base64String);
        return Image.memory(
          bytes,
          height: 177.h,
          width: double.infinity,
          fit: BoxFit.cover,
          errorBuilder: (context, error, stackTrace) {
            return Container(
              height: 177.h,
              width: double.infinity,
              color: Colors.grey[200],
              child: Icon(
                Icons.broken_image_outlined,
                size: 48.w,
                color: Colors.grey[400],
              ),
            );
          },
        );
      } catch (e) {
        return Container(
          height: 177.h,
          width: double.infinity,
          color: Colors.grey[200],
          child: Icon(
            Icons.broken_image_outlined,
            size: 48.w,
            color: Colors.grey[400],
          ),
        );
      }
    } else {
      // Network image URL - use Image.network directly
      return Image.network(
        imageUrl,
        height: 177.h,
        width: double.infinity,
        fit: BoxFit.cover,
        loadingBuilder: (context, child, loadingProgress) {
          if (loadingProgress == null) return child;
          return Container(
            height: 177.h,
            width: double.infinity,
            color: Colors.grey[100],
            child: Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  CircularProgressIndicator(
                    value: loadingProgress.expectedTotalBytes != null
                        ? loadingProgress.cumulativeBytesLoaded /
                            loadingProgress.expectedTotalBytes!
                        : null,
                    strokeWidth: 2,
                    color: Colors.black54,
                  ),
                  SizedBox(height: 8.h),
                  Text(
                    'Loading...',
                    style: TextStyle(
                      fontSize: 12.sp,
                      color: Colors.grey[600],
                    ),
                  ),
                ],
              ),
            ),
          );
        },
        errorBuilder: (context, error, stackTrace) {
          print('Image.network error for $imageUrl: $error');
          return Container(
            height: 177.h,
            width: double.infinity,
            color: Colors.grey[200],
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(
                  Icons.broken_image_outlined,
                  size: 48.w,
                  color: Colors.grey[400],
                ),
                Text(
                  'Image failed',
                  style: TextStyle(
                    fontSize: 10.sp,
                    color: Colors.grey[500],
                  ),
                ),
              ],
            ),
          );
        },
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16.r),
          boxShadow: [
            BoxShadow(
              color: Colors.grey.withOpacity(0.1),
              blurRadius: 8,
              offset: Offset(0, 4),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Image with optional favorite icon
            Stack(
              children: [
                ClipRRect(
                  borderRadius: BorderRadius.vertical(top: Radius.circular(16.r)),
                  child: _buildImage(),
                ),
                
                // Favorite icon overlay
                if (showFavoriteIcon)
                  Positioned(
                    top: 8.h,
                    right: 8.w,
                    child: GestureDetector(
                      onTap: onFavoriteToggle,
                      child: Container(
                        padding: EdgeInsets.all(4.w),
                        decoration: BoxDecoration(
                          color: Colors.white.withOpacity(0.9),
                          borderRadius: BorderRadius.circular(20.r),
                        ),
                        child: Icon(
                          techPack.isFavorite ? Icons.favorite : Icons.favorite_border,
                          color: techPack.isFavorite ? Colors.red : Colors.black,
                          size: 20.sp,
                        ),
                      ),
                    ),
                  ),
              ],
            ),
            
            // Project details
            Padding(
              padding: EdgeInsets.all(12.w),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    techPack.projectName,
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 14.sp,
                      color: Colors.black,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  
                  SizedBox(height: 4.h),
                  
                  Text(
                    techPack.collectionName,
                    style: TextStyle(
                      fontSize: 12.sp,
                      color: Colors.grey[600],
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  
                  SizedBox(height: 6.h),
                  
                  Text(
                    _formatDate(techPack.createdAt),
                    style: TextStyle(
                      color: Colors.grey,
                      fontSize: 11.sp,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  String _formatDate(DateTime date) {
    final months = [
      'Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun',
      'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec'
    ];
    
    return '${date.day} ${months[date.month - 1]} ${date.year}';
  }
}