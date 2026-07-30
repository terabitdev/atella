import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:cloud_functions/cloud_functions.dart';
import 'package:atella/Data/Models/order_model.dart';

/// Wraps the order-related callables. Every mutation goes through Cloud
/// Functions — this service never writes to `orders` directly (matches the
/// callable-only security rules from Section 1).
class OrdersService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseFunctions _functions = FirebaseFunctions.instance;

  Future<String> createSampleOrderForm({
    required String conversationId,
    required int amountTotal,
    String currency = 'usd',
    String? description,
  }) async {
    final callable = _functions.httpsCallable('createSampleOrderForm');
    final result = await callable.call({
      'conversationId': conversationId,
      'amountTotal': amountTotal,
      'currency': currency,
      'description': description,
    });
    return (result.data as Map)['orderId'] as String;
  }

  Future<String> createOrderPaymentIntent({
    required String orderId,
    required ShippingInfo shipping,
  }) async {
    final callable = _functions.httpsCallable('createOrderPaymentIntent');
    final result = await callable.call({
      'orderId': orderId,
      'shipping': shipping.toMap(),
    });
    return (result.data as Map)['clientSecret'] as String;
  }

  Future<void> markOrderShipped({
    required String orderId,
    required String trackingNumber,
    String? trackingCarrier,
  }) async {
    final callable = _functions.httpsCallable('markOrderShipped');
    await callable.call({
      'orderId': orderId,
      'trackingNumber': trackingNumber,
      'trackingCarrier': trackingCarrier,
    });
  }

  Stream<OrderModel?> streamOrder(String orderId) {
    return _firestore
        .collection('orders')
        .doc(orderId)
        .snapshots()
        .map((doc) => doc.exists ? OrderModel.fromFirestore(doc) : null);
  }

  Future<OrderModel?> getOrder(String orderId) async {
    final doc = await _firestore.collection('orders').doc(orderId).get();
    if (!doc.exists) return null;
    return OrderModel.fromFirestore(doc);
  }

  Stream<List<OrderModel>> streamOrdersAsBuyer(String uid) {
    return _firestore
        .collection('orders')
        .where('userUid', isEqualTo: uid)
        .orderBy('createdAt', descending: true)
        .snapshots()
        .map((snap) => snap.docs.map((d) => OrderModel.fromFirestore(d)).toList());
  }

  Stream<List<OrderModel>> streamOrdersAsSupplier(String supplierOwnerUid) {
    return _firestore
        .collection('orders')
        .where('supplierOwnerUid', isEqualTo: supplierOwnerUid)
        .orderBy('createdAt', descending: true)
        .snapshots()
        .map((snap) => snap.docs.map((d) => OrderModel.fromFirestore(d)).toList());
  }
}
