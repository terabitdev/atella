import 'package:atella/Modules/TechPack/Views/Screens/view_profile_tech_pack_screen.dart';
import 'package:atella/Modules/TechPack/Views/Widgets/segmented_tab_switcher.dart';
import 'package:atella/core/themes/app_fonts.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import '../Widgets/manufacturer_suggestion_card.dart';
import '../../controllers/manufacturer_suggestion_controller.dart';
import 'package:atella/Widgets/custom_roundbutton.dart';
import 'package:atella/core/themes/app_colors.dart';

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
  return SingleChildScrollView(
    padding: EdgeInsets.symmetric(horizontal: 18.w),
    child: Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        SizedBox(height: 8.h),
        Text('Manufacturer Suggestions', style: mstTextTextStyle26700),
        SizedBox(height: 8.h),
        Text(
          'We found 3 potential manufacturers that fit your product needs.',
          style: mstTextTextStyle184001,
        ),
        SizedBox(height: 18.h),
        ...controller.recommendedManufacturers.map(
          (m) => ManufacturerSuggestionCard(
            name: m['name']!,
            location: m['location']!,
            moq: m['moq']!,
            description: m['description']!,
            onViewProfile: () {},
            onContact: () {},
          ),
        ),
        SizedBox(height: 18.h),
      ],
    ),
  );
}

Widget customTab(ManufacturerSuggestionController controller) {
  return SingleChildScrollView(
    padding: EdgeInsets.symmetric(horizontal: 18.w),
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
        Text('Country or Region', style: cstTextTextStyle16500),
        SizedBox(height: 8.h),
        Obx(
          () => DropdownButtonFormField<String>(
            value: controller.selectedCountry.value,
            items: controller.countryList
                .map((c) => DropdownMenuItem(value: c, child: Text(c)))
                .toList(),
            onChanged: (v) => controller.selectedCountry.value = v!,
            decoration: InputDecoration(
              filled: true,
              fillColor: const Color.fromARGB(255, 227, 225, 251),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12.r),
                borderSide: BorderSide.none,
              ),
              contentPadding: EdgeInsets.symmetric(
                vertical: 14.h,
                horizontal: 16.w,
              ),
            ),
          ),
        ),
        SizedBox(height: 18.h),
        Text('Minimum Order Quantity (MOQ)', style: cstTextTextStyle16500),
        SizedBox(height: 8.h),
        Obx(
          () => Row(
            children: [
              Expanded(
                child: Slider(
                  value: controller.moq.value.toDouble(),
                  min: 1,
                  max: 500,
                  divisions: 50,
                  label: '${controller.moq.value} pcs',
                  activeColor: Colors.black,
                  inactiveColor: const Color(0xFFE3E1FB),
                  onChanged: (v) => controller.moq.value = v.round(),
                ),
              ),
              SizedBox(width: 8.w),
              Text(
                '${controller.moq.value} pcs',
                style: const TextStyle(fontWeight: FontWeight.w600),
              ),
            ],
          ),
        ),
        SizedBox(height: 18.h),
        Text(
          'Lead Time',
          style: TextStyle(fontWeight: FontWeight.w600, fontSize: 16.sp),
        ),
        SizedBox(height: 8.h),
        Obx(
          () => DropdownButtonFormField<String>(
            value: controller.leadTime.value,
            items: controller.leadTimeList
                .map((c) => DropdownMenuItem(value: c, child: Text(c)))
                .toList(),
            onChanged: (v) => controller.leadTime.value = v!,
            decoration: InputDecoration(
              filled: true,
              fillColor: const Color(0xFFE3E1FB),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12.r),
                borderSide: BorderSide.none,
              ),
              contentPadding: EdgeInsets.symmetric(
                vertical: 14.h,
                horizontal: 16.w,
              ),
            ),
          ),
        ),
        SizedBox(height: 18.h),
        ...controller.filteredManufacturers.map(
          (m) => ManufacturerSuggestionCard(
            name: m['name']!,
            location: m['location']!,
            moq: m['moq']!,
            description: m['description']!,
            onViewProfile: () {
              Get.to(ViewProfileTechPackScreen());
            },
            onContact: () {},
          ),
        ),
        SizedBox(height: 18.h),
        RoundButton(
          title: 'Search',
          onTap: () {},
          color: AppColors.buttonColor,
          isloading: false,
        ),
        SizedBox(height: 18.h),
      ],
    ),
  );
}
