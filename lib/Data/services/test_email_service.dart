import 'package:emailjs/emailjs.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

class TestEmailService {
  static const String _serviceId = 'service_uv0kspo';
  static const String _templateId = 'template_zn65ngo';
  static const String _publicKey = 'sHhGQhlBeKKbxxXAO';

  static Future<bool> sendTestEmail({
    required String toEmail,
    String? userMessage,
  }) async {
    try {
      final templateParams = {
        'to_email': toEmail,
        'to_name': 'Test User',
        'from_name': 'Atelia Fashion App',
        'from_email': 'noreply@atelia.com',
        'subject': 'Test Email from Atelia App',
        'message': userMessage ?? '''Hello!

This is a test email sent from the Atelia Fashion App to verify that our email integration is working correctly.

Best regards,
Atelia Team''',
      };

      await EmailJS.send(
        _serviceId,
        _templateId,
        templateParams,
        const Options(
          publicKey: _publicKey,
          limitRate: LimitRate(
            id: 'test_email',
            throttle: 5000, // 5 second throttle
          ),
        ),
      );

      return true;
    } catch (e) {
      print('❌ Test email failed: $e');
      return false;
    }
  }

  static Future<void> showTestEmailDialog({
    required String defaultEmail,
    Function(String)? onEmailSent,
  }) async {
    final TextEditingController emailController = TextEditingController(text: defaultEmail);
    final TextEditingController messageController = TextEditingController();
    final RxBool isSending = false.obs;

    Get.dialog(
      AlertDialog(
        title: const Text('Send Test Email'),
        content: Obx(() => Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
              controller: emailController,
              decoration: const InputDecoration(
                labelText: 'Email Address',
                border: OutlineInputBorder(),
                prefixIcon: Icon(Icons.email),
              ),
              keyboardType: TextInputType.emailAddress,
              enabled: !isSending.value,
            ),
            const SizedBox(height: 16),
            TextField(
              controller: messageController,
              decoration: const InputDecoration(
                labelText: 'Custom Message (Optional)',
                border: OutlineInputBorder(),
                prefixIcon: Icon(Icons.message),
              ),
              maxLines: 3,
              enabled: !isSending.value,
            ),
            if (isSending.value) ...[
              const SizedBox(height: 16),
              const Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  CircularProgressIndicator(),
                  SizedBox(width: 16),
                  Text('Sending email...'),
                ],
              ),
            ],
          ],
        )),
        actions: [
          TextButton(
            onPressed: isSending.value ? null : () => Get.back(),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: isSending.value ? null : () async {
              final email = emailController.text.trim();
              if (email.isEmpty) {
                Get.snackbar(
                  'Error',
                  'Please enter an email address',
                  backgroundColor: Colors.red.shade100,
                  colorText: Colors.red.shade800,
                );
                return;
              }

              isSending.value = true;
              
              final success = await sendTestEmail(
                toEmail: email,
                userMessage: messageController.text.trim().isEmpty 
                  ? null 
                  : messageController.text.trim(),
              );

              isSending.value = false;

              if (success) {
                Get.back();
                Get.snackbar(
                  'Success!',
                  'Test email sent successfully to $email',
                  backgroundColor: Colors.green.shade100,
                  colorText: Colors.green.shade800,
                  duration: const Duration(seconds: 3),
                );
                onEmailSent?.call(email);
              } else {
                Get.snackbar(
                  'Error',
                  'Failed to send email. Please check your configuration.',
                  backgroundColor: Colors.red.shade100,
                  colorText: Colors.red.shade800,
                );
              }
            },
            child: const Text('Send Test Email'),
          ),
        ],
      ),
    );
  }
}