import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:purchases_flutter/purchases_flutter.dart';
import 'package:flutter/services.dart';
import 'dart:io';

/// RevenueCat Service for In-App Purchases (Add-ons)
/// Handles extra designs and extra techpacks purchases via RevenueCat
/// Replaces Stripe payment processing while maintaining same Firestore logic
class RevenueCatService {
  static final RevenueCatService _instance = RevenueCatService._internal();
  factory RevenueCatService() => _instance;
  RevenueCatService._internal();

  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  bool _isConfigured = false;

  // RevenueCat API Keys
  static const String _androidApiKey = 'goog_qOfydVXlUDKrEqzbNxhXzeRWbQg';
  static const String _iosApiKey = 'appl_kKIaQpuiLdWtnKQKVlcKOKoyKFE';

  // Offering Identifiers
  static const String _designAddonsOfferingId = 'design_addons';
  static const String _techpackAddonsOfferingId = 'techpack_addons';

  // Package Identifiers (from screenshots)
  static const String _designAddonsPackageId = 'design_addons';
  static const String _techpackAddonsPackageId = 'techpack_addons';

  // Product IDs (App Store Connect)
  // NOTE: These must match EXACTLY with products created in App Store Connect
  // Format: {bundle_id}.{product_name}
  // These IDs are for reference and must be configured in:
  // 1. App Store Connect (In-App Purchases section)
  // 2. RevenueCat Dashboard (Products section)
  // RevenueCat uses offerings/packages, but products must exist in App Store Connect
  static const String _designAddonsProductId = 'atelia_design_addons_ios';
  static const String _techpackAddonsProductId = 'atelia_techpack_addons_ios';

  /// Initialize RevenueCat SDK
  /// Call this in main.dart after Firebase initialization
  Future<void> initialize() async {
    if (_isConfigured) {
      print('✅ RevenueCat already configured');
      return;
    }

    try {
      // Configure RevenueCat with platform-specific API key
      final configuration = PurchasesConfiguration(
        Platform.isAndroid ? _androidApiKey : _iosApiKey,
      );

      await Purchases.configure(configuration);

      // Set user ID if authenticated
      User? user = _auth.currentUser;
      if (user != null) {
        await Purchases.logIn(user.uid);
        print('✅ RevenueCat logged in with user: ${user.uid}');
      }

      // Enable debug logs in development
      await Purchases.setLogLevel(LogLevel.debug);

      _isConfigured = true;
      print('✅ RevenueCat initialized successfully');
    } catch (e) {
      print('❌ Error initializing RevenueCat: $e');
      rethrow;
    }
  }

  /// Login user to RevenueCat
  /// Call this after user authentication
  Future<void> loginUser(String userId) async {
    try {
      await Purchases.logIn(userId);
      print('✅ RevenueCat user logged in: $userId');
    } catch (e) {
      print('❌ Error logging in to RevenueCat: $e');
    }
  }

  /// Logout user from RevenueCat
  /// Call this when user logs out
  Future<void> logoutUser() async {
    try {
      await Purchases.logOut();
      print('✅ RevenueCat user logged out');
    } catch (e) {
      print('❌ Error logging out from RevenueCat: $e');
    }
  }

  /// Purchase Extra Designs (€9.99 = 5 designs)
  /// Replaces Stripe's purchaseExtraDesigns() function
  Future<bool> purchaseExtraDesigns() async {
    try {
      User? user = _auth.currentUser;
      if (user == null) {
        print('❌ Cannot purchase: No authenticated user');
        return false;
      }

      print('🛒 Starting RevenueCat purchase: Extra Designs');

      // Fetch all offerings for debugging
      Offerings offerings = await Purchases.getOfferings();
      print('📦 Available offerings: ${offerings.all.keys.toList()}');
      print('📦 Current offering: ${offerings.current?.identifier}');

      // List all offerings and their packages for debugging
      for (var entry in offerings.all.entries) {
        print('   Offering: ${entry.key}');
        for (var pkg in entry.value.availablePackages) {
          print(
            '      Package: ${pkg.identifier} (${pkg.storeProduct.identifier})',
          );
        }
      }

      // Fetch the design addons offering
      Offering? designOffering = offerings.getOffering(_designAddonsOfferingId);

      if (designOffering == null) {
        print('❌ Design addons offering not found: $_designAddonsOfferingId');
        print('💡 TIP: Check RevenueCat dashboard offering identifier');
        return false;
      }

      print('✅ Found offering: ${designOffering.identifier}');
      print(
        '📦 Available packages in offering: ${designOffering.availablePackages.map((p) => p.identifier).toList()}',
      );

      // Get the package - try to find it by identifier
      Package? designPackage;

      // First try exact match
      designPackage = designOffering.availablePackages
          .where((p) => p.identifier == _designAddonsPackageId)
          .firstOrNull;

      // If not found, try to get the first package
      if (designPackage == null &&
          designOffering.availablePackages.isNotEmpty) {
        print(
          '⚠️ Package "$_designAddonsPackageId" not found, using first available package',
        );
        designPackage = designOffering.availablePackages.first;
      }

      if (designPackage == null) {
        print('❌ No packages found in offering: $_designAddonsOfferingId');
        print(
          '💡 TIP: Check RevenueCat dashboard - ensure products are attached to offering',
        );
        return false;
      }

      print('📦 Found design package: ${designPackage.identifier}');
      print('💰 Price: ${designPackage.storeProduct.priceString}');

      // Make the purchase
      // ignore: deprecated_member_use
      PurchaseResult result = await Purchases.purchasePackage(designPackage);
      CustomerInfo customerInfo = result.customerInfo;

      print('✅ Purchase successful!');
      print('📋 Active entitlements: ${customerInfo.entitlements.active.keys}');

      // CRITICAL: Update Firestore - Same logic as Stripe
      // Each purchase = +1 to extraDesignsPurchased (which gives 5 designs)
      await _firestore.collection('users').doc(user.uid).update({
        'extraDesignsPurchased': FieldValue.increment(1),
      });

      print('✅ Extra designs purchased successfully via RevenueCat');
      print('   User: ${user.uid}');
      print('   Added: 1 pack (5 designs)');

      return true;
    } on PlatformException catch (e) {
      final errorCode = PurchasesErrorHelper.getErrorCode(e);
      if (errorCode == PurchasesErrorCode.purchaseCancelledError) {
        print('ℹ️ User cancelled the purchase');
      } else if (errorCode == PurchasesErrorCode.paymentPendingError) {
        print('⏳ Payment is pending');
      } else {
        print('❌ RevenueCat error: ${e.message}');
      }
      return false;
    } catch (e) {
      print('❌ Error purchasing extra designs: $e');
      return false;
    }
  }

  /// Purchase Extra Techpacks (€5.99 per techpack)
  /// Replaces Stripe's purchaseExtraTechpacks() function
  /// @param count: Number of techpacks to purchase (currently 1)
  /// @param price: Price per techpack (for display, not used in RevenueCat)
  Future<bool> purchaseExtraTechpacks(int count, double price) async {
    try {
      User? user = _auth.currentUser;
      if (user == null) {
        print('❌ Cannot purchase: No authenticated user');
        return false;
      }

      // NOTE: For now, we only support single techpack purchase (count = 1)
      // If you need multiple counts, create separate products in RevenueCat
      if (count != 1) {
        print(
          '⚠️ Warning: Only single techpack purchase supported. Requested: $count, processing: 1',
        );
      }

      print('🛒 Starting RevenueCat purchase: Extra Techpacks');

      // Fetch all offerings for debugging
      Offerings offerings = await Purchases.getOfferings();
      print('📦 Available offerings: ${offerings.all.keys.toList()}');
      print('📦 Current offering: ${offerings.current?.identifier}');

      // Fetch the techpack addons offering
      Offering? techpackOffering = offerings.getOffering(
        _techpackAddonsOfferingId,
      );

      if (techpackOffering == null) {
        print(
          '❌ Techpack addons offering not found: $_techpackAddonsOfferingId',
        );
        print('💡 TIP: Check RevenueCat dashboard offering identifier');
        return false;
      }

      print('✅ Found offering: ${techpackOffering.identifier}');
      print(
        '📦 Available packages in offering: ${techpackOffering.availablePackages.map((p) => p.identifier).toList()}',
      );

      // Get the package - try to find it by identifier
      Package? techpackPackage;

      // First try exact match
      techpackPackage = techpackOffering.availablePackages
          .where((p) => p.identifier == _techpackAddonsPackageId)
          .firstOrNull;

      // If not found, try to get the first package
      if (techpackPackage == null &&
          techpackOffering.availablePackages.isNotEmpty) {
        print(
          '⚠️ Package "$_techpackAddonsPackageId" not found, using first available package',
        );
        techpackPackage = techpackOffering.availablePackages.first;
      }

      if (techpackPackage == null) {
        print('❌ No packages found in offering: $_techpackAddonsOfferingId');
        print(
          '💡 TIP: Check RevenueCat dashboard - ensure products are attached to offering',
        );
        return false;
      }

      print('📦 Found techpack package: ${techpackPackage.identifier}');
      print('💰 Price: ${techpackPackage.storeProduct.priceString}');

      // Make the purchase
      // ignore: deprecated_member_use
      PurchaseResult result = await Purchases.purchasePackage(techpackPackage);
      CustomerInfo customerInfo = result.customerInfo;

      print('✅ Purchase successful!');
      print('📋 Active entitlements: ${customerInfo.entitlements.active.keys}');

      // CRITICAL: Update Firestore - Same logic as Stripe
      // Each purchase = +1 to extraTechpacksPurchased (1 techpack per purchase)
      await _firestore.collection('users').doc(user.uid).update({
        'extraTechpacksPurchased': FieldValue.increment(1),
      });

      print('✅ Extra techpacks purchased successfully via RevenueCat');
      print('   User: ${user.uid}');
      print('   Added: 1 techpack');

      return true;
    } on PlatformException catch (e) {
      final errorCode = PurchasesErrorHelper.getErrorCode(e);
      if (errorCode == PurchasesErrorCode.purchaseCancelledError) {
        print('ℹ️ User cancelled the purchase');
      } else if (errorCode == PurchasesErrorCode.paymentPendingError) {
        print('⏳ Payment is pending');
      } else {
        print('❌ RevenueCat error: ${e.message}');
      }
      return false;
    } catch (e) {
      print('❌ Error purchasing extra techpacks: $e');
      return false;
    }
  }

  /// Purchase Extra Designs for FREE users (same RevenueCat product, different Firestore field)
  /// Updates freeExtraDesignsPurchased (not extraDesignsPurchased)
  Future<bool> purchaseFreeExtraDesigns() async {
    try {
      User? user = _auth.currentUser;
      if (user == null) {
        print('❌ Cannot purchase: No authenticated user');
        return false;
      }

      print('🛒 Starting RevenueCat purchase: Free Extra Designs');
      Offerings offerings = await Purchases.getOfferings();
      Offering? designOffering = offerings.getOffering(_designAddonsOfferingId);
      if (designOffering == null) {
        print('❌ Design addons offering not found');
        return false;
      }

      Package? designPackage = designOffering.availablePackages
              .where((p) => p.identifier == _designAddonsPackageId)
              .firstOrNull ??
          (designOffering.availablePackages.isNotEmpty
              ? designOffering.availablePackages.first
              : null);

      if (designPackage == null) {
        print('❌ No packages found in design addons offering');
        return false;
      }

      // ignore: deprecated_member_use
      await Purchases.purchasePackage(designPackage);

      // Use set+merge so the field is created if it doesn't yet exist
      await _firestore.collection('users').doc(user.uid).set({
        'freeExtraDesignsPurchased': FieldValue.increment(1),
      }, SetOptions(merge: true));

      print('✅ Free extra designs purchased. User: ${user.uid}');
      return true;
    } on PlatformException catch (e) {
      final errorCode = PurchasesErrorHelper.getErrorCode(e);
      if (errorCode != PurchasesErrorCode.purchaseCancelledError) {
        print('❌ RevenueCat error: ${e.message}');
      }
      return false;
    } catch (e) {
      print('❌ Error purchasing free extra designs: $e');
      return false;
    }
  }

  /// Purchase Extra Techpacks for FREE users (same RevenueCat product, different Firestore field)
  /// Updates freeExtraTechpacksPurchased (not extraTechpacksPurchased)
  Future<bool> purchaseFreeExtraTechpacks(int count, double price) async {
    try {
      User? user = _auth.currentUser;
      if (user == null) {
        print('❌ Cannot purchase: No authenticated user');
        return false;
      }

      print('🛒 Starting RevenueCat purchase: Free Extra Techpacks');
      Offerings offerings = await Purchases.getOfferings();
      Offering? techpackOffering =
          offerings.getOffering(_techpackAddonsOfferingId);
      if (techpackOffering == null) {
        print('❌ Techpack addons offering not found');
        return false;
      }

      Package? techpackPackage = techpackOffering.availablePackages
              .where((p) => p.identifier == _techpackAddonsPackageId)
              .firstOrNull ??
          (techpackOffering.availablePackages.isNotEmpty
              ? techpackOffering.availablePackages.first
              : null);

      if (techpackPackage == null) {
        print('❌ No packages found in techpack addons offering');
        return false;
      }

      // ignore: deprecated_member_use
      await Purchases.purchasePackage(techpackPackage);

      // Use set+merge so the field is created if it doesn't yet exist
      await _firestore.collection('users').doc(user.uid).set({
        'freeExtraTechpacksPurchased': FieldValue.increment(1),
      }, SetOptions(merge: true));

      print('✅ Free extra techpacks purchased. User: ${user.uid}');
      return true;
    } on PlatformException catch (e) {
      final errorCode = PurchasesErrorHelper.getErrorCode(e);
      if (errorCode != PurchasesErrorCode.purchaseCancelledError) {
        print('❌ RevenueCat error: ${e.message}');
      }
      return false;
    } catch (e) {
      print('❌ Error purchasing free extra techpacks: $e');
      return false;
    }
  }

  /// Restore purchases
  /// Useful for users who reinstalled the app or switched devices
  Future<CustomerInfo?> restorePurchases() async {
    try {
      print('🔄 Restoring purchases...');
      CustomerInfo customerInfo = await Purchases.restorePurchases();
      print('✅ Purchases restored successfully');
      print('📋 Active entitlements: ${customerInfo.entitlements.active.keys}');
      return customerInfo;
    } catch (e) {
      print('❌ Error restoring purchases: $e');
      return null;
    }
  }

  /// Get customer info
  /// Returns current customer information and entitlements
  Future<CustomerInfo?> getCustomerInfo() async {
    try {
      CustomerInfo customerInfo = await Purchases.getCustomerInfo();
      return customerInfo;
    } catch (e) {
      print('❌ Error getting customer info: $e');
      return null;
    }
  }

  /// Check if user has active purchases
  Future<bool> hasActivePurchases() async {
    try {
      CustomerInfo customerInfo = await Purchases.getCustomerInfo();
      return customerInfo.entitlements.active.isNotEmpty;
    } catch (e) {
      print('❌ Error checking active purchases: $e');
      return false;
    }
  }

  /// Get available offerings
  /// Useful for debugging or displaying available products
  Future<Offerings?> getOfferings() async {
    try {
      Offerings offerings = await Purchases.getOfferings();
      print('📦 Available offerings: ${offerings.all.keys}');
      return offerings;
    } catch (e) {
      print('❌ Error getting offerings: $e');
      return null;
    }
  }
}
