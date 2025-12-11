import 'dart:convert';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/services.dart';
import 'package:atella/Data/Models/new_manufacturer_model.dart';

class NewManufacturerFirebaseService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final String _collectionName = 'new_manufacturers';

  // Import manufacturers from JSON asset file to Firestore
  Future<Map<String, dynamic>> importFromJsonAsset() async {
    try {
      print('Starting import from JSON asset...');

      // Load JSON from assets
      final String jsonString = await rootBundle.loadString('assets/manufactureers.json');
      final List<dynamic> jsonData = jsonDecode(jsonString);

      print('Loaded ${jsonData.length} manufacturers from JSON');

      int added = 0;
      int skipped = 0;
      int failed = 0;

      for (var item in jsonData) {
        try {
          final manufacturer = NewManufacturer.fromJson(item);

          if (manufacturer.companyName.trim().isEmpty) {
            skipped++;
            continue;
          }

          // Create document ID from company name
          String docId = _createDocumentId(manufacturer.companyName);
          if (docId.isEmpty) {
            docId = 'manufacturer_${DateTime.now().millisecondsSinceEpoch}';
          }

          // Check if already exists
          final docRef = _firestore.collection(_collectionName).doc(docId);
          final docSnapshot = await docRef.get();

          if (!docSnapshot.exists) {
            await docRef.set({
              'id': docId,
              'companyName': manufacturer.companyName,
              'country': manufacturer.country,
              'website': manufacturer.website,
              'email': manufacturer.email,
              'instagram': manufacturer.instagram,
              'moq': manufacturer.moq,
              'products': manufacturer.products,
              'certifications': manufacturer.certifications,
              'createdAt': FieldValue.serverTimestamp(),
              'source': 'airtable_import',
            });
            added++;
            print('Added: ${manufacturer.companyName}');
          } else {
            skipped++;
            print('Skipped (exists): ${manufacturer.companyName}');
          }
        } catch (e) {
          failed++;
          print('Failed to add manufacturer: $e');
        }
      }

      print('Import complete: $added added, $skipped skipped, $failed failed');

      return {
        'success': true,
        'total': jsonData.length,
        'added': added,
        'skipped': skipped,
        'failed': failed,
      };
    } catch (e) {
      print('Error importing manufacturers: $e');
      return {
        'success': false,
        'error': e.toString(),
      };
    }
  }

  // Create a clean document ID from company name
  String _createDocumentId(String name) {
    if (name.trim().isEmpty) return '';

    String cleaned = name
        .trim()
        .toLowerCase()
        .replaceAll(RegExp(r'[^a-zA-Z0-9\s]'), '')
        .replaceAll(RegExp(r'\s+'), '_')
        .replaceAll(RegExp(r'_+'), '_')
        .replaceAll(RegExp(r'^_|_$'), '');

    if (cleaned.isEmpty) return '';
    if (cleaned.length > 100) {
      cleaned = cleaned.substring(0, 100);
    }

    return cleaned;
  }

  // Get all manufacturers
  Future<List<NewManufacturer>> getAllManufacturers() async {
    try {
      final QuerySnapshot snapshot = await _firestore
          .collection(_collectionName)
          .orderBy('companyName')
          .get();

      return snapshot.docs.map((doc) {
        final data = doc.data() as Map<String, dynamic>;
        return NewManufacturer.fromJson(data);
      }).toList();
    } catch (e) {
      print('Error getting manufacturers: $e');
      return [];
    }
  }

  // Get manufacturers by country
  Future<List<NewManufacturer>> getManufacturersByCountry(String country) async {
    try {
      final QuerySnapshot snapshot = await _firestore
          .collection(_collectionName)
          .where('country', isEqualTo: country)
          .orderBy('companyName')
          .get();

      return snapshot.docs.map((doc) {
        final data = doc.data() as Map<String, dynamic>;
        return NewManufacturer.fromJson(data);
      }).toList();
    } catch (e) {
      print('Error getting manufacturers by country: $e');
      return [];
    }
  }

  // Get manufacturers by countries list
  Future<List<NewManufacturer>> getManufacturersByCountries(List<String> countries) async {
    try {
      final QuerySnapshot snapshot = await _firestore
          .collection(_collectionName)
          .where('country', whereIn: countries)
          .get();

      return snapshot.docs.map((doc) {
        final data = doc.data() as Map<String, dynamic>;
        return NewManufacturer.fromJson(data);
      }).toList();
    } catch (e) {
      print('Error getting manufacturers by countries: $e');
      return [];
    }
  }

  // Get manufacturers by product type
  Future<List<NewManufacturer>> getManufacturersByProduct(String product) async {
    try {
      final QuerySnapshot snapshot = await _firestore
          .collection(_collectionName)
          .where('products', arrayContains: product.toUpperCase())
          .get();

      return snapshot.docs.map((doc) {
        final data = doc.data() as Map<String, dynamic>;
        return NewManufacturer.fromJson(data);
      }).toList();
    } catch (e) {
      print('Error getting manufacturers by product: $e');
      return [];
    }
  }

  // Get manufacturers by certification
  Future<List<NewManufacturer>> getManufacturersByCertification(String certification) async {
    try {
      final QuerySnapshot snapshot = await _firestore
          .collection(_collectionName)
          .where('certifications', arrayContains: certification)
          .get();

      return snapshot.docs.map((doc) {
        final data = doc.data() as Map<String, dynamic>;
        return NewManufacturer.fromJson(data);
      }).toList();
    } catch (e) {
      print('Error getting manufacturers by certification: $e');
      return [];
    }
  }

  // Get manufacturers with low MOQ
  Future<List<NewManufacturer>> getManufacturersWithLowMOQ() async {
    try {
      final allManufacturers = await getAllManufacturers();
      return allManufacturers.where((m) => m.isLowMOQ).toList();
    } catch (e) {
      print('Error getting low MOQ manufacturers: $e');
      return [];
    }
  }

  // Get all unique countries
  Future<List<String>> getAllCountries() async {
    try {
      final QuerySnapshot snapshot = await _firestore
          .collection(_collectionName)
          .get();

      final Set<String> countries = {};
      for (var doc in snapshot.docs) {
        final data = doc.data() as Map<String, dynamic>;
        final country = data['country'] as String?;
        if (country != null && country.isNotEmpty) {
          countries.add(country);
        }
      }

      return countries.toList()..sort();
    } catch (e) {
      print('Error getting countries: $e');
      return [];
    }
  }

  // Get all unique products
  Future<List<String>> getAllProducts() async {
    try {
      final QuerySnapshot snapshot = await _firestore
          .collection(_collectionName)
          .get();

      final Set<String> products = {};
      for (var doc in snapshot.docs) {
        final data = doc.data() as Map<String, dynamic>;
        final productList = data['products'] as List<dynamic>?;
        if (productList != null) {
          for (var product in productList) {
            products.add(product.toString());
          }
        }
      }

      return products.toList()..sort();
    } catch (e) {
      print('Error getting products: $e');
      return [];
    }
  }

  // Get all unique certifications
  Future<List<String>> getAllCertifications() async {
    try {
      final QuerySnapshot snapshot = await _firestore
          .collection(_collectionName)
          .get();

      final Set<String> certifications = {};
      for (var doc in snapshot.docs) {
        final data = doc.data() as Map<String, dynamic>;
        final certList = data['certifications'] as List<dynamic>?;
        if (certList != null) {
          for (var cert in certList) {
            certifications.add(cert.toString());
          }
        }
      }

      return certifications.toList()..sort();
    } catch (e) {
      print('Error getting certifications: $e');
      return [];
    }
  }

  // Get manufacturer count
  Future<int> getManufacturerCount() async {
    try {
      final snapshot = await _firestore.collection(_collectionName).count().get();
      return snapshot.count ?? 0;
    } catch (e) {
      print('Error getting count: $e');
      return 0;
    }
  }

  // Search manufacturers by name
  Future<List<NewManufacturer>> searchByName(String query) async {
    try {
      final allManufacturers = await getAllManufacturers();
      final queryLower = query.toLowerCase();
      return allManufacturers
          .where((m) => m.companyName.toLowerCase().contains(queryLower))
          .toList();
    } catch (e) {
      print('Error searching manufacturers: $e');
      return [];
    }
  }

  // Clear all new manufacturers (for testing)
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
      print('Cleared all new manufacturers');
    } catch (e) {
      print('Error clearing manufacturers: $e');
    }
  }
}
