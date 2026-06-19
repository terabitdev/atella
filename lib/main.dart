import 'package:atella/Routes/app_pages.dart';
import 'package:atella/core/themes/app_theme.dart';
import 'package:atella/core/controllers/locale_controller.dart';
import 'package:atella/services/analytics/posthog_analytics_service.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_stripe/flutter_stripe.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:get/get.dart';
import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:posthog_flutter/posthog_flutter.dart';
import 'services/firebase/firebase_options.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'services/PaymentService/subscription_manager_service.dart';
import 'services/PaymentService/stripe_subscription_service.dart';
import 'services/PaymentService/revenuecat_service.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:atella/l10n/generated/app_localizations.dart';
import 'package:atella/services/translation/ml_translation_service.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await dotenv.load(fileName: ".env");
  Stripe.publishableKey = dotenv.env['PublishableKey']!;
  await Stripe.instance.applySettings();
  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);
  await SystemChrome.setPreferredOrientations([DeviceOrientation.portraitUp]);

  // Initialize RevenueCat for in-app purchases (add-ons)
  await RevenueCatService().initialize();

  // Initialize subscription manager to check for monthly resets
  await SubscriptionManagerService().initialize();

  // Initialize PostHog Analytics
  await _initializePostHog();
  // Identify returning user (if already authenticated)
  await _identifyExistingUser();

  // Initialize LocaleController for language management (permanent to survive logout)
  Get.put(LocaleController(), permanent: true);

  // Validate and cleanup incomplete/unpaid subscriptions
  await _validateSubscriptionOnLaunch();

  runApp(const MyApp());

  // Fire-and-forget: runs in background without blocking the app
  _initializeTranslationModel();
}

/// Initialize and download French translation model if needed
Future<void> _initializeTranslationModel() async {
  try {
    final translationService = MLTranslationService();

    // Initialize the translator
    await translationService.initialize();

    // Check if French model is already downloaded
    bool isDownloaded = await translationService.isModelDownloaded();

    if (!isDownloaded) {
      if (kDebugMode) {
        debugPrint(
          'Translation: Downloading French translation model (~30MB)...',
        );
      }

      // Download the model
      bool success = await translationService.downloadModel();

      if (success) {
        if (kDebugMode) {
          debugPrint('Translation: French model downloaded successfully!');
        }
      } else {
        if (kDebugMode) {
          debugPrint(
            'Translation: Failed to download French model. Translation will be disabled.',
          );
        }
      }
    } else {
      if (kDebugMode) {
        debugPrint('Translation: French model already downloaded and ready.');
      }
    }
  } catch (e) {
    if (kDebugMode) {
      debugPrint('Translation: Error initializing translation service: $e');
    }
    // Don't block app startup if translation fails
  }
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
    config.sessionReplayConfig.throttleDelay = const Duration(
      milliseconds: 700,
    );

    await Posthog().setup(config);

    // Ensure feature flags are loaded before app starts
    // This is important because isFeatureEnabled() returns false if flags haven't loaded yet
    await Posthog().reloadFeatureFlags();

    if (kDebugMode) {
      debugPrint(
        'PostHog: Initialized (optIn: $analyticsOptIn, replay: $analyticsOptIn)',
      );
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

/// Validate subscription status on app launch
/// This ensures that incomplete/unpaid subscriptions are cleaned up
Future<void> _validateSubscriptionOnLaunch() async {
  try {
    final user = FirebaseAuth.instance.currentUser;
    if (user != null) {
      // Import required for StripeSubscriptionService
      final stripeService = StripeSubscriptionService();
      await stripeService.validateAndCleanupSubscription();
      if (kDebugMode) {
        debugPrint('Subscription: Validation completed on app launch');
      }
    }
  } catch (e) {
    if (kDebugMode) {
      debugPrint('Subscription: Error validating on launch - $e');
    }
    // Don't block app startup if validation fails
  }
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return PostHogWidget(
      child: ScreenUtilInit(
        designSize: const Size(375, 812),
        minTextAdapt: true,
        builder: (context, child) {
          // Ensure LocaleController exists before using it (handles hot reload)
          final localeController = Get.isRegistered<LocaleController>()
              ? Get.find<LocaleController>()
              : Get.put(LocaleController(), permanent: true);

          return GetMaterialApp(
            title: 'Atelia',
            theme: AppTheme.lightTheme,
            themeMode: ThemeMode.light,
            debugShowCheckedModeBanner: false,
            initialRoute: AppPages.initial,
            getPages: AppPages.routes,
            navigatorObservers: [PosthogObserver()],
            // Localization — locale updates handled by Get.updateLocale() in LocaleController
            locale: localeController.currentLocale,
            supportedLocales: LocaleController.supportedLocales,
            localizationsDelegates: const [
              AppLocalizations.delegate,
              GlobalMaterialLocalizations.delegate,
              GlobalWidgetsLocalizations.delegate,
              GlobalCupertinoLocalizations.delegate,
            ],
          );
        },
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
