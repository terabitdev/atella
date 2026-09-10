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
import 'package:docx_template_fork/docx_template_fork.dart';

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

  // Save a design-only entry to the Dashboard (no tech pack pages yet).
  // Writes to the same users/{uid}/tech_packs collection as saveTechPackImages,
  // with has_tech_pack: false, so it shows up on the Dashboard immediately
  // without any of the tech-pack/export/factory actions.
  static Future<String> saveDesignOnly({
    required String base64Image,
    required String techPackId,
    String? projectName,
    String? collectionName,
    Map<String, dynamic>? designData,
  }) async {
    final user = _auth.currentUser;
    if (user == null) throw Exception('User not authenticated');

    try {
      final bytes = base64Decode(base64Image);

      final fileName = 'design_${DateTime.now().millisecondsSinceEpoch}.png';
      final ref = _storage
          .ref()
          .child('users')
          .child(user.uid)
          .child('tech_packs')
          .child(techPackId)
          .child(fileName);

      final uploadTask = await ref.putData(
        bytes,
        SettableMetadata(
          contentType: 'image/png',
          customMetadata: {
            'uploaded_by': user.uid,
            'tech_pack_id': techPackId,
          },
        ),
      );

      final downloadUrl = await uploadTask.ref.getDownloadURL();

      Map<String, dynamic> designOnlyData = {
        'tech_pack_id': techPackId,
        'images': <String, String>{},
        'selected_design_image_url': downloadUrl,
        'has_tech_pack': false,
        'created_at': FieldValue.serverTimestamp(),
        'updated_at': FieldValue.serverTimestamp(),
      };

      if (projectName != null) {
        designOnlyData['project_name'] = projectName;
      }
      if (collectionName != null) {
        designOnlyData['collection_name'] = collectionName;
      }
      if (designData != null) {
        designOnlyData['design_questionnaire'] = designData;
      }

      await _firestore
          .collection('users')
          .doc(user.uid)
          .collection('tech_packs')
          .doc(techPackId)
          .set(designOnlyData, SetOptions(merge: true));

      // Trigger a refresh event for any listening screens
      await _firestore
          .collection('users')
          .doc(user.uid)
          .set({
            'last_tech_pack_update': FieldValue.serverTimestamp(),
          }, SetOptions(merge: true));

      return downloadUrl;
    } catch (e) {
      throw Exception('Failed to save design: $e');
    }
  }

  // Request storage permission for Android
  static Future<bool> _requestStoragePermission() async {
    if (Platform.isAndroid) {
      // For Android 13+ (API 33+), we need to request photos permission
      // For Android 11-12 (API 30-32), we can use app-specific storage without permission
      // For Android 10 and below, we need storage permission

      // Check Android version
      final androidInfo = await Permission.storage.status;

      // For Android 11+ (API 30+), we don't need MANAGE_EXTERNAL_STORAGE
      // We can use app-specific storage which doesn't require permission
      if (androidInfo.isDenied || androidInfo.isPermanentlyDenied) {
        final status = await Permission.storage.request();

        // If still denied, try using photos permission for Android 13+
        if (status.isDenied || status.isPermanentlyDenied) {
          // Try photos permission (for Android 13+)
          final photosStatus = await Permission.photos.request();
          if (photosStatus.isGranted) {
            return true;
          }

          // For Android 11+, we can still save to app-specific directory
          // which doesn't require permission
          return true;
        }
        return status.isGranted;
      }
      return true;
    }
    return true; // iOS doesn't need this permission
  }

  // Generate and save PDF from tech pack images
  static Future<String> generateTechPackPDF({
    required List<String> base64Images,
    required String techPackSummary,
    required String projectName,
    bool withLogo = true,
    String? labelImagePath,
    String? logoPlacement,
    String? selectedDesignImageBase64,
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

// Load images before adding the page (only if withLogo is true)
pw.MemoryImage? titleImage;
pw.MemoryImage? logoImage;

if (withLogo) {
  titleImage = pw.MemoryImage(
    (await rootBundle.load('assets/images/title.png')).buffer.asUint8List(),
  );
  logoImage = pw.MemoryImage(
    (await rootBundle.load('assets/images/logo.png')).buffer.asUint8List(),
  );
}

// Load the final selected design image for the summary page, if provided
pw.MemoryImage? designImage;
if (selectedDesignImageBase64 != null && selectedDesignImageBase64.isNotEmpty) {
  try {
    final designBytes = base64Decode(selectedDesignImageBase64);
    designImage = pw.MemoryImage(designBytes);
  } catch (e) {
    print('⚠️ Could not load selected design image: $e');
  }
}

// Add cover page
pdf.addPage(
  pw.Page(
    pageFormat: PdfPageFormat.a4,
    margin: const pw.EdgeInsets.all(32),
    build: (context) {
      return pw.Column(
        crossAxisAlignment: pw.CrossAxisAlignment.start,
        children: [
          // Top row with title image (left) and logo image (right) - only if withLogo is true
          if (withLogo && titleImage != null && logoImage != null)
            pw.Row(
              mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
              children: [
                pw.Image(titleImage, height: 40, width: 120),
                pw.Image(logoImage, height: 40, width: 40),
              ],
            ),

          if (withLogo) pw.SizedBox(height: 20),

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

          if (designImage != null) ...[
            pw.SizedBox(height: 20),
            pw.Text(
              'Final Design',
              style: const pw.TextStyle(fontSize: 16),
            ),
            pw.SizedBox(height: 12),
            pw.Expanded(
              child: pw.Center(
                child: pw.Image(designImage, fit: pw.BoxFit.contain),
              ),
            ),
            pw.SizedBox(height: 12),
          ] else
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


      // Load label image if provided
      pw.MemoryImage? labelImage;
      if (labelImagePath != null && labelImagePath.isNotEmpty) {
        try {
          final labelFile = File(labelImagePath);
          if (await labelFile.exists()) {
            final labelBytes = await labelFile.readAsBytes();
            labelImage = pw.MemoryImage(labelBytes);
            print('✅ Label image loaded for PDF overlay');
          }
        } catch (e) {
          print('⚠️ Could not load label image: $e');
        }
      }

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
                    child: (i == 1 && labelImage != null)
                        ? pw.Stack(
                            children: [
                              // Main technical flat drawing (full size)
                              pw.Positioned.fill(
                                child: pw.Image(pdfImages[i], fit: pw.BoxFit.contain),
                              ),
                              // Logo overlay (top-right corner, bigger size)
                              pw.Positioned(
                                top: 20,
                                right: 20,
                                child: pw.Container(
                                  width: 60,
                                  height: 60,
                                  decoration: pw.BoxDecoration(
                                    color: PdfColors.white,
                                    borderRadius: pw.BorderRadius.circular(4),
                                  ),
                                  padding: const pw.EdgeInsets.all(4),
                                  child: pw.Image(
                                    labelImage,
                                    fit: pw.BoxFit.contain,
                                  ),
                                ),
                              ),
                            ],
                          )
                        : pw.Center(
                            child: pw.Image(pdfImages[i], fit: pw.BoxFit.contain),
                          ),
                  ),
                ],
              );
            },
          ),
        );
      }

      // Add a dedicated logo page if the user selected a logo/label image
      if (labelImage != null) {
        pdf.addPage(
          pw.Page(
            pageFormat: PdfPageFormat.a4,
            margin: const pw.EdgeInsets.all(32),
            build: (context) {
              return pw.Column(
                children: [
                  pw.Text(
                    'Logo',
                    style: const pw.TextStyle(fontSize: 18),
                  ),
                  pw.SizedBox(height: 20),
                  pw.Expanded(
                    child: pw.Center(
                      child: pw.Image(labelImage!, fit: pw.BoxFit.contain),
                    ),
                  ),
                  if (logoPlacement != null && logoPlacement.isNotEmpty) ...[
                    pw.SizedBox(height: 12),
                    pw.Text(
                      'Placement: $logoPlacement',
                      style: const pw.TextStyle(fontSize: 12),
                    ),
                  ],
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
        // For Android 11+ (API 30+), use app-specific storage
        // This doesn't require permissions and files are accessible via Files app
        directory = await getExternalStorageDirectory() ??
            await getApplicationDocumentsDirectory();

        // Navigate to a user-accessible location
        // From: /storage/emulated/0/Android/data/com.app/files
        // To: /storage/emulated/0/Download/ATELIA
        final List<String> paths = directory.path.split('/');
        final int index = paths.indexWhere((element) => element == 'Android');

        if (index != -1) {
          // Build path to Downloads/ATELIA
          final basePath = paths.sublist(0, index).join('/');
          directory = Directory('$basePath/Download/ATELIA');

          // Create directory if it doesn't exist
          if (!await directory.exists()) {
            try {
              await directory.create(recursive: true);
            } catch (e) {
              // If we can't create in Downloads, fall back to app-specific storage
              print('Could not create Downloads folder, using app storage: $e');
              directory = await getExternalStorageDirectory() ??
                  await getApplicationDocumentsDirectory();
            }
          }
          folderName = '';
        } else {
          folderName = 'TechPack';
        }
      } else {
        // Use documents directory for iOS
        directory = await getApplicationDocumentsDirectory();
        folderName = 'TechPack';
      }

      // Create TechPack folder if needed
      Directory techPackDir = directory;
      if (folderName.isNotEmpty) {
        techPackDir = Directory('${directory.path}/$folderName');
        if (!await techPackDir.exists()) {
          await techPackDir.create(recursive: true);
        }
      }

      final fileName = 'TechPack_${DateTime.now().millisecondsSinceEpoch}.pdf';
      final file = File('${techPackDir.path}/$fileName');

      final pdfBytes = await pdf.save();

      // Write bytes with flush to ensure file is written to disk immediately
      await file.writeAsBytes(pdfBytes, flush: true);

      // Add small delay to ensure file system has caught up
      await Future.delayed(const Duration(milliseconds: 300));

      // Verify file was created and has content
      if (!await file.exists()) {
        throw Exception('PDF file was not created successfully');
      }

      // Verify file size matches expected
      final fileSize = await file.length();
      if (fileSize == 0) {
        throw Exception('PDF file is empty');
      }

      if (fileSize != pdfBytes.length) {
        print('⚠️ Warning: File size mismatch. Expected: ${pdfBytes.length}, Got: $fileSize');
      }

      print('✅ PDF saved successfully: ${file.path} (${fileSize} bytes)');
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

      final data = userDesignDoc.data();
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

  // Generate and save Word document from tech pack images
  static Future<String> generateTechPackWord({
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

      // Load the Word template from assets
      final data = await rootBundle.load('assets/tech_pack_template.docx');
      final bytes = data.buffer.asUint8List();
      final docx = await DocxTemplate.fromBytes(bytes);

      // Prepare content for template
      final content = Content();

      // Add text content
      content
        ..add(TextContent("project_name", projectName.isNotEmpty ? projectName : 'Fashion Project'))
        ..add(TextContent("tech_pack_summary", techPackSummary))
        ..add(TextContent("generation_date", DateTime.now().toString().split(' ')[0]));

      // Add images as base64
      print('=== WORD DOCUMENT IMAGES ===');
      print('Total images received: ${base64Images.length}');
      
      if (base64Images.isNotEmpty) {
        // SWAPPED FOR TESTING - Send Technical Flat to placeholder 1
        final firstImageBytes = base64Decode(base64Images[1]);
        final firstImagePreview = base64Images[1].substring(0, 50);
        print('🔄 TEST: Sending Image[1] (Technical Flat) → TITLE=tech_pack_image_1');
        print('  Base64 preview: $firstImagePreview...');
        print('  Size: ${firstImageBytes.length} bytes');
        print('  Adding ImageContent with TITLE: tech_pack_image_1');
        content.add(ImageContent("tech_pack_image_1", firstImageBytes));
        print('  ✅ Added to content');
      }

      if (base64Images.length > 1) {
        // SWAPPED FOR TESTING - Send Manufacturing to placeholder 2
        final secondImageBytes = base64Decode(base64Images[0]);
        final secondImagePreview = base64Images[0].substring(0, 50);
        print('🔄 TEST: Sending Image[0] (Manufacturing) → TITLE=tech_pack_image_2');
        print('  Base64 preview: $secondImagePreview...');
        print('  Size: ${secondImageBytes.length} bytes');
        print('  Adding ImageContent with TITLE: tech_pack_image_2');
        content.add(ImageContent("tech_pack_image_2", secondImageBytes));
        print('  ✅ Added to content');
        
        // CRITICAL: Verify images are different
        final areImagesIdentical = base64Images[0] == base64Images[1];
        print('⚠️ ARE IMAGES IDENTICAL? $areImagesIdentical');
        if (areImagesIdentical) {
          print('❌ ERROR: Both images have the same base64 string!');
          print('This means the AI generated the same image twice or there is an issue with image order.');
        }
      } else {
        print('⚠️ Only one image available, {{tech_pack_image_2}} will be empty');
      }
      
      print('===========================');

      print('Generating Word document with content...');

      // Generate the final document
      final generated = await docx.generate(content);

      if (generated == null) {
        throw Exception('Failed to generate Word document');
      }

      print('Word document generated, size: ${generated.length} bytes');

      // Get appropriate directory for saving Word document
      Directory directory;
      String folderName;

      if (Platform.isAndroid) {
        directory = await getExternalStorageDirectory() ??
            await getApplicationDocumentsDirectory();

        final List<String> paths = directory.path.split('/');
        final int index = paths.indexWhere((element) => element == 'Android');

        if (index != -1) {
          final basePath = paths.sublist(0, index).join('/');
          directory = Directory('$basePath/Download/ATELIA');

          if (!await directory.exists()) {
            try {
              await directory.create(recursive: true);
            } catch (e) {
              print('Could not create Downloads folder, using app storage: $e');
              directory = await getExternalStorageDirectory() ??
                  await getApplicationDocumentsDirectory();
            }
          }
          folderName = '';
        } else {
          folderName = 'TechPack';
        }
      } else {
        directory = await getApplicationDocumentsDirectory();
        folderName = 'TechPack';
      }

      // Create TechPack folder if needed
      Directory techPackDir = directory;
      if (folderName.isNotEmpty) {
        techPackDir = Directory('${directory.path}/$folderName');
        if (!await techPackDir.exists()) {
          await techPackDir.create(recursive: true);
        }
      }

      final fileName = 'TechPack_${DateTime.now().millisecondsSinceEpoch}.docx';
      final file = File('${techPackDir.path}/$fileName');

      // Write bytes with flush to ensure file is written to disk immediately
      await file.writeAsBytes(generated, flush: true);

      // Add small delay to ensure file system has caught up
      await Future.delayed(const Duration(milliseconds: 300));

      // Verify file was created and has content
      if (!await file.exists()) {
        throw Exception('Word file was not created successfully');
      }

      // Verify file size
      final fileSize = await file.length();
      if (fileSize == 0) {
        throw Exception('Word file is empty');
      }

      if (fileSize != generated.length) {
        print('⚠️ Warning: File size mismatch. Expected: ${generated.length}, Got: $fileSize');
      }

      print('✅ Word document saved successfully: ${file.path} (${fileSize} bytes)');
      return file.path;
    } catch (e) {
      print('Error in generateTechPackWord: $e');
      throw Exception('Failed to generate Word document: $e');
    }
  }

  // Download Word document to Downloads folder
  static Future<String> downloadWord(String filePath) async {
    try {
      final file = File(filePath);

      // Verify file exists
      if (!await file.exists()) {
        throw Exception('Word file not found at path: $filePath');
      }

      // Get file size to ensure it's valid
      final fileSize = await file.length();
      if (fileSize == 0) {
        throw Exception('Word file is empty');
      }

      print('Word document downloaded successfully: $filePath (${fileSize} bytes)');

      // Return the file path for success message
      return filePath;
    } catch (e) {
      print('Error downloading Word: $e');
      throw Exception('Failed to download Word document: $e');
    }
  }
}
