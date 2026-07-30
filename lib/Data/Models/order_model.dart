import 'package:cloud_firestore/cloud_firestore.dart';

class ShippingInfo {
  final String name;
  final String addressLine1;
  final String? addressLine2;
  final String city;
  final String state;
  final String postalCode;
  final String country;
  final String phone;

  ShippingInfo({
    required this.name,
    required this.addressLine1,
    this.addressLine2,
    required this.city,
    required this.state,
    required this.postalCode,
    required this.country,
    required this.phone,
  });

  Map<String, dynamic> toMap() => {
        'name': name,
        'addressLine1': addressLine1,
        'addressLine2': addressLine2,
        'city': city,
        'state': state,
        'postalCode': postalCode,
        'country': country,
        'phone': phone,
      };

  factory ShippingInfo.fromMap(Map<String, dynamic> map) => ShippingInfo(
        name: map['name'] ?? '',
        addressLine1: map['addressLine1'] ?? '',
        addressLine2: map['addressLine2'],
        city: map['city'] ?? '',
        state: map['state'] ?? '',
        postalCode: map['postalCode'] ?? '',
        country: map['country'] ?? '',
        phone: map['phone'] ?? '',
      );
}

/// A sample or production order. Money-bearing — always created/mutated via
/// Cloud Functions (Admin SDK); the client only ever reads this collection.
class OrderModel {
  final String id;
  final String type; // sample | production
  final String submissionId;
  final String conversationId;
  final String userUid;
  final String userName;
  final String supplierId;
  final String supplierOwnerUid;
  final String companyName;
  final int amountTotal; // smallest currency unit (e.g. cents)
  final String currency;
  final int applicationFeeAmount;
  final String? description;
  final String status; // awaiting_payment | paid | shipped | delivered | cancelled | refunded
  final ShippingInfo? shipping;
  final String? trackingNumber;
  final String? trackingCarrier;
  final int? quantity;
  final DateTime? createdAt;
  final DateTime? paidAt;
  final DateTime? shippedAt;

  OrderModel({
    required this.id,
    required this.type,
    required this.submissionId,
    required this.conversationId,
    required this.userUid,
    required this.userName,
    required this.supplierId,
    required this.supplierOwnerUid,
    required this.companyName,
    required this.amountTotal,
    required this.currency,
    required this.applicationFeeAmount,
    this.description,
    required this.status,
    this.shipping,
    this.trackingNumber,
    this.trackingCarrier,
    this.quantity,
    this.createdAt,
    this.paidAt,
    this.shippedAt,
  });

  double get amountTotalDisplay => amountTotal / 100;

  factory OrderModel.fromFirestore(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>? ?? {};
    return OrderModel(
      id: doc.id,
      type: data['type'] ?? 'sample',
      submissionId: data['submissionId'] ?? '',
      conversationId: data['conversationId'] ?? '',
      userUid: data['userUid'] ?? '',
      userName: data['userName'] ?? 'Designer',
      supplierId: data['supplierId'] ?? '',
      supplierOwnerUid: data['supplierOwnerUid'] ?? '',
      companyName: data['companyName'] ?? 'Supplier',
      amountTotal: data['amountTotal'] ?? 0,
      currency: data['currency'] ?? 'usd',
      applicationFeeAmount: data['applicationFeeAmount'] ?? 0,
      description: data['description'],
      status: data['status'] ?? 'awaiting_payment',
      shipping: data['shipping'] != null ? ShippingInfo.fromMap(Map<String, dynamic>.from(data['shipping'])) : null,
      trackingNumber: data['trackingNumber'],
      trackingCarrier: data['trackingCarrier'],
      quantity: data['quantity'],
      createdAt: (data['createdAt'] as Timestamp?)?.toDate(),
      paidAt: (data['paidAt'] as Timestamp?)?.toDate(),
      shippedAt: (data['shippedAt'] as Timestamp?)?.toDate(),
    );
  }
}
