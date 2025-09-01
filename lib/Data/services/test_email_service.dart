import 'package:http/http.dart' as http;
import 'dart:convert';
import 'dart:io';
import 'dart:typed_data';
import 'package:flutter/foundation.dart';
import 'package:flutter_image_compress/flutter_image_compress.dart';
import 'package:path_provider/path_provider.dart';

class EmailJSDebugService {
  static const String _serviceId = 'service_uwuy153';
  static const String _templateId = 'template_7zj5iof';
  static const String _publicKey = 'xQoXK58-R-NzOi3NG';

  // Download network image
  static Future<String?> downloadNetworkImage(String imageUrl, String filename) async {
    try {
      final response = await http.get(Uri.parse(imageUrl));
      if (response.statusCode != 200) {
        if (kDebugMode) {
          print('Failed to download image: ${response.statusCode}');
        }
        return null;
      }

      final directory = await getTemporaryDirectory();
      final path = '${directory.path}/$filename';
      await File(path).writeAsBytes(response.bodyBytes);
      if (kDebugMode) {
        print('Saved network image to: $path');
      }
      return path;
    } catch (e) {
      if (kDebugMode) {
        print('Error downloading image: $e');
      }
      return null;
    }
  }

  static Future<Uint8List?> getImageBytes(String imagePath) async {
    try {
      final file = File(imagePath);
      if (!await file.exists()) {
        if (kDebugMode) {
          print('File does not exist: $imagePath');
        }
        return null;
      }
      if (kDebugMode) {
        print('Processing file: $imagePath');
      }
      return await file.readAsBytes();
    } catch (e) {
      if (kDebugMode) {
        print('Error getting image bytes: $e');
      }
      return null;
    }
  }

  static Future<Uint8List?> compressImage(String imagePath) async {
    try {
      final originalBytes = await getImageBytes(imagePath);
      if (originalBytes == null) {
        return null;
      }

      final originalSize = originalBytes.length;
      if (kDebugMode) {
        print('Original image size: ${(originalSize / 1024).toStringAsFixed(1)} KB');
      }

      if (originalSize < 100 * 1024) {
        return originalBytes;
      }

      final compressedBytes = await FlutterImageCompress.compressWithList(
        originalBytes,
        minHeight: 400,
        minWidth: 400,
        quality: 50,
        format: CompressFormat.jpeg,
      );

      final compressedSize = compressedBytes.length;
      if (kDebugMode) {
        print('Compressed image size: ${(compressedSize / 1024).toStringAsFixed(1)} KB');
      }

      return compressedBytes;
    } catch (e) {
      if (kDebugMode) {
        print('Error compressing image: $e');
      }
      return await getImageBytes(imagePath);
    }
  }

  static Future<bool> testEmailJSDirectly({
    required String toEmail,
    String? userMessage,
    List<String> imageUrls = const [],
    List<String> imagePaths = const [],
    bool minimalTest = false,
  }) async {
    final url = Uri.parse('https://api.emailjs.com/api/v1.0/email/send');

    // Prepare attachments (only for non-minimal test)
    List<Map<String, String>> attachments = [];
    if (!minimalTest) {
      // Handle network images
      for (int i = 0; i < imageUrls.length && i < 3; i++) {
        final filename = 'test_techpack${i + 1}.jpg';
        final filePath = await downloadNetworkImage(imageUrls[i], filename);
        if (filePath == null || !await File(filePath).exists()) {
          if (kDebugMode) {
            print('Skipping invalid network image: ${imageUrls[i]}');
          }
          continue;
        }

        final compressedBytes = await compressImage(filePath);
        if (compressedBytes == null) {
          if (kDebugMode) {
            print('Skipping failed compression: $filePath');
          }
          continue;
        }

        final base64Data = base64Encode(compressedBytes);
        attachments.add({
          'filename': filename,
          'data': base64Data,
          'contentType': 'image/jpeg',
        });
      }

      // Handle local file paths
      for (int i = 0; i < imagePaths.length && i < 3; i++) {
        final file = File(imagePaths[i]);
        if (!await file.exists()) {
          if (kDebugMode) {
            print('Skipping invalid file path: ${imagePaths[i]}');
          }
          continue;
        }

        final compressedBytes = await compressImage(imagePaths[i]);
        if (compressedBytes == null) {
          if (kDebugMode) {
            print('Skipping failed compression: ${imagePaths[i]}');
          }
          continue;
        }

        final filename = file.path.split('/').last;
        final base64Data = base64Encode(compressedBytes);
        attachments.add({
          'filename': filename,
          'data': base64Data,
          'contentType': 'image/jpeg',
        });
      }
    }

    // Prepare payload
    final payload = {
      'service_id': _serviceId,
      'template_id': _templateId,
      'user_id': _publicKey,
      'template_params': minimalTest
          ? {
              'to_email': toEmail,
              'message': userMessage ?? 'Minimal test email from Atelia Fashion App',
            }
          : {
              'to_email': toEmail,
              'name': 'Atelia Fashion App',
              'time': DateTime.now().toIso8601String(),
              'message': userMessage ?? 'Hello from Flutter 🚀',
            },
      if (!minimalTest && attachments.isNotEmpty) 'attachments': attachments,
    };

    if (kDebugMode) {
      print('🚀 Sending payload: ${jsonEncode(payload)}');
      if (!minimalTest) {
        print('📎 Attachments count: ${attachments.length}');
        for (var att in attachments) {
          print('📎 Attachment ${att['filename']}: ${att['data']} chars, contentType: ${att['contentType']}');
        }
      } else {
        print('📎 Minimal test: No attachments included');
      }
    }

    try {
      final response = await http.post(
        url,
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode(payload),
      );

      if (kDebugMode) {
        print('📤 Response Status: ${response.statusCode}');
        print('📤 Response Body: ${response.body}');
        if (response.statusCode != 200) {
          try {
            final errorJson = jsonDecode(response.body);
            print('📤 Parsed Error Details: ${jsonEncode(errorJson)}');
          } catch (e) {
            print('📤 Could not parse response body as JSON: ${response.body}');
          }
        }
      }

      if (response.statusCode == 200) {
        if (kDebugMode) {
          print('✅ Email sent successfully!');
        }
        return true;
      } else {
        if (kDebugMode) {
          print('❌ Failed to send email');
          print('Error details: ${response.body}');
        }
        return false;
      }
    } catch (e) {
      if (kDebugMode) {
        print('❌ Exception occurred: $e');
      }
      return false;
    }
  }
}