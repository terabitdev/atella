# PostHog Implementation - Atelia App

## Project Overview
Fashion-focused SaaS platform for independent creators (Flutter mobile app)

**Tech Stack:** Flutter 3.8.1+ | Firebase | GetX | Stripe

---

## Implementation Status

### 1. Installation & Configuration

| Task | Status | Notes |
|------|--------|-------|
| PostHog SDK installed | ✅ Done | `posthog_flutter: ^5.6.0` in pubspec.yaml |
| Cloud instance configured | ✅ Done | US Cloud (`us.i.posthog.com`) |
| API key secured | ✅ Done | Stored in `.env` file |
| Android configured | ✅ Done | `AUTO_INIT=false` in AndroidManifest.xml |
| iOS configured | ✅ Done | `AUTO_INIT=false` in Info.plist |
| Manual initialization | ✅ Done | In `main.dart` |
| PostHogWidget wrapper | ✅ Done | Required for mobile session replay |
| Navigator observer | ✅ Done | `PosthogObserver()` for auto screen tracking |

### 2. Core Features Setup

| Feature | Status | Notes |
|---------|--------|-------|
| Session Recordings | ✅ Configured | `sessionReplay = on (when analytics enabled)`, masking OFF (full visibility) |
| Automatic Screen Tracking | ✅ Done | Via `PosthogObserver` |
| User Identification | ✅ Ready | `identifyUser()` method in analytics service |
| Feature Flags | ✅ Ready | Methods available in analytics service |
| Heatmaps | ✅ Custom | Custom tap tracking via `trackTap()` method |
| Funnels | ✅ Done | Design Creation + Onboarding + Conversion + Churn funnels created in PostHog |
| Cohorts | ✅ Done | Power Users, New Users, Free Users, Paid Users, Churned Users cohorts created |

### 3. Event Tracking Integration

#### Authentication Events
| Event | Status | Screen/Location | Method |
|-------|--------|-----------------|--------|
| `user_signed_up` | ✅ Done | signup_controller.dart | `trackUserSignedUp(method:)` |
| `user_logged_in` | ✅ Done | login_controller.dart | `trackUserLoggedIn(method:)` |
| `user_logged_out` | ✅ Done | profile_controller.dart | `trackUserLoggedOut()` |
| User identification | ✅ Done | login_controller.dart | `identifyUser(userId:, email:, name:)` |

#### Design Flow Events
| Event | Status | Screen/Location | Method |
|-------|--------|-----------------|--------|
| `creative_brief_completed` | ✅ Done | creative_brief_controller.dart | `trackCreativeBriefCompleted(...)` |
| `refined_concept_completed` | ✅ Done | refining_concept_controller.dart | `trackRefinedConceptCompleted(...)` |
| `final_details_completed` | ✅ Done | final_detail_controller.dart | `trackFinalDetailsCompleted(...)` |
| `design_generation_started` | ✅ Done | generate_tech_pack_controller.dart | `trackDesignGenerationStarted()` |
| `design_generation_completed` | ✅ Done | generate_tech_pack_controller.dart | `trackDesignGenerationCompleted(...)` |
| `design_generation_failed` | ✅ Done | generate_tech_pack_controller.dart | `trackDesignGenerationFailed(...)` |
| `design_selected` | ✅ Done | generate_tech_pack_controller.dart | `trackDesignSelected(...)` |

#### Tech Pack Events
| Event | Status | Screen/Location | Method |
|-------|--------|-----------------|--------|
| `tech_pack_started` | ✅ Done | generate_tech_pack_controller.dart | `trackTechPackStarted()` |
| `tech_pack_completed` | ✅ Done | tech_pack_ready_controller.dart | `trackTechPackCompleted(garmentType:)` |
| `tech_pack_downloaded` | ✅ Done | tech_pack_ready_controller.dart | `trackTechPackDownloaded(format:)` |

#### Subscription Events
| Event | Status | Screen/Location | Method |
|-------|--------|-----------------|--------|
| `subscription_viewed` | ✅ Done | subscribe_controller.dart | `trackSubscriptionViewed(...)` |
| `subscription_started` | ✅ Done | subscribe_controller.dart | `trackSubscriptionStarted(...)` |
| `subscription_cancelled` | ✅ Done | subscribe_controller.dart | `trackSubscriptionCancelled(...)` |

#### Custom Heatmap Events
| Event | Status | Screen/Location | Method |
|-------|--------|-----------------|--------|
| `tap` | ✅ Ready | Any screen via TapTrackingWrapper | `trackTap(screen, x, y, screen_width, screen_height, widget?)` |

---

## Tracking Plan

### Funnels (in PostHog Dashboard)

#### 1. Design Creation Funnel ✅ Created
```
Creative Brief → Refined Concept → Final Details → Design Generated → Design Selected
```

#### 2. Onboarding Funnel ✅ Created (3 steps)
```
Sign Up → Creative Brief → Design Generated → [Tech Pack Completed]*
```
*Step 4 (`tech_pack_completed`) to be added once events are captured*

#### 3. Conversion Funnel ✅ Created
```
Subscription Viewed → Subscription Started
```

#### 4. Subscription Churn Funnel ✅ Created
```
Subscription Started → Subscription Cancelled
```
*Measures churn rate - what % of paying users cancel their subscription*

### User Properties to Track
| Property | When Set | Purpose |
|----------|----------|---------|
| `email` | On identification | User contact |
| `name` | On identification | Personalization |
| `subscription_plan` | On subscription change | Segmentation |
| `designs_created_count` | On design completion | Engagement metric |
| `first_seen_at` | On first identification | Cohort analysis |

### Cohorts (in PostHog Dashboard)
| Cohort | Status | Criteria |
|--------|--------|----------|
| **Power Users** | ✅ Created | Users with 5+ designs generated |
| **New Users (7 days)** | ✅ Created | First seen in last 7 days |
| **Free Users** | ✅ Created | Users who signed up but never started a subscription |
| **Paid Users** | ✅ Created | Users who completed at least one `subscription_started` event |
| **Churned Users** | ✅ Created | Users who completed at least one `subscription_cancelled` event |

---

## Files Created/Modified

### New Files
- `lib/services/analytics/posthog_analytics_service.dart` - Analytics service singleton
- `lib/core/widgets/tap_tracking_wrapper.dart` - Custom tap tracking wrapper for heatmaps

### Modified Files
- `pubspec.yaml` - Added posthog_flutter dependency
- `lib/main.dart` - PostHog initialization + PostHogWidget
- `android/app/src/main/AndroidManifest.xml` - AUTO_INIT=false
- `ios/Runner/Info.plist` - AUTO_INIT=false
- `.env` - POSTHOG_API_KEY and POSTHOG_HOST
- `lib/Modules/Auth/Controllers/signup_controller.dart` - Added signup tracking
- `lib/Modules/Auth/Controllers/login_controller.dart` - Added login tracking + user identification
- `lib/Modules/Home/Controllers/profile_controller.dart` - Added logout tracking
- `lib/Modules/creative_brief/controllers/creative_brief_controller.dart` - Added creative brief tracking
- `lib/Modules/refining_concept/controllers/refining_concept_controller.dart` - Added refined concept tracking
- `lib/Modules/final_details/controllers/final_detail_controller.dart` - Added final details tracking
- `lib/Modules/tech_pack/controllers/generate_tech_pack_controller.dart` - Added design generation + tech pack started tracking
- `lib/Modules/tech_pack/controllers/tech_pack_ready_controller.dart` - Added tech pack completed/downloaded tracking
- `lib/Modules/Home/Controllers/subscribe_controller.dart` - Added subscription tracking + cancellation reasons
- `lib/Modules/Home/View/Screens/subscribe_starter_plan.dart` - Added cancellation reason dialog
- `lib/Modules/Home/View/Screens/subscribe_pro_plan.dart` - Added cancellation reason dialog

---

## Integration Checklist

### Phase 1: Core Setup ✅
- [x] Install PostHog SDK
- [x] Configure cloud instance
- [x] Set up manual initialization
- [x] Enable session recordings
- [x] Add PostHogWidget wrapper
- [x] Add navigator observer for screen tracking
- [x] Create analytics service with event methods

### Phase 2: Event Integration ✅
- [x] Integrate auth events (sign up, login, logout)
- [x] Add user identification after successful auth
- [x] Integrate design flow events
- [x] Integrate tech pack events
- [x] Integrate subscription events

### Phase 3: Dashboard Configuration ✅
- [x] Verify events are flowing in PostHog
- [x] Create Onboarding Funnel (3 steps - 4th step pending `tech_pack_completed` events)
- [x] Create Design Creation Funnel
- [x] Create Conversion Funnel (`subscription_viewed` → `subscription_started`)
- [x] Create Churn Funnel (`subscription_started` → `subscription_cancelled`)
- [x] Set up user cohorts (Power Users, New Users, Free Users, Paid Users, Churned Users)
- [ ] Configure session replay filters (optional)

### Phase 4: Validation & Testing ✅
- [x] Test all events fire correctly (verified in PostHog dashboard)
- [x] Verify session recordings capture correctly
- [x] Validate user identification works
- [x] Check funnels show correct data
- [ ] Performance testing (no app slowdowns) - optional
- [ ] Document edge cases - optional

---

## Configuration Details

### PostHog Config (main.dart)
```dart
final config = PostHogConfig(apiKey);
config.host = 'https://us.i.posthog.com';
config.debug = kDebugMode;
config.captureApplicationLifecycleEvents = true;
config.personProfiles = PostHogPersonProfiles.identifiedOnly;

// Session Replay
config.optOut = !analyticsOptIn;           // respects user toggle
config.sessionReplay = analyticsOptIn;     // on when enabled
config.sessionReplayConfig.maskAllTexts = false;   // show all text
config.sessionReplayConfig.maskAllImages = false;  // show all images
config.sessionReplayConfig.throttleDelay = Duration(milliseconds: 700);
```

**Consent & Sampling**
- Analytics opt-in toggle lives in Profile screen; default ON, persisted.
- Session replay runs when analytics is enabled (no sampling) with full visibility (no masking).
- Users can disable analytics/replay at any time; when disabled we call `Posthog().disable()` to stop collection. Update the Privacy Policy/ToS to disclose analytics and the opt-out location in-app.

### Environment Variables (.env)
```
POSTHOG_API_KEY=phc_xxxxx
POSTHOG_HOST=https://us.i.posthog.com
```

---

## Feature Flags

Feature flags allow you to enable/disable features remotely without deploying new code. They're useful for A/B testing, gradual rollouts, and kill switches.

### Available Methods

| Method | Description | Returns |
|--------|-------------|---------|
| `isFeatureEnabled(flagKey)` | Check if a boolean flag is enabled | `Future<bool>` |
| `getFeatureFlag(flagKey)` | Get flag value (for multivariate flags) | `Future<dynamic>` |
| `getFeatureFlagPayload(flagKey)` | Get JSON payload attached to flag | `Future<dynamic>` |
| `reloadFeatureFlags()` | Force refresh all flags from server | `Future<void>` |

### Creating a Feature Flag in PostHog Dashboard

1. Go to **Feature Flags** → **New feature flag**
2. Enter a **Key** (e.g., `new_subscription_ui`)
3. Set **Release conditions**:
   - Roll out to X% of users
   - Target specific cohorts (e.g., "Paid Users")
   - Target by user properties
4. Optionally add a **Payload** (JSON data)
5. Click **Save**

### Usage Examples

#### Basic Boolean Flag
```dart
// Check if feature is enabled
if (await PostHogAnalyticsService().isFeatureEnabled('new_subscription_ui')) {
  // Show new UI
} else {
  // Show old UI
}
```

#### Multivariate Flag (A/B/C Testing)
```dart
// Get which variant the user is in
final variant = await PostHogAnalyticsService().getFeatureFlag('button_color_test');

switch (variant) {
  case 'red':
    return Colors.red;
  case 'blue':
    return Colors.blue;
  case 'green':
    return Colors.green;
  default:
    return Colors.grey; // Control/default
}
```

#### Flag with Payload (Remote Config)
```dart
// Get JSON payload attached to the flag
final payload = await PostHogAnalyticsService().getFeatureFlagPayload('app_config');

if (payload != null) {
  final maxDesigns = payload['max_designs'] ?? 10;
  final welcomeMessage = payload['welcome_message'] ?? 'Welcome!';
  // Use the remote config values
}
```

#### Force Reload Flags
```dart
// Useful after user logs in or changes subscription
await PostHogAnalyticsService().reloadFeatureFlags();
```

### Suggested Feature Flags for Atelia

| Flag Key | Type | Use Case |
|----------|------|----------|
| `show_analytics_toggle` | Boolean | **✅ IMPLEMENTED** - Show/hide analytics toggle in Edit Profile |
| `new_subscription_ui` | Boolean | A/B test new subscription screen design |
| `ai_design_v2` | Boolean | Gradual rollout of new AI model |
| `enable_tech_pack_export` | Boolean | Kill switch for PDF export |
| `max_free_designs` | Payload | Remote config for free tier limits |
| `enable_manufacturer_suggestions` | Boolean | Feature gate for paid users only |
| `beta_features` | Boolean | Enable experimental features for beta testers |

### Best Practices

1. **Use descriptive flag names**: `enable_dark_mode` not `flag1`
2. **Default to safe values**: If flag check fails, default to existing behavior
3. **Reload after auth changes**: Call `reloadFeatureFlags()` after login/logout
4. **Clean up old flags**: Remove flags from code after full rollout
5. **Use cohorts for targeting**: Target "Paid Users" cohort for premium features

### Example: Premium Feature Gate

```dart
class ManufacturerSuggestionsButton extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return FutureBuilder<bool>(
      future: PostHogAnalyticsService().isFeatureEnabled('enable_manufacturer_suggestions'),
      builder: (context, snapshot) {
        final isEnabled = snapshot.data ?? false;

        if (!isEnabled) {
          return SizedBox.shrink(); // Hide button
        }

        return ElevatedButton(
          onPressed: () => Get.to(() => ManufacturerSuggestionsScreen()),
          child: Text('Get Manufacturer Suggestions'),
        );
      },
    );
  }
}
```

### Example: A/B Test with Tracking

```dart
Future<void> showSubscriptionScreen() async {
  final variant = await PostHogAnalyticsService().getFeatureFlag('subscription_screen_test');

  // Track which variant the user saw (for analysis)
  await PostHogAnalyticsService().trackEvent('subscription_screen_viewed', properties: {
    'variant': variant ?? 'control',
  });

  if (variant == 'new_design') {
    Get.to(() => NewSubscriptionScreen());
  } else {
    Get.to(() => SubscriptionScreen());
  }
}
```

### Real Implementation: `show_analytics_toggle`

**File:** `lib/Modules/Home/View/Screens/profile_screen.dart`

This is a working feature flag implementation in the codebase that controls whether the analytics toggle is shown in the Edit Profile screen.

```dart
FutureBuilder<bool>(
  future: PostHogAnalyticsService().isFeatureEnabled('show_analytics_toggle'),
  builder: (context, snapshot) {
    // Default to showing the toggle if flag check fails or is loading
    final showToggle = snapshot.data ?? true;

    if (!showToggle) {
      return const SizedBox.shrink();
    }

    return /* Analytics toggle widget */;
  },
),
```

**To create this flag in PostHog:**
1. Go to **Feature Flags** → **New feature flag**
2. Key: `show_analytics_toggle`
3. Set rollout to **100%** (enabled for all users)
4. Save

**Note:** The flag defaults to `true` if not found, so the toggle will always show unless you explicitly disable it in PostHog.

### Feature Flags Troubleshooting

**Problem: Feature flag always returns `false`**

Feature flags are loaded asynchronously from PostHog's servers. If you check a flag before it's loaded, it returns `false`.

**Solution:** We call `reloadFeatureFlags()` during app initialization in `main.dart`:

```dart
await Posthog().setup(config);
// Ensure feature flags are loaded before app starts
await Posthog().reloadFeatureFlags();
```

**Debugging:** Check the debug console for logs like:
```
PostHog Feature Flag [show_analytics_toggle]: connectionState=done, data=true, error=null
```

**Common issues:**
1. **Flag key mismatch** - Ensure the key in code matches exactly (case-sensitive)
2. **Flags not loaded** - Call `reloadFeatureFlags()` after PostHog setup
3. **User not identified** - If flag targets specific users, ensure user is identified first
4. **Network issues** - Check if PostHog calls are being blocked

---

## Notes

### Heatmaps (Custom Implementation for Flutter)

**PostHog heatmaps are web-only** - they don't work for Flutter native apps (Android/iOS/macOS).

#### Our Workaround: Custom Tap Tracking

We capture tap coordinates as events using `TapTrackingWrapper`:

```dart
// lib/core/widgets/tap_tracking_wrapper.dart
TapTrackingWrapper(
  screenName: 'HomeScreen',
  child: YourScreenContent(),
)
```

This sends `tap` events to PostHog with:
- `screen` - Screen name
- `x` - X coordinate
- `y` - Y coordinate
- `widget` - Optional widget name

#### How to Visualize Tap Data

**Option 1: HogQL Query in PostHog**

Go to **Data Warehouse → SQL editor** and run:

```sql
SELECT
  properties.screen AS screen,
  floor(toFloat(properties.x) / 50) * 50 AS x_bucket,
  floor(toFloat(properties.y) / 50) * 50 AS y_bucket,
  count() AS tap_count
FROM events
WHERE event = 'tap'
GROUP BY screen, x_bucket, y_bucket
ORDER BY tap_count DESC
LIMIT 100
```

**Note:** Properties are returned as strings in HogQL, so we use `toFloat()` to convert x/y coordinates before math operations.

This buckets taps into 50px grid cells to show density.

**Sample Result:**
```json
[
  {
    "screen": "GenerateTechPackScreen",
    "x_bucket": 300,
    "y_bucket": 800,
    "tap_count": 1
  }
]
```

**Additional Useful Queries:**

Taps per screen:
```sql
SELECT properties.screen AS screen, count() AS total_taps
FROM events
WHERE event = 'tap'
GROUP BY screen
ORDER BY total_taps DESC
```

Recent taps (last 7 days):
```sql
SELECT properties.screen, properties.x, properties.y, timestamp
FROM events
WHERE event = 'tap' AND timestamp > now() - interval 7 day
ORDER BY timestamp DESC
LIMIT 50
```

**Option 2: Export & Visualize Externally**

1. Go to **Data Management → Events**
2. Filter by `tap` event
3. Export as CSV
4. Use Python/matplotlib or any visualization tool to create heatmap overlay

**Option 3: PostHog Trends**

1. Create a Trend insight
2. Select `tap` event
3. Break down by `screen` property
4. See which screens get the most taps

#### Screens Wrapped with TapTrackingWrapper ✅

| Screen | File | Status |
|--------|------|--------|
| HomeScreen | `home_screen.dart` | ✅ Implemented |
| SubscribeScreen | `subscribe_screen.dart` | ✅ Implemented |
| GenerateTechPackScreen | `generate_tech_pack_screen.dart` | ✅ Implemented |
| TechPackReadyScreen | `tech_pack_ready_screen.dart` | ✅ Implemented |

#### Limitations vs Web Heatmaps

| Feature | Web Heatmaps | Our Flutter Solution |
|---------|--------------|----------------------|
| Visual overlay on screenshots | ✅ | ❌ (manual visualization) |
| Clickmaps | ✅ | ✅ (via HogQL) |
| Scrollmaps | ✅ | ❌ |
| Rage clicks | ✅ | ❌ |
| Automatic capture | ✅ | ❌ (must wrap screens) |

### Backend Integration
This is a Flutter-only mobile app. If there's a backend API, PostHog server-side SDK would need to be installed there separately for backend event tracking.

### Performance Considerations
- Session replay throttle set to 500ms (balance between detail and performance)
- `personProfiles = identifiedOnly` reduces data sent for anonymous users
- Large images in session replay could be masked if performance issues arise

---

## Future Work

### Optional Enhancements
| Task | Description |
|------|-------------|
| Add step 4 to Onboarding Funnel | Add `tech_pack_completed` once more events are captured |
| Configure session replay filters | Filter recordings by user properties or events (optional) |
| Add `designs_created_count` user property | Track total designs per user for segmentation |
| Performance testing | Verify no app slowdowns from PostHog SDK |
| Wrap additional screens with TapTrackingWrapper | Add tap tracking to more screens as needed |

---

## Implementation Complete ✅

All PostHog analytics code integration is complete. The following features are fully functional:

| Feature | Status |
|---------|--------|
| Session recordings | ✅ Working |
| User identification | ✅ Working |
| 15 custom events tracked | ✅ Implemented |
| Design Creation Funnel | ✅ Created |
| Onboarding Funnel (3 steps) | ✅ Created |
| Conversion Funnel | ✅ Created |
| Subscription Churn Funnel | ✅ Created |
| Power Users cohort | ✅ Created |
| New Users cohort | ✅ Created |
| Free Users cohort | ✅ Created |
| Paid Users cohort | ✅ Created |
| Churned Users cohort | ✅ Created |
| Custom tap tracking | ✅ Implemented on 4 key screens |
| Analytics opt-in toggle | ✅ Implemented (Profile screen) |
| Cancellation reason tracking | ✅ Implemented |
| Feature Flags | ✅ Working (`show_analytics_toggle` implemented) |

**Date:** December 2025
