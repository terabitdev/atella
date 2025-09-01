import 'package:atella/modules/tech_pack/Views/Screens/view_profile_tech_pack_screen.dart';
import 'package:atella/modules/tech_pack/Views/Widgets/segmented_tab_switcher.dart';
import 'package:atella/core/themes/app_fonts.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:country_picker/country_picker.dart';
import 'package:lottie/lottie.dart';
import 'package:atella/modules/tech_pack/Views/Widgets/manufacturer_suggestion_card.dart';
import 'package:atella/modules/tech_pack/controllers/manufacturer_suggestion_controller.dart';

class RecommendedManufactureScreen extends StatelessWidget {
  const RecommendedManufactureScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final controller = Get.put(ManufacturerSuggestionController());
    return Scaffold(
      backgroundColor: const Color(0xFFFDFDFD),
      body: SafeArea(
        child: Obx(
          () => Column(
            children: [
              SegmentedTabSwitcher(controller: controller),
              Expanded(
                child: controller.tabIndex.value == 0
                    ? recommendedTab(controller)
                    : customTab(controller),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

Widget recommendedTab(ManufacturerSuggestionController controller) {
  return RefreshIndicator(
    onRefresh: controller.refreshManufacturers,
    child: SingleChildScrollView(
      controller: controller.scrollController,
      padding: EdgeInsets.symmetric(horizontal: 18.w),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(height: 8.h),
          Text('Manufacturer Suggestions', style: mstTextTextStyle26700),
          SizedBox(height: 8.h),
          Obx(() => Text(
            controller.isLoading.value 
              ? 'Loading manufacturers...'
              : 'We found ${controller.allManufacturersCache.length} manufacturers from around the world.',
            style: mstTextTextStyle184001,
          )),
          SizedBox(height: 8.h),
          SizedBox(height: 18.h),
          Obx(() {
            if (controller.isLoading.value) {
              return Center(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Lottie.asset(
                      'assets/lottie/Loading_dots.json',
                      width: 100.w,
                      height: 100.h,
                      fit: BoxFit.cover,
                    ),
                    SizedBox(height: 16.h),
                    Text(
                      'Loading manufacturers...',
                      style: TextStyle(
                        fontSize: 16.sp,
                        color: const Color(0xFF666666),
                      ),
                    ),
                  ],
                ),
              );
            } else if (controller.error.value.isNotEmpty) {
              return Container(
                padding: EdgeInsets.all(16.r),
                margin: EdgeInsets.symmetric(vertical: 8.h),
                decoration: BoxDecoration(
                  color: Colors.red.shade50,
                  borderRadius: BorderRadius.circular(8.r),
                  border: Border.all(color: Colors.red.shade200),
                ),
                child: Text(
                  controller.error.value,
                  style: TextStyle(color: Colors.red.shade700),
                ),
              );
            } else if (controller.displayedManufacturers.isEmpty) {
              return Center(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(
                      Icons.inventory_2_outlined,
                      size: 64.sp,
                      color: Colors.grey,
                    ),
                    SizedBox(height: 16.h),
                    Text(
                      'No manufacturers available',
                      style: TextStyle(
                        fontSize: 16.sp,
                        color: Colors.grey,
                      ),
                    ),
                  ],
                ),
              );
            } else {
              return Column(
                children: [
                  ...controller.displayedManufacturers.map(
                    (manufacturer) => ManufacturerSuggestionCard(
                      manufacturer: manufacturer,
                      onViewProfile: () {},
                      onSendEmail: () => controller.sendEmailToManufacturer(manufacturer),
                    ),
                  ).toList(),
                  if (controller.isLoadingMore.value)
                    Padding(
                      padding: EdgeInsets.symmetric(vertical: 20.h),
                      child: Center(
                        child: Lottie.asset(
                          'assets/lottie/Loading_dots.json',
                          width: 60.w,
                          height: 60.h,
                          fit: BoxFit.cover,
                        ),
                      ),
                    ),
                  if (!controller.hasMoreData && controller.displayedManufacturers.isNotEmpty)
                    Padding(
                      padding: EdgeInsets.symmetric(vertical: 20.h),
                      child: Center(
                        child: Text(
                          'All manufacturers loaded',
                          style: TextStyle(
                            fontSize: 14.sp,
                            color: Colors.grey,
                          ),
                        ),
                      ),
                    ),
                ],
              );
            }
          }),
          SizedBox(height: 18.h),
        ],
      ),
    ),
  );
}

Widget customTab(ManufacturerSuggestionController controller) {
  return RefreshIndicator(
    onRefresh: controller.refreshManufacturers,
    child: SingleChildScrollView(
      padding: EdgeInsets.symmetric(horizontal: 18.w),
      physics: const AlwaysScrollableScrollPhysics(),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(height: 8.h),
          Text('Filter Manufacturers Manually', style: mstTextTextStyle26700),
          SizedBox(height: 8.h),
          Text(
            'Use filters below to search our full manufacturer directory:',
            style: mstTextTextStyle184001,
          ),
          SizedBox(height: 18.h),

        // Country or Region label
        Text('Country or Region', style: cstTextTextStyle16500),
        SizedBox(height: 8.h),

        // Country Picker
        Builder(
          builder: (BuildContext ctx) => Obx(
            () => InkWell(
              onTap: () {
                showCountryPicker(
                  context: ctx,
                  showPhoneCode: false,
                  onSelect: (Country country) {
                    controller.selectCountry(country);
                  },
                  countryListTheme: CountryListThemeData(
                    backgroundColor: Colors.white,
                    textStyle: TextStyle(fontSize: 16.sp),
                    searchTextStyle: TextStyle(fontSize: 16.sp),
                    inputDecoration: InputDecoration(
                      labelText: 'Search',
                      hintText: 'Start typing to search',
                      prefixIcon: const Icon(Icons.search),
                      border: OutlineInputBorder(
                        borderSide: BorderSide(
                          color: const Color(0xFF8C98A8).withValues(alpha: 0.2),
                        ),
                      ),
                    ),
                  ),
                );
              },
              child: Container(
                padding: EdgeInsets.symmetric(vertical: 14.h, horizontal: 16.w),
                decoration: BoxDecoration(
                  color: const Color.fromARGB(255, 227, 225, 251),
                  borderRadius: BorderRadius.circular(12.r),
                ),
                child: Row(
                  children: [
                    Expanded(
                      child: Text(
                        controller.selectedCountryName.value,
                        style: TextStyle(fontSize: 16.sp),
                      ),
                    ),
                    const Icon(Icons.arrow_drop_down),
                  ],
                ),
              ),
            ),
          ),
        ),

        SizedBox(height: 8.h),

        // Clear Filter button
        Obx(() => controller.selectedCountry.value != null
            ? TextButton(
                onPressed: controller.clearCountryFilter,
                child: Text(
                  'Clear Filter',
                  style: cstTextTextStyle16500.copyWith(
                    color: Colors.red,
                  ),
                ),
              )
            : const SizedBox.shrink()),

        SizedBox(height: 18.h),

          // Manufacturer list
          Obx(() {
            if (controller.isLoading.value) {
              return Center(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Lottie.asset(
                      'assets/lottie/Loading_dots.json',
                      width: 100.w,
                      height: 100.h,
                      fit: BoxFit.cover,
                    ),
                    SizedBox(height: 16.h),
                    Text(
                      'Loading manufacturers...',
                      style: TextStyle(
                        fontSize: 16.sp,
                        color: const Color(0xFF666666),
                      ),
                    ),
                  ],
                ),
              );
            } else if (controller.filteredManufacturers.isEmpty) {
              return Center(
                child: Padding(
                  padding: EdgeInsets.symmetric(vertical: 40.h),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(
                        Icons.search_off,
                        size: 64.sp,
                        color: Colors.grey,
                      ),
                      SizedBox(height: 16.h),
                      Text(
                        'No manufacturers found',
                        style: TextStyle(
                          fontSize: 16.sp,
                          color: Colors.grey,
                        ),
                      ),
                      if (controller.selectedCountry.value != null)
                        Padding(
                          padding: EdgeInsets.only(top: 8.h),
                          child: Text(
                            'Try clearing the filter',
                            style: TextStyle(
                              fontSize: 14.sp,
                              color: Colors.grey,
                            ),
                          ),
                        ),
                    ],
                  ),
                ),
              );
            } else {
              return Column(
                children: controller.filteredManufacturers.map(
                  (manufacturer) => ManufacturerSuggestionCard(
                    manufacturer: manufacturer,
                    onViewProfile: () {
                      Get.to(ViewProfileTechPackScreen());
                    },
                    onSendEmail: () => controller.sendEmailToManufacturer(manufacturer),
                  ),
                ).toList(),
              );
            }
          }),

          SizedBox(height: 18.h),
        ],
      ),
    ),
  );
}
