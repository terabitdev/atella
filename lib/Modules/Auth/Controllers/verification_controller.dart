import 'package:get/get.dart';

class VerificationController extends GetxController {
  final RxString selectedMethod = 'email'.obs;
  final RxString maskedEmail = '********@mail.com'.obs;

  void selectVerificationMethod(String method) {
    selectedMethod.value = method;
  }

  bool get isEmailSelected => selectedMethod.value == 'email';

  void sendVerificationLink() {
    // Handle sending verification link logic
    if (selectedMethod.value == 'email') {
      // Send email verification
      print('Sending email verification to: ${maskedEmail.value}');
    }
  }
}
