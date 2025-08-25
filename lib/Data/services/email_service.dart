import 'package:emailjs/emailjs.dart';
import 'package:emailjs/emailjs.dart' as EmailJS;
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'dart:io';
import 'package:flutter/foundation.dart';

class EmailService {
  static const String _serviceId = 'YOUR_EMAILJS_SERVICE_ID';
  static const String _templateId = 'YOUR_EMAILJS_TEMPLATE_ID';
  static const String _publicKey = 'YOUR_EMAILJS_PUBLIC_KEY';
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

My name is [Your Name] from $userCompanyName, and I am reaching out regarding a potential production opportunity.

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

Best regards,
[Your Name]
$userCompanyName''',
      });
    }
  }

  static Future<String> convertImageToBase64(String imagePath) async {
    try {
      final file = File(imagePath);
      final bytes = await file.readAsBytes();
      return base64Encode(bytes);
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
      // Convert images to base64 for attachment
      List<Map<String, String>> attachments = [];
      for (int i = 0; i < imagePaths.length; i++) {
        if (imagePaths[i].isNotEmpty) {
          final base64Image = await convertImageToBase64(imagePaths[i]);
          if (base64Image.isNotEmpty) {
            String fileName = '';
            if (i == 0) fileName = 'design_reference.jpg';
            else if (i == 1) fileName = 'measurement_chart.jpg';
            else if (i == 2) fileName = 'label_reference.jpg';
            else fileName = 'image_${i + 1}.jpg';

            attachments.add({
              'name': fileName,
              'data': base64Image,
              'type': 'image/jpeg',
            });
          }
        }
      }

      final templateParams = {
        'to_email': manufacturerEmail,
        'to_name': manufacturerName,
        'from_name': userCompanyName,
        'from_email': userEmail,
        'subject': subject,
        'message': body,
        'attachments': attachments,
      };

      await EmailJS.send(
        _serviceId,
        _templateId,
        templateParams,
        const Options(
          publicKey: _publicKey,
          limitRate: const LimitRate(
            id: 'app',
            throttle: 10000,
          ),
        ),
      );

      return true;
    } catch (e) {
      if (kDebugMode) {
        print('Email sending failed: $e');
      }
      return false;
    }
  }
}