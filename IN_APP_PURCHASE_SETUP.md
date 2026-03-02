# iOS In-App Purchase Setup Guide

This guide will help you complete the setup for in-app purchases in your Atella app.

## ✅ Already Completed (by Claude)

1. ✅ Added product IDs to `revenuecat_service.dart`
2. ✅ Created StoreKit configuration file for local testing

## 📋 What You Need to Do Next

### 1. Enable In-App Purchase in Xcode (IMPORTANT - Do This First!)

1. Open `ios/Runner.xcworkspace` in Xcode (NOT .xcodeproj)
2. Select the **Runner** project in the left sidebar
3. Select the **Runner** target
4. Go to **Signing & Capabilities** tab
5. Click **+ Capability** button (top left)
6. Search for and add **In-App Purchase**
7. Save the project (Cmd+S)

**Note:** This capability doesn't add anything to the .entitlements file. It just enables In-App Purchase for your app in the provisioning profile.

### 2. App Store Connect Configuration

#### Step 1: Create In-App Purchase Products
1. Go to [App Store Connect](https://appstoreconnect.apple.com)
2. Select your app "Atella" (Bundle ID: `com.example.atella`)
3. Go to **Features** → **In-App Purchases**
4. Click **+** to create new products

#### Product 1: Design Addons
- **Product ID:** `atelia_design_addons_ios`
- **Reference Name:** Design Addons
- **Type:** Consumable
- **Price:** €9.99 (or your preferred price tier)
- **Localized Info:**
  - **Display Name:** Extra Designs Pack
  - **Description:** Purchase 5 extra design slots for your fashion projects

#### Product 2: Tech Pack Addons
- **Product ID:** `atelia_techpack_addons_ios`
- **Reference Name:** Tech Pack Addons
- **Type:** Consumable
- **Price:** €5.99 (or your preferred price tier)
- **Localized Info:**
  - **Display Name:** Extra Tech Pack
  - **Description:** Purchase 1 extra tech pack for your design

#### Step 2: Submit Products for Review
- Add screenshots for each product (1024x1024px recommended)
- Submit products for review along with your app

### 3. RevenueCat Dashboard Configuration

#### Step 1: Add Products to RevenueCat
1. Log in to [RevenueCat Dashboard](https://app.revenuecat.com)
2. Go to your project
3. Navigate to **Products** section
4. Add both products:
   - `atelia_design_addons_ios`
   - `atelia_techpack_addons_ios`

#### Step 2: Create Offerings
1. Go to **Offerings** section
2. Create offering: `design_addons`
   - Add product: `atelia_design_addons_ios`
   - Set package identifier: `design_addons`
3. Create offering: `techpack_addons`
   - Add product: `atelia_techpack_addons_ios`
   - Set package identifier: `techpack_addons`

#### Step 3: Verify API Keys
Your iOS API key is already configured in the code:
- **iOS API Key:** `appl_kKIaQpuiLdWtnKQKVlcKOKoyKFE`

Make sure this matches your RevenueCat project.

### 4. Xcode Configuration for Local Testing

#### Enable StoreKit Testing
1. Open `ios/Runner.xcworkspace` in Xcode
2. Go to **Product** → **Scheme** → **Edit Scheme**
3. Select **Run** on the left
4. Go to **Options** tab
5. Under **StoreKit Configuration**, select `Configuration.storekit`
6. Click **Close**

Now you can test purchases locally without real money!

### 5. Testing Checklist

#### Local Testing (with StoreKit)
- [ ] Run app in Xcode simulator
- [ ] Try purchasing design addons
- [ ] Try purchasing tech pack addons
- [ ] Check Xcode console for purchase logs
- [ ] Verify Firestore updates correctly

#### Sandbox Testing (real App Store sandbox)
- [ ] Create sandbox test user in App Store Connect
- [ ] Sign out of real Apple ID on test device
- [ ] Sign in with sandbox test account when prompted
- [ ] Test real purchase flow
- [ ] Verify receipt validation works

#### Production Testing
- [ ] Submit app with products for review
- [ ] After approval, test with real Apple ID (you won't be charged)
- [ ] Verify revenue appears in RevenueCat dashboard

## 🔧 Troubleshooting

### "Products not found" error
- Check product IDs match exactly in App Store Connect and code
- Verify products are in "Ready to Submit" or "Approved" state
- Wait 2-4 hours after creating products (propagation delay)
- Clear app data and restart

### "Invalid entitlements" error
- Open Xcode project
- Select Runner target → Signing & Capabilities
- Verify "In-App Purchase" capability is enabled
- Re-sign the app

### RevenueCat errors
- Check API key is correct for iOS
- Verify offerings exist in RevenueCat dashboard
- Check products are attached to offerings
- Enable debug logs: `await Purchases.setLogLevel(LogLevel.debug);`

## 📚 Helpful Links

- [App Store Connect](https://appstoreconnect.apple.com)
- [RevenueCat Dashboard](https://app.revenuecat.com)
- [RevenueCat iOS Guide](https://www.revenuecat.com/docs/getting-started/installation/ios)
- [StoreKit Testing Guide](https://developer.apple.com/documentation/xcode/setting-up-storekit-testing-in-xcode)

## 📞 Support

If you face any issues:
1. Check Xcode console logs (filter by "RevenueCat" or "Purchase")
2. Check RevenueCat dashboard for transaction logs
3. Verify all steps in this guide are completed

---

**Last Updated:** February 23, 2026
**Bundle ID:** com.example.atella
**RevenueCat iOS API Key:** appl_kKIaQpuiLdWtnKQKVlcKOKoyKFE
lla
**RevenueCat iOS API Key:** appl_kKIaQpuiLdWtnKQKVlcKOKoyKFE
