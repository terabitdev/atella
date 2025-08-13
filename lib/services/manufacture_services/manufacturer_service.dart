import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:get/get.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import '../../Data/Models/manufacturer_model.dart';
import '../firebase/services/manufacturer_firebase_service.dart';

class ManufacturerService extends GetxService {
  static ManufacturerService get instance => Get.find();
  
  final String _openAiBaseUrl = 'https://api.openai.com/v1/chat/completions';
  String get _apiKey => dotenv.env['OPENAI_API_KEY'] ?? '';
  
  final RxBool isLoading = false.obs;
  final RxString error = ''.obs;
  
  // Firebase service instance
  final ManufacturerFirebaseService _firebaseService = ManufacturerFirebaseService();
  
  // Country groups for batch fetching
  static const List<String> firstBatchCountries = [
    'Australia',
    'Bangladesh',
    'China',
    'India',
    'Italy',
    'Turkey',
    'USA',
    'UK',
    'Vietnam',
    'Pakistan'
  ];
  
  static const List<String> secondBatchCountries = [
    'Canada',
    'Germany',
    'France',
    'Japan',
    'South Korea',
    'Brazil',
    'Mexico',
    'Spain',
    'Portugal',
    'Netherlands'
  ];
  
  static const List<String> thirdBatchCountries = [
    'Thailand',
    'Indonesia',
    'Malaysia',
    'Singapore',
    'Philippines',
    'Egypt',
    'Morocco',
    'South Africa',
    'Poland',
    'Romania'
  ];
  
  static const List<String> fourthBatchCountries = [
    'Denmark',
    'Finland',
    'Belgium',
    'Switzerland',
    'Austria',
    'Czech Republic',
    'Hungary',
    'Greece'
  ];
//more countries can be added here
static const List<String> sixthBatchCountries = [
  'United Arab Emirates',
  'Qatar',
  'Kuwait',
  'Oman',
  'Jordan',
  'Lebanon',
  'Israel',
  'Sri Lanka',
  'Nepal',
  'Kenya'
];

  // Get all country groups
  static List<List<String>> get allCountryBatches => [
    firstBatchCountries,
    secondBatchCountries,
    thirdBatchCountries,
    fourthBatchCountries,
  ];
  
  // Fetch manufacturers for a specific batch of countries and store in Firebase
  Future<List<Manufacturer>> fetchManufacturersByBatch(int batchIndex) async {
    if (batchIndex < 0 || batchIndex >= allCountryBatches.length) {
      throw Exception('Invalid batch index. Use 0-${allCountryBatches.length - 1}');
    }
    
    final countries = allCountryBatches[batchIndex];
    return await fetchManufacturersByCountries(countries);
  }
  
  // Fetch manufacturers for specific countries and automatically store in Firebase
  Future<List<Manufacturer>> fetchManufacturersByCountries(List<String> countries) async {
    try {
      print('🔄 Fetching manufacturers for countries: ${countries.join(', ')}');
      isLoading.value = true;
      error.value = '';
      
      if (_apiKey.isEmpty) {
        throw Exception('OpenAI API key not found in environment variables');
      }
      
      final countriesString = countries.join(', ');
      final requestBody = {
        'model': 'gpt-4',
        'messages': [
          {
            'role': 'system',
            'content': 'You are a helpful assistant that provides structured data about garment manufacturers.'
          },
          {
            'role': 'user',
            'content': '''
Provide exactly 5 garment manufacturers for each of the following countries: 
$countriesString

For each manufacturer, include:
- name
- location
- country
- phoneNumber
- email
- website

Return ONLY a valid JSON array, without code fences, text, or explanations.
'''
          }
        ],
        'max_tokens': 4000,
        'temperature': 0.7,
      };
      
      print('📤 Making API request for ${countries.length} countries...');
      
      final response = await http.post(
        Uri.parse(_openAiBaseUrl),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $_apiKey',
        },
        body: json.encode(requestBody),
      );
      
      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        
        if (data['choices'] != null && data['choices'].isNotEmpty) {
          final content = data['choices'][0]['message']['content'];
          final manufacturers = _parseManufacturersFromText(content);
          
          // Automatically store in Firebase
          if (manufacturers.isNotEmpty) {
            print('💾 Storing ${manufacturers.length} manufacturers in Firebase...');
            await _firebaseService.addManufacturers(manufacturers);
            print('✅ Successfully stored manufacturers in Firebase');
          }
          
          return manufacturers;
        } else {
          throw Exception('No choices found in API response');
        }
      } else {
        throw Exception('API Error ${response.statusCode}: ${response.body}');
      }
    } catch (e) {
      print('❌ Error fetching manufacturers: $e');
      error.value = 'Error: $e';
      return [];
    } finally {
      isLoading.value = false;
    }
  }
  
  // Fetch manufacturers from all country batches sequentially
  Future<Map<String, List<Manufacturer>>> fetchAllManufacturersGlobally() async {
    Map<String, List<Manufacturer>> allManufacturers = {};
    
    try {
      print('🌍 Starting global manufacturer fetch across all country batches...');
      
      for (int i = 0; i < allCountryBatches.length; i++) {
        print('\n📦 Processing batch ${i + 1} of ${allCountryBatches.length}...');
        final batchName = 'batch_${i + 1}';
        
        // Add delay between API calls to avoid rate limiting
        if (i > 0) {
          print('⏳ Waiting 2 seconds before next API call...');
          await Future.delayed(Duration(seconds: 2));
        }
        
        final manufacturers = await fetchManufacturersByBatch(i);
        allManufacturers[batchName] = manufacturers;
        
        print('✅ Batch ${i + 1} completed: ${manufacturers.length} manufacturers fetched and stored');
      }
      
      print('\n🎉 Global fetch completed! Total batches processed: ${allManufacturers.length}');
      
      // Get total count
      int totalManufacturers = 0;
      allManufacturers.forEach((key, value) {
        totalManufacturers += value.length;
      });
      
      print('📊 Total manufacturers fetched and stored: $totalManufacturers');
      
      return allManufacturers;
    } catch (e) {
      print('❌ Error in global fetch: $e');
      error.value = 'Error fetching global manufacturers: $e';
      return allManufacturers;
    }
  }
  
  // Get manufacturers from Firebase (cached data)
  Future<List<Manufacturer>> getManufacturersFromFirebase({String? country}) async {
    try {
      if (country != null && country != 'All') {
        return await _firebaseService.getManufacturersByCountry(country);
      } else {
        return await _firebaseService.getAllManufacturers();
      }
    } catch (e) {
      print('❌ Error getting manufacturers from Firebase: $e');
      return [];
    }
  }
  
  // Check which countries have data in Firebase
  Future<Map<String, bool>> checkCountryCoverage() async {
    try {
      final allCountries = allCountryBatches.expand((batch) => batch).toList();
      return await _firebaseService.checkCountriesCoverage(allCountries);
    } catch (e) {
      print('❌ Error checking country coverage: $e');
      return {};
    }
  }
  
  // Get statistics about stored manufacturers
  Future<Map<String, int>> getManufacturerStatistics() async {
    try {
      return await _firebaseService.getManufacturerCountByCountry();
    } catch (e) {
      print('❌ Error getting manufacturer statistics: $e');
      return {};
    }
  }
  
  // Original method kept for backward compatibility - now uses first batch and stores in Firebase
  Future<List<Manufacturer>> getRecommendedManufacturers() async {
    // Use the sixth batch of countries
    return await fetchManufacturersByCountries(sixthBatchCountries);
  }
  
  List<Manufacturer> _parseManufacturersFromText(String text) {
    List<Manufacturer> manufacturers = [];
    
    try {
      print('🔍 Parsing manufacturers from text: ${text.substring(0, text.length > 500 ? 500 : text.length)}...');
      
      // Try to extract JSON from the response
      final jsonMatch = RegExp(r'\[.*\]', dotAll: true).firstMatch(text);
      if (jsonMatch != null) {
        final jsonString = jsonMatch.group(0)!;
        print('📊 Found JSON array: ${jsonString.substring(0, jsonString.length > 200 ? 200 : jsonString.length)}...');
        
        final List<dynamic> manufacturerList = json.decode(jsonString);
        print('✅ Successfully decoded JSON array with ${manufacturerList.length} items');
        
        manufacturers = manufacturerList.map((item) {
          print('🏭 Processing manufacturer: ${item['name'] ?? 'Unknown'}');
          print('📋 Full manufacturer data: $item');
          return Manufacturer.fromJson(item as Map<String, dynamic>);
        }).toList();
        
        print('✅ Successfully parsed ${manufacturers.length} manufacturers from JSON');
      } else {
        print('⚠️ No JSON array found in response, trying manual parsing...');
        manufacturers = _parseTextManually(text);
      }
    } catch (e) {
      print('❌ Error parsing manufacturers from text: $e');
      print('🔄 Falling back to default manufacturers...');
      manufacturers = _getDefaultManufacturers();
    }
    
    return manufacturers;
  }
  
  List<Manufacturer> _parseTextManually(String text) {
    print('🔧 Manual parsing of text response...');
    // For now, return default manufacturers if JSON parsing fails
    // This can be enhanced later based on actual GPT response format
    return _getDefaultManufacturers();
  }
  
  List<Manufacturer> _getDefaultManufacturers() {
    print('📋 Returning default manufacturers as fallback');
    return [
      Manufacturer(
        name: 'SkyStitch Apparel Ltd.',
        location: 'Guangzhou, China',
        country: 'China',
        phoneNumber: '+86-20-1234-5678',
        email: 'info@skystitch.com',
        website: 'https://www.skystitch.com',
      ),
      Manufacturer(
        name: 'StitchLab Studio',
        location: 'Istanbul, Turkey',
        country: 'Turkey',
        phoneNumber: '+90-212-123-4567',
        email: 'contact@stitchlab.com',
        website: 'https://www.stitchlab.com',
      ),
      Manufacturer(
        name: 'ClassicTailors',
        location: 'Sialkot, Pakistan',
        country: 'Pakistan',
        phoneNumber: '+92-52-123-4567',
        email: 'info@classictailors.com',
        website: 'https://www.classictailors.com',
      ),
      Manufacturer(
        name: 'London Fashion Works',
        location: 'London, United Kingdom',
        country: 'United Kingdom',
        phoneNumber: '+44-20-1234-5678',
        email: 'hello@londonfashionworks.co.uk',
        website: 'https://www.londonfashionworks.co.uk',
      ),
      Manufacturer(
        name: 'Bengal Textiles',
        location: 'Dhaka, Bangladesh',
        country: 'Bangladesh',
        phoneNumber: '+880-2-1234-5678',
        email: 'orders@bengaltextiles.com',
        website: 'https://www.bengaltextiles.com',
      ),
    ];
  }
  
  List<Manufacturer> getFilteredManufacturers({
    String? country, required RxList<Manufacturer> sourceManufacturers,
  }) {
    print('🔍 Filtering manufacturers by country: $country');
    List<Manufacturer> allManufacturers = _getAllManufacturers();
    
    return allManufacturers.where((manufacturer) {
      bool matchesCountry = country == null || 
          country == 'All' ||
          manufacturer.country.toLowerCase().contains(country.toLowerCase());
      
      return matchesCountry;
    }).toList();
  }
  
  List<Manufacturer> _getAllManufacturers() {
    return _getDefaultManufacturers();
  }


}