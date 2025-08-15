import 'package:atella/Modules/Home/Controllers/home_controller.dart';
import 'package:atella/Modules/Home/View/Widgets/search_widget.dart';
import 'package:atella/Modules/Home/View/Screens/preview_screen.dart';
import 'package:atella/Widgets/custom_roundbutton.dart';
import 'package:atella/Widgets/design_grid_item.dart';
import 'package:atella/Widgets/empty_state_widget.dart';
import 'package:atella/core/themes/app_fonts.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:lottie/lottie.dart';
import 'package:get/get.dart';

class MyDesignScreen extends StatefulWidget {
  const MyDesignScreen({super.key});

  @override
  State<MyDesignScreen> createState() => _MyDesignScreenState();
}

class _MyDesignScreenState extends State<MyDesignScreen> {
  final controller = Get.find<HomeController>();

  @override
  void initState() {
    super.initState();
    controller.refreshData();
  }
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Padding(
        padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 54.h),
        child: SingleChildScrollView(
          child: Column(
            children: [
              Row(
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
                    'My Designs',
                    style: ssTitleTextTextStyle208001.copyWith(
                      color: Colors.black,
                    ),
                  ),
                ],
              ),
              SizedBox(height: 34.h),
              SearchWidget(
                controller: controller.searchController,
                onChanged: controller.onSearchChanged,
                onClear: controller.clearSearch,
              ),
              SizedBox(height: 20.h),
              // Dynamic content based on designs
              Obx(() {
                // Loading state
                if (controller.isLoading.value) {
                  return Container(
                    height: 200.h,
                    child: Center(
                      child: Lottie.asset(
                        'assets/lottie/Loading_dots.json',
                        width: 100.w,
                        height: 100.h,
                        fit: BoxFit.cover,
                      ),
                    ),
                  );
                }

                // Empty state - no designs
                if (!controller.hasDesigns && controller.searchQuery.value.isEmpty) {
                  return HomeEmptyState(
                    onCreateProject: controller.startNewProject,
                  );
                }

                // Search empty state
                if (!controller.hasDesigns && controller.searchQuery.value.isNotEmpty) {
                  return SearchEmptyState(
                    searchQuery: controller.searchQuery.value,
                    onClearSearch: controller.clearSearch,
                  );
                }

                // Show designs grid
                return Padding(
                  padding: EdgeInsets.symmetric(horizontal: 16.w),
                  child: GridView.builder(
                    shrinkWrap: true,
                    physics: NeverScrollableScrollPhysics(),
                    itemCount: controller.myDesigns.length,
                    gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                      crossAxisCount: 2,
                      crossAxisSpacing: 16.w,
                      mainAxisSpacing: 16.h,
                      childAspectRatio: 0.6,
                    ),
                    itemBuilder: (context, index) {
                      final techPack = controller.myDesigns[index];
                      return DesignGridItem(
                        techPack: techPack,
                        showFavoriteIcon: true,
                        onTap: () {
                          Get.to(() => PreviewScreen(
                            techPack: techPack,
                            version: 'V2',
                          ));
                        },
                        onFavoriteToggle: () {
                          controller.toggleFavorite(techPack);
                        },
                      );
                    },
                  ),
                );
              }),
              SizedBox(height: 20.h),
              RoundButton(
                title: 'Create New Design',
                onTap: controller.startNewProject,
                color: Colors.black,
                isloading: false,
              )
            ],
          ),
        ),
      ),
    );
  }
}
