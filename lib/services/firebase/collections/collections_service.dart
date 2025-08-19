import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

class CollectionsService {
  static final CollectionsService _instance = CollectionsService._internal();
  factory CollectionsService() => _instance;
  CollectionsService._internal();

  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;

  // Get current user ID
  String? get currentUserId => _auth.currentUser?.uid;

  // Get user's collections
  Future<List<String>> getUserCollections() async {
    try {
      if (currentUserId == null) {
        print('User not authenticated');
        return ['SUMMER COLLECTION', 'WINTER COLLECTION']; // Default collections
      }

      final userDoc = await _firestore
          .collection('users')
          .doc(currentUserId)
          .get();

      if (!userDoc.exists) {
        // Return default collections if user doc doesn't exist
        return ['SUMMER COLLECTION', 'WINTER COLLECTION'];
      }

      final data = userDoc.data();
      final collections = List<String>.from(data?['collections'] ?? []);
      
      // Always include default collections
      if (!collections.contains('SUMMER COLLECTION')) {
        collections.add('SUMMER COLLECTION');
      }
      if (!collections.contains('WINTER COLLECTION')) {
        collections.add('WINTER COLLECTION');
      }
      
      return collections;
    } catch (e) {
      print('Error fetching collections: $e');
      return ['SUMMER COLLECTION', 'WINTER COLLECTION'];
    }
  }

  // Add new collection
  Future<void> addCollection(String collectionName) async {
    try {
      if (currentUserId == null) {
        throw Exception('User not authenticated');
      }

      final upperCaseName = collectionName.toUpperCase();
      
      await _firestore.collection('users').doc(currentUserId).set({
        'collections': FieldValue.arrayUnion([upperCaseName]),
        'updatedAt': FieldValue.serverTimestamp(),
      }, SetOptions(merge: true));
      
      print('Collection added: $upperCaseName');
    } catch (e) {
      print('Error adding collection: $e');
      throw Exception('Failed to add collection: $e');
    }
  }

  // Check if collection exists
  Future<bool> collectionExists(String collectionName) async {
    try {
      final collections = await getUserCollections();
      return collections.contains(collectionName.toUpperCase());
    } catch (e) {
      print('Error checking collection: $e');
      return false;
    }
  }
}