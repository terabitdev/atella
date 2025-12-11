import 'package:flutter/material.dart';
import 'package:atella/services/analytics/posthog_analytics_service.dart';

/// A wrapper widget that tracks tap coordinates for custom heatmap analysis.
///
/// Wrap any screen or widget with this to capture tap locations.
/// This is a workaround since PostHog heatmaps are web-only.
///
/// Usage:
/// ```dart
/// TapTrackingWrapper(
///   screenName: 'HomeScreen',
///   child: YourScreenContent(),
/// )
/// ```
class TapTrackingWrapper extends StatelessWidget {
  final Widget child;
  final String screenName;

  const TapTrackingWrapper({
    super.key,
    required this.child,
    required this.screenName,
  });

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;
    return GestureDetector(
      behavior: HitTestBehavior.translucent,
      onTapDown: (details) {
        final pos = details.globalPosition;
        PostHogAnalyticsService().trackTap(
          screenName: screenName,
          x: pos.dx,
          y: pos.dy,
          screenWidth: size.width,
          screenHeight: size.height,
        );
      },
      child: child,
    );
  }
}
