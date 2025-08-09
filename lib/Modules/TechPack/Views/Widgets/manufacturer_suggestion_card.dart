// ignore_for_file: public_member_api_docs, sort_constructors_first
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

class ManufacturerSuggestionCard extends StatelessWidget {
  final String name;
  final String location;
  final String moq;
  final String description;
  final VoidCallback onViewProfile;
  final VoidCallback onContact;
  const ManufacturerSuggestionCard({
    super.key,
    required this.name,
    required this.location,
    required this.moq,
    required this.description,
    required this.onViewProfile,
    required this.onContact,
  });
  @override
  Widget build(BuildContext context) {
    return Container(
      margin: EdgeInsets.symmetric(vertical: 10.h),
      padding: EdgeInsets.all(18.r),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(18.r),
        boxShadow: [
          BoxShadow(
            color: Colors.black,
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
        border: Border.all(color: const Color(0xFFE0E0E0)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            name,
            style: TextStyle(fontWeight: FontWeight.w700, fontSize: 20.sp),
          ),
          SizedBox(height: 8.h),
          Row(
            children: [
              Icon(Icons.location_on, color: Color(0xFFFF2D55), size: 20.w),
              SizedBox(width: 4.w),
              Expanded(
                child: Text(location, style: TextStyle(fontSize: 15.sp)),
              ),
              Text(
                moq,
                style: TextStyle(
                  fontWeight: FontWeight.w500,
                  fontSize: 15.sp,
                ),
              ),
            ],
          ),
          SizedBox(height: 10.h),
          Text(
            description,
            style: TextStyle(fontSize: 15.sp, color: Color(0xFF222222)),
          ),
          SizedBox(height: 16.h),
          Row(
            children: [
              Expanded(
                child: OutlinedButton(
                  onPressed: onViewProfile,
                  style: OutlinedButton.styleFrom(
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8.r),
                    ),
                    side: const BorderSide(color: Colors.black, width: 1),
                    padding: EdgeInsets.symmetric(vertical: 12.h),
                  ),
                  child: const Text(
                    'View Profile',
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
                  onPressed: onContact,
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
}
