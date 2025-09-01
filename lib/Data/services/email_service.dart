import 'package:http/http.dart' as http;
import 'dart:convert';
import 'dart:io';
import 'dart:typed_data';
import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';

class EmailService {
  static const String _serviceId = 'service_6wga9uc';
  static const String _templateId = 'template_zn65ngo';
  static const String _publicKey = 'sHhGQhlBeKKbxxXAO';
  static const String _privateKey = 'Phyfg7C4d6MiNjO7DFMBp';
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
              'content': 'You are a professional business communication expert specializing in fashion industry B2B emails.'
            },
            {
              'role': 'user',
              'content': prompt,
            }
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
          // If JSON parsing fails, return a fallback structure
          return jsonEncode({
            'subject': 'Production Inquiry from $userCompanyName',
            'body': content,
          });
        }
      } else {
        throw Exception('Failed to generate email content: ${response.statusCode}');
      }
    } catch (e) {
      // Fallback email content
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
      // Check if string looks like base64 (common image prefixes)
      if (str.startsWith('data:image/') || 
          str.startsWith('/9j/') || // JPEG
          str.startsWith('iVBORw0KGgo') || // PNG
          str.startsWith('UklGR')) { // WebP
        return true;
      }
      
      // Try to decode as base64
      base64.decode(str);
      return true;
    } catch (e) {
      return false;
    }
  }

  static Future<Uint8List?> getImageBytes(String imagePathOrBase64) async {
    try {
      // Check if it's base64 data
      if (isBase64(imagePathOrBase64)) {
        if (kDebugMode) {
          print('Processing base64 image data (${imagePathOrBase64.length} characters)');
        }
        
        String base64Data = imagePathOrBase64;
        // Remove data URL prefix if present
        if (base64Data.startsWith('data:image/')) {
          final commaIndex = base64Data.indexOf(',');
          if (commaIndex != -1) {
            base64Data = base64Data.substring(commaIndex + 1);
          }
        }
        
        return base64.decode(base64Data);
      } else {
        // It's a file path
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

      // If file is already small enough (less than 12KB), don't compress
      if (originalSize < 12 * 1024) {
        return originalBytes;
      }

      // Use a simple byte reduction approach by reducing quality
      // This is a basic implementation - just take every nth byte for smaller images
      final targetSize = 10 * 1024; // Target 10KB (3 images = 30KB total)
      final ratio = originalSize / targetSize;
      
      if (ratio > 1) {
        // Simple decimation - take every nth byte
        final step = (ratio * 1.2).round(); // Add some margin
        final compressedBytes = <int>[];
        
        for (int i = 0; i < originalBytes.length; i += step) {
          if (compressedBytes.length < targetSize) {
            compressedBytes.add(originalBytes[i]);
          } else {
            break;
          }
        }
        
        final result = Uint8List.fromList(compressedBytes);
        if (kDebugMode) {
          print('Compressed image size: ${(result.length / 1024).toStringAsFixed(1)} KB');
        }
        
        return result;
      }

      return originalBytes;
    } catch (e) {
      if (kDebugMode) {
        print('Error compressing image: $e');
      }
      // Return original bytes if compression fails
      return await getImageBytes(imagePathOrBase64);
    }
  }

  static Future<String> convertImageToBase64(String imagePath) async {
    try {
      final compressedBytes = await compressImage(imagePath);
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
      
      // Convert images to base64 for attachment
      List<Map<String, String>> attachments = [];
      for (int i = 0; i < imagePaths.length; i++) {
        if (imagePaths[i].isNotEmpty) {
          final base64Image = await convertImageToBase64(imagePaths[i]);
          if (base64Image.isNotEmpty) {
            String fileName = '';
            if (i == 0) fileName = 'selected_design.jpg';
            else if (i == 1) fileName = 'tech_pack_flat_drawing.jpg';
            else if (i == 2) fileName = 'tech_pack_manufacturing.jpg';
            else fileName = 'image_${i + 1}.jpg';

            attachments.add({
              'name': fileName,
              'data': base64Image,
              'type': 'image/jpeg',
            });
          }
        }
      }

      // Truncate the body if it's too long to save space
      String optimizedBody = body;
      if (body.length > 1000) {
        optimizedBody = '${body.substring(0, 1000)}...';
      }

      final payload = {
        'service_id': _serviceId,
        'template_id': _templateId,
        'user_id': _publicKey,
        'accessToken': _privateKey,
        'template_params': {
          'to_email': manufacturerEmail,
          'to_name': manufacturerName,
          'from_name': userCompanyName,
          'from_email': userEmail,
          'subject': subject,
          'message': optimizedBody,
          'attachments': attachments,
        }
      };

      if (kDebugMode) {
        print('🚀 Sending email to: $manufacturerEmail');
        print('📧 Subject: $subject');
        print('📎 Attachments count: ${attachments.length}');
        
        // Calculate total payload size
        final payloadJson = jsonEncode(payload);
        final payloadSize = payloadJson.length;
        print('📊 Total payload size: ${(payloadSize / 1024).toStringAsFixed(1)} KB');
        
        // Calculate attachment sizes
        int totalAttachmentSize = 0;
        for (int i = 0; i < attachments.length; i++) {
          final attachmentSize = attachments[i]['data']?.length ?? 0;
          totalAttachmentSize += attachmentSize;
          print('📎 Attachment ${i + 1} size: ${(attachmentSize / 1024).toStringAsFixed(1)} KB');
        }
        print('📎 Total attachments size: ${(totalAttachmentSize / 1024).toStringAsFixed(1)} KB');
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
        print('❌ Exception occurred while sending email: $e');
      }
      return false;
    }
  }
}