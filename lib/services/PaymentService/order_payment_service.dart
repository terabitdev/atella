import 'package:flutter/material.dart';
import 'package:flutter_stripe/flutter_stripe.dart';

/// Presents Stripe's payment sheet for a single order PaymentIntent
/// (client_secret supplied by the createOrderPaymentIntent Cloud Function —
/// no secret key ever touches the client). Deliberately separate from
/// stripe_subscription_service.dart to avoid dragging in its unrelated
/// subscription/customer-reuse logic.
class OrderPaymentService {
  Future<bool> payForOrder(String clientSecret) async {
    await Stripe.instance.initPaymentSheet(
      paymentSheetParameters: SetupPaymentSheetParameters(
        paymentIntentClientSecret: clientSecret,
        merchantDisplayName: 'Atelia',
        style: ThemeMode.system,
      ),
    );

    await Stripe.instance.presentPaymentSheet();
    return true;
  }
}
