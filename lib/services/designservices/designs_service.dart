import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:atella/Data/Models/design_model.dart';
import 'dart:convert';
import 'dart:typed_data';

class DesignsService {
  static final DesignsService _instance = DesignsService._internal();
  factory DesignsService() => _instance;
  DesignsService._internal();

  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseStorage _storage = FirebaseStorage.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;

  // Get current user ID
  String? get currentUserId => _auth.currentUser?.uid;

  // Collection reference
  CollectionReference get _designsCollection => _firestore.collection('designs');

  // Test Firebase Storage connectivity
  Future<bool> testStorageConnection() async {
    try {
      // Try to get storage reference
      Reference testRef = _storage.ref('test/connection_test.txt');
      
      // Try to upload a small test file
      await testRef.putString('test', format: PutStringFormat.raw);
      
      // Try to delete the test file
      await testRef.delete();
      
      print('Firebase Storage connection test: SUCCESS');
      return true;
    } catch (e) {
      print('Firebase Storage connection test: FAILED - $e');
      return false;
    }
  }

  // Generate next design ID for user
  Future<String> _generateNextDesignId(String userId) async {
    try {
      DocumentSnapshot userDoc = await _designsCollection.doc(userId).get();
      
      if (!userDoc.exists) {
        return '${userId}1';
      }
      
      Map<String, dynamic>? data = userDoc.data() as Map<String, dynamic>?;
      List<dynamic> designs = data?['designs'] ?? [];
      
      // Find the highest increment number
      int maxIncrement = 0;
      for (var design in designs) {
        String designId = design['designId'] ?? '';
        if (designId.startsWith(userId)) {
          String incrementStr = designId.substring(userId.length);
          int? increment = int.tryParse(incrementStr);
          if (increment != null && increment > maxIncrement) {
            maxIncrement = increment;
          }
        }
      }
      
      return '$userId${maxIncrement + 1}';
    } catch (e) {
      print('Error generating design ID: $e');
      return '${userId}1'; // Fallback to first design
    }
  }

  // Upload image to Firebase Storage
  Future<String> _uploadImageToStorage(String base64Image, String designId) async {
    try {
      print('Starting image upload for design: $designId');
      
      // Decode base64 to bytes
      Uint8List imageBytes = base64Decode(base64Image);
      print('Image decoded, size: ${imageBytes.length} bytes');
      
      // Create reference to storage location with timestamp for uniqueness
      String timestamp = DateTime.now().millisecondsSinceEpoch.toString();
      String fileName = '${designId}_$timestamp.jpg';
      Reference storageRef = _storage.ref('designs/$fileName');
      
      print('Storage reference created: ${storageRef.fullPath}');
      
      // Upload the file with metadata
      UploadTask uploadTask = storageRef.putData(
        imageBytes,
        SettableMetadata(
          contentType: 'image/jpeg',
          customMetadata: {
            'designId': designId,
            'uploadedBy': currentUserId ?? 'unknown',
            'uploadedAt': DateTime.now().toIso8601String(),
          },
        ),
      );
      
      // Monitor upload progress
      uploadTask.snapshotEvents.listen((TaskSnapshot snapshot) {
        double progress = (snapshot.bytesTransferred / snapshot.totalBytes) * 100;
        print('Upload progress: ${progress.toStringAsFixed(2)}%');
      });
      
      // Wait for upload to complete
      TaskSnapshot snapshot = await uploadTask.whenComplete(() {
        print('Upload completed for $fileName');
      });
      
      // Get download URL
      String downloadUrl = await snapshot.ref.getDownloadURL();
      print('Download URL obtained: $downloadUrl');
      
      return downloadUrl;
    } catch (e) {
      print('Error uploading image: $e');
      print('Error type: ${e.runtimeType}');
      
      // More specific error handling
      if (e.toString().contains('object-not-found')) {
        throw Exception('Storage bucket configuration error. Please check Firebase Storage rules and bucket setup.');
      } else if (e.toString().contains('unauthorized')) {
        throw Exception('Unauthorized access to Firebase Storage. Please check authentication.');
      } else if (e.toString().contains('network')) {
        throw Exception('Network error while uploading image. Please check your internet connection.');
      } else {
        throw Exception('Failed to upload image: $e');
      }
    }
  }

  // Save design data to Firestore
  Future<void> saveDesign({
    required String base64Image,
    required Map<String, dynamic> questionnaireData,
    required bool isSelected,
  }) async {
    try {
      if (currentUserId == null) {
        throw Exception('User not authenticated');
      }

      // Generate design ID
      String designId = await _generateNextDesignId(currentUserId!);
      
      // Upload image to storage
      String imageUrl = await _uploadImageToStorage(base64Image, designId);
      
      // Create design model
      DesignModel design = DesignModel(
        designId: designId,
        userId: currentUserId!,
        questionnaire: questionnaireData,
        designImageUrl: imageUrl,
        selected: isSelected,
        createdAt: DateTime.now(),
      );

      // Get existing user document
      DocumentReference userDocRef = _designsCollection.doc(currentUserId!);
      DocumentSnapshot userDoc = await userDocRef.get();

      if (userDoc.exists) {
        // Update existing document - add to designs array
        await userDocRef.update({
          'designs': FieldValue.arrayUnion([design.toMap()]),
          'updatedAt': FieldValue.serverTimestamp(),
        });
      } else {
        // Create new document with designs array
        await userDocRef.set({
          'userId': currentUserId!,
          'designs': [design.toMap()],
          'createdAt': FieldValue.serverTimestamp(),
          'updatedAt': FieldValue.serverTimestamp(),
        });
      }

      print('Design saved successfully with ID: $designId');
    } catch (e) {
      print('Error saving design: $e');
      throw Exception('Failed to save design: $e');
    }
  }

  // Save multiple designs at once (when all 3 are generated)
  Future<void> saveMultipleDesigns({
    required List<String> base64Images,
    required Map<String, dynamic> questionnaireData,
    required int selectedIndex,
  }) async {
    try {
      if (currentUserId == null) {
        throw Exception('User not authenticated');
      }

      List<DesignModel> designs = [];
      
      // Process each design
      for (int i = 0; i < base64Images.length; i++) {
        // Generate design ID
        String designId = await _generateNextDesignId(currentUserId!);
        
        String imageUrl;
        
        try {
          // Try to upload image to storage
          imageUrl = await _uploadImageToStorage(base64Images[i], designId);
          print('Successfully uploaded image to storage for design $designId');
        } catch (e) {
          print('Storage upload failed for design $designId: $e');
          print('Falling back to base64 storage in Firestore');
          
          // Fallback: store base64 directly (prefix to identify)
          imageUrl = 'data:image/jpeg;base64,${base64Images[i]}';
        }
        
        // Create design model
        DesignModel design = DesignModel(
          designId: designId,
          userId: currentUserId!,
          questionnaire: questionnaireData,
          designImageUrl: imageUrl,
          selected: i == selectedIndex, // Only selected design is marked as true
          createdAt: DateTime.now(),
        );
        
        designs.add(design);
        print('Design $designId processed successfully');
      }

      // Save all designs to user document
      DocumentReference userDocRef = _designsCollection.doc(currentUserId!);
      DocumentSnapshot userDoc = await userDocRef.get();

      List<Map<String, dynamic>> designMaps = designs.map((d) => d.toMap()).toList();

      if (userDoc.exists) {
        // Update existing document - add to designs array
        await userDocRef.update({
          'designs': FieldValue.arrayUnion(designMaps),
          'updatedAt': FieldValue.serverTimestamp(),
        });
      } else {
        // Create new document with designs array
        await userDocRef.set({
          'userId': currentUserId!,
          'designs': designMaps,
          'createdAt': FieldValue.serverTimestamp(),
          'updatedAt': FieldValue.serverTimestamp(),
        });
      }

      print('Successfully saved ${designs.length} designs');
    } catch (e) {
      print('Error saving multiple designs: $e');
      throw Exception('Failed to save designs: $e');
    }
  }

  // Get user's designs
  Future<List<DesignModel>> getUserDesigns() async {
    try {
      if (currentUserId == null) {
        throw Exception('User not authenticated');
      }

      DocumentSnapshot userDoc = await _designsCollection.doc(currentUserId!).get();
      
      if (!userDoc.exists) {
        return [];
      }

      Map<String, dynamic>? data = userDoc.data() as Map<String, dynamic>?;
      List<dynamic> designsData = data?['designs'] ?? [];
      
      return designsData.map((designData) => DesignModel.fromMap(designData)).toList();
    } catch (e) {
      print('Error fetching user designs: $e');
      return [];
    }
  }

  // Update design selection status
  Future<void> updateDesignSelection(String designId, bool selected) async {
    try {
      if (currentUserId == null) {
        throw Exception('User not authenticated');
      }

      DocumentReference userDocRef = _designsCollection.doc(currentUserId!);
      DocumentSnapshot userDoc = await userDocRef.get();
      
      if (!userDoc.exists) {
        throw Exception('User document not found');
      }

      Map<String, dynamic>? data = userDoc.data() as Map<String, dynamic>?;
      List<dynamic> designs = List.from(data?['designs'] ?? []);
      
      // Update the specific design
      for (int i = 0; i < designs.length; i++) {
        if (designs[i]['designId'] == designId) {
          designs[i]['selected'] = selected;
          break;
        }
      }

      // Update the document
      await userDocRef.update({
        'designs': designs,
        'updatedAt': FieldValue.serverTimestamp(),
      });

      print('Design selection updated for: $designId');
    } catch (e) {
      print('Error updating design selection: $e');
      throw Exception('Failed to update design selection: $e');
    }
  }
}