import 'package:atella/Modules/tech_pack/controllers/manufacturer_suggestion_controller.dart';
import 'package:atella/Modules/tech_pack/Views/Screens/view_profile_tech_pack_screen.dart';
import 'package:atella/Modules/tech_pack/Views/Widgets/segmented_tab_switcher.dart';
import 'package:atella/core/themes/app_fonts.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:lottie/lottie.dart';
import 'package:atella/Modules/tech_pack/Views/Widgets/manufacturer_suggestion_card.dart';

class RecommendedManufactureScreen extends StatelessWidget {
  const RecommendedManufactureScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final controller = Get.put(ManufacturerSuggestionController());
    return Scaffold(
      backgroundColor: const Color(0xFFFDFDFD),
      body: SafeArea(
        child: Stack(
          children: [
            Obx(
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
            // Full screen loading overlay
            Obx(
              () => controller.isSendingEmail.value
                  ? Container(
                      color: Colors.black.withValues(alpha: 0.5),
                      child: Center(
                        child: Container(
                          padding: EdgeInsets.all(24.r),
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(16.r),
                          ),
                          child: Column(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Lottie.asset(
                                'assets/lottie/Loading_dots.json',
                                width: 80.w,
                                height: 80.h,
                                fit: BoxFit.cover,
                              ),
                              SizedBox(height: 16.h),
                              Text(
                                'Sending Email...',
                                style: TextStyle(
                                  fontSize: 18.sp,
                                  fontWeight: FontWeight.w600,
                                  color: Colors.black,
                                ),
                              ),
                              SizedBox(height: 8.h),
                              Text(
                                'Preparing your tech pack\nand sending to manufacturer',
                                textAlign: TextAlign.center,
                                style: TextStyle(
                                  fontSize: 14.sp,
                                  color: Colors.grey[600],
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    )
                  : const SizedBox.shrink(),
            ),
          ],
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
          Obx(
            () => Text(
              controller.isLoading.value
                  ? 'Loading manufacturers...'
                  : 'We found ${controller.allManufacturersCache.length} manufacturers from around the world.',
              style: mstTextTextStyle184001,
            ),
          ),
          SizedBox(height: 8.h),
          SizedBox(height: 18.h),
          Obx(() {
            final manufacturers = controller.displayedManufacturers;

            if (controller.isLoading.value && manufacturers.isEmpty) {
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
            } else if (manufacturers.isEmpty && !controller.isLoading.value) {
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
                      style: TextStyle(fontSize: 16.sp, color: Colors.grey),
                    ),
                  ],
                ),
              );
            } else {
              return Column(
                children: [
                  ...manufacturers.map(
                    (manufacturer) => ManufacturerSuggestionCard(
                      manufacturer: manufacturer,
                      onViewProfile: () {},
                      onSendEmail: () =>
                          controller.previewEmailToManufacturer(manufacturer),
                    ),
                  ),
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
                  if (!controller.hasMoreData && manufacturers.isNotEmpty)
                    Padding(
                      padding: EdgeInsets.symmetric(vertical: 20.h),
                      child: Center(
                        child: Text(
                          'All manufacturers loaded',
                          style: TextStyle(fontSize: 14.sp, color: Colors.grey),
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
          Text('Filter Manufacturers', style: mstTextTextStyle26700),
          SizedBox(height: 8.h),
          Text(
            'Use filters below to search our manufacturer directory:',
            style: mstTextTextStyle184001,
          ),
          SizedBox(height: 18.h),

          // Country Filter
          Obx(() {
            if (controller.availableCountries.isEmpty) {
              return const SizedBox.shrink();
            }
            return Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('Country or Region', style: cstTextTextStyle16500),
                SizedBox(height: 8.h),
                InkWell(
                  onTap: () => _showCountryPicker(controller),
                  child: Container(
                    padding: EdgeInsets.symmetric(
                      vertical: 14.h,
                      horizontal: 16.w,
                    ),
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
                SizedBox(height: 16.h),
              ],
            );
          }),

          // Product Filter
          Obx(() {
            if (controller.availableProducts.isEmpty) {
              return const SizedBox.shrink();
            }
            return Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('Product Type', style: cstTextTextStyle16500),
                SizedBox(height: 8.h),
                InkWell(
                  onTap: () => _showProductPicker(controller),
                  child: Container(
                    padding: EdgeInsets.symmetric(
                      vertical: 14.h,
                      horizontal: 16.w,
                    ),
                    decoration: BoxDecoration(
                      color: const Color.fromARGB(255, 227, 225, 251),
                      borderRadius: BorderRadius.circular(12.r),
                    ),
                    child: Row(
                      children: [
                        Expanded(
                          child: Text(
                            controller.selectedProduct.value,
                            style: TextStyle(fontSize: 16.sp),
                          ),
                        ),
                        const Icon(Icons.arrow_drop_down),
                      ],
                    ),
                  ),
                ),
                SizedBox(height: 16.h),
              ],
            );
          }),

          // Certification Filter
          Obx(() {
            if (controller.availableCertifications.isEmpty) {
              return const SizedBox.shrink();
            }
            return Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('Certification', style: cstTextTextStyle16500),
                SizedBox(height: 8.h),
                InkWell(
                  onTap: () => _showCertificationPicker(controller),
                  child: Container(
                    padding: EdgeInsets.symmetric(
                      vertical: 14.h,
                      horizontal: 16.w,
                    ),
                    decoration: BoxDecoration(
                      color: const Color.fromARGB(255, 227, 225, 251),
                      borderRadius: BorderRadius.circular(12.r),
                    ),
                    child: Row(
                      children: [
                        Expanded(
                          child: Text(
                            controller.selectedCertification.value,
                            style: TextStyle(fontSize: 16.sp),
                          ),
                        ),
                        const Icon(Icons.arrow_drop_down),
                      ],
                    ),
                  ),
                ),
                SizedBox(height: 8.h),
              ],
            );
          }),

          // Clear All Filters button
          Obx(
            () => (controller.selectedCountryName.value != 'All Countries' ||
                    controller.selectedProduct.value != 'All Products' ||
                    controller.selectedCertification.value != 'All Certifications')
                ? TextButton(
                    onPressed: controller.clearAllFilters,
                    child: Text(
                      'Clear All Filters',
                      style: cstTextTextStyle16500.copyWith(color: Colors.red),
                    ),
                  )
                : const SizedBox.shrink(),
          ),

          SizedBox(height: 18.h),

          // Manufacturer list
          Obx(() {
            final filteredManufacturers = controller.filteredManufacturers;

            if (controller.allManufacturersCache.isEmpty) {
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
            } else if (filteredManufacturers.isEmpty) {
              return Center(
                child: Padding(
                  padding: EdgeInsets.symmetric(vertical: 40.h),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(Icons.search_off, size: 64.sp, color: Colors.grey),
                      SizedBox(height: 16.h),
                      Text(
                        'No manufacturers found',
                        style: TextStyle(fontSize: 16.sp, color: Colors.grey),
                      ),
                      Padding(
                        padding: EdgeInsets.only(top: 8.h),
                        child: Text(
                          'Try adjusting your filters',
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
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    '${filteredManufacturers.length} manufacturer${filteredManufacturers.length == 1 ? '' : 's'} found',
                    style: TextStyle(
                      fontSize: 14.sp,
                      color: const Color(0xFF666666),
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                  SizedBox(height: 12.h),
                  ...filteredManufacturers.map(
                    (manufacturer) => ManufacturerSuggestionCard(
                      manufacturer: manufacturer,
                      onViewProfile: () {
                        Get.to(ViewProfileTechPackScreen());
                      },
                      onSendEmail: () =>
                          controller.previewEmailToManufacturer(manufacturer),
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

void _showCountryPicker(ManufacturerSuggestionController controller) {
  Get.bottomSheet(
    Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.only(
          topLeft: Radius.circular(20.r),
          topRight: Radius.circular(20.r),
        ),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Padding(
            padding: EdgeInsets.all(16.r),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'Select Country',
                  style: TextStyle(
                    fontSize: 18.sp,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                IconButton(
                  onPressed: () => Get.back(),
                  icon: const Icon(Icons.close),
                ),
              ],
            ),
          ),
          const Divider(height: 1),
          Flexible(
            child: ListView(
              shrinkWrap: true,
              children: [
                ListTile(
                  title: const Text('All Countries'),
                  trailing: controller.selectedCountryName.value == 'All Countries'
                      ? const Icon(Icons.check, color: Colors.green)
                      : null,
                  onTap: () {
                    controller.clearCountryFilter();
                    Get.back();
                  },
                ),
                ...controller.availableCountries.map((country) {
                  return ListTile(
                    title: Text(country),
                    trailing: controller.selectedCountryName.value == country
                        ? const Icon(Icons.check, color: Colors.green)
                        : null,
                    onTap: () {
                      controller.selectCountry(country);
                      Get.back();
                    },
                  );
                }),
              ],
            ),
          ),
          SizedBox(height: 20.h),
        ],
      ),
    ),
  );
}

void _showProductPicker(ManufacturerSuggestionController controller) {
  Get.bottomSheet(
    Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.only(
          topLeft: Radius.circular(20.r),
          topRight: Radius.circular(20.r),
        ),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Padding(
            padding: EdgeInsets.all(16.r),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'Select Product Type',
                  style: TextStyle(
                    fontSize: 18.sp,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                IconButton(
                  onPressed: () => Get.back(),
                  icon: const Icon(Icons.close),
                ),
              ],
            ),
          ),
          const Divider(height: 1),
          Flexible(
            child: ListView(
              shrinkWrap: true,
              children: [
                ListTile(
                  title: const Text('All Products'),
                  trailing: controller.selectedProduct.value == 'All Products'
                      ? const Icon(Icons.check, color: Colors.green)
                      : null,
                  onTap: () {
                    controller.clearProductFilter();
                    Get.back();
                  },
                ),
                ...controller.availableProducts.map((product) {
                  return ListTile(
                    title: Text(product),
                    trailing: controller.selectedProduct.value == product
                        ? const Icon(Icons.check, color: Colors.green)
                        : null,
                    onTap: () {
                      controller.selectProduct(product);
                      Get.back();
                    },
                  );
                }),
              ],
            ),
          ),
          SizedBox(height: 20.h),
        ],
      ),
    ),
  );
}

void _showCertificationPicker(ManufacturerSuggestionController controller) {
  Get.bottomSheet(
    Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.only(
          topLeft: Radius.circular(20.r),
          topRight: Radius.circular(20.r),
        ),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Padding(
            padding: EdgeInsets.all(16.r),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'Select Certification',
                  style: TextStyle(
                    fontSize: 18.sp,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                IconButton(
                  onPressed: () => Get.back(),
                  icon: const Icon(Icons.close),
                ),
              ],
            ),
          ),
          const Divider(height: 1),
          Flexible(
            child: ListView(
              shrinkWrap: true,
              children: [
                ListTile(
                  title: const Text('All Certifications'),
                  trailing: controller.selectedCertification.value == 'All Certifications'
                      ? const Icon(Icons.check, color: Colors.green)
                      : null,
                  onTap: () {
                    controller.clearCertificationFilter();
                    Get.back();
                  },
                ),
                ...controller.availableCertifications.map((cert) {
                  return ListTile(
                    title: Text(cert),
                    trailing: controller.selectedCertification.value == cert
                        ? const Icon(Icons.check, color: Colors.green)
                        : null,
                    onTap: () {
                      controller.selectCertification(cert);
                      Get.back();
                    },
                  );
                }),
              ],
            ),
          ),
          SizedBox(height: 20.h),
        ],
      ),
    ),
  );
}
