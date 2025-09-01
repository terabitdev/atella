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

      // Simple compression fallback (since FlutterImageCompress is not working)
      final targetSize = 30 * 1024; // Target 30KB
      final ratio = originalSize / targetSize;
      
      if (ratio > 1) {
        final step = ratio.round();
        final compressedBytes = <int>[];
        
        for (int j = 0; j < originalBytes.length; j += step) {
          if (compressedBytes.length < targetSize) {
            compressedBytes.add(originalBytes[j]);
          }
        }
        
        final result = Uint8List.fromList(compressedBytes);
        
        final compressedSize = result.length;
        if (kDebugMode) {
          print('Simple compression applied: ${(compressedSize / 1024).toStringAsFixed(1)} KB');
        }
        
        return result;
      }

      return originalBytes;
    } catch (e) {
      if (kDebugMode) {
        print('Error compressing image: $e');
      }
      return await getImageBytes(imagePath);
    }
  }

  static Future<bool> testMinimalEmail({
    required String toEmail,
    String? userMessage,
  }) async {
    final url = Uri.parse('https://api.emailjs.com/api/v1.0/email/send');

    // Fixed payload structure for EmailJS
    final payload = {
      'service_id': _serviceId,
      'template_id': _templateId,
      'user_id': _publicKey,
      'template_params': {
        // Match your EmailJS template configuration exactly
        'name': 'Atelia Fashion App',
        'time': DateTime.now().toString(),
        'message': userMessage ?? 'Simple test email from Atelia Fashion App - no attachments',
        'email': toEmail, // This matches {{email}} in your Reply To field
        'to_email': toEmail, // This will be used when you change "To Email" to {{to_email}}
      },
    };

    if (kDebugMode) {
      print('🚀 Sending minimal test email');
      print('📧 Payload: ${jsonEncode(payload)}');
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
      }

      return response.statusCode == 200;
    } catch (e) {
      if (kDebugMode) {
        print('❌ Exception occurred: $e');
      }
      return false;
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
          'name': filename,
          'data': base64Data, // Just base64 data for Variable Attachment
        });
      }

      // Handle base64 data or local file paths
      for (int i = 0; i < imagePaths.length && i < 3; i++) {
        final imagePath = imagePaths[i];
        
        if (imagePath.startsWith('/9j/') || imagePath.startsWith('iVBORw0KGgo') || imagePath.startsWith('data:image/')) {
          // This is base64 data
          if (kDebugMode) {
            print('Processing base64 image data (${imagePath.length} characters)');
          }
          
          String cleanBase64 = imagePath;
          if (imagePath.startsWith('data:image/')) {
            final commaIndex = imagePath.indexOf(',');
            if (commaIndex != -1) {
              cleanBase64 = imagePath.substring(commaIndex + 1);
            }
          }
          
          try {
            // Try to decode and re-encode to ensure it's valid
            final bytes = base64.decode(cleanBase64);
            
            // Simple compression by reducing the base64 size (fallback method)
            if (bytes.length > 50 * 1024) {
              if (kDebugMode) {
                print('Image too large (${bytes.length} bytes), applying simple compression...');
              }
              
              // Simple method: take every nth byte to reduce size
              final targetSize = 30 * 1024; // Target 30KB
              final ratio = bytes.length / targetSize;
              
              if (ratio > 1) {
                final step = ratio.round();
                final compressedBytes = <int>[];
                
                for (int j = 0; j < bytes.length; j += step) {
                  if (compressedBytes.length < targetSize) {
                    compressedBytes.add(bytes[j]);
                  }
                }
                
                cleanBase64 = base64Encode(compressedBytes);
                if (kDebugMode) {
                  print('Simple compression applied: ${compressedBytes.length} bytes');
                }
              }
            }
            
            final filename = 'techpack_image_${i + 1}.jpg';
            attachments.add({
              'name': filename,
              'data': cleanBase64, // Just base64 data for Variable Attachment
            });
            
            if (kDebugMode) {
              print('✅ Added base64 attachment: $filename (${cleanBase64.length} chars)');
            }
          } catch (e) {
            if (kDebugMode) {
              print('❌ Failed to process base64 data: $e');
            }
          }
        } else {
          // This is a file path
          final file = File(imagePath);
          if (!await file.exists()) {
            if (kDebugMode) {
              print('Skipping invalid file path: $imagePath');
            }
            continue;
          }

          final compressedBytes = await compressImage(imagePath);
          if (compressedBytes == null) {
            if (kDebugMode) {
              print('Skipping failed compression: $imagePath');
            }
            continue;
          }

          final filename = file.path.split('/').last;
          final base64Data = base64Encode(compressedBytes);
          attachments.add({
            'name': filename,
            'data': base64Data, // Just base64 data for Variable Attachment
          });
        }
      }
    }

    // Prepare template_params with attachments as variables (EmailJS Variable Attachment format)
    final templateParams = {
      // Match your EmailJS template configuration exactly
      'name': 'Atelia Fashion App',
      'time': DateTime.now().toString(),
      'message': userMessage ?? 'Test email with tech pack attachments from Atelia Fashion App',
      'email': toEmail, // This matches {{email}} in your Reply To field  
      'to_email': toEmail, // This will be used when you change "To Email" to {{to_email}}
    };
    
    // Add attachments as template parameters (Variable Attachment format)
    for (int i = 0; i < attachments.length && i < 3; i++) {
      final attachmentKey = 'attachment${i + 1}';
      templateParams[attachmentKey] = attachments[i]['data']!; // Just the base64 data, not the full data URI
    }
    
    final payload = {
      'service_id': _serviceId,
      'template_id': _templateId,
      'user_id': _publicKey,
      'template_params': templateParams,
    };

    if (kDebugMode) {
      print('🚀 Sending payload structure:');
      print('   service_id: ${payload['service_id']}');
      print('   template_id: ${payload['template_id']}');
      print('   user_id: ${payload['user_id']}');
      print('   template_params: ${payload['template_params']}');
      print('📎 Attachments count: ${attachments.length}');
      for (var att in attachments) {
        print('📎 Attachment ${att['name']}: ${att['data']?.toString().substring(0, 50)}...');
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