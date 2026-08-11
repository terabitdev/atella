import 'package:cloud_firestore/cloud_firestore.dart';

/// A manufacturing workshop's account on Atella. Distinct from the static
/// `manufacturer_model.dart` catalog — this represents an invited, logged-in
/// supplier with orders, messaging, and payouts.
class SupplierModel {
  final String id;
  final String companyName;
  final String? logoUrl;
  final String? specialty;
  final String? originCountry;
  final String? description;
  final String status; // pending_invite | active | disabled
  final String? ownerUid;
  final String inviteEmail;
  final bool payoutsEnabled;
  final bool detailsSubmitted;
  final String onboardingStatus; // not_started | in_progress | complete
  final String? stripeConnectAccountId;
  final DateTime? createdAt;

  SupplierModel({
    required this.id,
    required this.companyName,
    this.logoUrl,
    this.specialty,
    this.originCountry,
    this.description,
    required this.status,
    this.ownerUid,
    required this.inviteEmail,
    this.payoutsEnabled = false,
    this.detailsSubmitted = false,
    this.onboardingStatus = 'not_started',
    this.stripeConnectAccountId,
    this.createdAt,
  });

  factory SupplierModel.fromFirestore(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>? ?? {};
    return SupplierModel(
      id: doc.id,
      companyName: data['companyName'] ?? '',
      logoUrl: data['logoUrl'],
      specialty: data['specialty'],
      originCountry: data['originCountry'],
      description: data['description'],
      status: data['status'] ?? 'pending_invite',
      ownerUid: data['ownerUid'],
      inviteEmail: data['inviteEmail'] ?? '',
      payoutsEnabled: data['payoutsEnabled'] ?? false,
      detailsSubmitted: data['detailsSubmitted'] ?? false,
      onboardingStatus: data['onboardingStatus'] ?? 'not_started',
      stripeConnectAccountId: data['stripeConnectAccountId'],
      createdAt: (data['createdAt'] as Timestamp?)?.toDate(),
    );
  }
}

/// A pending/accepted invite for a supplier account.
class SupplierInviteModel {
  final String id;
  final String email;
  final String supplierId;
  final String token;
  final String status; // pending | accepted | expired | revoked
  final DateTime? createdAt;
  final DateTime? expiresAt;

  SupplierInviteModel({
    required this.id,
    required this.email,
    required this.supplierId,
    required this.token,
    required this.status,
    this.createdAt,
    this.expiresAt,
  });

  factory SupplierInviteModel.fromFirestore(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>? ?? {};
    return SupplierInviteModel(
      id: doc.id,
      email: data['email'] ?? '',
      supplierId: data['supplierId'] ?? '',
      token: data['token'] ?? '',
      status: data['status'] ?? 'pending',
      createdAt: (data['createdAt'] as Timestamp?)?.toDate(),
      expiresAt: (data['expiresAt'] as Timestamp?)?.toDate(),
    );
  }
}
