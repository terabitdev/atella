import 'dart:convert';
import 'dart:io';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:path_provider/path_provider.dart';
import 'package:permission_handler/permission_handler.dart';


class TechPackService {
  static final FirebaseStorage _storage = FirebaseStorage.instance;
  static final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  static final FirebaseAuth _auth = FirebaseAuth.instance;

  // Save tech pack images to Firebase Storage
  static Future<Map<String, String>> saveTechPackImages({
    required List<String> base64Images,
    required String techPackId,
  }) async {
    final user = _auth.currentUser;
    if (user == null) throw Exception('User not authenticated');

    Map<String, String> uploadedUrls = {};

    try {
      for (int i = 0; i < base64Images.length; i++) {
        // Convert base64 to bytes
        final bytes = base64Decode(base64Images[i]);
        
        // Create reference in Firebase Storage
        final fileName = 'tech_pack_${i + 1}_${DateTime.now().millisecondsSinceEpoch}.png';
        final ref = _storage.ref()
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

      // Save metadata to Firestore
      await _firestore
          .collection('users')
          .doc(user.uid)
          .collection('tech_packs')
          .doc(techPackId)
          .set({
        'images': uploadedUrls,
        'created_at': FieldValue.serverTimestamp(),
        'updated_at': FieldValue.serverTimestamp(),
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

      // Add cover page
      pdf.addPage(
        pw.Page(
          pageFormat: PdfPageFormat.a4,
          margin: const pw.EdgeInsets.all(32),
          build: (context) {
            return pw.Column(
              crossAxisAlignment: pw.CrossAxisAlignment.start,
              children: [
                pw.Center(
                  child: pw.Text(
                    'TECH PACK',
                    style: const pw.TextStyle(
                      fontSize: 32,
                    ),
                  ),
                ),
                pw.SizedBox(height: 20),
                pw.Center(
                  child: pw.Text(
                    projectName.isNotEmpty ? projectName : 'Fashion Project',
                    style: const pw.TextStyle(
                      fontSize: 24,
                    ),
                  ),
                ),
                pw.SizedBox(height: 40),
                pw.Divider(thickness: 2),
                pw.SizedBox(height: 20),
                pw.Text(
                  'Project Specifications',
                  style: const pw.TextStyle(
                    fontSize: 18,
                  ),
                ),
                pw.SizedBox(height: 16),
                pw.Text(
                  techPackSummary,
                  style: const pw.TextStyle(
                    fontSize: 14,
                    lineSpacing: 1.5,
                  ),
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
                    style: const pw.TextStyle(
                      fontSize: 18,
                    ),
                  ),
                  pw.SizedBox(height: 16),
                  pw.Expanded(
                    child: pw.Center(
                      child: pw.Image(
                        pdfImages[i],
                        fit: pw.BoxFit.contain,
                      ),
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
        directory = await getExternalStorageDirectory() ?? await getApplicationDocumentsDirectory();
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
}