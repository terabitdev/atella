import 'package:atella/core/themes/app_fonts.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';

class RevisionHistoryScreen extends StatefulWidget {
  const RevisionHistoryScreen({Key? key}) : super(key: key);

  @override
  State<RevisionHistoryScreen> createState() => _RevisionHistoryScreenState();
}

class _RevisionHistoryScreenState extends State<RevisionHistoryScreen> {
  // Static revision data
  final List<Map<String, String>> revisions = [
    {
      'image': 'assets/images/grid1.png',
      'title': 'Final Version',
      'date': '26 July 2025',
    },
    {
      'image': 'assets/images/grid1.png',
      'title': 'Fabric Modified',
      'date': '18 July 2025',
    },
    {
      'image': 'assets/images/grid1.png',
      'title': 'Color Updated',
      'date': '26 July 2025',
    },
    {
      'image': 'assets/images/grid1.png',
      'title': 'Version 1',
      'date': '26 July 2025',
    },
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: EdgeInsets.symmetric(horizontal: 24.w, vertical: 54.h),
            child: Row(
              children: [
                InkWell(
                  onTap: () => Get.back(),
                  child: Image.asset(
                    'assets/images/Arrow_Left.png',
                    height: 40.h,
                    width: 40.w,
                  ),
                ),
                SizedBox(width: 8.w),
                Text(
                  'Revision History',
                  style: TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                    fontSize: 20.sp,
                  ),
                ),
              ],
            ),
          ),
          SizedBox(height: 10.h),
          Expanded(
            child: Container(
              width: double.infinity,
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.only(
                  topLeft: Radius.circular(30.r),
                  topRight: Radius.circular(30.r),
                ),
              ),
              padding: EdgeInsets.symmetric(horizontal: 0, vertical: 0),
              child: ListView.separated(
                padding: EdgeInsets.symmetric(vertical: 24.h, horizontal: 0),
                itemCount: revisions.length,
                separatorBuilder: (context, index) => Divider(height: 1, color: Colors.grey.shade300),
                itemBuilder: (context, index) {
                  final revision = revisions[index];
                  return Padding(
                    padding: EdgeInsets.symmetric(horizontal: 24.w, vertical: 12.h),
                    child: Container(
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(16),
                      ),
                      child: Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          ClipRRect(
                            borderRadius: BorderRadius.circular(12),
                            child: Image.asset(
                              revision['image']!,
                              width: 105.w,
                              height: 105.w,
                              fit: BoxFit.cover,
                            ),
                          ),
                          SizedBox(width: 16.w),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                SizedBox(height: 4.h),
                                Text(
                                  revision['title']!,
                                  style: rhsTitleTextTextStyle20700,
                                ),
                                SizedBox(height: 4.h),
                                Text(
                                  revision['date']!,
                                  style: rhsTitleTextTextStyle16400,
                                ),
                                SizedBox(height: 12.h),
                                Row(
                                  children: [
                                    Expanded(
                                      child: OutlinedButton(
                                        onPressed: () {
                                        },
                                        style: OutlinedButton.styleFrom(
                                          side: BorderSide(color: Colors.grey.shade300),
                                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(7)),
                                          padding: EdgeInsets.symmetric(vertical: 0),
                                        ),
                                        child: Text('Restore', style: rhsTitleTextTextStyle12500),
                                      ),
                                    ),
                                    SizedBox(width: 12.w),
                                    Expanded(
                                      child: OutlinedButton(
                                        onPressed: () {
                                        },
                                        style: OutlinedButton.styleFrom(
                                          side: BorderSide(color: Colors.grey.shade300),
                                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(7)),
                                          padding: EdgeInsets.symmetric(vertical: 0),
                                        ),
                                        child: Text('Preview', style: rhsTitleTextTextStyle12500),
                                      ),
                                    ),
                                  ],
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                  );
                },
              ),
            ),
          ),
        ],
      ),
    );
  }
}
