import 'package:atella/Routes/app_routes.dart';
import 'package:atella/Modules/Auth/Bindings/auth_bindings.dart';
import 'package:atella/Modules/Auth/View/Screens/Signup_screen.dart';
import 'package:atella/Modules/Auth/View/Screens/login_screen.dart';
import 'package:atella/Modules/Auth/View/Screens/onboarding_screen.dart';
import 'package:atella/Modules/Auth/View/Screens/splash_screen.dart';
import 'package:atella/Modules/Auth/View/Screens/verification_screen.dart';
import 'package:atella/Modules/creative_brief/Bindings/creative_brief_binding.dart';
import 'package:atella/Modules/creative_brief/Views/Screens/creative_brief_screen.dart';
import 'package:atella/Modules/creative_brief/Views/Screens/gathering_brief_screen.dart';
import 'package:atella/Modules/final_details/Views/Screens/final_detail_onboard.dart';
import 'package:atella/Modules/final_details/Views/Screens/final_detail_screen.dart';
import 'package:atella/Modules/final_details/bindings/final_detail_binding.dart';
import 'package:atella/Modules/Home/View/Screens/create_screen.dart';
import 'package:atella/Modules/Home/View/Screens/favourite_screen.dart';
import 'package:atella/Modules/Home/View/Screens/home_screen.dart';
import 'package:atella/Modules/Home/View/Screens/my_collection_screen.dart';
import 'package:atella/Modules/Home/View/Screens/my_design_screen.dart';
import 'package:atella/Modules/Home/View/Screens/profile_screen.dart';
import 'package:atella/Modules/Home/View/Screens/subscribe_free_plan.dart';
import 'package:atella/Modules/Home/View/Screens/subscribe_pro_plan.dart';
import 'package:atella/Modules/Home/View/Screens/subscribe_screen.dart';
import 'package:atella/Modules/Home/View/Screens/subscribe_starter_plan.dart';
import 'package:atella/Modules/Home/View/Screens/subscribe_studio_plan.dart';
import 'package:atella/Modules/Home/View/Screens/terms_and_conditions_screen.dart';
import 'package:atella/Modules/Home/bindings/subscribe_binding.dart';
import 'package:atella/Modules/refining_concept/Views/Screens/refine_concept_screen.dart';
import 'package:atella/Modules/refining_concept/Views/Screens/refining_brief_screen.dart';
import 'package:atella/Modules/refining_concept/bindings/refining_concept_binding.dart';
import 'package:atella/Modules/tech_pack/Views/Screens/generate_tech_pack_screen.dart';
import 'package:atella/Modules/tech_pack/Views/Screens/recommended_manufacture_screen.dart';
import 'package:atella/Modules/tech_pack/Views/Screens/tech_pack_details_screen.dart';
import 'package:atella/Modules/tech_pack/Views/Screens/tech_pack_ready_screen.dart';
import 'package:atella/Modules/tech_pack/Views/Screens/view_profile_tech_pack_screen.dart';
import 'package:atella/Modules/tech_pack/bindings/tech_pack_binding.dart';
import 'package:atella/nav_bar.dart';
import 'package:get/get.dart';

class AppPages {
  static const initial = AppRoutes.splash;

  static final routes = [
    GetPage(name: AppRoutes.splash, page: () => const SplashScreen()),
    GetPage(name: AppRoutes.onboarding, page: () => const OnboardingScreen()),
    GetPage(
      name: AppRoutes.login,
      page: () => LoginScreen(),
      binding: LoginBinding(),
    ),
    GetPage(
      name: AppRoutes.signup,
      page: () => SignUpscreen(),
      binding: SignupBinding(),
    ),
    GetPage(
      name: AppRoutes.verification,
      page: () => const VerificationScreen(),
    ),
    GetPage(name: AppRoutes.home, page: () => const HomeScreen()),
    GetPage(name: AppRoutes.profile, page: () => const ProfileScreen()),
    GetPage(name: AppRoutes.create, page: () => const CreateScreen()),
    GetPage(name: AppRoutes.favourite, page: () => const FavouriteScreen()),
    GetPage(name: AppRoutes.navBar, page: () => const CustomNavigationBar()),
    GetPage(
      name: AppRoutes.creativeBrief,
      page: () => const CreativeBriefScreen(),
      binding: CreativeBriefBinding(),
    ),
    GetPage(
      name: AppRoutes.gatheringBrief,
      page: () => const GatheringBriefScreen(),
      binding: CreativeBriefBinding(),
    ),
    GetPage(
      name: AppRoutes.refineConcept,
      page: () => const RefineConceptScreen(),
      binding: RefiningConceptBinding(),
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
      binding: TechPackBinding(),
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
      name: AppRoutes.subscribe,
      page: () => const SubscribeScreen(),
      binding: SubscribeBinding(),
    ),
    GetPage(name: AppRoutes.myDesigns, page: () => const MyDesignScreen()),
    GetPage(
      name: AppRoutes.collections,
      page: () => const MyCollectionScreen(),
    ),
    GetPage(
      name: AppRoutes.subscribeFree,
      page: () => const SubscribeFreePlan(),
    ),
    GetPage(
      name: AppRoutes.subscribeStarter,
      page: () => const SubscribeStarterPlan(),
    ),
    GetPage(name: AppRoutes.subscribePro, page: () => const SubscribeProPlan()),
    GetPage(name: AppRoutes.subscribeStudio, page: () => const SubscribeStudioPlan()),
    GetPage(name: AppRoutes.terms, page: () => const TermsAndConditionsScreen()),
    // Add more routes here
  ];
}
