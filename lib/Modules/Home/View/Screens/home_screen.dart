import 'package:atella/core/constants/app_images.dart';
import 'package:atella/core/themes/app_fonts.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import '../../../../core/themes/app_colors.dart';
import '../../../../Widgets/custom_roundbutton.dart';
import '../Widgets/search_widget.dart';
import '../../Controllers/home_controller.dart';
import 'package:atella/Modules/Home/View/Screens/preview_screen.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final HomeController controller = Get.put(HomeController());

  // Static data for My Designs
  final List<Map<String, String>> myDesigns = [
    {
      'image': 'assets/images/grid1.png',
      'name': 'Project 1',
      'date': '13 July 2025',
    },
    {
      'image': 'assets/images/grid2.png',
      'name': 'Project 2',
      'date': '20Mar 2025',
    },
  ];

  // Static data for Collections
  final List<Map<String, String>> collections = [
    {
      'image': 'assets/images/grid2.png',
      'name': 'Project3',
      'date': '13 July 2025',
    },
    {
      'image': 'assets/images/grid1.png',
      'name': 'Project 4',
      'date': '20Mar 2025',
    },
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.backgroundColor,
      resizeToAvoidBottomInset: true,
      body: SingleChildScrollView(
        child: Column(
          children: [
            // ---------- Stack for background ----------
            Stack(
              children: [
                // 🔻 Background curved container
                Container(
                  decoration: const BoxDecoration(
                    color: Colors.black,
                    borderRadius: BorderRadius.only(
                      bottomLeft: Radius.circular(30),
                      bottomRight: Radius.circular(30),
                    ),
                  ),
                  child: ClipRRect(
                    borderRadius: const BorderRadius.only(
                      bottomLeft: Radius.circular(30),
                      bottomRight: Radius.circular(30),
                    ),
                    child: Image.asset(
                      'assets/images/home_container.png',
                      fit: BoxFit.cover,
                      width: double.infinity,
                      height: 300.h,
                    ),
                  ),
                ),
                // 🔺 Foreground content
                Padding(
                  padding: EdgeInsets.symmetric(horizontal: 24.w, vertical: 20.h),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      SizedBox(height: 20.h),
                      // Logo at top center
                      Center(
                        child: Image.asset(
                          homeLogo,
                          height: 60.h,
                          width: 37.w,
                          fit: BoxFit.cover,
                        ),
                      ),
                      SizedBox(height: 40.h),
                      Text(
                        'Welcome to ATELIA!',
                        style: TextStyle(
                          fontSize: 20.sp,
                          fontWeight: FontWeight.bold,
                          color: Colors.white,
                        ),
                      ),
                      SizedBox(height: 60.h),
                      SearchWidget(
                        controller: controller.searchController,
                        onChanged: controller.onSearchChanged,
                      ),
                      SizedBox(height: 32.h),
                    ],
                  ),
                ),
              ],
            ),
            // My Designs Section
            Padding(
              padding: EdgeInsets.symmetric(horizontal: 24.w, vertical: 16.h),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text('My Designs', style: hsTitleTextTextStyle18800),
                      GestureDetector(
                        onTap: (){
                          Get.toNamed('/my_designs');
                        },
                        child: Text('See All', style: ssTitleTextTextStyle14400),
                      ),
                    ],
                  ),
                  SizedBox(height: 12.h),
                  GridView.builder(
                    shrinkWrap: true,
                    physics: NeverScrollableScrollPhysics(),
                    itemCount: myDesigns.length,
                    gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                      crossAxisCount: 2,
                      crossAxisSpacing: 16.w,
                      mainAxisSpacing: 16.h,
                      childAspectRatio: 0.6,
                    ),
                    itemBuilder: (context, index) {
                      final project = myDesigns[index];
                      return GestureDetector(
                        onTap: () {
                          Get.to(() => PreviewScreen(
                            image: project['image']!,
                            title: project['name']! +' (Short-sleeve Shirt)',
                            version: 'V2',
                          ));
                        },
                        child: Container(
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(16),
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
                              ClipRRect(
                                borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
                                child: Image.asset(
                                  project['image']!,
                                  height: 177.h,
                                  width: 162.w,
                                  fit: BoxFit.cover,
                                ),
                              ),
                              Padding(
                                padding: EdgeInsets.all(12.w),
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      project['name']!,
                                      style: TextStyle(
                                        fontWeight: FontWeight.bold,
                                        fontSize: 14.sp,
                                      ),
                                    ),
                                    SizedBox(height: 6.h),
                                    Text(
                                      project['date']!,
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
                    },
                  ),
                ],
              ),
            ),
            // Collections Section
            Padding(
              padding: EdgeInsets.symmetric(horizontal: 24.w, vertical: 16.h),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text('Collections', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 20.sp)),
                      GestureDetector(
                        onTap: () {
                          Get.toNamed('/collections');
                        },
                        child: Text('See All', style: TextStyle(color: Colors.grey, fontSize: 14.sp)),
                      ),
                    ],
                  ),
                  SizedBox(height: 12.h),
                  GridView.builder(
                    shrinkWrap: true,
                    physics: NeverScrollableScrollPhysics(),
                    itemCount: collections.length,
                    gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                      crossAxisCount: 2,
                      crossAxisSpacing: 16.w,
                      mainAxisSpacing: 16.h,
                      childAspectRatio: 0.6,
                    ),
                    itemBuilder: (context, index) {
                      final project = collections[index];
                      return GestureDetector(
                        onTap: () {
                          Get.to(() => PreviewScreen(
                            image: project['image']!,
                            title: project['name']! + ' (Short-sleeve Shirt)',
                            version: 'V2',
                          ));
                        },
                        child: Container(
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(16),
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
                              ClipRRect(
                                borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
                                child: Image.asset(
                                  project['image']!,
                                  height: 177.h,
                                  width: 162.w,
                                  fit: BoxFit.cover,
                                ),
                              ),
                              Padding(
                                padding: EdgeInsets.all(12.w),
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      project['name']!,
                                      style: TextStyle(
                                        fontWeight: FontWeight.bold,
                                        fontSize: 14.sp,
                                      ),
                                    ),
                                    SizedBox(height: 6.h),
                                    Text(
                                      project['date']!,
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
                    },
                  ),
                ],
              ),
            ),
            // ------------- Start New Project Button --------------
            Padding(
              padding: const EdgeInsets.all(20.0),
              child: RoundButton(
                title: 'Start New Project',
                onTap: controller.startNewProject,
                color: AppColors.buttonColor,
                isloading: false,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
