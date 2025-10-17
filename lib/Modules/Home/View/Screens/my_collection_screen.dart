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

class MyCollectionScreen extends StatefulWidget {
  const MyCollectionScreen({super.key});

  @override
  State<MyCollectionScreen> createState() => _MyCollectionScreenState();
}

class _MyCollectionScreenState extends State<MyCollectionScreen> {
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
                    'My Collections',
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
              // Dynamic content based on collections
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

                // Empty state - no collections
                if (!controller.hasCollections && controller.searchQuery.value.isEmpty) {
                  return HomeEmptyState(
                    onCreateProject: controller.startNewProject,
                  );
                }

                // Search empty state
                if (!controller.hasCollections && controller.searchQuery.value.isNotEmpty) {
                  return SearchEmptyState(
                    searchQuery: controller.searchQuery.value,
                    onClearSearch: controller.clearSearch,
                  );
                }

                // Show collections grouped by category
                final grouped = controller.groupedCollections;
                
                return Column(
                  children: grouped.entries.map((entry) {
                    final collectionName = entry.key;
                    final techPacks = entry.value;
                    
                    return Padding(
                      padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 8.h),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Text(
                                '$collectionName ',
                                style: hsTitleTextTextStyle18800,
                              ),
                              if (techPacks.length > 4)
                                GestureDetector(
                                  onTap: () {
                                    // Navigate to collection detail screen
                                    // You can implement this later if needed
                                  },
                                  child: Text('See All', style: ssTitleTextTextStyle14400),
                                ),
                            ],
                          ),
                          SizedBox(height: 12.h),
                          GridView.builder(
                            shrinkWrap: true,
                            physics: NeverScrollableScrollPhysics(),
                            itemCount: techPacks.length > 4 ? 4 : techPacks.length,
                            gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                              crossAxisCount: 2,
                              crossAxisSpacing: 16.w,
                              mainAxisSpacing: 16.h,
                              childAspectRatio: 0.6,
                            ),
                            itemBuilder: (context, index) {
                              final techPack = techPacks[index];
                              return DesignGridItem(
                                techPack: techPack,
                                showFavoriteIcon: true,
                                onTap: () {
                                  Get.to(() => PreviewScreen(
                                    techPack: techPack,
                                    version: 'Collection',
                                  ));
                                },
                                onFavoriteToggle: () {
                                  controller.toggleFavorite(techPack);
                                },
                              );
                            },
                          ),
                          SizedBox(height: 20.h),
                        ],
                      ),
                    );
                  }).toList(),
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
