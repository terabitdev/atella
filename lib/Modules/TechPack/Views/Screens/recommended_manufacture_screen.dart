import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../Widgets/manufacturer_suggestion_card.dart';
import '../Widgets/save_export_button_row.dart';
import '../../controllers/manufacturer_suggestion_controller.dart';
import 'package:atella/Widgets/custom_roundbutton.dart';
import 'package:atella/core/themes/app_colors.dart';

class RecommendedManufactureScreen extends StatelessWidget {
  const RecommendedManufactureScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final controller = Get.put(ManufacturerSuggestionController());
    return Scaffold(
      backgroundColor: const Color(0xFFFDFDFD),
      body: SafeArea(
        child: Obx(
          () => Column(
            children: [
              // Tab Bar
              Padding(
                padding: const EdgeInsets.symmetric(
                  horizontal: 18,
                  vertical: 18,
                ),
                child: Row(
                  children: [
                    Expanded(
                      child: GestureDetector(
                        onTap: () => controller.tabIndex.value = 0,
                        child: Container(
                          height: 48,
                          decoration: BoxDecoration(
                            color: controller.tabIndex.value == 0
                                ? const Color(0xFF8B88F8)
                                : const Color(0xFFE3E1FB),
                            borderRadius: BorderRadius.circular(24),
                          ),
                          alignment: Alignment.center,
                          child: Text(
                            'Recommended Manufacturers',
                            style: TextStyle(
                              color: controller.tabIndex.value == 0
                                  ? Colors.white
                                  : const Color(0xFF8B88F8),
                              fontWeight: FontWeight.w600,
                              fontSize: 16,
                            ),
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: GestureDetector(
                        onTap: () => controller.tabIndex.value = 1,
                        child: Container(
                          height: 48,
                          decoration: BoxDecoration(
                            color: controller.tabIndex.value == 1
                                ? const Color(0xFF8B88F8)
                                : const Color(0xFFE3E1FB),
                            borderRadius: BorderRadius.circular(24),
                          ),
                          alignment: Alignment.center,
                          child: Text(
                            'Custom',
                            style: TextStyle(
                              color: controller.tabIndex.value == 1
                                  ? Colors.white
                                  : const Color(0xFF8B88F8),
                              fontWeight: FontWeight.w600,
                              fontSize: 16,
                            ),
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              Expanded(
                child: controller.tabIndex.value == 0
                    ? _RecommendedTab(controller)
                    : _CustomTab(controller),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

Widget _RecommendedTab(ManufacturerSuggestionController controller) {
  return SingleChildScrollView(
    padding: const EdgeInsets.symmetric(horizontal: 18),
    child: Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const SizedBox(height: 8),
        const Text(
          'Manufacturer Suggestions',
          style: TextStyle(fontWeight: FontWeight.w800, fontSize: 28),
        ),
        const SizedBox(height: 8),
        const Text(
          'We found 3 potential manufacturers that fit your product needs.',
          style: TextStyle(fontSize: 17, color: Color(0xFF222222)),
        ),
        const SizedBox(height: 18),
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
        const SizedBox(height: 18),
      ],
    ),
  );
}

Widget _CustomTab(ManufacturerSuggestionController controller) {
  return SingleChildScrollView(
    padding: const EdgeInsets.symmetric(horizontal: 18),
    child: Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const SizedBox(height: 8),
        const Text(
          'Filter Manufacturers Manually',
          style: TextStyle(fontWeight: FontWeight.w800, fontSize: 28),
        ),
        const SizedBox(height: 8),
        const Text(
          'Use filters below to search our full manufacturer directory:',
          style: TextStyle(fontSize: 17, color: Color(0xFF222222)),
        ),
        const SizedBox(height: 18),
        const Text(
          'Country or Region',
          style: TextStyle(fontWeight: FontWeight.w600, fontSize: 16),
        ),
        const SizedBox(height: 8),
        Obx(
          () => DropdownButtonFormField<String>(
            value: controller.selectedCountry.value,
            items: controller.countryList
                .map((c) => DropdownMenuItem(value: c, child: Text(c)))
                .toList(),
            onChanged: (v) => controller.selectedCountry.value = v!,
            decoration: InputDecoration(
              filled: true,
              fillColor: const Color(0xFFE3E1FB),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: BorderSide.none,
              ),
              contentPadding: const EdgeInsets.symmetric(
                vertical: 14,
                horizontal: 16,
              ),
            ),
          ),
        ),
        const SizedBox(height: 18),
        const Text(
          'Minimum Order Quantity (MOQ)',
          style: TextStyle(fontWeight: FontWeight.w600, fontSize: 16),
        ),
        const SizedBox(height: 8),
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
                  activeColor: const Color(0xFF8B88F8),
                  inactiveColor: const Color(0xFFE3E1FB),
                  onChanged: (v) => controller.moq.value = v.round(),
                ),
              ),
              const SizedBox(width: 8),
              Text(
                '${controller.moq.value} pcs',
                style: const TextStyle(fontWeight: FontWeight.w600),
              ),
            ],
          ),
        ),
        const SizedBox(height: 18),
        const Text(
          'Lead Time',
          style: TextStyle(fontWeight: FontWeight.w600, fontSize: 16),
        ),
        const SizedBox(height: 8),
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
                borderRadius: BorderRadius.circular(12),
                borderSide: BorderSide.none,
              ),
              contentPadding: const EdgeInsets.symmetric(
                vertical: 14,
                horizontal: 16,
              ),
            ),
          ),
        ),
        const SizedBox(height: 18),
        ...controller.filteredManufacturers.map(
          (m) => ManufacturerSuggestionCard(
            name: m['name']!,
            location: m['location']!,
            moq: m['moq']!,
            description: m['description']!,
            onViewProfile: () {},
            onContact: () {},
          ),
        ),
        const SizedBox(height: 18),
        RoundButton(
          title: 'Search',
          onTap: () {},
          color: AppColors.splashcolor,
          isloading: false,
        ),
        const SizedBox(height: 18),
      ],
    ),
  );
}
