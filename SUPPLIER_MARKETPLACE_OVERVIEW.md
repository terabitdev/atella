# Supplier Marketplace — Technical Overview

## Summary

Replaces the cancelled EmailJS "email tech pack to manufacturer" integration with an in-house marketplace: invite-only manufacturer ("supplier") accounts, in-app messaging, and paid sample orders processed through Stripe Connect (destination charges with a platform commission). Built in 6 core sections (data model, admin invites, Connect onboarding, directory, messaging, orders) plus a UX refinement pass and a deep-linking overhaul.

## Roles & auth

- Firebase Auth custom claim `role: 'admin' | 'supplier' | 'user'`, set server-side via Cloud Functions (never client-writable).
- Mirrored into `users/{uid}.accountType` + `users/{uid}.supplierId` for cheap client-side reads without needing `getIdTokenResult`.
- Client must force-refresh the ID token (`user.getIdTokenResult(true)`) immediately after any role change (e.g. right after `acceptSupplierInvite` succeeds), since claims are only picked up on token refresh.
- Supplier accounts are **not self-serve** — only creatable by an admin-issued, single-use invite tied to one exact email address.

## Data model (Firestore)

| Collection | Purpose | Key fields |
|---|---|---|
| `suppliers/{supplierId}` | Manufacturer profile | `companyName`, `logoUrl`, `specialty`, `moqTiers`, `originCountry`, `description`, `status: pending_invite\|active\|disabled`, `ownerUid`, `inviteEmail`, `stripeConnectAccountId`, `payoutsEnabled` |
| `supplierInvites/{inviteId}` | One-time invite tokens (kept separate from `suppliers` so tokens are never exposed by a public supplier read) | `email`, `supplierId`, `token`, `status`, `expiresAt` |
| `supplierSubmissions/{id}` | A tech pack sent from a user to a supplier | `techPackId`, `userUid`, `supplierId`, `status: sent\|viewed\|in_discussion\|sample_order_created\|closed` |
| `conversations/{id}` | One conversation per submission | `submissionId`, `participantUids`, `userUid`, `supplierId`, `lastMessage`, `lastMessageAt`, `unreadCountByUid` |
| `conversations/{id}/messages/{id}` | Chat messages | `senderUid`, `text`, `attachmentUrl`, `type: text\|system\|tech_pack_shared\|sample_order_form`, `createdAt`, `readBy` |
| `orders/{id}` | Sample (and future production) orders | `type: sample\|production`, `submissionId`, `conversationId`, `userUid`, `supplierId`, `stripeConnectAccountId` (snapshotted), `amountTotal`, `applicationFeeAmount`, `status: awaiting_payment\|paid\|shipped\|delivered\|cancelled\|refunded`, `shipping{...}`, `trackingNumber`, `trackingCarrier`, `stripePaymentIntentId` |

Storage: `supplier_logos/{supplierId}/logo.jpg`, writable by admin or the owning supplier.

## Security rules (Firestore/Storage)

- `suppliers`: public read only where `status == 'active'`; writes restricted to `role == 'admin'` or matching `ownerUid`.
- `supplierInvites`: fully closed to clients — Admin SDK / callable functions only.
- `conversations`/`messages`: read/write only if `request.auth.uid in resource.data.participantUids`.
- `orders`: **no direct client writes at all** — every mutation goes through a callable Cloud Function; clients only get scoped reads (`userUid == request.auth.uid` or supplier's `ownerUid`).
- `design_quotas/{email}`: added later (pre-existing, previously-unprotected collection found during a bug investigation) — `isAdmin() || (isSignedIn() && request.auth.token.email.lower() == email)`.
- Pre-existing collections (`users`, `designs`, tech pack collections) had no rules before this project — owner-only rules were authored from scratch as part of Section 1.

## Cloud Functions (TypeScript, 2nd Gen, Node 20)

- `functions/src/suppliers/invites.ts`
  - `createSupplierInvite` (callable, admin-only) — creates `suppliers` + `supplierInvites` docs, returns an `inviteLink` of the form `https://atelia-123.web.app/supplier-invite?token=...`.
  - `validateSupplierInvite` (callable, no auth) — checks token validity, returns the locked email.
  - `acceptSupplierInvite` (callable, requires a freshly-created Firebase Auth user) — re-verifies the token, checks `auth.token.email == invite.email`, sets the `supplier` custom claim, links `users/{uid}` ↔ `suppliers/{supplierId}`, marks the invite accepted.
- `functions/src/suppliers/connect.ts`
  - `createConnectAccount` (supplier-only) — creates a Stripe Connect **Express** account.
  - `createConnectOnboardingLink` — generates a hosted Stripe `accountLinks.create` URL, opened via `url_launcher`.
  - `stripeConnectWebhook` — separate HTTPS endpoint, own signing secret (`STRIPE_CONNECT_WEBHOOK_SECRET`), listens for `account.updated` to flip `payoutsEnabled`.
- `functions/src/orders/orders.ts`
  - `createSampleOrderForm` (supplier-only) — posts a `sample_order_form` chat message; rejects if `payoutsEnabled != true`.
  - `createOrderPaymentIntent` (user-only) — computes a 10% `application_fee_amount`, creates a **destination charge** PaymentIntent with `transfer_data.destination` set to the supplier's connected account, returns `client_secret` for `flutter_stripe`'s payment sheet. All PaymentIntent creation happens server-side — the Flutter client never touches a Stripe secret key.
  - `markOrderShipped` (supplier-only) — sets tracking number/carrier, notifies the user.
- `functions/src/subscriptions/subscriptionWebhook.ts` — pre-existing subscription webhook, extended to try multiple signing secrets in sequence (see "Stripe webhooks" below).
- Shared: `functions/src/lib/admin.ts` (single `admin.initializeApp()`, Firestore `db`, shared `Stripe` client instance, `apiVersion: '2023-10-16'`).

## Payment flow (Stripe Connect)

1. Supplier completes Stripe Connect **Express** onboarding (hosted flow) → `payoutsEnabled = true`.
2. Supplier sends a priced sample order form in-chat.
3. User fills in shipping details and pays via `flutter_stripe`'s payment sheet, backed by a server-created PaymentIntent.
4. Stripe processes a **destination charge**: the full amount is charged to the user, a 10% `application_fee_amount` is retained by the platform (Atella's Stripe account), and the remainder is transferred automatically to the supplier's connected account (`transfer_data.destination`).
5. `payment_intent.succeeded` webhook flips the order to `paid`.
6. Supplier calls `markOrderShipped` with tracking info; user sees live status via a Firestore stream.

### Stripe webhooks — multiple secrets

Stripe's dashboard doesn't allow editing an existing webhook destination's event list, so a second destination was created for order-related events, each with its own signing secret. `subscriptionWebhook.ts` verifies incoming events against an array of secrets, trying each until one succeeds:

```typescript
const stripeWebhookSecrets = [
  process.env.STRIPE_WEBHOOK_SECRET || '',
  process.env.STRIPE_ORDERS_WEBHOOK_SECRET || '',
].filter(Boolean);
// loop: stripe.webhooks.constructEvent(payload, sig, secret) for each, break on first success
```

Three distinct webhook secrets exist in total: `STRIPE_WEBHOOK_SECRET` (subscriptions), `STRIPE_CONNECT_WEBHOOK_SECRET` (`account.updated`), `STRIPE_ORDERS_WEBHOOK_SECRET` (order payment events).

## Flutter app structure

- `lib/Modules/Admin/` — admin invite creation screen (`admin_supplier_invite_screen.dart` / `_controller.dart`), gated on the `admin` custom claim.
- `lib/Modules/SupplierAuth/` — invite-link landing + signup screen (locked email, password entry), calls `acceptSupplierInvite`.
- `lib/Modules/SupplierAccount/` — supplier-side bottom nav shell (`supplier_nav_bar_screen.dart` + `supplier_nav_bar_controller.dart`, mirrors the customer app's `nav_bar.dart` pattern), with 4 tabs: Dashboard (`supplier_dashboard_screen.dart`, shows onboarding status + recent orders/submissions), Profile (`supplier_profile_tab_screen.dart`), Messages (embeds `ConversationListScreen`), Orders (embeds `OrderListScreen`).
- `lib/Modules/SupplierDirectory/` — browsable/filterable supplier list + detail screen with "Send Tech Pack" CTA.
- `lib/Modules/Messaging/` — `conversation_list_screen.dart`, `chat_screen.dart`, `message_bubble.dart` (renders `text`, `system`, `tech_pack_shared`, and `sample_order_form` message types via a `type` switch).
- `lib/Modules/Orders/` — `sample_order_form_screen.dart` (supplier), `order_checkout_screen.dart` (user, shipping form + Stripe payment sheet), `order_tracking_screen.dart` (redesigned with `_SectionCard`/`_InfoRow` widgets), `order_list_screen.dart` (shared, scoped by `asSupplier`/`forceAsSupplier`).
- Services: `lib/services/firebase/services/{supplier_admin_service, supplier_auth_service, messaging_service, orders_service, supplier_submission_service}.dart`, `lib/services/PaymentService/order_payment_service.dart` (kept separate from the legacy `stripe_subscription_service.dart` to avoid its dead/commented-out code).

### Embedding shared screens as bottom-nav tabs

`ConversationListScreen`/`OrderListScreen` are used both as pushed customer screens (with a back button) and as embedded supplier nav-bar tabs (no back button, nothing to pop):
- `GlobalHeader` (`lib/Widgets/app_header.dart`) got an optional `showBackButton` param (default `true`, non-breaking).
- `OrderListController` got an optional `forceAsSupplier` constructor param — preferred over the `Get.arguments`-based check when the controller is bound statically inside a nav-bar tab (no arguments are passed to a static tab).

## Deep linking (invite links)

Real Android App Links + iOS Universal Links replace the original non-clickable `atella://` custom scheme (most messaging apps won't auto-linkify unrecognized schemes).

- **Firebase Hosting** (`atelia-123.web.app`, free default domain, no new domain purchase) serves:
  - `public/.well-known/assetlinks.json` — Android Digital Asset Links, `com.company.atella` + SHA-256 cert fingerprints. JSON doesn't support comments, so the four entries are labeled here instead (in array order):
    1. `C1:4B:51:...:0E:55` — original debug fingerprint (whoever first set up this feature; machine unknown).
    2. `2A:4C:86:...:5F:F2` — original release/upload-key fingerprint (from that same original setup; may or may not match the actual Play Store distribution certificate below).
    3. `9C:C8:11:...:89:6F` — **Play Store production signing certificate** (from Play Console → Setup → App integrity → "App signing key certificate"). This is the one real Play Store downloads are actually signed with — every user gets this same fingerprint.
    4. `A3:A2:C9:...:4D:27` — debug fingerprint for a specific developer machine (retrieved via `keytool -list -v -keystore "$env:USERPROFILE\.android\debug.keystore" -alias androiddebugkey -storepass android -keypass android`). Each developer's debug keystore is unique per machine — add your own the same way if App Links don't open in your local `flutter run` builds.
  - `public/.well-known/apple-app-site-association` — `appID: "YM28RS6N8K.com.example.atella"`, `paths: ["/supplier-invite*"]`; served with `Content-Type: application/json` via a `firebase.json` header override (no file extension, so Hosting won't set the type correctly by default).
  - `public/supplier-invite/index.html` — fallback page if opened without the app installed.
- **Android**: second intent-filter in `AndroidManifest.xml` with `android:autoVerify="true"`, `scheme="https"`, `host="atelia-123.web.app"`, `pathPrefix="/supplier-invite"` (old `atella://` filter kept for backward compatibility). `flutter_deeplinking_enabled=false` meta-data tag added to disable Flutter engine's own native deep-link route interception (it was hijacking the launch URL as GetX's initial route, causing a null-check crash in `PageRedirect.page`).
- **iOS**: `Runner.entitlements` rewritten (fixed pre-existing corruption — duplicate `</plist>` tags) to include `com.apple.developer.associated-domains: ["applinks:atelia-123.web.app"]` alongside the existing Sign in with Apple entry. `FlutterDeepLinkingEnabled=false` set in `Info.plist` for the same reason as Android.
- `lib/services/deeplink/deep_link_service.dart` — `_handleUri` matches both the legacy `atella://supplier-invite` scheme and the new `https://atelia-123.web.app/supplier-invite` host+path; navigation is deferred via `WidgetsBinding.instance.addPostFrameCallback` **nested inside** `Future.delayed(Duration.zero, ...)` (the single-level post-frame callback still fired during the Navigator's locked transition phase and hit a `_debugLocked` assertion).
- `lib/main.dart` restructured so `runApp()` fires as early as possible (Firebase init, Stripe setup, and orientation lock happen first; RevenueCat/PostHog/subscription-validation/translation-model init were moved to an `unawaited()` background task) — this fixed a cold-start ANR (`Input dispatching timed out`) that was blocking the UI thread before the app could render a frame, which was also breaking deep-link cold starts.

## Business model

- Atella is the payment intermediary — funds always flow through the platform account, never directly peer-to-peer.
- 10% commission (`application_fee_amount`) currently applies to **every** sample order payment.
- Supplier payout is automatic via Stripe Connect, net of the commission.

## Known gaps / not yet built

- **Localization** — all new marketplace screens (directory, messaging, orders, admin invite, supplier dashboard) are English-only; not yet wired into the app's existing translation system.
- **Production orders** (Section 7 of the original plan) — quantity/MOQ-tier ordering after sample approval is not implemented. Payment mechanics (`createOrderPaymentIntent`) are already reusable as-is.
- **Notifications inbox + email** (Section 8) — notification docs are written to Firestore behind the scenes but there is no bell/inbox UI, and no transactional email provider is wired up yet (EmailJS was the old approach and is being phased out, not replaced 1:1).
- **Sample-order commission** — currently 10% on samples too; open question whether samples should be commission-free with commission only on future production orders (small, deliberate code change if so).
- **Stripe live mode** — the connected Stripe account still needs real identity verification completed before non-test payments can process.
