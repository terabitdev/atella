import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

class TextInputWithSend extends StatelessWidget {
  final TextEditingController controller;
  final String placeholder;
  final VoidCallback onSend;
  final bool isLoading;

  const TextInputWithSend({
    super.key,
    required this.controller,
    required this.placeholder,
    required this.onSend,
    this.isLoading = false,
  }) ;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 24.w, vertical: 20.h),
      color: Colors.white,
      child: Row(
        children: [
          Expanded(
            child: Container(
              decoration: BoxDecoration(
                color: const Color.fromRGBO(236, 239, 246, 1),
                borderRadius: BorderRadius.circular(12.r),
              ),
              child: TextField(
                controller: controller,
                decoration: InputDecoration(
                  hintText: placeholder,
                  hintStyle: TextStyle(color: Colors.black, fontSize: 16.sp),
                  border: InputBorder.none,
                  contentPadding: EdgeInsets.symmetric(
                    horizontal: 16.w,
                    vertical: 14.h,
                  ),
                  suffixIcon: IconButton(
                    icon: const Icon(Icons.clear, color: Colors.grey),
                    onPressed: () => controller.clear(),
                  ),
                ),
                style: TextStyle(fontSize: 16.sp, color: Colors.black),
              ),
            ),
          ),
          SizedBox(width: 16.w),
          GestureDetector(
            onTap: onSend,
            child: isLoading
                ? Center(
                    child: SizedBox(
                      width: 24.w,
                      height: 24.h,
                      child: const CircularProgressIndicator(
                        color: Colors.white,
                        strokeWidth: 2,
                      ),
                    ),
                  )
                : Image.asset('assets/images/send.png', width: 48.w, height: 48.h),
          ),
        ],
      ),
    );
  }
}
