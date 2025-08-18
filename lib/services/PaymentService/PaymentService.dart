import 'dart:convert';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:http/http.dart' as http;
import 'package:flutter_stripe/flutter_stripe.dart';

import '../../core/themes/app_colors.dart';



class PaymentService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;
  Map<String, dynamic>? paymentIntentData;
  static Future<Map<String, dynamic>?> createPaymentIntent(
      String amount, String currency) async {
    try {
      Map<String, dynamic> body = {
        'amount': calculateAmount(amount),
        'currency': currency,
        'payment_method_types[]': 'card',
      };

      var response = await http.post(
        Uri.parse('https://api.stripe.com/v1/payment_intents'),
        body: body,
        headers: {
          'Authorization':
          'Bearer ',
          'Content-Type': 'application/x-www-form-urlencoded',
        },
      );
      return jsonDecode(response.body);
    } catch (err) {
      print('Error creating payment intent: ${err.toString()}');
      return null;
    }
  }

  static Future<void> initPaymentSheet(
      {required String clientSecret,
        required String merchantDisplayName}) async {
    try {
      await Stripe.instance.initPaymentSheet(
        paymentSheetParameters: SetupPaymentSheetParameters(
          paymentIntentClientSecret: clientSecret,
          merchantDisplayName: merchantDisplayName,
          style: ThemeMode.dark,
        ),
      );
    } catch (e) {
      print('Error initializing payment sheet: $e');
    }
  }

  static Future<void> displayPaymentSheet() async {
    try {
      await Stripe.instance.presentPaymentSheet();
    } catch (e) {
      print('Error displaying payment sheet: $e');
      throw Exception('Payment failed or cancelled');
    }
  }

  static String calculateAmount(String amount) {
    final a = (int.parse(amount)) * 100;
    return a.toString();
  }

  Future<void> makePayment(BuildContext context) async {
    try {
      paymentIntentData = await PaymentService.createPaymentIntent('80', 'EUR');
      if (paymentIntentData != null) {
        await PaymentService.initPaymentSheet(
          clientSecret: paymentIntentData!['client_secret'],
          merchantDisplayName: 'Your Merchant',
        );
        await PaymentService.displayPaymentSheet();
        await updatePremiumStatus();
        paymentIntentData = null;
        PaymentService()
            .showSubscriptionSuccessDialog(
            context);
      } else {
        print('Failed to create payment intent');
      }
    } catch (e) {
      print('Payment exception: $e');
    }
  }

  Future<void> updatePremiumStatus() async {
    try {
      final String userId = _auth.currentUser?.uid ?? '';
      if (userId.isEmpty) throw Exception('User not authenticated');

      final DateTime now = DateTime.now();
      await _firestore.collection('users').doc(userId).update({
        'isPremium': true,
        'premiumStartDate': now.toIso8601String(),
        'premiumEndDate': now.add(Duration(days: 365)).toIso8601String(),
      });
    } catch (e) {
      print('Error updating premium status: $e');
      throw Exception('Failed to update premium status');
    }
  }

  Future<void> showSubscriptionSuccessDialog(BuildContext context) async {
    return showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => AlertDialog(
        contentPadding: EdgeInsets.zero,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(10.r),
        ),
        content: Container(
          width: double.infinity,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(10.r),
            color: Color(0xFFF7F8FA),
          ),
          child: Padding(
            padding: EdgeInsets.symmetric(horizontal: 20.w, vertical: 20.h),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Container(
                  padding: const EdgeInsets.all(4),
                  decoration: BoxDecoration(
                    color: AppColors.splashcolor,
                    borderRadius: BorderRadius.circular(15),
                  ),
                  child: const Icon(
                    Icons.check,
                    color: Colors.white,
                    size: 20,
                  ),
                ),
                SizedBox(height: 15.h),
                Text(
                  'Subscription Activated Successfully',
                  style:TextStyle(
                    color: Colors.black,
                    fontSize: 16.sp,
                  ),
                ),
                SizedBox(height: 20.h),
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      backgroundColor:  Colors.black,
                      padding: const EdgeInsets.symmetric(
                        horizontal: 50,
                        vertical: 10,
                      ),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(10),
                      ),
                      minimumSize: const Size(double.infinity, 50),
                    ),
                    onPressed: () {
                      Navigator.pop(context);
                      Get.offAllNamed('/HomeScreen');
                    },
                    child: Text(
                      'Done',
                      style:TextStyle(
                        color: Colors.black,
                        fontSize: 16.sp,
                    ),
                  ),
                ),
                )],
            ),
          ),
        ),
      ),
    );
  }
}