import 'package:atella/core/constants/app_images.dart';
import 'package:atella/core/themes/app_fonts.dart';
import 'package:atella/l10n/generated/app_localizations.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:lottie/lottie.dart';
import '../../../../core/themes/app_colors.dart';
import '../../../../Widgets/custom_roundbutton.dart';
import '../../../../Widgets/empty_state_widget.dart';
import '../../../../Widgets/design_grid_item.dart';
import '../Widgets/search_widget.dart';
import '../../Controllers/home_controller.dart';
import 'package:atella/Modules/Home/View/Screens/preview_screen.dart';
import 'package:atella/core/widgets/tap_tracking_wrapper.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  late final HomeController controller;
  late final ScrollController _scrollController;
  bool _isSearchBarPinned = false;

  @override
  void initState() {
    super.initState();

    // If controller exists, delete it first to ensure fresh data after account switch
    if (Get.isRegistered<HomeController>()) {
      Get.delete<HomeController>(force: true);
      print('🔄 Deleted existing HomeController for fresh data');
    }

    // Use permanent to prevent disposal when navigating away
    controller = Get.put(HomeController(), permanent: true);
    print('✅ Created new HomeController');

    // Initialize scroll controller
    _scrollController = ScrollController();
    _scrollController.addListener(_onScroll);

    // Refresh data if coming back from another screen
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final args = Get.arguments;
      if (args != null && args['refresh'] == true) {
        controller.refreshData();
      }
    });
  }

  void _onScroll() {
    // Calculate the threshold: when search bar should pin (logo + welcome text + spacing)
    // 20 (top padding) + 60 (logo height) + 40 (spacing) + 18 (text height approx) + 60 (spacing) = ~198
    final double threshold = 170.h;

    if (_scrollController.offset >= threshold && !_isSearchBarPinned) {
      setState(() {
        _isSearchBarPinned = true;
      });
    } else if (_scrollController.offset < threshold && _isSearchBarPinned) {
      setState(() {
        _isSearchBarPinned = false;
      });
    }
  }

  @override
  void dispose() {
    _scrollController.removeListener(_onScroll);
    _scrollController.dispose();
    // Don't dispose the controller since it's permanent
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    return Scaffold(
      backgroundColor: AppColors.backgroundColor,
      resizeToAvoidBottomInset: true,
      body: TapTrackingWrapper(
        screenName: 'HomeScreen',
        child: Stack(
          children: [
            // Main scrollable content
            SingleChildScrollView(
              controller: _scrollController,
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
                      height: 280.h,
                    ),
                  ),
                ),
                // 🔺 Foreground content
                Padding(
                  padding: EdgeInsets.symmetric(horizontal: 24.w, vertical: 20.h),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      SizedBox(height: 30.h),
                      // Logo at top center
                      Center(
                        child: Image.asset(
                          homeLogo,
                          height: 60.h,
                          fit: BoxFit.contain,
                        ),
                      ),
                      SizedBox(height: 40.h),
                      Text(
                        l10n.welcomeToAtelia,
                        style: hTitleTextStyle18600,
                      ),
                      SizedBox(height: 20.h),
                      SearchWidget(
                        controller: controller.searchController,
                        onChanged: controller.onSearchChanged,
                        onClear: controller.clearSearch,
                      ),
                      SizedBox(height: 22.h),
                    ],
                  ),
                ),
              ],
            ),
            // My Designs Section
            Obx(() {
              if (controller.isLoading.value) {
                return Container(
                  height: 200.h,
                  padding: EdgeInsets.symmetric(horizontal: 24.w, vertical: 16.h),
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

              // Show empty state if no data and not searching
              if (!controller.hasAnyData && controller.searchQuery.value.isEmpty) {
                return Padding(
                  padding: EdgeInsets.symmetric(horizontal: 24.w, vertical: 16.h),
                  child: HomeEmptyState(
                    onCreateProject: controller.startNewProject,
                  ),
                );
              }

              // Show search empty state if searching with no results
              if (!controller.hasDesigns && controller.searchQuery.value.isNotEmpty) {
                return Padding(
                  padding: EdgeInsets.symmetric(horizontal: 24.w, vertical: 16.h),
                  child: SearchEmptyState(
                    searchQuery: controller.searchQuery.value,
                    onClearSearch: controller.clearSearch,
                  ),
                );
              }

              // Show designs section
              return Padding(
                padding: EdgeInsets.symmetric(horizontal: 24.w, vertical: 16.h),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(l10n.myDesigns, style: hsTitleTextTextStyle18800),
                        if (controller.hasDesigns)
                          GestureDetector(
                            onTap: () {
                              Get.toNamed('/my_designs');
                            },
                            child: Text(l10n.seeAll, style: ssTitleTextTextStyle14400),
                          ),
                      ],
                    ),
                    SizedBox(height: 12.h),
                    GridView.builder(
                      shrinkWrap: true,
                      physics: NeverScrollableScrollPhysics(),
                      itemCount: controller.myDesigns.length > 2 ? 2 : controller.myDesigns.length,
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
                              version: 'designs',
                            ));
                          },
                          onFavoriteToggle: () {
                            controller.toggleFavorite(techPack);
                          },
                        );
                      },
                    ),
                  ],
                ),
              );
            }),
            // Collections Section  
            Obx(() {
              // Don't show collections section during loading or if no collections
              if (controller.isLoading.value || !controller.hasCollections) {
                return SizedBox.shrink();
              }

              return Padding(
                padding: EdgeInsets.symmetric(horizontal: 24.w, vertical: 16.h),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(l10n.myCollections, style: hsTitleTextTextStyle18800),
                        if (controller.hasCollections)
                          GestureDetector(
                            onTap: () {
                              Get.toNamed('/collections');
                            },
                            child: Text(l10n.seeAll, style: ssTitleTextTextStyle14400),
                          ),
                      ],
                    ),
                    SizedBox(height: 12.h),
                    GridView.builder(
                      shrinkWrap: true,
                      physics: NeverScrollableScrollPhysics(),
                      itemCount: controller.myCollections.length > 2 ? 2 : controller.myCollections.length,
                      gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                        crossAxisCount: 2,
                        crossAxisSpacing: 16.w,
                        mainAxisSpacing: 16.h,
                        childAspectRatio: 0.6,
                      ),
                      itemBuilder: (context, index) {
                        final techPack = controller.myCollections[index];
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
                  ],
                ),
              );
            }),
            // ------------- Start New Project Button --------------
            Obx(() {
              // Only show button if user has data (not on empty state)
              if (controller.hasAnyData) {
                return Padding(
                  padding: const EdgeInsets.all(20.0),
                  child: RoundButton(
                    title: l10n.startNewProject,
                    onTap: controller.startNewProject,
                    color: AppColors.buttonColor,
                    isloading: false,
                  ),
                );
              }
              return SizedBox.shrink();
            }),
                ],
              ),
            ),
            // Pinned search bar overlay (appears when scrolled)
            if (_isSearchBarPinned)
              Positioned(
                top: 0,
                left: 0,
                right: 0,
                child: Container(
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
                    child: Container(
                      decoration: BoxDecoration(
                        image: DecorationImage(
                          image: AssetImage('assets/images/home_container.png'),
                          fit: BoxFit.cover,
                        ),
                      ),
                      padding: EdgeInsets.only(
                        left: 24.w,
                        right: 24.w,
                        top: 40.h,
                        bottom: 16.h,
                      ),
                      child: SearchWidget(
                        controller: controller.searchController,
                        onChanged: controller.onSearchChanged,
                        onClear: controller.clearSearch,
                      ),
                    ),
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }
}
