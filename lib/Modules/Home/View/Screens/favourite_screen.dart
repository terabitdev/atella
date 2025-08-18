import 'package:atella/modules/home/Controllers/home_controller.dart';
import 'package:atella/modules/home/View/Widgets/search_widget.dart';
import 'package:atella/Widgets/custom_roundbutton.dart';
import 'package:atella/Widgets/empty_state_widget.dart';
import 'package:atella/Widgets/design_grid_item.dart';
import 'package:atella/core/themes/app_fonts.dart';
import 'package:atella/core/themes/app_colors.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:lottie/lottie.dart';
import 'package:get/get.dart';

class FavouriteScreen extends StatefulWidget {
  const FavouriteScreen({super.key});

  @override
  State<FavouriteScreen> createState() => _FavouriteScreenState();
}

class _FavouriteScreenState extends State<FavouriteScreen> {
  // Get the existing HomeController instance
  final controller = Get.find<HomeController>();

  @override
  void initState() {
    super.initState();
    // Refresh favorites when screen opens
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
                  Align(
                    alignment: Alignment.centerLeft,
                    child: Text(
                      'Favorites',
                      style: ssTitleTextTextStyle208001.copyWith(
                        color: Colors.black,
                      ),
                    ),
                  ),
              
              SizedBox(height: 34.h),
              SearchWidget(
                controller: controller.searchController,
                onChanged: controller.onSearchChanged,
              ),
              SizedBox(height: 20.h),
              // Dynamic content based on favorites
              Obx(() {
                  // Loading state
                  if (controller.isLoading.value) {
                    return Center(
                      child: Lottie.asset(
                        'assets/lottie/Loading_dots.json',
                        width: 100.w,
                        height: 100.h,
                        fit: BoxFit.cover,
                      ),
                    );
                  }

                  // Empty state - no favorites
                  if (!controller.hasFavorites && controller.searchQuery.value.isEmpty) {
                    return FavoritesEmptyState(
                      onCreateProject: controller.startNewProject,
                    );
                  }

                  // Search empty state
                  if (!controller.hasFavorites && controller.searchQuery.value.isNotEmpty) {
                    return SearchEmptyState(
                      searchQuery: controller.searchQuery.value,
                      onClearSearch: controller.clearSearch,
                    );
                  }

                  // Show favorites grid
                  return SingleChildScrollView(
                    child: Padding(
                      padding: EdgeInsets.symmetric(horizontal: 16.w),
                      child: Column(
                        children: [
                          GridView.builder(
                            shrinkWrap: true,
                            physics: NeverScrollableScrollPhysics(),
                            itemCount: controller.favorites.length,
                            gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                              crossAxisCount: 2,
                              crossAxisSpacing: 16.w,
                              mainAxisSpacing: 16.h,
                              childAspectRatio: 0.6,
                            ),
                            itemBuilder: (context, index) {
                              final techPack = controller.favorites[index];
                              return DesignGridItem(
                                techPack: techPack,
                                showFavoriteIcon: true,
                                onTap: () {
                                  // Navigate to preview or details
                                },
                                onFavoriteToggle: () {
                                  controller.toggleFavorite(techPack);
                                },
                              );
                            },
                          ),
                          SizedBox(height: 20.h),
                          // Create new design button (only show if there are favorites)
                          if (controller.hasFavorites)
                            RoundButton(
                              title: 'Create New Design',
                              onTap: controller.startNewProject,
                              color: AppColors.buttonColor,
                              isloading: false,
                            ),
                          SizedBox(height: 20.h),
                        ],
                      ),
                    ),
                  );
                }),
            ],
          ),
        ),
      ),
    );
  }
}