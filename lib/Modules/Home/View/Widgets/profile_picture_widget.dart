import 'package:atella/core/constants/app_iamges.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

class ProfilePictureWidget extends StatelessWidget {
  final String? imageUrl;
  final VoidCallback? onEditTap;
  final double size;

  const ProfilePictureWidget({
    super.key,
    this.imageUrl,
    this.onEditTap,
    this.size = 120,
  });

  @override
  Widget build(BuildContext context) {
    return Stack(
      alignment: Alignment.bottomRight,
      children: [
        // Main profile picture
        Container(
          width: size.w,
          height: size.w,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            color: Colors.grey.shade200,
            image: DecorationImage(
              image: imageUrl != null
                  ? NetworkImage(imageUrl!)
                  : AssetImage(imageUrlIcon) as ImageProvider,
              fit: BoxFit.cover,
            ),
          ),
          // Optional fallback icon if needed when image fails
          child: imageUrl == null
              ? null
              : null, // you can add a fallback here if needed
        ),

        // Edit button
        GestureDetector(
          onTap: onEditTap,
          child: Image.asset(
            editbuttonIcon,
            height: 32.h,
            width: 32.w,
            fit: BoxFit.cover,
          ),
        ),
      ],
    );
  }
}
