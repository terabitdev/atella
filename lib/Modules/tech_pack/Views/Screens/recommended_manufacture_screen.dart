import 'package:atella/Modules/tech_pack/controllers/manufacturer_suggestion_controller.dart';
import 'package:atella/Modules/tech_pack/Views/Screens/view_profile_tech_pack_screen.dart';
import 'package:atella/Modules/tech_pack/Views/Widgets/segmented_tab_switcher.dart';
import 'package:atella/core/themes/app_fonts.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:lottie/lottie.dart';
import 'package:country_picker/country_picker.dart';
import 'package:atella/Modules/tech_pack/Views/Widgets/translated_manufacturer_card.dart';
import 'package:atella/Data/Models/translated_manufacturer_model.dart';
import 'package:atella/l10n/generated/app_localizations.dart';

class RecommendedManufactureScreen extends StatelessWidget {
  const RecommendedManufactureScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final controller = Get.put(ManufacturerSuggestionController());
    return Scaffold(
      backgroundColor: const Color(0xFFFDFDFD),
      body: SafeArea(
        child: Stack(
          children: [
            Obx(
              () => Column(
                children: [
                  // Back button row
                  Padding(
                    padding: EdgeInsets.symmetric(horizontal: 18.w, vertical: 18.h),
                    child: Row(
                      children: [
                        GestureDetector(
                          onTap: () {
                            Get.back();
                          },
                          child: Image.asset(
                            'assets/images/Arrow_Left.png',
                            height: 40.h,
                            width: 40.w,
                          ),
                        ),
                        SizedBox(width: 8.w),
                        Text(
                          l10n.mfManufacturerSuggestions,
                          style: TextStyle(
                            fontSize: 20.sp,
                            fontWeight: FontWeight.w700,
                            color: Colors.black,
                          ),
                        ),
                      ],
                    ),
                  ),
                  SegmentedTabSwitcher(controller: controller),

                  // Search bar
                  Padding(
                    padding: EdgeInsets.symmetric(horizontal: 18.w, vertical: 12.h),
                    child: Container(
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(12.r),
                        border: Border.all(color: const Color(0xFFE0E0E0)),
                      ),
                      child: TextField(
                        controller: controller.searchController,
                        decoration: InputDecoration(
                          hintText: l10n.mfSearchManufacturer,
                          hintStyle: TextStyle(
                            color: const Color(0xFF999999),
                            fontSize: 15.sp,
                          ),
                          prefixIcon: Icon(
                            Icons.search,
                            color: const Color(0xFF666666),
                            size: 22.w,
                          ),
                          suffixIcon: Obx(() => controller.searchQuery.value.isNotEmpty
                              ? IconButton(
                                  icon: Icon(
                                    Icons.clear,
                                    color: const Color(0xFF666666),
                                    size: 20.w,
                                  ),
                                  onPressed: controller.clearSearch,
                                )
                              : const SizedBox.shrink()),
                          border: InputBorder.none,
                          contentPadding: EdgeInsets.symmetric(
                            horizontal: 16.w,
                            vertical: 12.h,
                          ),
                        ),
                        style: TextStyle(
                          fontSize: 15.sp,
                          color: Colors.black,
                        ),
                      ),
                    ),
                  ),

                  Expanded(
                    child: controller.tabIndex.value == 0
                        ? recommendedTab(controller, l10n)
                        : customTab(controller, l10n),
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
                                l10n.mfSendingEmail,
                                style: TextStyle(
                                  fontSize: 18.sp,
                                  fontWeight: FontWeight.w600,
                                  color: Colors.black,
                                ),
                              ),
                              SizedBox(height: 8.h),
                              Text(
                                l10n.mfPreparingTechPack,
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

Widget recommendedTab(ManufacturerSuggestionController controller, AppLocalizations l10n) {
  return RefreshIndicator(
    onRefresh: controller.refreshManufacturers,
    child: SingleChildScrollView(
      controller: controller.scrollController,
      padding: EdgeInsets.symmetric(horizontal: 18.w),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(height: 8.h),
          Text(l10n.mfManufacturerSuggestions, style: mstTextTextStyle26700),
          SizedBox(height: 8.h),
          Obx(
            () => Text(
              controller.isLoading.value
                  ? l10n.mfLoadingManufacturers
                  : l10n.mfFoundManufacturers(controller.allManufacturersCache.length),
              style: mstTextTextStyle184001,
            ),
          ),
          SizedBox(height: 8.h),
          SizedBox(height: 18.h),
          Builder(
            builder: (context) => Obx(() {
              final manufacturers = controller.displayedManufacturers;
              final translatedManufacturers = controller.translatedDisplayedManufacturers;
              final locale = Localizations.localeOf(context).languageCode;

              // Trigger translation when manufacturers change
              if (manufacturers.isNotEmpty &&
                  (translatedManufacturers.isEmpty ||
                   translatedManufacturers.length != manufacturers.length)) {
                Future.microtask(() => controller.translateAllManufacturers(locale));
              }

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
                      l10n.mfLoadingManufacturers,
                      style: TextStyle(
                        fontSize: 16.sp,
                        color: const Color(0xFF666666),
                      ),
                    ),
                  ],
                ),
              );
            } else if (controller.isTranslating.value) {
              // Show loading indicator while translating
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
                      l10n.mfLoadingManufacturers,
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
                      l10n.mfNoManufacturersAvailable,
                      style: TextStyle(fontSize: 16.sp, color: Colors.grey),
                    ),
                  ],
                ),
              );
            } else {
              return Column(
                children: [
                  ...translatedManufacturers.map(
                    (translatedManufacturer) => TranslatedManufacturerCard(
                      translatedManufacturer: translatedManufacturer,
                      onViewProfile: () {},
                      onSendEmail: () =>
                          controller.previewEmailToManufacturer(translatedManufacturer),
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
                          l10n.mfAllManufacturersLoaded,
                          style: TextStyle(fontSize: 14.sp, color: Colors.grey),
                        ),
                      ),
                    ),
                ],
              );
            }
            }),
          ),
          SizedBox(height: 18.h),
        ],
      ),
    ),
  );
}

Widget customTab(ManufacturerSuggestionController controller, AppLocalizations l10n) {
  return RefreshIndicator(
    onRefresh: controller.refreshManufacturers,
    child: SingleChildScrollView(
      padding: EdgeInsets.symmetric(horizontal: 18.w),
      physics: const AlwaysScrollableScrollPhysics(),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(height: 8.h),
          Text(l10n.mfFilterManufacturers, style: mstTextTextStyle26700),
          SizedBox(height: 8.h),
          Text(
            l10n.mfUseFiltersBelow,
            style: mstTextTextStyle184001,
          ),
          SizedBox(height: 18.h),

          // Country Filter with searchable picker
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(l10n.mfCountryOrRegion, style: cstTextTextStyle16500),
              SizedBox(height: 8.h),
              Builder(
                builder: (ctx) => InkWell(
                  onTap: () {
                    showCountryPicker(
                      context: ctx,
                      showPhoneCode: false,
                      onSelect: (Country country) {
                        controller.selectCountry(country.name);
                      },
                      countryListTheme: CountryListThemeData(
                        backgroundColor: Colors.white,
                        textStyle: TextStyle(fontSize: 16.sp),
                        searchTextStyle: TextStyle(fontSize: 16.sp),
                        inputDecoration: InputDecoration(
                          labelText: l10n.mfSearchCountry,
                          hintText: l10n.mfSearchCountryHint,
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
                  borderRadius: BorderRadius.circular(12.r),
                  child: Container(
                    width: double.infinity,
                    padding: EdgeInsets.symmetric(vertical: 14.h, horizontal: 16.w),
                    decoration: BoxDecoration(
                      color: const Color(0xFFE3E1FB),
                      borderRadius: BorderRadius.circular(12.r),
                    ),
                    child: Row(
                      children: [
                        Expanded(
                          child: Obx(() => Text(
                            controller.selectedCountryName.value == 'All Countries' ||
                                    controller.selectedCountryName.value.isEmpty
                                ? l10n.mfAllCountries
                                : controller.selectedCountryName.value,
                            style: TextStyle(fontSize: 16.sp),
                          )),
                        ),
                        const Icon(Icons.arrow_drop_down),
                      ],
                    ),
                  ),
                ),
              ),
              SizedBox(height: 8.h),
            ],
          ),

          // Clear Filter button
          Obx(
            () => controller.selectedCountryName.value != 'All Countries' &&
                    controller.selectedCountryName.value.isNotEmpty
                ? TextButton(
                    onPressed: controller.clearCountryFilter,
                    child: Text(
                      l10n.mfClearFilter,
                      style: cstTextTextStyle16500.copyWith(color: Colors.red),
                    ),
                  )
                : const SizedBox.shrink(),
          ),

          SizedBox(height: 18.h),

          // Manufacturer list
          Builder(
            builder: (context) => Obx(() {
              final filteredManufacturers = controller.filteredManufacturers;
              final locale = Localizations.localeOf(context).languageCode;

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
                        l10n.mfLoadingManufacturers,
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
                          l10n.mfNoManufacturersFound,
                          style: TextStyle(fontSize: 16.sp, color: Colors.grey),
                        ),
                        Padding(
                          padding: EdgeInsets.only(top: 8.h),
                          child: Text(
                            l10n.mfTryAdjustingFilters,
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
                return FutureBuilder<List<TranslatedManufacturer>>(
                  future: _translateFilteredManufacturers(
                    controller,
                    filteredManufacturers,
                    locale,
                  ),
                  builder: (context, snapshot) {
                    if (snapshot.connectionState == ConnectionState.waiting) {
                      // Show loading while translating
                      if (locale == 'fr') {
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
                                l10n.mfLoadingManufacturers,
                                style: TextStyle(
                                  fontSize: 16.sp,
                                  color: const Color(0xFF666666),
                                ),
                              ),
                            ],
                          ),
                        );
                      }
                    }

                    final translatedManufacturers = snapshot.data ?? [];

                    return Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          l10n.mfManufacturersFound(
                            filteredManufacturers.length,
                            filteredManufacturers.length == 1 ? '' : 's',
                          ),
                          style: TextStyle(
                            fontSize: 14.sp,
                            color: const Color(0xFF666666),
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                        SizedBox(height: 12.h),
                        ...translatedManufacturers.map(
                          (translatedManufacturer) {
                            return TranslatedManufacturerCard(
                              translatedManufacturer: translatedManufacturer,
                              onViewProfile: () {
                                Get.to(ViewProfileTechPackScreen());
                              },
                              onSendEmail: () =>
                                  controller.previewEmailToManufacturer(translatedManufacturer),
                            );
                          },
                        ),
                      ],
                    );
                  },
                );
              }
            }),
          ),

          SizedBox(height: 18.h),
        ],
      ),
    ),
  );
}

/// Helper function to translate filtered manufacturers
Future<List<TranslatedManufacturer>> _translateFilteredManufacturers(
  ManufacturerSuggestionController controller,
  List<dynamic> manufacturers,
  String locale,
) async {
  if (locale != 'fr') {
    // If not French, return as-is without translation
    return manufacturers.map((m) => TranslatedManufacturer.fromManufacturer(
      m,
      translatedMoq: m.moq,
      translatedProducts: m.products,
    )).toList();
  }

  // Translate all manufacturers for French
  final List<TranslatedManufacturer> translated = [];
  for (final manufacturer in manufacturers) {
    final translatedManufacturer = await controller.translateManufacturer(
      manufacturer,
      locale,
    );
    translated.add(translatedManufacturer);
  }

  return translated;
}
