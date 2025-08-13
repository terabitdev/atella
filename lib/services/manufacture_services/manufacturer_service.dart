import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:get/get.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import '../../Data/Models/manufacturer_model.dart';

class ManufacturerService extends GetxService {
  static ManufacturerService get instance => Get.find();
  
  final String _openAiBaseUrl = 'https://api.openai.com/v1/chat/completions';
  String get _apiKey => dotenv.env['OPENAI_API_KEY'] ?? '';
  
  final RxBool isLoading = false.obs;
  final RxString error = ''.obs;
  
  Future<List<Manufacturer>> getRecommendedManufacturers() async {
    try {
      print('🔄 Starting manufacturer recommendations API call...');
      isLoading.value = true;
      error.value = '';
      
      if (_apiKey.isEmpty) {
        throw Exception('OpenAI API key not found in environment variables');
      }
      
      print('✅ API Key found, making request to: $_openAiBaseUrl');
      
      final requestBody = {
        'model': 'gpt-4.1-2025-04-14',
        'messages': [
          {
            'role': 'system',
            'content': 'You are a helpful assistant that provides structured data about garment manufacturers.'
          },
          {
            'role': 'user',
            'content': 'Can you please provide me a complete list of atleast 40 garments manufacturers from all over the world. I want their location, name, phone number, website url and email. I dont have any preferences. You just need to list them down with complete details regardless of their location or type. Please format the response as a JSON array with objects containing: name, location, country, phoneNumber, email, website fields only.'
          }
        ],
        'max_tokens': 4000,
        'temperature': 0.7,
      };
      
      print('📤 Request payload: ${json.encode(requestBody)}');
      
      final response = await http.post(
        Uri.parse(_openAiBaseUrl),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $_apiKey',
        },
        body: json.encode(requestBody),
      );
      
      print('📥 Response status code: ${response.statusCode}');
      print('📥 Response headers: ${response.headers}');
      print('📥 Response body: ${response.body}');
      
      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        print('✅ Successfully parsed response JSON');
        
        if (data['choices'] != null && data['choices'].isNotEmpty) {
          final content = data['choices'][0]['message']['content'];
          print('📝 GPT Response content: $content');
          
          final manufacturers = _parseManufacturersFromText(content);
          print('✅ Successfully parsed ${manufacturers.length} manufacturers');
          return manufacturers;
        } else {
          throw Exception('No choices found in API response');
        }
      } else {
        final errorMessage = 'API Error ${response.statusCode}: ${response.body}';
        print('❌ $errorMessage');
        throw Exception(errorMessage);
      }
    } catch (e) {
      print('❌ Error in getRecommendedManufacturers: $e');
      error.value = 'Error: $e';
      return _getDefaultManufacturers(); // Return fallback data
    } finally {
      isLoading.value = false;
      print('🏁 API call completed, loading state reset');
    }
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