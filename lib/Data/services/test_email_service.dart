import 'dart:convert';
import 'package:http/http.dart' as http;

class EmailJSDebugService {
  static const String _serviceId = 'service_uv0kspo';
  static const String _templateId = 'template_zn65ngo';
  static const String _publicKey = 'sHhGQhlBeKKbxxXAO';

  static Future<void> testEmailJSDirectly({
    required String toEmail,
    String? userMessage,
  }) async {
    final url = Uri.parse('https://api.emailjs.com/api/v1.0/email/send');
    
    final payload = {
      'service_id': _serviceId,
      'template_id': _templateId,
      'user_id': _publicKey, // Note: EmailJS REST API uses 'user_id'
      'template_params': {
        'to_email': toEmail,
        'message': userMessage ?? 'Hello from Flutter 🚀',
        'from_name': 'Atelia Fashion App',
      }
    };

    print('🚀 Sending payload: ${jsonEncode(payload)}');

    try {
      final response = await http.post(
        url,
        headers: {
          'Content-Type': 'application/json',
        },
        body: jsonEncode(payload),
      );

      print('📤 Response Status: ${response.statusCode}');
      print('📤 Response Body: ${response.body}');

      if (response.statusCode == 200) {
        print('✅ Email sent successfully!');
      } else {
        print('❌ Failed to send email');
        print('Error details: ${response.body}');
      }
    } catch (e) {
      print('❌ Exception occurred: $e');
    }
  }
}