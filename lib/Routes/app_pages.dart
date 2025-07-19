import 'package:atella/Modules/Auth/View/Screens/Signup_screen.dart';
import 'package:atella/Modules/Auth/View/Screens/login_screen.dart';
import 'package:atella/Modules/Auth/View/Screens/onboarding_screen.dart';
import 'package:atella/Modules/Auth/View/Screens/splash_screen.dart';
import 'package:atella/Modules/Auth/View/Screens/verification_screen.dart';
import 'package:atella/Modules/Home/View/Screens/create_screen.dart';
import 'package:atella/Modules/Home/View/Screens/home_screen.dart';
import 'package:atella/Modules/Home/View/Screens/profile_screen.dart';
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
    // Add more routes here
  ];
}
