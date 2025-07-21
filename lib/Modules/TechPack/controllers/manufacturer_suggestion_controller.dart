import 'package:get/get.dart';

class ManufacturerSuggestionController extends GetxController {
  // Tab index: 0 = Recommended, 1 = Custom
  final RxInt tabIndex = 0.obs;

  // Filters for custom tab
  final RxString selectedCountry = 'United Kingdom'.obs;
  final RxInt moq = 50.obs;
  final RxString leadTime = 'Under 15 days'.obs;

  final List<String> countryList = [
    'United Kingdom',
    'China',
    'Turkey',
    'Pakistan',
    'Bangladesh',
  ];

  final List<String> leadTimeList = [
    'Under 7 days',
    'Under 15 days',
    'Under 30 days',
    'Any',
  ];

  // Manufacturer data (hardcoded for now)
  final List<Map<String, String>> recommendedManufacturers = [
    {
      'name': 'SkyStitch Apparel Ltd.',
      'location': 'Guangzhou, China',
      'moq': 'MOQ: 50 pcs',
      'description':
          'Specialized in cotton knitwear. Offers eco-certification.',
    },
    {
      'name': 'StitchLab Studio',
      'location': 'Istanbul, Turkey',
      'moq': 'MOQ: 5–20 days',
      'description': 'Low-MOQ flexible partner, supports custom tags.',
    },
    {
      'name': 'ClassicTailors',
      'location': 'Sialkot, Pakistan',
      'moq': 'MOQ: 18 days',
      'description': 'Specializes in streetwear. Offers sampling & scaling.',
    },
  ];

  // For custom tab, filter logic can be added later
  List<Map<String, String>> get filteredManufacturers =>
      recommendedManufacturers;
}
