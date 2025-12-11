import 'package:atella/Routes/app_pages.dart';
import 'package:atella/core/themes/app_theme.dart';
import 'package:atella/services/analytics/posthog_analytics_service.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_stripe/flutter_stripe.dart';
import 'package:get/get.dart';
import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:posthog_flutter/posthog_flutter.dart';
import 'services/firebase/firebase_options.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'services/PaymentService/subscription_manager_service.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await dotenv.load(fileName: ".env");
  Stripe.publishableKey = dotenv.env['PublishableKey']!;
  await Stripe.instance.applySettings();
  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);
  await SystemChrome.setPreferredOrientations([DeviceOrientation.portraitUp]);
  // Initialize subscription manager to check for monthly resets
  await SubscriptionManagerService().initialize();

  // Initialize PostHog Analytics
  await _initializePostHog();
  // Identify returning user (if already authenticated)
  await _identifyExistingUser();

  runApp(const MyApp());
}

/// Initialize PostHog for analytics tracking
Future<void> _initializePostHog() async {
  final apiKey = dotenv.env['POSTHOG_API_KEY'];
  final host = dotenv.env['POSTHOG_HOST'] ?? 'https://us.i.posthog.com';

  if (apiKey == null || apiKey.isEmpty) {
    if (kDebugMode) {
      debugPrint('PostHog: API key not configured, skipping initialization');
    }
    return;
  }

  try {
    final prefs = await SharedPreferences.getInstance();
    // Respect user opt-in; default to true but allow toggle in profile.
    final analyticsOptIn = prefs.getBool('analytics_opt_in') ?? true;

    final config = PostHogConfig(apiKey);
    config.host = host;
    config.debug = kDebugMode; // Enable debug logs in development
    config.captureApplicationLifecycleEvents = true;
    // Use identified events only when user is identified (more cost effective)
    config.personProfiles = PostHogPersonProfiles.identifiedOnly;
    // Respect user consent
    config.optOut = !analyticsOptIn;

    // Enable Session Replay
    config.sessionReplay = analyticsOptIn;
    // Show all text and images in session replays (no masking)
    config.sessionReplayConfig.maskAllTexts = false;
    config.sessionReplayConfig.maskAllImages = false;
    // Slightly tighter throttle to balance fidelity/perf
    config.sessionReplayConfig.throttleDelay =
        const Duration(milliseconds: 700);

    await Posthog().setup(config);

    // Ensure feature flags are loaded before app starts
    // This is important because isFeatureEnabled() returns false if flags haven't loaded yet
    await Posthog().reloadFeatureFlags();

    if (kDebugMode) {
      debugPrint('PostHog: Initialized (optIn: $analyticsOptIn, replay: $analyticsOptIn)');
    }
  } catch (e) {
    if (kDebugMode) {
      debugPrint('PostHog: Failed to initialize - $e');
    }
  }
}

/// Identify an already-authenticated user on app start
Future<void> _identifyExistingUser() async {
  final user = FirebaseAuth.instance.currentUser;
  if (user != null) {
    await PostHogAnalyticsService().identifyUser(
      userId: user.uid,
      email: user.email,
      name: user.displayName,
    );
  }
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});
  @override
  Widget build(BuildContext context) {
    // PostHogWidget is required for mobile session replay
    return PostHogWidget(
      child: ScreenUtilInit(
        designSize: const Size(375, 812),
        minTextAdapt: true,
        // useInheritedMediaQuery: true,
        builder: (context, child) => GetMaterialApp(
          title: 'Atelia',
          theme: AppTheme.lightTheme,
          themeMode: ThemeMode.light,
          debugShowCheckedModeBanner: false,
          initialRoute: AppPages.initial,
          getPages: AppPages.routes,
          // PostHog: Automatic screen view tracking
          navigatorObservers: [PosthogObserver()],
          // locale: DevicePreview.locale(context),
          // builder: DevicePreview.appBuilder,
        ),
      ),
    );
  }
}

// import 'package:atella/services/word_generator_screen.dart';
// import 'package:flutter/material.dart';
// import 'package:get/get.dart';

// void main() {
//   runApp(const MyApp());
// }

// class MyApp extends StatelessWidget {
//   const MyApp({super.key});

//   @override
//   Widget build(BuildContext context) {
//     return GetMaterialApp(
//       debugShowCheckedModeBanner: false,
//       title: 'Word Generator App',
//       home: const WordGeneratorScreen(),
//     );
//   }
// }
