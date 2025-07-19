import 'package:atella/Modules/Auth/View/Screens/Signup_screen.dart';
import 'package:atella/Modules/Auth/View/Screens/login_screen.dart';
import 'package:atella/Modules/Auth/View/Screens/onboarding_screen.dart';
import 'package:atella/Modules/Auth/View/Screens/splash_screen.dart';
import 'package:atella/Modules/Auth/View/Screens/verification_screen.dart';
import 'package:atella/Modules/CreativeBrief/Bindings/creative_brief_binding.dart';
import 'package:atella/Modules/CreativeBrief/Views/Screens/creative_brief_Screen.dart';
import 'package:atella/Modules/CreativeBrief/Views/Screens/gathering_brief_screen.dart';
import 'package:atella/Modules/Home/View/Screens/create_screen.dart';
import 'package:atella/Modules/Home/View/Screens/home_screen.dart';
import 'package:atella/Modules/Home/View/Screens/profile_screen.dart';
import 'package:atella/Modules/RefiningConcept/Views/Screens/refine_concept_screen.dart';
import 'package:atella/Modules/RefiningConcept/Views/Screens/refining_brief_screen.dart';
import 'package:atella/Modules/RefiningConcept/bindings/refining_concept_binding.dart';
import 'package:atella/Routes/app_routes.dart';
import 'package:atella/nav_bar.dart';
import 'package:get/get.dart';

class AppPages {
  static const INITIAL = AppRoutes.splash;

  static final routes = [
    GetPage(name: AppRoutes.splash, page: () => const SplashScreen()),
    GetPage(name: AppRoutes.onboarding, page: () => const OnboardingScreen()),
    GetPage(name: AppRoutes.login, page: () => LoginScreen()),
    GetPage(name: AppRoutes.signup, page: () => SignUpscreen()),
    GetPage(
      name: AppRoutes.verification,
      page: () => const VerificationScreen(),
    ),
    GetPage(name: AppRoutes.home, page: () => const HomeScreen()),
    GetPage(name: AppRoutes.profile, page: () => const ProfileScreen()),
    GetPage(name: AppRoutes.create, page: () => const CreateScreen()),
    GetPage(name: AppRoutes.navBar, page: () => const Custom_NavigationBar()),
    GetPage(
      name: AppRoutes.creativeBrief,
      page: () => const CreativeBriefScreen(),
      binding: CreativeBriefBinding(),
    ),
    GetPage(
      name: AppRoutes.gatheringBrief,
      page: () => const GatheringBriefScreen(),
    ),
    GetPage(
      name: AppRoutes.refineConcept,
      page: () => const RefineConceptScreen(),
    ),
    GetPage(
      name: AppRoutes.refiningConcept,
      page: () => const RefiningBriefScreen(),
      binding: RefiningConceptBinding(),
    ),
    // Add more routes here
  ];
}
