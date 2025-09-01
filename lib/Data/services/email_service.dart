import 'package:http/http.dart' as http;
import 'dart:convert';
import 'dart:io';
import 'dart:typed_data';
import 'package:flutter/foundation.dart';
import 'package:flutter_image_compress/flutter_image_compress.dart';
import 'package:path_provider/path_provider.dart';

class EmailService {
  static const String _serviceId = 'service_uwuy153';
  static const String _templateId = 'template_7zj5iof';
  static const String _publicKey = 'xQoXK58-R-NzOi3NG';
  static const String _privateKey = 'tec1d9iLbllZvHiPEoMN8';
  static const String _openaiApiKey = 'YOUR_OPENAI_API_KEY';

  static Future<String> generateEmailContent({
    required String manufacturerName,
    required String manufacturerLocation,
    required String manufacturerCountry,
    required Map<String, dynamic> techPackData,
    required String userCompanyName,
  }) async {
    try {
      final prompt = '''
Generate a professional business email for a fashion brand to send to a manufacturer. Use this information:

Manufacturer: $manufacturerName
Location: $manufacturerLocation, $manufacturerCountry
Brand: $userCompanyName

Tech Pack Details:
- Main Fabric: ${techPackData['mainFabric'] ?? 'Not specified'}
- Secondary Materials: ${techPackData['secondaryMaterials'] ?? 'Not specified'}
- Fabric Properties: ${techPackData['fabricProperties'] ?? 'Not specified'}
- Primary Color: ${techPackData['primaryColor'] ?? 'Not specified'}
- Size Range: ${techPackData['sizeRange'] ?? 'Not specified'}
- Cost per Piece: ${techPackData['costPerPiece'] ?? 'Not specified'}
- Quantity: ${techPackData['quantity'] ?? 'Not specified'}
- Delivery Date: ${techPackData['deliveryDate'] ?? 'Not specified'}
- Accessories: ${techPackData['accessories'] ?? 'Not specified'}
- Logo Placement: ${techPackData['logoPlacement'] ?? 'Not specified'}
- Packaging Type: ${techPackData['packagingType'] ?? 'Not specified'}

Generate a professional email that:
1. Has a compelling subject line
2. Introduces the brand professionally
3. Clearly outlines the production requirements
4. Mentions that detailed tech pack images are attached
5. Requests a quote and production timeline
6. Maintains a professional yet friendly tone
7. Includes a clear call to action

Format as JSON with "subject" and "body" fields.
''';

      final response = await http.post(
        Uri.parse('https://api.openai.com/v1/chat/completions'),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $_openaiApiKey',
        },
        body: jsonEncode({
          'model': 'gpt-4',
          'messages': [
            {
              'role': 'system',
              'content': 'You are a professional business communication expert specializing in fashion industry B2B emails.',
            },
            {'role': 'user', 'content': prompt},
          ],
          'max_tokens': 1000,
          'temperature': 0.7,
        }),
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        final content = data['choices'][0]['message']['content'];

        try {
          final emailData = jsonDecode(content);
          return jsonEncode(emailData);
        } catch (e) {
          return jsonEncode({
            'subject': 'Production Inquiry from $userCompanyName',
            'body': content,
          });
        }
      } else {
        throw Exception('Failed to generate email content: ${response.statusCode}');
      }
    } catch (e) {
      return jsonEncode({
        'subject': 'Production Inquiry from $userCompanyName',
        'body': '''Dear $manufacturerName Team,

I hope this email finds you well.

My name is $userCompanyName, and I am reaching out regarding a potential production opportunity.

We are looking to produce a garment with the following specifications:
• Main Fabric: ${techPackData['mainFabric'] ?? 'Not specified'}
• Quantity: ${techPackData['quantity'] ?? 'Not specified'}
• Target Cost: ${techPackData['costPerPiece'] ?? 'Not specified'}
• Delivery Timeline: ${techPackData['deliveryDate'] ?? 'Not specified'}

I have attached detailed tech pack images and specifications for your review. Could you please provide:
1. A detailed quote for the specified quantity
2. Your production timeline
3. Sample development timeline and costs
4. Minimum order quantities

We are excited about the possibility of working with your team and look forward to your response.

Best regards
$userCompanyName''',
      });
    }
  }

  static bool isBase64(String str) {
    try {
      if (str.startsWith('data:image/') ||
          str.startsWith('/9j/') || // JPEG
          str.startsWith('iVBORw0KGgo') || // PNG
          str.startsWith('UklGR')) { // WebP
        return true;
      }
      base64.decode(str);
      return true;
    } catch (e) {
      return false;
    }
  }

  static Future<Uint8List?> getImageBytes(String imagePathOrBase64) async {
    try {
      if (isBase64(imagePathOrBase64)) {
        if (kDebugMode) {
          print('Processing base64 image data (${imagePathOrBase64.length} characters)');
        }
        String base64Data = imagePathOrBase64;
        if (base64Data.startsWith('data:image/')) {
          final commaIndex = base64Data.indexOf(',');
          if (commaIndex != -1) {
            base64Data = base64Data.substring(commaIndex + 1);
          }
        }
        return base64.decode(base64Data);
      } else {
        final file = File(imagePathOrBase64);
        if (!await file.exists()) {
          if (kDebugMode) {
            print('File does not exist: $imagePathOrBase64');
          }
          return null;
        }
        if (kDebugMode) {
          print('Processing file: $imagePathOrBase64');
        }
        return await file.readAsBytes();
      }
    } catch (e) {
      if (kDebugMode) {
        print('Error getting image bytes: $e');
      }
      return null;
    }
  }

  static Future<Uint8List?> compressImage(String imagePathOrBase64) async {
    try {
      final originalBytes = await getImageBytes(imagePathOrBase64);
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
        minHeight: 800,
        minWidth: 800,
        quality: 70,
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
      return await getImageBytes(imagePathOrBase64);
    }
  }

  static Future<String> convertImageToBase64(String imagePathOrBase64) async {
    try {
      final compressedBytes = await compressImage(imagePathOrBase64);
      if (compressedBytes != null) {
        return base64Encode(compressedBytes);
      }
      return '';
    } catch (e) {
      if (kDebugMode) {
        print('Error converting image to base64: $e');
      }
      return '';
    }
  }

  static Future<String> saveBase64ToFile(String base64Data, String filename) async {
    try {
      final directory = await getTemporaryDirectory();
      final path = '${directory.path}/$filename';
      String cleanBase64 = base64Data;
      if (base64Data.startsWith('data:image/')) {
        cleanBase64 = base64Data.substring(base64Data.indexOf(',') + 1);
      }
      final bytes = base64.decode(cleanBase64);
      await File(path).writeAsBytes(bytes);
      if (kDebugMode) {
        print('Saved image to: $path');
      }
      return path;
    } catch (e) {
      if (kDebugMode) {
        print('Error saving base64 to file: $e');
      }
      return '';
    }
  }

  static Future<bool> sendEmail({
    required String manufacturerEmail,
    required String manufacturerName,
    required String subject,
    required String body,
    required String userCompanyName,
    required String userEmail,
    List<String> imagePaths = const [],
  }) async {
    try {
      final url = Uri.parse('https://api.emailjs.com/api/v1.0/email/send');

      // Validate and prepare attachments
      List<Map<String, String>> attachments = [];
      for (int i = 0; i < imagePaths.length && i < 3; i++) {
        String base64Data;
        String filename = 'techpack${i + 1}.jpg';
        if (isBase64(imagePaths[i])) {
          final filePath = await saveBase64ToFile(imagePaths[i], filename);
          if (filePath.isEmpty || !await File(filePath).exists()) {
            if (kDebugMode) {
              print('Skipping invalid base64 data: ${imagePaths[i].substring(0, 20)}...');
            }
            continue;
          }
          base64Data = await convertImageToBase64(filePath);
        } else {
          final file = File(imagePaths[i]);
          if (!await file.exists()) {
            if (kDebugMode) {
              print('Skipping invalid file path: ${imagePaths[i]}');
            }
            continue;
          }
          base64Data = await convertImageToBase64(imagePaths[i]);
          filename = file.path.split('/').last;
        }
        if (base64Data.isNotEmpty) {
          attachments.add({
            'name': filename,
            'data': base64Data,
          });
        }
      }

      // Shorten body if too long
      String optimizedBody = body.length > 1000 ? '${body.substring(0, 1000)}...' : body;

      final payload = {
        'service_id': _serviceId,
        'template_id': _templateId,
        'user_id': _publicKey,
        'template_params': {
          'to_email': manufacturerEmail,
          'from_name': userCompanyName,
          'reply_to': userEmail,
          'subject': subject,
          'message': optimizedBody,
        },
        'attachments': attachments,
      };

      if (kDebugMode) {
        print('Payload: ${jsonEncode(payload)}');
        print('🚀 Sending email to: $manufacturerEmail');
        print('📧 Subject: $subject');
        print('📎 Attachments count: ${attachments.length}');
        for (var att in attachments) {
          print('📎 Attachment ${att['name']}: ${att['data']?.length ?? 0} chars');
        }
      }

      final response = await http.post(
        url,
        headers: {
          'Content-Type': 'application/json',
        },
        body: jsonEncode(payload),
      );

      if (kDebugMode) {
        print('📤 Response Status: ${response.statusCode}');
        print('📤 Response Body: ${response.body}');
      }

      return response.statusCode == 200;
    } catch (e) {
      if (kDebugMode) {
        print('❌ Exception while sending email: $e');
      }
      return false;
    }
  }
}