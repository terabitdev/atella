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

  // NEW: Save all images to Storage but only selected design data to Firestore
  Future<void> saveDesignsOptimized({
    required List<String> base64Images,
    required Map<String, dynamic> questionnaireData,
    required int selectedIndex,
  }) async {
    try {
      if (currentUserId == null) {
        throw Exception('User not authenticated');
      }

      print('=== OPTIMIZED DESIGN SAVE STARTED ===');
      
      // Step 1: Upload ALL images to Firebase Storage
      List<String> allImageUrls = [];
      String sessionId = DateTime.now().millisecondsSinceEpoch.toString();
      
      for (int i = 0; i < base64Images.length; i++) {
        try {
          // Create unique path for each design image
          Uint8List imageBytes = base64Decode(base64Images[i]);
          String fileName = 'design_${i + 1}_$sessionId.jpg';
          Reference storageRef = _storage.ref('users/$currentUserId/designs/$sessionId/$fileName');
          
          print('Uploading design ${i + 1} to Storage...');
          
          // Upload with metadata
          UploadTask uploadTask = storageRef.putData(
            imageBytes,
            SettableMetadata(
              contentType: 'image/jpeg',
              customMetadata: {
                'sessionId': sessionId,
                'designIndex': i.toString(),
                'isSelected': (i == selectedIndex).toString(),
                'uploadedBy': currentUserId!,
                'uploadedAt': DateTime.now().toIso8601String(),
              },
            ),
          );
          
          TaskSnapshot snapshot = await uploadTask;
          String downloadUrl = await snapshot.ref.getDownloadURL();
          allImageUrls.add(downloadUrl);
          
          print('✅ Design ${i + 1} uploaded successfully');
        } catch (e) {
          print('❌ Failed to upload design ${i + 1}: $e');
          throw Exception('Failed to upload design image ${i + 1}');
        }
      }
      
      print('All ${allImageUrls.length} images uploaded to Storage');
      
      // Step 2: Save ONLY selected design data to Firestore
      String designId = await _generateNextDesignId(currentUserId!);
      
      // Create design document with selected design data only
      // Note: Cannot use FieldValue.serverTimestamp() inside arrays
      Map<String, dynamic> selectedDesignData = {
        'designId': designId,
        'userId': currentUserId!,
        'sessionId': sessionId,
        'selectedDesignImageUrl': allImageUrls[selectedIndex],
        'selectedIndex': selectedIndex,
        'allDesignImageUrls': allImageUrls, // Store references to all images
        'questionnaire': questionnaireData,
        'creativeBrief': questionnaireData['creativeBrief'] ?? {},
        'refinedConcept': questionnaireData['refinedConcept'] ?? {},
        'finalDetails': questionnaireData['finalDetails'] ?? {},
        'prompt': questionnaireData['prompt'] ?? '',
        'createdAt': DateTime.now().toIso8601String(), // Use DateTime instead of serverTimestamp
        'updatedAt': DateTime.now().toIso8601String(),
      };
      
      // Save to Firestore (only selected design data)
      DocumentReference userDocRef = _designsCollection.doc(currentUserId!);
      DocumentSnapshot userDoc = await userDocRef.get();
      
      if (userDoc.exists) {
        // Update existing document - add to designs array
        await userDocRef.update({
          'designs': FieldValue.arrayUnion([selectedDesignData]),
          'updatedAt': FieldValue.serverTimestamp(),
        });
      } else {
        // Create new document with designs array
        await userDocRef.set({
          'userId': currentUserId!,
          'designs': [selectedDesignData],
          'createdAt': FieldValue.serverTimestamp(),
          'updatedAt': FieldValue.serverTimestamp(),
        });
      }
      
      print('=== OPTIMIZED SAVE COMPLETED ===');
      print('✅ Storage: All ${allImageUrls.length} images saved');
      print('✅ Firestore: Only selected design data saved (index: $selectedIndex)');
      
    } catch (e) {
      print('=== OPTIMIZED SAVE FAILED ===');
      print('Error: $e');
      throw Exception('Failed to save designs: $e');
    }
  }

  // DEPRECATED: Old method that saves all designs to Firestore
  // Keeping for backward compatibility but marked as deprecated
  @Deprecated('Use saveDesignsOptimized instead - it only saves selected design to Firestore')
  Future<void> saveMultipleDesigns({
    required List<String> base64Images,
    required Map<String, dynamic> questionnaireData,
    required int selectedIndex,
  }) async {
    // Call the new optimized method instead
    await saveDesignsOptimized(
      base64Images: base64Images,
      questionnaireData: questionnaireData,
      selectedIndex: selectedIndex,
    );
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

  // NEW: Get all design images for a session (useful for viewing design history)
  Future<List<String>> getSessionDesignImages(String sessionId) async {
    try {
      if (currentUserId == null) {
        throw Exception('User not authenticated');
      }
      
      // Get the design document that contains this session
      DocumentSnapshot userDoc = await _designsCollection.doc(currentUserId!).get();
      
      if (!userDoc.exists) {
        return [];
      }
      
      Map<String, dynamic>? data = userDoc.data() as Map<String, dynamic>?;
      List<dynamic> designs = data?['designs'] ?? [];
      
      // Find the design with matching sessionId
      for (var design in designs) {
        if (design['sessionId'] == sessionId) {
          List<dynamic> urls = design['allDesignImageUrls'] ?? [];
          return urls.cast<String>();
        }
      }
      
      return [];
    } catch (e) {
      print('Error fetching session design images: $e');
      return [];
    }
  }
  
  // NEW: Get only selected designs for display (optimized for list views)
  Future<List<Map<String, dynamic>>> getSelectedDesigns() async {
    try {
      if (currentUserId == null) {
        throw Exception('User not authenticated');
      }
      
      DocumentSnapshot userDoc = await _designsCollection.doc(currentUserId!).get();
      
      if (!userDoc.exists) {
        return [];
      }
      
      Map<String, dynamic>? data = userDoc.data() as Map<String, dynamic>?;
      List<dynamic> designs = data?['designs'] ?? [];
      
      // Return only essential data for each design
      return designs.map((design) => {
        'designId': design['designId'],
        'selectedDesignImageUrl': design['selectedDesignImageUrl'],
        'sessionId': design['sessionId'],
        'createdAt': design['createdAt'],
        'prompt': design['prompt'] ?? '',
      }).toList().cast<Map<String, dynamic>>();
      
    } catch (e) {
      print('Error fetching selected designs: $e');
      return [];
    }
  }

  // Update design selection status (kept for compatibility but simplified)
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
      
      // With new architecture, this is mainly for changing selection after save
      // Update the specific design
      for (int i = 0; i < designs.length; i++) {
        if (designs[i]['designId'] == designId) {
          // Update selected index if needed
          designs[i]['selectedIndex'] = selected ? designs[i]['selectedIndex'] : -1;
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