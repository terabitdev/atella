import 'package:atella/Modules/Auth/View/Screens/Signup_screen.dart';
import 'package:atella/Modules/Auth/View/Screens/login_screen.dart';
import 'package:atella/Modules/Auth/View/Screens/onboarding_screen.dart';
import 'package:atella/Modules/Auth/View/Screens/splash_screen.dart';
import 'package:atella/Modules/Auth/View/Screens/verification_screen.dart';
import 'package:atella/Modules/CreativeBrief/Bindings/creative_brief_binding.dart';
import 'package:atella/Modules/CreativeBrief/Views/Screens/creative_brief_Screen.dart';
import 'package:atella/Modules/CreativeBrief/Views/Screens/gathering_brief_screen.dart';
import 'package:atella/Modules/FinalDetails/Views/Screens/final_detail_onboard.dart';
import 'package:atella/Modules/FinalDetails/Views/Screens/final_detail_screen.dart';
import 'package:atella/Modules/FinalDetails/bindings/final_detail_binding.dart';
import 'package:atella/Modules/Home/View/Screens/create_screen.dart';
import 'package:atella/Modules/Home/View/Screens/home_screen.dart';
import 'package:atella/Modules/Home/View/Screens/profile_screen.dart';
import 'package:atella/Modules/RefiningConcept/Views/Screens/refine_concept_screen.dart';
import 'package:atella/Modules/RefiningConcept/Views/Screens/refining_brief_screen.dart';
import 'package:atella/Modules/RefiningConcept/bindings/refining_concept_binding.dart';
import 'package:atella/Modules/TechPack/Views/Screens/edit_project_screen.dart';
import 'package:atella/Modules/TechPack/Views/Screens/generate_tech_pack_screen.dart';
import 'package:atella/Modules/TechPack/Views/Screens/recommended_manufacture_screen.dart';
import 'package:atella/Modules/TechPack/Views/Screens/tech_pack_details_screen.dart';
import 'package:atella/Modules/TechPack/Views/Screens/tech_pack_ready_screen.dart';
import 'package:atella/Modules/TechPack/Views/Screens/view_profile_tech_pack_screen.dart';
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
    GetPage(
      name: AppRoutes.finalDetailOnboard,
      page: () => const FinalDetailOnboard(),
    ),
    GetPage(
      name: AppRoutes.finalDetails,
      page: () => const FinalDetailsScreen(),
      binding: FinalDetailsBinding(),
    ),
    GetPage(
      name: AppRoutes.generateTechPack,
      page: () => GenerateTechPackScreen(),
    ),
    GetPage(
      name: AppRoutes.techPackDetails,
      page: () => TechPackDetailsScreen(),
    ),
    GetPage(
      name: AppRoutes.techPackReadyScreen,
      page: () => const TechPackReadyScreen(),
    ),
    GetPage(
      name: AppRoutes.recommendedTechPack,
      page: () => const RecommendedManufactureScreen(),
    ),
    GetPage(
      name: AppRoutes.viewprofileTechPack,
      page: () => const ViewProfileTechPackScreen(),
    ),
    GetPage(
      name: AppRoutes.editProjectScreen,
      page: () => const EditProjectScreen(),
    ),
    // Add more routes here
  ];
}
