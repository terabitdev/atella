import 'package:atella/core/constants/app_iamges.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

class AddProfilePicture extends StatelessWidget {
  final VoidCallback onTap;
  final String? imagePath;

  const AddProfilePicture({Key? key, required this.onTap, this.imagePath})
    : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        GestureDetector(
          onTap: onTap,
          child: Container(
            height: 96.h,
            width: 96.h,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              border: Border.all(
                color: const Color.fromRGBO(246, 121, 82, 1),
                style: BorderStyle.solid,
                width: 2,
              ),
            ),
            child: Center(
              child: imagePath == null
                  ? Image.asset(cameraIcon, height: 32.h, width: 32.w)
                  : ClipOval(
                      child: Image.asset(
                        imagePath!,
                        height: 96.h,
                        width: 96.h,
                        fit: BoxFit.cover,
                      ),
                    ),
            ),
          ),
        ),
        SizedBox(height: 12.h),
        Text(
          "Add Profile Picture",
          style: TextStyle(fontSize: 15.sp, fontWeight: FontWeight.w600),
        ),
        SizedBox(height: 25.h),
      ],
    );
  }
}
