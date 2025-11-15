import 'dart:convert';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:atella/Data/Models/manufacturer_model.dart';
import 'package:atella/Data/api/openai_service.dart';
import 'package:http/http.dart' as http;

class ManufacturerFirebaseService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final String _collectionName = 'manufacturers';

  // Add a single manufacturer to Firestore using manufacturer name as document ID
  Future<void> addManufacturer(Manufacturer manufacturer) async {
    try {
      // Validate manufacturer name
      if (manufacturer.name.trim().isEmpty) {
        // print('⚠️ Skipping manufacturer with empty name');
        return;
      }
      
      // Create a clean document ID from manufacturer name
      String docId = _createDocumentId(manufacturer.name);
      
      // Double check docId is not empty
      if (docId.isEmpty) {
        // print('⚠️ Could not create valid document ID for: ${manufacturer.name}');
        // Fallback: use timestamp-based ID
        docId = 'manufacturer_${DateTime.now().millisecondsSinceEpoch}';
      }
      
      // Check if manufacturer already exists by document ID
      final docRef = _firestore.collection(_collectionName).doc(docId);
      final docSnapshot = await docRef.get();

      if (!docSnapshot.exists) {
        // Add new manufacturer with name as document ID
        await docRef.set({
          'name': manufacturer.name,
          'location': manufacturer.location,
          'country': manufacturer.country,
          'phoneNumber': manufacturer.phoneNumber,
          'email': manufacturer.email,
          'website': manufacturer.website,
          'createdAt': FieldValue.serverTimestamp(),
          'source': 'gpt_api',
        });
        // print('✅ Added new manufacturer: ${manufacturer.name} from ${manufacturer.country}');
      } else {
        // print('⚠️ Manufacturer already exists: ${manufacturer.name} from ${manufacturer.country}');
      }
    } catch (e) {
      // print('❌ Error adding manufacturer to Firebase: $e');
      // print('❌ Manufacturer data: name=${manufacturer.name}, country=${manufacturer.country}');
      throw Exception('Failed to add manufacturer to database: $e');
    }
  }
  
  // Create a clean document ID from manufacturer name
  String _createDocumentId(String name) {
    if (name.trim().isEmpty) {
      return '';
    }
    
    // Remove special characters and spaces, replace with underscores
    // Convert to lowercase for consistency
    String cleaned = name
        .trim()
        .toLowerCase()
        .replaceAll(RegExp(r'[^a-zA-Z0-9\s]'), '') // Remove special characters
        .replaceAll(RegExp(r'\s+'), '_') // Replace spaces with underscores
        .replaceAll(RegExp(r'_+'), '_') // Replace multiple underscores with single
        .replaceAll(RegExp(r'^_|_$'), ''); // Remove leading/trailing underscores
    
    // Ensure we have at least some content
    if (cleaned.isEmpty) {
      return '';
    }
    
    // Limit length for Firestore document ID (max 1500 bytes, but keep it shorter)
    if (cleaned.length > 100) {
      cleaned = cleaned.substring(0, 100);
    }
    
    return cleaned;
  }

  // Add multiple manufacturers to Firestore
  Future<void> addManufacturers(List<Manufacturer> manufacturers) async {
    try {
      // print('🔄 Adding ${manufacturers.length} manufacturers to Firebase...');
      
      for (Manufacturer manufacturer in manufacturers) {
        await addManufacturer(manufacturer);
      }
      
      // print('✅ Successfully added ${manufacturers.length} manufacturers to Firebase');
    } catch (e) {
      // print('❌ Error adding manufacturers to Firebase: $e');
      throw Exception('Failed to add manufacturers to database: $e');
    }
  }

  // Get all manufacturers from Firestore
  Future<List<Manufacturer>> getAllManufacturers() async {
    try {
      final QuerySnapshot snapshot = await _firestore
          .collection(_collectionName)
          .orderBy('createdAt', descending: true)
          .get();

      return snapshot.docs.map((doc) {
        final data = doc.data() as Map<String, dynamic>;
        return Manufacturer.fromJson(data);
      }).toList();
    } catch (e) {
      // print('❌ Error getting manufacturers from Firebase: $e');
      return [];
    }
  }

  // Get manufacturers with pagination
  Future<List<Manufacturer>> getManufacturersPaginated({
    int limit = 10,
    DocumentSnapshot? startAfter,
  }) async {
    try {
      Query query = _firestore
          .collection(_collectionName)
          .orderBy('createdAt', descending: true)
          .limit(limit);
      
      if (startAfter != null) {
        query = query.startAfterDocument(startAfter);
      }
      
      final QuerySnapshot snapshot = await query.get();
      
      return snapshot.docs.map((doc) {
        final data = doc.data() as Map<String, dynamic>;
        return Manufacturer.fromJson(data);
      }).toList();
    } catch (e) {
      // print('❌ Error getting paginated manufacturers from Firebase: $e');
      return [];
    }
  }

  // Get manufacturers by country
  Future<List<Manufacturer>> getManufacturersByCountry(String country) async {
    try {
      final QuerySnapshot snapshot = await _firestore
          .collection(_collectionName)
          .where('country', isEqualTo: country)
          .orderBy('createdAt', descending: true)
          .get();

      return snapshot.docs.map((doc) {
        final data = doc.data() as Map<String, dynamic>;
        return Manufacturer.fromJson(data);
      }).toList();
    } catch (e) {
      // print('❌ Error getting manufacturers by country from Firebase: $e');
      return [];
    }
  }

  // Get manufacturers by multiple countries
  Future<List<Manufacturer>> getManufacturersByCountries(List<String> countries) async {
    try {
      final QuerySnapshot snapshot = await _firestore
          .collection(_collectionName)
          .where('country', whereIn: countries)
          .orderBy('createdAt', descending: true)
          .get();

      return snapshot.docs.map((doc) {
        final data = doc.data() as Map<String, dynamic>;
        return Manufacturer.fromJson(data);
      }).toList();
    } catch (e) {
      // print('❌ Error getting manufacturers by countries from Firebase: $e');
      return [];
    }
  }

  // Check if we have manufacturers for specific countries
  Future<Map<String, bool>> checkCountriesCoverage(List<String> countries) async {
    try {
      Map<String, bool> coverage = {};
      
      for (String country in countries) {
        final QuerySnapshot snapshot = await _firestore
            .collection(_collectionName)
            .where('country', isEqualTo: country)
            .limit(1)
            .get();
        
        coverage[country] = snapshot.docs.isNotEmpty;
      }
      
      return coverage;
    } catch (e) {
      // print('❌ Error checking countries coverage: $e');
      return {};
    }
  }

  // Get count of manufacturers by country
  Future<Map<String, int>> getManufacturerCountByCountry() async {
    try {
      final QuerySnapshot snapshot = await _firestore
          .collection(_collectionName)
          .get();

      Map<String, int> countByCountry = {};
      
      for (var doc in snapshot.docs) {
        final data = doc.data() as Map<String, dynamic>;
        final country = data['country'] as String? ?? 'Unknown';
        countByCountry[country] = (countByCountry[country] ?? 0) + 1;
      }
      
      return countByCountry;
    } catch (e) {
      // print('❌ Error getting manufacturer count by country: $e');
      return {};
    }
  }

  // Clear all manufacturers (for testing purposes)
  Future<void> clearAllManufacturers() async {
    try {
      final QuerySnapshot snapshot = await _firestore
          .collection(_collectionName)
          .get();

      final batch = _firestore.batch();
      for (var doc in snapshot.docs) {
        batch.delete(doc.reference);
      }

      await batch.commit();
      // print('🗑️ Cleared all manufacturers from Firebase');
    } catch (e) {
      // print('❌ Error clearing manufacturers: $e');
      throw Exception('Failed to clear manufacturers: $e');
    }
  }

//   // Generate and add small-brand-friendly manufacturers using GPT
//   Future<Map<String, dynamic>> generateSmallBrandManufacturers({
//     required List<String> countries,
//     int manufacturersPerCountry = 5,
//   }) async {
//     try {
//       print('🤖 Starting GPT generation for ${countries.length} countries...');

//       final apiKey = await OpenAIService.getApiKey();
//       if (apiKey == null || apiKey.isEmpty) {
//         throw Exception('OpenAI API key not found');
//       }

//       int totalAdded = 0;
//       int totalFailed = 0;
//       Map<String, int> countryResults = {};

//       for (String country in countries) {
//         print('\n📍 Processing country: $country');

//         try {
//           // Create GPT prompt for small-brand manufacturers
//           final prompt = '''
// List $manufacturersPerCountry clothing manufacturers in $country that are suitable for small fashion brands and independent designers.

// IMPORTANT REQUIREMENTS:
// - These should be SMALL or MEDIUM-sized manufacturers (NOT large industrial groups)
// - Accept small orders (50-500 pieces minimum order quantity)
// - Work with independent designers, startups, and emerging brands
// - More affordable pricing than luxury manufacturers
// - Good for small fashion businesses

// DO NOT include large textile mills or industrial groups. Focus on smaller, more accessible manufacturers.

// For each manufacturer provide ONLY:
// 1. Company name
// 2. City (just city name, no full address)
// 3. Email address
// 4. Phone number with country code
// 5. Website URL (if available, otherwise use "N/A")

// Format your response as a JSON array like this:
// [
//   {
//     "name": "ABC Garments",
//     "location": "Karachi",
//     "email": "info@abcgarments.com",
//     "phoneNumber": "+92-XXX-XXXXXXX",
//     "website": "https://abcgarments.com"
//   }
// ]

// Return ONLY the JSON array, no additional text.
// ''';

//           final response = await http.post(
//             Uri.parse('https://api.openai.com/v1/chat/completions'),
//             headers: {
//               'Content-Type': 'application/json',
//               'Authorization': 'Bearer $apiKey',
//             },
//             body: jsonEncode({
//               'model': 'gpt-4',
//               'messages': [
//                 {
//                   'role': 'system',
//                   'content': 'You are a helpful assistant that provides manufacturer data in JSON format. Always respond with valid JSON only.'
//                 },
//                 {'role': 'user', 'content': prompt},
//               ],
//               'max_tokens': 1500,
//               'temperature': 0.7,
//             }),
//           );

//           if (response.statusCode == 200) {
//             final data = jsonDecode(response.body);
//             final content = data['choices'][0]['message']['content'];

//             // Extract JSON from response (in case there's extra text)
//             String jsonString = content.trim();
//             if (jsonString.contains('[')) {
//               final startIndex = jsonString.indexOf('[');
//               final endIndex = jsonString.lastIndexOf(']') + 1;
//               jsonString = jsonString.substring(startIndex, endIndex);
//             }

//             final List<dynamic> manufacturersData = jsonDecode(jsonString);
//             print('  ✅ GPT returned ${manufacturersData.length} manufacturers for $country');

//             // Add each manufacturer to Firebase
//             int addedForCountry = 0;
//             for (var mfgData in manufacturersData) {
//               try {
//                 final manufacturer = Manufacturer(
//                   name: mfgData['name'] ?? 'Unknown',
//                   location: '${mfgData['location']}, $country',
//                   country: country,
//                   phoneNumber: mfgData['phoneNumber'] ?? '',
//                   email: mfgData['email'] ?? '',
//                   website: mfgData['website'] ?? '', id: '',
//                 );

//                 // Add with targetAudience field
//                 await _addSmallBrandManufacturer(manufacturer);
//                 addedForCountry++;
//               } catch (e) {
//                 print('  ⚠️ Failed to add manufacturer: $e');
//                 totalFailed++;
//               }
//             }

//             totalAdded += addedForCountry;
//             countryResults[country] = addedForCountry;
//             print('  ✅ Added $addedForCountry manufacturers for $country');

//           } else {
//             print('  ❌ GPT API error for $country: ${response.statusCode}');
//             print('  Response: ${response.body}');
//             countryResults[country] = 0;
//             totalFailed++;
//           }

//           // Small delay to avoid rate limiting
//           await Future.delayed(const Duration(seconds: 2));

//         } catch (e) {
//           print('  ❌ Error processing $country: $e');
//           countryResults[country] = 0;
//           totalFailed++;
//         }
//       }

//       print('\n✅ COMPLETED!');
//       print('   Total manufacturers added: $totalAdded');
//       print('   Total failed: $totalFailed');

//       return {
//         'success': true,
//         'totalAdded': totalAdded,
//         'totalFailed': totalFailed,
//         'countryResults': countryResults,
//       };

//     } catch (e) {
//       print('❌ Error in generateSmallBrandManufacturers: $e');
//       return {
//         'success': false,
//         'error': e.toString(),
//         'totalAdded': 0,
//         'totalFailed': countries.length,
//       };
//     }
//   }

//   // Add a manufacturer with targetAudience field
//   Future<void> _addSmallBrandManufacturer(Manufacturer manufacturer) async {
//     try {
//       if (manufacturer.name.trim().isEmpty) {
//         return;
//       }

//       String docId = _createDocumentId(manufacturer.name);

//       if (docId.isEmpty) {
//         docId = 'manufacturer_${DateTime.now().millisecondsSinceEpoch}';
//       }

//       final docRef = _firestore.collection(_collectionName).doc(docId);
//       final docSnapshot = await docRef.get();

//       if (!docSnapshot.exists) {
//         await docRef.set({
//           'name': manufacturer.name,
//           'location': manufacturer.location,
//           'country': manufacturer.country,
//           'phoneNumber': manufacturer.phoneNumber,
//           'email': manufacturer.email,
//           'website': manufacturer.website,
//           'createdAt': FieldValue.serverTimestamp(),
//           'source': 'gpt_api',
//           'targetAudience': 'small_brands', // NEW FIELD
//           'minimumOrderQuantity': '50-500 pieces', // NEW FIELD
//         });
//       }
//     } catch (e) {
//       throw Exception('Failed to add small-brand manufacturer: $e');
//     }
//   }
// }
}