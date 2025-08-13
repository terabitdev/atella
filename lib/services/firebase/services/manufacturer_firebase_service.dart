import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:atella/Data/Models/manufacturer_model.dart';

class ManufacturerFirebaseService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final String _collectionName = 'manufacturers';

  // Add a single manufacturer to Firestore using manufacturer name as document ID
  Future<void> addManufacturer(Manufacturer manufacturer) async {
    try {
      // Validate manufacturer name
      if (manufacturer.name == null || manufacturer.name.trim().isEmpty) {
        print('⚠️ Skipping manufacturer with empty name');
        return;
      }
      
      // Create a clean document ID from manufacturer name
      String docId = _createDocumentId(manufacturer.name);
      
      // Double check docId is not empty
      if (docId.isEmpty) {
        print('⚠️ Could not create valid document ID for: ${manufacturer.name}');
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
        print('✅ Added new manufacturer: ${manufacturer.name} from ${manufacturer.country}');
      } else {
        print('⚠️ Manufacturer already exists: ${manufacturer.name} from ${manufacturer.country}');
      }
    } catch (e) {
      print('❌ Error adding manufacturer to Firebase: $e');
      print('❌ Manufacturer data: name=${manufacturer.name}, country=${manufacturer.country}');
      throw Exception('Failed to add manufacturer to database: $e');
    }
  }
  
  // Create a clean document ID from manufacturer name
  String _createDocumentId(String name) {
    if (name == null || name.trim().isEmpty) {
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
      print('🔄 Adding ${manufacturers.length} manufacturers to Firebase...');
      
      for (Manufacturer manufacturer in manufacturers) {
        await addManufacturer(manufacturer);
      }
      
      print('✅ Successfully added ${manufacturers.length} manufacturers to Firebase');
    } catch (e) {
      print('❌ Error adding manufacturers to Firebase: $e');
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
      print('❌ Error getting manufacturers from Firebase: $e');
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
      print('❌ Error getting manufacturers by country from Firebase: $e');
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
      print('❌ Error getting manufacturers by countries from Firebase: $e');
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
      print('❌ Error checking countries coverage: $e');
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
      print('❌ Error getting manufacturer count by country: $e');
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
      print('🗑️ Cleared all manufacturers from Firebase');
    } catch (e) {
      print('❌ Error clearing manufacturers: $e');
      throw Exception('Failed to clear manufacturers: $e');
    }
  }
}
