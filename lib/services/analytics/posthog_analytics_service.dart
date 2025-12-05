import 'package:flutter/foundation.dart';
import 'package:posthog_flutter/posthog_flutter.dart';
import 'package:shared_preferences/shared_preferences.dart';

/// PostHog Analytics Service
///
/// A singleton service for tracking analytics events throughout the app.
/// Provides methods for identifying users, tracking events, and managing user sessions.
class PostHogAnalyticsService {
  static final PostHogAnalyticsService _instance = PostHogAnalyticsService._internal();
  factory PostHogAnalyticsService() => _instance;
  PostHogAnalyticsService._internal();

  final Posthog _posthog = Posthog();
  static const _optInKey = 'analytics_opt_in';

  // ==================== USER IDENTIFICATION ====================

  /// Identify a user after login/signup
  /// Call this when user successfully authenticates
  Future<void> identifyUser({
    required String userId,
    String? email,
    String? name,
    Map<String, Object>? additionalProperties,
  }) async {
    try {
      final properties = <String, Object>{};
      if (email != null) properties['email'] = email;
      if (name != null) properties['name'] = name;
      if (additionalProperties != null) properties.addAll(additionalProperties);

      await _posthog.identify(
        userId: userId,
        userProperties: properties,
        userPropertiesSetOnce: {
          'first_seen_at': DateTime.now().toIso8601String(),
        },
      );

      _debugLog('User identified: $userId');
    } catch (e) {
      _debugLog('Failed to identify user: $e');
    }
  }

  /// Reset user session on logout
  Future<void> reset() async {
    try {
      await _posthog.reset();
      _debugLog('User session reset');
    } catch (e) {
      _debugLog('Failed to reset session: $e');
    }
  }

  // ==================== EVENT TRACKING ====================

  /// Track a custom event
  /// Use format: [object] [verb] (e.g., 'design created', 'user signed up')
  Future<void> trackEvent(
    String eventName, {
    Map<String, Object>? properties,
  }) async {
    try {
      await _posthog.capture(
        eventName: eventName,
        properties: properties,
      );
      _debugLog('Event tracked: $eventName');
    } catch (e) {
      _debugLog('Failed to track event: $e');
    }
  }

  // ==================== DESIGN FLOW EVENTS ====================

  /// Track when user starts creating a design
  Future<void> trackDesignStarted() async {
    await trackEvent('design_started');
  }

  /// Track creative brief completion
  Future<void> trackCreativeBriefCompleted({
    required String garmentType,
    required String style,
    required String targetAudience,
  }) async {
    await trackEvent('creative_brief_completed', properties: {
      'garment_type': garmentType,
      'style': style,
      'target_audience': targetAudience,
    });
  }

  /// Track refined concept completion
  Future<void> trackRefinedConceptCompleted({
    required String silhouette,
    required String features,
  }) async {
    await trackEvent('refined_concept_completed', properties: {
      'silhouette': silhouette,
      'features': features,
    });
  }

  /// Track final details completion
  Future<void> trackFinalDetailsCompleted({
    required String season,
    required String budget,
    required String values,
  }) async {
    await trackEvent('final_details_completed', properties: {
      'season': season,
      'budget': budget,
      'values': values,
    });
  }

  /// Track design generation started
  Future<void> trackDesignGenerationStarted() async {
    await trackEvent('design_generation_started');
  }

  /// Track design generation completed
  Future<void> trackDesignGenerationCompleted({
    required int numberOfDesigns,
    required Duration generationTime,
  }) async {
    await trackEvent('design_generation_completed', properties: {
      'number_of_designs': numberOfDesigns,
      'generation_time_ms': generationTime.inMilliseconds,
    });
  }

  /// Track design generation failed
  Future<void> trackDesignGenerationFailed({
    required String errorMessage,
  }) async {
    await trackEvent('design_generation_failed', properties: {
      'error_message': errorMessage,
    });
  }

  /// Track design selected
  Future<void> trackDesignSelected({
    required int designIndex,
  }) async {
    await trackEvent('design_selected', properties: {
      'design_index': designIndex,
    });
  }

  // ==================== TECH PACK EVENTS ====================

  /// Track tech pack creation started
  Future<void> trackTechPackStarted() async {
    await trackEvent('tech_pack_started');
  }

  /// Track tech pack completed
  Future<void> trackTechPackCompleted({
    required String garmentType,
  }) async {
    await trackEvent('tech_pack_completed', properties: {
      'garment_type': garmentType,
    });
  }

  /// Track tech pack downloaded
  Future<void> trackTechPackDownloaded({
    required String format,
  }) async {
    await trackEvent('tech_pack_downloaded', properties: {
      'format': format,
    });
  }

  // ==================== SUBSCRIPTION EVENTS ====================

  /// Track subscription page viewed
  Future<void> trackSubscriptionViewed({
    required String currentPlan,
  }) async {
    await trackEvent('subscription_viewed', properties: {
      'current_plan': currentPlan,
    });
  }

  /// Track subscription started
  Future<void> trackSubscriptionStarted({
    required String plan,
    required String billingCycle,
    required double price,
  }) async {
    await trackEvent('subscription_started', properties: {
      'plan': plan,
      'billing_cycle': billingCycle,
      'price': price,
    });
  }

  /// Track subscription cancelled
  Future<void> trackSubscriptionCancelled({
    required String plan,
    String? reason,
  }) async {
    await trackEvent('subscription_cancelled', properties: {
      'plan': plan,
      if (reason != null) 'reason': reason,
    });
  }

  // ==================== AUTH EVENTS ====================

  /// Track user signup
  Future<void> trackUserSignedUp({
    required String method,
  }) async {
    await trackEvent('user_signed_up', properties: {
      'signup_method': method,
    });
  }

  /// Track user login
  Future<void> trackUserLoggedIn({
    required String method,
  }) async {
    await trackEvent('user_logged_in', properties: {
      'login_method': method,
    });
  }

  /// Track user logout
  Future<void> trackUserLoggedOut() async {
    await trackEvent('user_logged_out');
    await reset();
  }

  // ==================== FEATURE FLAGS ====================

  /// Check if a feature flag is enabled
  Future<bool> isFeatureEnabled(String flagKey) async {
    try {
      return await _posthog.isFeatureEnabled(flagKey);
    } catch (e) {
      _debugLog('Failed to check feature flag: $e');
      return false;
    }
  }

  /// Get feature flag value
  Future<dynamic> getFeatureFlag(String flagKey) async {
    try {
      return await _posthog.getFeatureFlag(flagKey);
    } catch (e) {
      _debugLog('Failed to get feature flag: $e');
      return null;
    }
  }

  /// Reload feature flags
  Future<void> reloadFeatureFlags() async {
    try {
      await _posthog.reloadFeatureFlags();
      _debugLog('Feature flags reloaded');
    } catch (e) {
      _debugLog('Failed to reload feature flags: $e');
    }
  }

  // ==================== GROUP ANALYTICS ====================

  /// Associate user with a group (e.g., company, team)
  Future<void> setGroup({
    required String groupType,
    required String groupKey,
    Map<String, Object>? groupProperties,
  }) async {
    try {
      await _posthog.group(
        groupType: groupType,
        groupKey: groupKey,
        groupProperties: groupProperties,
      );
      _debugLog('Group set: $groupType - $groupKey');
    } catch (e) {
      _debugLog('Failed to set group: $e');
    }
  }

  // ==================== SUPER PROPERTIES ====================

  /// Register a super property (sent with every event)
  Future<void> registerSuperProperty(String key, dynamic value) async {
    try {
      await _posthog.register(key, value);
      _debugLog('Super property registered: $key');
    } catch (e) {
      _debugLog('Failed to register super property: $e');
    }
  }

  /// Unregister a super property
  Future<void> unregisterSuperProperty(String key) async {
    try {
      await _posthog.unregister(key);
      _debugLog('Super property unregistered: $key');
    } catch (e) {
      _debugLog('Failed to unregister super property: $e');
    }
  }

  // ==================== OPT OUT ====================

  /// Opt user out of analytics
  Future<void> optOut() async {
    try {
      await _posthog.disable();
      _debugLog('User opted out of analytics');
    } catch (e) {
      _debugLog('Failed to opt out: $e');
    }
  }

  /// Opt user back in to analytics
  Future<void> optIn() async {
    try {
      await _posthog.enable();
      _debugLog('User opted in to analytics');
    } catch (e) {
      _debugLog('Failed to opt in: $e');
    }
  }

  /// Check if user is opted out
  Future<bool> isOptedOut() async {
    try {
      return await _posthog.isOptOut();
    } catch (e) {
      _debugLog('Failed to check opt out status: $e');
      return false;
    }
  }

  // ==================== OPT IN PERSISTENCE ====================

  /// Enable/disable analytics & replays (persisted).
  Future<void> setAnalyticsOptIn(bool enabled) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(_optInKey, enabled);
    if (enabled) {
      await _posthog.enable();
    } else {
      // Disable also tears down error/replay integrations
      await _posthog.disable();
    }
    _debugLog('Analytics opt-in set to $enabled');
  }

  // ==================== TAP HEATMAP TRACKING ====================

  /// Track tap events for custom heatmap analysis
  /// This is a workaround since PostHog heatmaps are web-only
  Future<void> trackTap({
    required String screenName,
    required double x,
    required double y,
    required double screenWidth,
    required double screenHeight,
    String? widgetName,
  }) async {
    await trackEvent('tap', properties: {
      'screen': screenName,
      'x': x,
      'y': y,
      'screen_width': screenWidth,
      'screen_height': screenHeight,
      if (widgetName != null) 'widget': widgetName,
    });
  }

  // ==================== HELPERS ====================

  void _debugLog(String message) {
    if (kDebugMode) {
      debugPrint('PostHog: $message');
    }
  }
}
