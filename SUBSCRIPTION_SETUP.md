# Subscription System Setup Guide

## Overview
The app now has a complete subscription system integrated with Stripe and Firebase. Users start with a FREE plan that allows unlimited AI-generated designs but requires subscription to access premium features like techpack generation.

## Subscription Plans

### FREE Plan (€0/Month)
- Unlimited AI-generated designs
- No techpack generation (upgrade required)
- No PDF export (upgrade required)  
- No access to manufacturers (upgrade required)

### STARTER Plan (€9.99/Month)
- Unlimited AI-generated designs
- Up to 3 techpacks per month
- Custom PDF export (includes logo)
- Access to a curated list of manufacturers

### PRO Plan (€24.99/Month)
- Unlimited AI-generated designs
- Unlimited techpacks
- Custom PDF export (includes logo)
- Access to a curated list of manufacturers
- Priority support

## Stripe Configuration

### 1. Create Products in Stripe Dashboard
1. Log into your Stripe Dashboard
2. Navigate to Products
3. Create the following products:

#### Starter Plan
- Name: Atella Starter
- Price: €9.99
- Billing: Monthly
- Save the Price ID (e.g., `price_1234...`)

#### Pro Plan
- Name: Atella Pro
- Price: €24.99
- Billing: Monthly
- Save the Price ID (e.g., `price_5678...`)

### 2. Update Price IDs
Update the price IDs in `lib/models/subscription_plan.dart`:
```dart
static const SubscriptionPlan starterPlan = SubscriptionPlan(
  // ...
  stripePriceId: 'YOUR_STARTER_PRICE_ID', // Replace with actual ID
  // ...
);

static const SubscriptionPlan proPlan = SubscriptionPlan(
  // ...
  stripePriceId: 'YOUR_PRO_PRICE_ID', // Replace with actual ID
  // ...
);
```

### 3. Environment Variables
Ensure your `.env` file contains:
```
PublishableKey=pk_test_...
StripeSecretKey=sk_test_...
```

## Firebase Configuration

### User Document Structure
When users sign up, their Firebase document includes:
```json
{
  "uid": "user_id",
  "name": "User Name",
  "email": "user@email.com",
  "subscriptionPlan": "FREE",
  "subscriptionStatus": "active",
  "trialStartDate": "timestamp",
  "trialEndDate": "ISO date string",
  "stripeCustomerId": null,
  "currentSubscriptionId": null,
  "techpacksUsedThisMonth": 0,
  "currentPeriodStart": "timestamp",
  "currentPeriodEnd": "timestamp"
}
```

## Webhook Setup (Backend Required)

### Important: Backend Implementation Required
The webhook handler (`lib/services/stripe_webhook_handler.dart`) is a reference implementation. You need to implement the actual webhook endpoint on your backend server.

### Steps:
1. Create a backend endpoint (e.g., `/stripe-webhook`)
2. Configure the webhook in Stripe Dashboard:
   - URL: `https://your-backend.com/stripe-webhook`
   - Events to listen for:
     - `customer.subscription.created`
     - `customer.subscription.updated`
     - `customer.subscription.deleted`
     - `invoice.payment_succeeded`
     - `invoice.payment_failed`
     - `customer.subscription.trial_will_end`

3. Implement webhook signature verification
4. Update Firebase from your backend based on webhook events

## Testing the Integration

### 1. Test User Registration
- New users automatically get FREE plan (no trial period)
- Check Firebase to verify user document is created correctly

### 2. Test Subscription Purchase
- Navigate to subscription screen
- Select a plan
- Complete payment with Stripe test cards:
  - Success: `4242 4242 4242 4242`
  - Declined: `4000 0000 0000 0002`

### 3. Test Premium Features
- Try to generate a techpack on FREE plan (should show upgrade prompt)
- Subscribe to STARTER/PRO plan
- Verify techpack generation works
- For STARTER plan, verify 3 techpack limit per month

### 4. Test Subscription Management
- Cancel subscription
- Verify user reverts to FREE plan
- Check subscription status updates in Firebase

## Code Components

### Services
- `lib/services/stripe_subscription_service.dart` - Main subscription service
- `lib/services/stripe_webhook_handler.dart` - Webhook handler reference

### Models
- `lib/models/subscription_plan.dart` - Subscription plan definitions
- `lib/models/user_subscription.dart` - User subscription model

### Controllers
- `lib/Modules/Home/Controllers/subscribe_controller.dart` - Subscription UI controller
- `lib/Modules/TechPack/controllers/generate_tech_pack_controller.dart` - Updated with subscription checks

### UI
- `lib/Modules/Home/View/Screens/subscribe_screen.dart` - Subscription plans UI

## Maintenance

### Monthly Tasks
- Monitor subscription metrics in Stripe Dashboard
- Check for failed payments
- Review techpack usage for STARTER plan users

### User Support
- For subscription issues, check:
  1. User's Firebase document
  2. Stripe customer record
  3. Payment history in Stripe

## Security Notes
- Never expose Stripe Secret Key in client code
- Always verify webhook signatures on backend
- Use environment variables for all sensitive keys
- Implement proper error handling for payment failures