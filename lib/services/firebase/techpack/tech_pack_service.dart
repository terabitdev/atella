import 'dart:convert';
import 'dart:io';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:path_provider/path_provider.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:flutter/services.dart' show rootBundle;

class TechPackService {
  static final FirebaseStorage _storage = FirebaseStorage.instance;
  static final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  static final FirebaseAuth _auth = FirebaseAuth.instance;

  // Save tech pack images to Firebase Storage with complete questionnaire data
  static Future<Map<String, String>> saveTechPackImages({
    required List<String> base64Images,
    required String techPackId,
    String? projectName,
    String? collectionName,
    String? selectedDesignImageUrl,
    Map<String, dynamic>? techPackQuestionnaireData,
    Map<String, dynamic>? designData,
  }) async {
    final user = _auth.currentUser;
    if (user == null) throw Exception('User not authenticated');

    Map<String, String> uploadedUrls = {};

    try {
      for (int i = 0; i < base64Images.length; i++) {
        // Convert base64 to bytes
        final bytes = base64Decode(base64Images[i]);

        // Create reference in Firebase Storage
        final fileName =
            'tech_pack_${i + 1}_${DateTime.now().millisecondsSinceEpoch}.png';
        final ref = _storage
            .ref()
            .child('users')
            .child(user.uid)
            .child('tech_packs')
            .child(techPackId)
            .child(fileName);

        // Upload the image
        final uploadTask = await ref.putData(
          bytes,
          SettableMetadata(
            contentType: 'image/png',
            customMetadata: {
              'uploaded_by': user.uid,
              'tech_pack_id': techPackId,
              'image_index': i.toString(),
            },
          ),
        );

        // Get download URL
        final downloadUrl = await uploadTask.ref.getDownloadURL();
        uploadedUrls['image_${i + 1}'] = downloadUrl;
      }

      // Save complete metadata to Firestore including questionnaire data
      Map<String, dynamic> techPackData = {
        'tech_pack_id': techPackId,
        'images': uploadedUrls,
        'created_at': FieldValue.serverTimestamp(),
        'updated_at': FieldValue.serverTimestamp(),
      };

      // Add optional fields if provided
      if (projectName != null) {
        techPackData['project_name'] = projectName;
      }
      if (collectionName != null) {
        techPackData['collection_name'] = collectionName;
      }
      if (selectedDesignImageUrl != null) {
        techPackData['selected_design_image_url'] = selectedDesignImageUrl;
      }
      
      // Add tech pack questionnaire data if provided
      if (techPackQuestionnaireData != null) {
        techPackData['tech_pack_details'] = techPackQuestionnaireData;
      }
      
      // Add design questionnaire data if provided
      if (designData != null) {
        techPackData['design_questionnaire'] = designData;
      }

      await _firestore
          .collection('users')
          .doc(user.uid)
          .collection('tech_packs')
          .doc(techPackId)
          .set(techPackData, SetOptions(merge: true));

      // Trigger a refresh event for any listening screens
      await _firestore
          .collection('users')
          .doc(user.uid)
          .set({
            'last_tech_pack_update': FieldValue.serverTimestamp(),
          }, SetOptions(merge: true));

      return uploadedUrls;
    } catch (e) {
      throw Exception('Failed to save tech pack images: $e');
    }
  }

  // Request storage permission for Android
  static Future<bool> _requestStoragePermission() async {
    if (Platform.isAndroid) {
      final status = await Permission.storage.request();
      return status.isGranted;
    }
    return true; // iOS doesn't need this permission
  }

  // Generate and save PDF from tech pack images
  static Future<String> generateTechPackPDF({
    required List<String> base64Images,
    required String techPackSummary,
    required String projectName,
  }) async {
    try {
      // Request permission first
      final hasPermission = await _requestStoragePermission();
      if (!hasPermission) {
        throw Exception('Storage permission denied');
      }

      final pdf = pw.Document();

      // Use simple text styling without problematic fonts

      // Convert base64 images to PDF images
      List<pw.ImageProvider> pdfImages = [];
      for (String base64Image in base64Images) {
        try {
          final bytes = base64Decode(base64Image);
          final image = pw.MemoryImage(bytes);
          pdfImages.add(image);
        } catch (e) {
          print('Error processing image: $e');
          throw Exception('Failed to process tech pack image');
        }
      }

// Load images before adding the page
final titleImage = pw.MemoryImage(
  (await rootBundle.load('assets/images/title.png')).buffer.asUint8List(),
);

final logoImage = pw.MemoryImage(
  (await rootBundle.load('assets/images/logo.png')).buffer.asUint8List(),
);

// Add cover page
pdf.addPage(
  pw.Page(
    pageFormat: PdfPageFormat.a4,
    margin: const pw.EdgeInsets.all(32),
    build: (context) {
      return pw.Column(
        crossAxisAlignment: pw.CrossAxisAlignment.start,
        children: [
          // Top row with title image (left) and logo image (right)
          pw.Row(
            mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
            children: [
              pw.Image(titleImage, height: 40, width: 120),
              pw.Image(logoImage, height: 40, width: 40),
            ],
          ),

          pw.SizedBox(height: 20),

          pw.Center(
            child: pw.Text(
              projectName.isNotEmpty ? projectName : 'Fashion Project',
              style: const pw.TextStyle(fontSize: 24),
            ),
          ),
          pw.SizedBox(height: 40),
          pw.Divider(thickness: 2),
          pw.SizedBox(height: 20),

          pw.Text(
            'Project Specifications',
            style: const pw.TextStyle(fontSize: 18),
          ),
          pw.SizedBox(height: 16),

          pw.Text(
            techPackSummary,
            style: const pw.TextStyle(fontSize: 14, lineSpacing: 1.5),
          ),

          pw.Spacer(),

          pw.Center(
            child: pw.Text(
              'Generated on ${DateTime.now().toString().split(' ')[0]}',
              style: const pw.TextStyle(
                fontSize: 12,
                color: PdfColors.grey700,
              ),
            ),
          ),
        ],
      );
    },
  ),
);


      // Add image pages
      for (int i = 0; i < pdfImages.length; i++) {
        pdf.addPage(
          pw.Page(
            pageFormat: PdfPageFormat.a4,
            margin: const pw.EdgeInsets.all(16),
            build: (context) {
              return pw.Column(
                children: [
                  pw.Text(
                    i == 0 ? 'Tech Pack Details' : 'Technical Flat Drawing',
                    style: const pw.TextStyle(fontSize: 18),
                  ),
                  pw.SizedBox(height: 16),
                  pw.Expanded(
                    child: pw.Center(
                      child: pw.Image(pdfImages[i], fit: pw.BoxFit.contain),
                    ),
                  ),
                ],
              );
            },
          ),
        );
      }

      // Get appropriate directory for saving PDF
      Directory directory;
      String folderName;

      if (Platform.isAndroid) {
        // Use external storage directory for Android
        directory =
            await getExternalStorageDirectory() ??
            await getApplicationDocumentsDirectory();
        folderName = 'TechPack Downloads';
      } else {
        // Use documents directory for iOS
        directory = await getApplicationDocumentsDirectory();
        folderName = 'TechPack';
      }

      // Create TechPack folder inside the directory
      final techPackDir = Directory('${directory.path}/$folderName');
      if (!await techPackDir.exists()) {
        await techPackDir.create(recursive: true);
      }

      final fileName = 'TechPack_${DateTime.now().millisecondsSinceEpoch}.pdf';
      final file = File('${techPackDir.path}/$fileName');

      final pdfBytes = await pdf.save();
      await file.writeAsBytes(pdfBytes);

      // Verify file was created
      if (!await file.exists()) {
        throw Exception('PDF file was not created successfully');
      }

      print('PDF saved to: ${file.path}');
      return file.path;
    } catch (e) {
      print('Error in generateTechPackPDF: $e');
      throw Exception('Failed to generate PDF: $e');
    }
  }

  // Download PDF to Downloads folder
  static Future<String> downloadPDF(String filePath) async {
    try {
      final file = File(filePath);

      // Verify file exists
      if (!await file.exists()) {
        throw Exception('PDF file not found at path: $filePath');
      }

      // Get file size to ensure it's valid
      final fileSize = await file.length();
      if (fileSize == 0) {
        throw Exception('PDF file is empty');
      }

      print('PDF downloaded successfully: $filePath (${fileSize} bytes)');

      // Return the file path for success message
      return filePath;
    } catch (e) {
      print('Error downloading PDF: $e');
      throw Exception('Failed to download PDF: $e');
    }
  }

  // Get selected design image URL for current user - OPTIMIZED VERSION
  static Future<String?> getSelectedDesignImageUrl() async {
    try {
      final user = _auth.currentUser;
      if (user == null) {
        print('User not authenticated');
        return null;
      }

      print('Looking for selected design for user: ${user.uid}');

      // Get the user's design document from designs collection
      final userDesignDoc = await _firestore
          .collection('designs')
          .doc(user.uid)
          .get();

      if (!userDesignDoc.exists) {
        print('No design document found for user');
        return null;
      }

      final data = userDesignDoc.data() as Map<String, dynamic>?;
      final designs = data?['designs'] as List<dynamic>? ?? [];
      
      print('Found ${designs.length} designs');

      // With new optimized structure, get the most recent design
      // All designs in the array are already "selected" designs
      if (designs.isNotEmpty) {
        // Get the most recent design (last in array or by timestamp)
        final latestDesign = designs.last as Map<String, dynamic>;
        
        // Use the new field name from optimized structure
        final designImageUrl = latestDesign['selectedDesignImageUrl'] as String?;
        
        if (designImageUrl != null) {
          print('Found selected design with URL: $designImageUrl');
          return designImageUrl;
        }
        
        // Fallback for old structure
        final oldImageUrl = latestDesign['designImageUrl'] as String?;
        if (oldImageUrl != null) {
          print('Found design with URL (old structure): $oldImageUrl');
          return oldImageUrl;
        }
      }
      
      print('No selected design found');
      return null;
    } catch (e) {
      print('Error getting selected design: $e');
      return null;
    }
  }
}
