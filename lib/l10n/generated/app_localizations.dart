import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:intl/intl.dart' as intl;

import 'app_localizations_en.dart';
import 'app_localizations_fr.dart';

// ignore_for_file: type=lint

/// Callers can lookup localized strings with an instance of AppLocalizations
/// returned by `AppLocalizations.of(context)`.
///
/// Applications need to include `AppLocalizations.delegate()` in their app's
/// `localizationDelegates` list, and the locales they support in the app's
/// `supportedLocales` list. For example:
///
/// ```dart
/// import 'generated/app_localizations.dart';
///
/// return MaterialApp(
///   localizationsDelegates: AppLocalizations.localizationsDelegates,
///   supportedLocales: AppLocalizations.supportedLocales,
///   home: MyApplicationHome(),
/// );
/// ```
///
/// ## Update pubspec.yaml
///
/// Please make sure to update your pubspec.yaml to include the following
/// packages:
///
/// ```yaml
/// dependencies:
///   # Internationalization support.
///   flutter_localizations:
///     sdk: flutter
///   intl: any # Use the pinned version from flutter_localizations
///
///   # Rest of dependencies
/// ```
///
/// ## iOS Applications
///
/// iOS applications define key application metadata, including supported
/// locales, in an Info.plist file that is built into the application bundle.
/// To configure the locales supported by your app, you’ll need to edit this
/// file.
///
/// First, open your project’s ios/Runner.xcworkspace Xcode workspace file.
/// Then, in the Project Navigator, open the Info.plist file under the Runner
/// project’s Runner folder.
///
/// Next, select the Information Property List item, select Add Item from the
/// Editor menu, then select Localizations from the pop-up menu.
///
/// Select and expand the newly-created Localizations item then, for each
/// locale your application supports, add a new item and select the locale
/// you wish to add from the pop-up menu in the Value field. This list should
/// be consistent with the languages listed in the AppLocalizations.supportedLocales
/// property.
abstract class AppLocalizations {
  AppLocalizations(String locale)
    : localeName = intl.Intl.canonicalizedLocale(locale.toString());

  final String localeName;

  static AppLocalizations? of(BuildContext context) {
    return Localizations.of<AppLocalizations>(context, AppLocalizations);
  }

  static const LocalizationsDelegate<AppLocalizations> delegate =
      _AppLocalizationsDelegate();

  /// A list of this localizations delegate along with the default localizations
  /// delegates.
  ///
  /// Returns a list of localizations delegates containing this delegate along with
  /// GlobalMaterialLocalizations.delegate, GlobalCupertinoLocalizations.delegate,
  /// and GlobalWidgetsLocalizations.delegate.
  ///
  /// Additional delegates can be added by appending to this list in
  /// MaterialApp. This list does not have to be used at all if a custom list
  /// of delegates is preferred or required.
  static const List<LocalizationsDelegate<dynamic>> localizationsDelegates =
      <LocalizationsDelegate<dynamic>>[
        delegate,
        GlobalMaterialLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
      ];

  /// A list of this localizations delegate's supported locales.
  static const List<Locale> supportedLocales = <Locale>[
    Locale('en'),
    Locale('fr'),
  ];

  /// The app name
  ///
  /// In en, this message translates to:
  /// **'Atelia'**
  String get appName;

  /// Welcome message on home screen
  ///
  /// In en, this message translates to:
  /// **'Welcome to ATELIA!'**
  String get welcomeToAtelia;

  /// Welcome message shown on the home screen
  ///
  /// In en, this message translates to:
  /// **'Welcome to Atelia'**
  String get welcomeMessage;

  /// Login button text
  ///
  /// In en, this message translates to:
  /// **'Login'**
  String get login;

  /// Log in button text
  ///
  /// In en, this message translates to:
  /// **'Log In'**
  String get logIn;

  /// Logging in loading text
  ///
  /// In en, this message translates to:
  /// **'Logging In...'**
  String get loggingIn;

  /// Sign up button text
  ///
  /// In en, this message translates to:
  /// **'Sign Up'**
  String get signUp;

  /// Signing up loading text
  ///
  /// In en, this message translates to:
  /// **'Signing Up...'**
  String get signingUp;

  /// Sign in link text
  ///
  /// In en, this message translates to:
  /// **'Sign In'**
  String get signIn;

  /// Email field label
  ///
  /// In en, this message translates to:
  /// **'Email'**
  String get email;

  /// Password field label
  ///
  /// In en, this message translates to:
  /// **'Password'**
  String get password;

  /// Confirm password field label
  ///
  /// In en, this message translates to:
  /// **'Confirm Password'**
  String get confirmPassword;

  /// Full name field label
  ///
  /// In en, this message translates to:
  /// **'Full Name'**
  String get fullName;

  /// Forgot password link text
  ///
  /// In en, this message translates to:
  /// **'Forgot Password?'**
  String get forgotPassword;

  /// Google sign-in button text
  ///
  /// In en, this message translates to:
  /// **'Continue with Google'**
  String get continueWithGoogle;

  /// Apple sign in button text
  ///
  /// In en, this message translates to:
  /// **'Continue with Apple'**
  String get continueWithApple;

  /// Divider text for social login
  ///
  /// In en, this message translates to:
  /// **'Or continue with'**
  String get orContinueWith;

  /// Create account button text
  ///
  /// In en, this message translates to:
  /// **'Create Account'**
  String get createAccount;

  /// Create your account header
  ///
  /// In en, this message translates to:
  /// **'Create your account'**
  String get createYourAccount;

  /// Text for existing users
  ///
  /// In en, this message translates to:
  /// **'Already have an account?'**
  String get alreadyHaveAccount;

  /// Already joined text for signup screen
  ///
  /// In en, this message translates to:
  /// **'Already Joined?'**
  String get alreadyJoined;

  /// Text for new users
  ///
  /// In en, this message translates to:
  /// **'Don\'t have an account?'**
  String get dontHaveAccount;

  /// Join now button text
  ///
  /// In en, this message translates to:
  /// **'Join Now'**
  String get joinNow;

  /// Onboarding screen title
  ///
  /// In en, this message translates to:
  /// **'Welcome to AteliA — Your\nFashion Brand Starts Here.'**
  String get onboardingTitle;

  /// Onboarding screen subtitle
  ///
  /// In en, this message translates to:
  /// **'Turn your ideas into real clothing — with AI-powered design tools and manufacturer support.'**
  String get onboardingSubtitle;

  /// Verification screen title
  ///
  /// In en, this message translates to:
  /// **'Verification'**
  String get verification;

  /// Verification screen description
  ///
  /// In en, this message translates to:
  /// **'Enter your email address and we\'ll send you a verification link to reset your password.'**
  String get verificationDescription;

  /// Send verification link button
  ///
  /// In en, this message translates to:
  /// **'Send Verification Link'**
  String get sendVerificationLink;

  /// Home navigation item
  ///
  /// In en, this message translates to:
  /// **'Home'**
  String get home;

  /// Profile navigation item
  ///
  /// In en, this message translates to:
  /// **'Profile'**
  String get profile;

  /// Settings navigation item
  ///
  /// In en, this message translates to:
  /// **'Settings'**
  String get settings;

  /// Logout button text
  ///
  /// In en, this message translates to:
  /// **'Logout'**
  String get logout;

  /// Logout confirmation dialog message
  ///
  /// In en, this message translates to:
  /// **'Are you sure you want to logout?'**
  String get logoutConfirmation;

  /// Cancel button text
  ///
  /// In en, this message translates to:
  /// **'Cancel'**
  String get cancel;

  /// Confirm button text
  ///
  /// In en, this message translates to:
  /// **'Confirm'**
  String get confirm;

  /// Save button text
  ///
  /// In en, this message translates to:
  /// **'Save'**
  String get save;

  /// Delete button text
  ///
  /// In en, this message translates to:
  /// **'Delete'**
  String get delete;

  /// Edit button text
  ///
  /// In en, this message translates to:
  /// **'Edit'**
  String get edit;

  /// Edit profile screen title
  ///
  /// In en, this message translates to:
  /// **'Edit Profile'**
  String get editProfile;

  /// Download button text
  ///
  /// In en, this message translates to:
  /// **'Download'**
  String get download;

  /// Preview screen title
  ///
  /// In en, this message translates to:
  /// **'Preview'**
  String get preview;

  /// Loading title
  ///
  /// In en, this message translates to:
  /// **'Loading'**
  String get loading;

  /// Error title
  ///
  /// In en, this message translates to:
  /// **'Error'**
  String get error;

  /// Success message title
  ///
  /// In en, this message translates to:
  /// **'Success'**
  String get success;

  /// Retry button text
  ///
  /// In en, this message translates to:
  /// **'Retry'**
  String get retry;

  /// Next button text
  ///
  /// In en, this message translates to:
  /// **'Next'**
  String get next;

  /// Back button text
  ///
  /// In en, this message translates to:
  /// **'Back'**
  String get back;

  /// Done button text
  ///
  /// In en, this message translates to:
  /// **'Done'**
  String get done;

  /// Skip button text
  ///
  /// In en, this message translates to:
  /// **'Skip'**
  String get skip;

  /// Language setting label
  ///
  /// In en, this message translates to:
  /// **'Language'**
  String get language;

  /// English language option
  ///
  /// In en, this message translates to:
  /// **'English'**
  String get english;

  /// French language option
  ///
  /// In en, this message translates to:
  /// **'French'**
  String get french;

  /// Language selection title
  ///
  /// In en, this message translates to:
  /// **'Select Language'**
  String get selectLanguage;

  /// Tech pack label
  ///
  /// In en, this message translates to:
  /// **'Tech Pack'**
  String get techPack;

  /// Design image label
  ///
  /// In en, this message translates to:
  /// **'Design Image'**
  String get designImage;

  /// Tech pack image label with number
  ///
  /// In en, this message translates to:
  /// **'Tech Pack Image {number}'**
  String techPackImageN(int number);

  /// Manufacture suggestions button text
  ///
  /// In en, this message translates to:
  /// **'Manufacture suggestions'**
  String get manufactureSuggestions;

  /// No images message
  ///
  /// In en, this message translates to:
  /// **'No images available to download'**
  String get noImagesAvailable;

  /// Download progress message
  ///
  /// In en, this message translates to:
  /// **'Downloading {current} of {total}...'**
  String downloadingNOfTotal(int current, int total);

  /// Images saved success message
  ///
  /// In en, this message translates to:
  /// **'{count} images saved to gallery in \"Atelia\" album'**
  String imagesSavedToGallery(int count);

  /// My Designs screen title
  ///
  /// In en, this message translates to:
  /// **'My Designs'**
  String get myDesigns;

  /// My Collections screen title
  ///
  /// In en, this message translates to:
  /// **'My Collections'**
  String get myCollections;

  /// See all button text
  ///
  /// In en, this message translates to:
  /// **'See All'**
  String get seeAll;

  /// Start new project button
  ///
  /// In en, this message translates to:
  /// **'Start New Project'**
  String get startNewProject;

  /// Create new design button text
  ///
  /// In en, this message translates to:
  /// **'Create New Design'**
  String get createNewDesign;

  /// Create new project button
  ///
  /// In en, this message translates to:
  /// **'Create New Project'**
  String get createNewProject;

  /// Favorites screen title
  ///
  /// In en, this message translates to:
  /// **'Favorites'**
  String get favorites;

  /// Empty favorites title
  ///
  /// In en, this message translates to:
  /// **'No favorite projects yet'**
  String get noFavoritesYet;

  /// Empty favorites subtitle
  ///
  /// In en, this message translates to:
  /// **'Start creating projects and mark your favorites to see them here.'**
  String get noFavoritesSubtitle;

  /// Home empty state title
  ///
  /// In en, this message translates to:
  /// **'Here to guide you through creating the garment you have in mind.'**
  String get homeEmptyStateTitle;

  /// No search results message
  ///
  /// In en, this message translates to:
  /// **'No results found for \"{query}\"'**
  String noResultsFor(String query);

  /// Search empty state subtitle
  ///
  /// In en, this message translates to:
  /// **'Try adjusting your search terms or create a new project.'**
  String get tryAdjustingSearch;

  /// Clear search button
  ///
  /// In en, this message translates to:
  /// **'Clear Search'**
  String get clearSearch;

  /// Personal information setting
  ///
  /// In en, this message translates to:
  /// **'Personal Information'**
  String get personalInformation;

  /// Subscription plan setting
  ///
  /// In en, this message translates to:
  /// **'Premium Plans'**
  String get subscriptionPlan;

  /// Terms of use setting
  ///
  /// In en, this message translates to:
  /// **'Terms of use'**
  String get termsOfUse;

  /// Privacy policy setting
  ///
  /// In en, this message translates to:
  /// **'Privacy Policy'**
  String get privacyPolicy;

  /// Analytics toggle label
  ///
  /// In en, this message translates to:
  /// **'Allow analytics'**
  String get allowAnalytics;

  /// Analytics toggle description
  ///
  /// In en, this message translates to:
  /// **'We record sessions to improve your experience. Turn this off to stop all analytics and recordings.'**
  String get analyticsDescription;

  /// Update button
  ///
  /// In en, this message translates to:
  /// **'Update'**
  String get update;

  /// Updating loading text
  ///
  /// In en, this message translates to:
  /// **'Updating...'**
  String get updating;

  /// Subscribe screen title
  ///
  /// In en, this message translates to:
  /// **'Premium Plans'**
  String get subscribe;

  /// Choose plan title
  ///
  /// In en, this message translates to:
  /// **'Choose Your Plan'**
  String get chooseYourPlan;

  /// Subscription subtitle
  ///
  /// In en, this message translates to:
  /// **'Start for free. Upgrade anytime.'**
  String get startForFree;

  /// Current plan badge
  ///
  /// In en, this message translates to:
  /// **'Current'**
  String get current;

  /// Free plan name
  ///
  /// In en, this message translates to:
  /// **'Free'**
  String get free;

  /// Starter plan name
  ///
  /// In en, this message translates to:
  /// **'Starter'**
  String get starter;

  /// Pro plan name
  ///
  /// In en, this message translates to:
  /// **'Pro'**
  String get pro;

  /// Monthly billing option
  ///
  /// In en, this message translates to:
  /// **'Monthly'**
  String get monthly;

  /// Yearly billing option with savings
  ///
  /// In en, this message translates to:
  /// **'Yearly (Save 17%)'**
  String get yearlySavePercent;

  /// Features include label
  ///
  /// In en, this message translates to:
  /// **'Features include:'**
  String get featuresInclude;

  /// Starter plan description
  ///
  /// In en, this message translates to:
  /// **'Ideal for launching your first productions.'**
  String get idealForLaunching;

  /// Pro plan description
  ///
  /// In en, this message translates to:
  /// **'For creators ready to scale their vision.'**
  String get forCreatorsReady;

  /// Free plan description
  ///
  /// In en, this message translates to:
  /// **'Perfect to test, imagine, and create freely.'**
  String get perfectToTest;

  /// Techpacks per month feature
  ///
  /// In en, this message translates to:
  /// **'{count} techpacks per month'**
  String techpacksPerMonth(int count);

  /// Techpacks per month for yearly plans
  ///
  /// In en, this message translates to:
  /// **'{count} techpacks per month ({total} total per year)'**
  String techpacksPerMonthYearly(int count, int total);

  /// Unlimited 3D visualization feature
  ///
  /// In en, this message translates to:
  /// **'Unlimited 3D visualization'**
  String get unlimited3DVisualization;

  /// Custom PDF export feature
  ///
  /// In en, this message translates to:
  /// **'Custom PDF export (with user\'s logo)'**
  String get customPdfExport;

  /// Fully customized PDF exports feature
  ///
  /// In en, this message translates to:
  /// **'Fully customized PDF exports'**
  String get fullyCustomizedPdfExports;

  /// Access to manufacturers feature
  ///
  /// In en, this message translates to:
  /// **'Access to manufacturers list'**
  String get accessToManufacturers;

  /// Free plan designs limit
  ///
  /// In en, this message translates to:
  /// **'3 AI design generations / month'**
  String get upTo10Designs;

  /// Starter plan design limit
  ///
  /// In en, this message translates to:
  /// **'5 AI design generations per month'**
  String get starterDesignLimit;

  /// Starter plan monthly price
  ///
  /// In en, this message translates to:
  /// **'Starter €19.99/Month'**
  String get starterMonthlyPrice;

  /// Starter plan yearly price
  ///
  /// In en, this message translates to:
  /// **'Starter €199.99/Year'**
  String get starterYearlyPrice;

  /// Pro plan monthly price
  ///
  /// In en, this message translates to:
  /// **'Pro €49.99/Month'**
  String get proMonthlyPrice;

  /// Pro plan yearly price
  ///
  /// In en, this message translates to:
  /// **'Pro €499.99/Year'**
  String get proYearlyPrice;

  /// Pro plan design limit
  ///
  /// In en, this message translates to:
  /// **'12 AI design generations per month'**
  String get proDesignLimit;

  /// Studio plan monthly price
  ///
  /// In en, this message translates to:
  /// **'Studio €99.99/Month'**
  String get studioMonthlyPrice;

  /// Studio plan yearly price
  ///
  /// In en, this message translates to:
  /// **'Studio €999.99/Year'**
  String get studioYearlyPrice;

  /// Studio plan design limit
  ///
  /// In en, this message translates to:
  /// **'25 AI design generations per month'**
  String get studioDesignLimit;

  /// Per month suffix for pricing
  ///
  /// In en, this message translates to:
  /// **'/Month'**
  String get perMonth;

  /// Per year suffix for pricing
  ///
  /// In en, this message translates to:
  /// **'/Year'**
  String get perYear;

  /// 3D visualization included feature
  ///
  /// In en, this message translates to:
  /// **'3D Visualization included'**
  String get visualization3DIncluded;

  /// No techpack generation feature
  ///
  /// In en, this message translates to:
  /// **'No techpack generation'**
  String get noTechpackGeneration;

  /// No PDF export feature
  ///
  /// In en, this message translates to:
  /// **'No PDF export'**
  String get noPdfExport;

  /// No access to manufacturers feature
  ///
  /// In en, this message translates to:
  /// **'No access to manufacturers'**
  String get noAccessToManufacturers;

  /// Start button
  ///
  /// In en, this message translates to:
  /// **'Start'**
  String get start;

  /// Current plan button text
  ///
  /// In en, this message translates to:
  /// **'Current Plan'**
  String get currentPlan;

  /// Cancel monthly plan first message
  ///
  /// In en, this message translates to:
  /// **'Cancel Monthly plan first'**
  String get cancelMonthlyPlanFirst;

  /// Cancel yearly plan first message
  ///
  /// In en, this message translates to:
  /// **'Cancel Yearly plan first'**
  String get cancelYearlyPlanFirst;

  /// Cancel current plan first message
  ///
  /// In en, this message translates to:
  /// **'Cancel current plan first'**
  String get cancelSubscriptionFirst;

  /// Upgrade plan button
  ///
  /// In en, this message translates to:
  /// **'Upgrade'**
  String get upgradePlan;

  /// Cancel subscription button
  ///
  /// In en, this message translates to:
  /// **'Cancel Subscription'**
  String get cancelSubscription;

  /// Keep subscription button
  ///
  /// In en, this message translates to:
  /// **'Keep Subscription'**
  String get keepSubscription;

  /// Cancel subscription dialog title
  ///
  /// In en, this message translates to:
  /// **'Cancel Subscription'**
  String get cancelSubscriptionTitle;

  /// Cancel subscription dialog message
  ///
  /// In en, this message translates to:
  /// **'We\'re sorry to see you go. Please let us know why:\n\n⚠️ Warning: Upon canceling, any purchased extra designs and techpacks will be lost.'**
  String get cancelSubscriptionMessage;

  /// Please specify placeholder
  ///
  /// In en, this message translates to:
  /// **'Please specify...'**
  String get pleaseSpecify;

  /// Terms agreement text
  ///
  /// In en, this message translates to:
  /// **'By placing this order, you agree to the '**
  String get termsAgreement;

  /// Terms of service link
  ///
  /// In en, this message translates to:
  /// **'Terms of Service'**
  String get termsOfService;

  /// And connector
  ///
  /// In en, this message translates to:
  /// **' and\n'**
  String get and;

  /// Free plan upgrade message
  ///
  /// In en, this message translates to:
  /// **'You can upgrade your plan to generate tech PDF\'s and access to manufacturers'**
  String get upgradeMessage;

  /// Free per month label
  ///
  /// In en, this message translates to:
  /// **'Free/Month'**
  String get freePerMonth;

  /// Create screen title
  ///
  /// In en, this message translates to:
  /// **'Gathering the Creative Brief '**
  String get gatheringCreativeBrief;

  /// Create screen subtitle
  ///
  /// In en, this message translates to:
  /// **'As your expert virtual fashion designer.'**
  String get asYourExpertDesigner;

  /// Create screen description
  ///
  /// In en, this message translates to:
  /// **'I\'m here to help you create a custom garment or collection.'**
  String get hereToHelpCreate;

  /// Get started button
  ///
  /// In en, this message translates to:
  /// **'Get Started'**
  String get getStarted;

  /// Info message title
  ///
  /// In en, this message translates to:
  /// **'Info'**
  String get info;

  /// Local assets message
  ///
  /// In en, this message translates to:
  /// **'All images are local assets and cannot be downloaded'**
  String get allImagesLocalAssets;

  /// Partial success message title
  ///
  /// In en, this message translates to:
  /// **'Partial Success'**
  String get partialSuccess;

  /// Partial download message
  ///
  /// In en, this message translates to:
  /// **'{saved} images saved to gallery. {failed} failed.'**
  String imagesSavedFailed(int saved, int failed);

  /// Failed to save images message
  ///
  /// In en, this message translates to:
  /// **'Failed to save images to gallery.'**
  String get failedToSaveImages;

  /// Download failed error message
  ///
  /// In en, this message translates to:
  /// **'Download failed: {error}'**
  String downloadFailed(String error);

  /// Failed to download message
  ///
  /// In en, this message translates to:
  /// **'Failed to download images: {error}'**
  String failedToDownload(String error);

  /// Designs counter display
  ///
  /// In en, this message translates to:
  /// **'{display}'**
  String designs(String display);

  /// Designs usage counter
  ///
  /// In en, this message translates to:
  /// **'Designs used: {used} / {total} this month'**
  String designsUsed(String used, String total);

  /// Techpacks usage counter with monthly period
  ///
  /// In en, this message translates to:
  /// **'Techpacks used: {used} / {total} this month'**
  String techpacksUsed(String used, String total);

  /// Other option in cancellation reasons
  ///
  /// In en, this message translates to:
  /// **'Other'**
  String get other;

  /// Cancellation reason - too expensive
  ///
  /// In en, this message translates to:
  /// **'Too expensive'**
  String get tooExpensive;

  /// Cancellation reason - not using enough
  ///
  /// In en, this message translates to:
  /// **'Not using it enough'**
  String get notUsingEnough;

  /// Cancellation reason - missing features
  ///
  /// In en, this message translates to:
  /// **'Missing features I need'**
  String get missingFeatures;

  /// Cancellation reason - found alternative
  ///
  /// In en, this message translates to:
  /// **'Found a better alternative'**
  String get foundBetterAlternative;

  /// Cancellation reason - technical issues
  ///
  /// In en, this message translates to:
  /// **'Technical issues'**
  String get technicalIssues;

  /// All images are local message
  ///
  /// In en, this message translates to:
  /// **'All images are local assets and cannot be downloaded'**
  String get allImagesLocal;

  /// Downloading progress message
  ///
  /// In en, this message translates to:
  /// **'Downloading {current} of {total}...'**
  String downloading(int current, int total);

  /// Failed to download error message
  ///
  /// In en, this message translates to:
  /// **'Failed to download images: {error}'**
  String failedToDownloadImages(String error);

  /// Partial download success message
  ///
  /// In en, this message translates to:
  /// **'{downloaded} images saved to gallery. {failed} failed.'**
  String partialDownloadSuccess(int downloaded, int failed);

  /// Tech pack image label
  ///
  /// In en, this message translates to:
  /// **'Tech Pack Image {number}'**
  String techPackImage(int number);

  /// Error text when image fails to load
  ///
  /// In en, this message translates to:
  /// **'Image failed'**
  String get imageFailed;

  /// Search placeholder text
  ///
  /// In en, this message translates to:
  /// **'Search Designs'**
  String get searchDesigns;

  /// Email validation error
  ///
  /// In en, this message translates to:
  /// **'Email is required'**
  String get emailIsRequired;

  /// Email format validation error
  ///
  /// In en, this message translates to:
  /// **'Enter a valid email'**
  String get enterValidEmail;

  /// Password validation error
  ///
  /// In en, this message translates to:
  /// **'Password is required'**
  String get passwordIsRequired;

  /// Password length validation error
  ///
  /// In en, this message translates to:
  /// **'Password must be at least 8 characters'**
  String get passwordMinLength;

  /// Name validation error
  ///
  /// In en, this message translates to:
  /// **'Name is required'**
  String get nameIsRequired;

  /// Confirm password validation error
  ///
  /// In en, this message translates to:
  /// **'Confirm your password'**
  String get confirmYourPassword;

  /// Password mismatch validation error
  ///
  /// In en, this message translates to:
  /// **'Passwords do not match'**
  String get passwordsDoNotMatch;

  /// Login success message
  ///
  /// In en, this message translates to:
  /// **'User successfully logged in'**
  String get userSuccessfullyLoggedIn;

  /// Google sign in success message
  ///
  /// In en, this message translates to:
  /// **'Successfully signed in with Google'**
  String get successfullySignedInWithGoogle;

  /// Apple sign in success message
  ///
  /// In en, this message translates to:
  /// **'Successfully signed in with Apple'**
  String get successfullySignedInWithApple;

  /// Signup success message
  ///
  /// In en, this message translates to:
  /// **'User registered successfully'**
  String get userRegisteredSuccessfully;

  /// Duplicate email error
  ///
  /// In en, this message translates to:
  /// **'User already exists with this email'**
  String get userAlreadyExistsWithEmail;

  /// Password reset link sent title
  ///
  /// In en, this message translates to:
  /// **'Verification Link Sent'**
  String get verificationLinkSent;

  /// Password reset link sent message
  ///
  /// In en, this message translates to:
  /// **'A password reset link has been sent to {email}.'**
  String passwordResetLinkSent(String email);

  /// Password reset link error
  ///
  /// In en, this message translates to:
  /// **'Failed to send verification link. Please try again.'**
  String get failedToSendVerificationLink;

  /// Error updating favorite
  ///
  /// In en, this message translates to:
  /// **'Failed to update favorite status'**
  String get failedToUpdateFavorite;

  /// Error loading profile
  ///
  /// In en, this message translates to:
  /// **'Failed to load profile data'**
  String get failedToLoadProfile;

  /// Profile update success
  ///
  /// In en, this message translates to:
  /// **'Profile updated successfully'**
  String get profileUpdatedSuccessfully;

  /// Profile update error
  ///
  /// In en, this message translates to:
  /// **'Failed to update profile. Please try again.'**
  String get failedToUpdateProfile;

  /// Profile update exception
  ///
  /// In en, this message translates to:
  /// **'An error occurred while updating profile'**
  String get errorUpdatingProfile;

  /// Name field validation
  ///
  /// In en, this message translates to:
  /// **'Please enter your full name'**
  String get pleaseEnterFullName;

  /// Analytics toggle on title
  ///
  /// In en, this message translates to:
  /// **'Analytics enabled'**
  String get analyticsEnabled;

  /// Analytics toggle off title
  ///
  /// In en, this message translates to:
  /// **'Analytics disabled'**
  String get analyticsDisabled;

  /// Analytics enabled message
  ///
  /// In en, this message translates to:
  /// **'Helps improve the app. Session replays remain sampled.'**
  String get analyticsEnabledMessage;

  /// Analytics disabled message
  ///
  /// In en, this message translates to:
  /// **'We will stop sending analytics and session replays.'**
  String get analyticsDisabledMessage;

  /// Info snackbar title
  ///
  /// In en, this message translates to:
  /// **'Info'**
  String get infoMessage;

  /// Free plan info message
  ///
  /// In en, this message translates to:
  /// **'You are on the free plan'**
  String get youAreOnFreePlan;

  /// Subscription success title
  ///
  /// In en, this message translates to:
  /// **'Success! 🎉'**
  String get subscriptionSuccessTitle;

  /// Welcome message for new plan
  ///
  /// In en, this message translates to:
  /// **'Welcome to {plan}! You can now generate techpacks.'**
  String welcomeToPlan(String plan);

  /// Subscription active title
  ///
  /// In en, this message translates to:
  /// **'Subscription Active! 🎉'**
  String get subscriptionActive;

  /// Techpack generation enabled message
  ///
  /// In en, this message translates to:
  /// **'You can now generate your techpack. Click \"Generate Tech Pack\" button.'**
  String get canNowGenerateTechpack;

  /// Subscription error
  ///
  /// In en, this message translates to:
  /// **'Failed to complete subscription'**
  String get failedToCompleteSubscription;

  /// Cancellation success
  ///
  /// In en, this message translates to:
  /// **'Subscription cancelled successfully'**
  String get subscriptionCancelledSuccessfully;

  /// Cancellation error
  ///
  /// In en, this message translates to:
  /// **'Failed to cancel subscription'**
  String get failedToCancelSubscription;

  /// Subscription load error
  ///
  /// In en, this message translates to:
  /// **'Failed to load subscription details'**
  String get failedToLoadSubscription;

  /// Generic error with details
  ///
  /// In en, this message translates to:
  /// **'An error occurred: {error}'**
  String anErrorOccurred(String error);

  /// Creative Brief screen title
  ///
  /// In en, this message translates to:
  /// **'Creative Brief'**
  String get creativeBrief;

  /// Gathering brief screen title
  ///
  /// In en, this message translates to:
  /// **'Gathering the Creative Brief'**
  String get gatheringTheCreativeBrief;

  /// Gathering brief subtitle
  ///
  /// In en, this message translates to:
  /// **'As your expert virtual fashion designer.'**
  String get asYourExpertVirtualFashionDesigner;

  /// Gathering brief description
  ///
  /// In en, this message translates to:
  /// **'I\'m here to help you create a custom garment or collection.'**
  String get imHereToHelpCreateCustomGarment;

  /// Creative Brief question: garment type
  ///
  /// In en, this message translates to:
  /// **'What type of garment are you creating? 👕'**
  String get cbQuestionGarmentType;

  /// Creative Brief question: style
  ///
  /// In en, this message translates to:
  /// **'What is the overall desired style? ✨'**
  String get cbQuestionStyle;

  /// Creative Brief question: target audience
  ///
  /// In en, this message translates to:
  /// **'Who is this garment intended for? 👤'**
  String get cbQuestionTargetAudience;

  /// Creative Brief question: occasion
  ///
  /// In en, this message translates to:
  /// **'What is the intended occasion or use? 📅'**
  String get cbQuestionOccasion;

  /// Creative Brief question: inspiration
  ///
  /// In en, this message translates to:
  /// **'Do you have any visual inspirations or references? 🖼️'**
  String get cbQuestionInspiration;

  /// Creative Brief question: colors
  ///
  /// In en, this message translates to:
  /// **'What colors and patterns should the design include? 🎨'**
  String get cbQuestionColors;

  /// Creative Brief question: fabrics
  ///
  /// In en, this message translates to:
  /// **'Which fabric or material would you like to use? 🧵'**
  String get cbQuestionFabrics;

  /// Garment category: Tops
  ///
  /// In en, this message translates to:
  /// **'Tops'**
  String get cbCategoryTops;

  /// Garment category: Bottoms
  ///
  /// In en, this message translates to:
  /// **'Bottoms'**
  String get cbCategoryBottoms;

  /// Garment category: Dresses
  ///
  /// In en, this message translates to:
  /// **'Dresses'**
  String get cbCategoryDresses;

  /// Garment category: Jumpsuits
  ///
  /// In en, this message translates to:
  /// **'Jumpsuits'**
  String get cbCategoryJumpsuits;

  /// Garment category: Outerwear
  ///
  /// In en, this message translates to:
  /// **'Outerwear'**
  String get cbCategoryOuterwear;

  /// Garment category: Sportswear
  ///
  /// In en, this message translates to:
  /// **'Sportswear'**
  String get cbCategorySportswear;

  /// Garment category: Accessories
  ///
  /// In en, this message translates to:
  /// **'Accessories'**
  String get cbCategoryAccessories;

  /// Fabric category: Cotton
  ///
  /// In en, this message translates to:
  /// **'Cotton'**
  String get cbCategoryCotton;

  /// Fabric category: Wool
  ///
  /// In en, this message translates to:
  /// **'Wool'**
  String get cbCategoryWool;

  /// Fabric category: Silk
  ///
  /// In en, this message translates to:
  /// **'Silk'**
  String get cbCategorySilk;

  /// Fabric category: Linen
  ///
  /// In en, this message translates to:
  /// **'Linen'**
  String get cbCategoryLinen;

  /// Fabric category: Synthetic
  ///
  /// In en, this message translates to:
  /// **'Synthetic'**
  String get cbCategorySynthetic;

  /// Fabric category: Eco options
  ///
  /// In en, this message translates to:
  /// **'Eco options'**
  String get cbCategoryEcoOptions;

  /// Fabric category: Leather/Faux leather
  ///
  /// In en, this message translates to:
  /// **'Leather/Faux leather'**
  String get cbCategoryLeatherFauxLeather;

  /// Fabric category: Knitwear
  ///
  /// In en, this message translates to:
  /// **'Knitwear'**
  String get cbCategoryKnitwear;

  /// Colors category: Prints
  ///
  /// In en, this message translates to:
  /// **'Prints'**
  String get cbCategoryPrints;

  /// Colors category: Techniques
  ///
  /// In en, this message translates to:
  /// **'Techniques'**
  String get cbCategoryTechniques;

  /// No description provided for @cbOptionTShirt.
  ///
  /// In en, this message translates to:
  /// **'T-shirt'**
  String get cbOptionTShirt;

  /// No description provided for @cbOptionShirt.
  ///
  /// In en, this message translates to:
  /// **'Shirt'**
  String get cbOptionShirt;

  /// No description provided for @cbOptionBlouse.
  ///
  /// In en, this message translates to:
  /// **'Blouse'**
  String get cbOptionBlouse;

  /// No description provided for @cbOptionHoodie.
  ///
  /// In en, this message translates to:
  /// **'Hoodie'**
  String get cbOptionHoodie;

  /// No description provided for @cbOptionJacket.
  ///
  /// In en, this message translates to:
  /// **'Jacket'**
  String get cbOptionJacket;

  /// No description provided for @cbOptionCoat.
  ///
  /// In en, this message translates to:
  /// **'Coat'**
  String get cbOptionCoat;

  /// No description provided for @cbOptionVest.
  ///
  /// In en, this message translates to:
  /// **'Vest'**
  String get cbOptionVest;

  /// No description provided for @cbOptionTankTop.
  ///
  /// In en, this message translates to:
  /// **'Tank top'**
  String get cbOptionTankTop;

  /// No description provided for @cbOptionCropTop.
  ///
  /// In en, this message translates to:
  /// **'Crop top'**
  String get cbOptionCropTop;

  /// No description provided for @cbOptionSweater.
  ///
  /// In en, this message translates to:
  /// **'Sweater'**
  String get cbOptionSweater;

  /// No description provided for @cbOptionPants.
  ///
  /// In en, this message translates to:
  /// **'Pants'**
  String get cbOptionPants;

  /// No description provided for @cbOptionJeans.
  ///
  /// In en, this message translates to:
  /// **'Jeans'**
  String get cbOptionJeans;

  /// No description provided for @cbOptionSkirts.
  ///
  /// In en, this message translates to:
  /// **'Skirts'**
  String get cbOptionSkirts;

  /// No description provided for @cbOptionShorts.
  ///
  /// In en, this message translates to:
  /// **'Shorts'**
  String get cbOptionShorts;

  /// No description provided for @cbOptionLeggings.
  ///
  /// In en, this message translates to:
  /// **'Leggings'**
  String get cbOptionLeggings;

  /// No description provided for @cbOptionCulottes.
  ///
  /// In en, this message translates to:
  /// **'Culottes'**
  String get cbOptionCulottes;

  /// No description provided for @cbOptionPalazzo.
  ///
  /// In en, this message translates to:
  /// **'Palazzo'**
  String get cbOptionPalazzo;

  /// No description provided for @cbOptionJoggers.
  ///
  /// In en, this message translates to:
  /// **'Joggers'**
  String get cbOptionJoggers;

  /// No description provided for @cbOptionCasualDress.
  ///
  /// In en, this message translates to:
  /// **'Casual dress'**
  String get cbOptionCasualDress;

  /// No description provided for @cbOptionEvening.
  ///
  /// In en, this message translates to:
  /// **'Evening'**
  String get cbOptionEvening;

  /// No description provided for @cbOptionCocktailDress.
  ///
  /// In en, this message translates to:
  /// **'Cocktail dress'**
  String get cbOptionCocktailDress;

  /// No description provided for @cbOptionGown.
  ///
  /// In en, this message translates to:
  /// **'Gown'**
  String get cbOptionGown;

  /// No description provided for @cbOptionMaxiDress.
  ///
  /// In en, this message translates to:
  /// **'Maxi dress'**
  String get cbOptionMaxiDress;

  /// No description provided for @cbOptionMidiDress.
  ///
  /// In en, this message translates to:
  /// **'Midi dress'**
  String get cbOptionMidiDress;

  /// No description provided for @cbOptionMiniDress.
  ///
  /// In en, this message translates to:
  /// **'Mini dress'**
  String get cbOptionMiniDress;

  /// No description provided for @cbOptionJumpsuit.
  ///
  /// In en, this message translates to:
  /// **'Jumpsuit'**
  String get cbOptionJumpsuit;

  /// No description provided for @cbOptionRomper.
  ///
  /// In en, this message translates to:
  /// **'Romper'**
  String get cbOptionRomper;

  /// No description provided for @cbOptionPlaysuit.
  ///
  /// In en, this message translates to:
  /// **'Playsuit'**
  String get cbOptionPlaysuit;

  /// No description provided for @cbOptionOveralls.
  ///
  /// In en, this message translates to:
  /// **'Overalls'**
  String get cbOptionOveralls;

  /// No description provided for @cbOptionTrenchCoat.
  ///
  /// In en, this message translates to:
  /// **'Trench coat'**
  String get cbOptionTrenchCoat;

  /// No description provided for @cbOptionBomberJacket.
  ///
  /// In en, this message translates to:
  /// **'Bomber jacket'**
  String get cbOptionBomberJacket;

  /// No description provided for @cbOptionBlazer.
  ///
  /// In en, this message translates to:
  /// **'Blazer'**
  String get cbOptionBlazer;

  /// No description provided for @cbOptionPufferJacket.
  ///
  /// In en, this message translates to:
  /// **'Puffer jacket'**
  String get cbOptionPufferJacket;

  /// No description provided for @cbOptionTracksuit.
  ///
  /// In en, this message translates to:
  /// **'Tracksuit'**
  String get cbOptionTracksuit;

  /// No description provided for @cbOptionActivewear.
  ///
  /// In en, this message translates to:
  /// **'Activewear'**
  String get cbOptionActivewear;

  /// No description provided for @cbOptionSwimwear.
  ///
  /// In en, this message translates to:
  /// **'Swimwear'**
  String get cbOptionSwimwear;

  /// No description provided for @cbOptionHat.
  ///
  /// In en, this message translates to:
  /// **'Hat'**
  String get cbOptionHat;

  /// No description provided for @cbOptionBag.
  ///
  /// In en, this message translates to:
  /// **'Bag'**
  String get cbOptionBag;

  /// No description provided for @cbOptionScarf.
  ///
  /// In en, this message translates to:
  /// **'Scarf'**
  String get cbOptionScarf;

  /// No description provided for @cbOptionGloves.
  ///
  /// In en, this message translates to:
  /// **'Gloves'**
  String get cbOptionGloves;

  /// No description provided for @cbOptionCasual.
  ///
  /// In en, this message translates to:
  /// **'Casual'**
  String get cbOptionCasual;

  /// No description provided for @cbOptionChic.
  ///
  /// In en, this message translates to:
  /// **'Chic'**
  String get cbOptionChic;

  /// No description provided for @cbOptionSporty.
  ///
  /// In en, this message translates to:
  /// **'Sporty'**
  String get cbOptionSporty;

  /// No description provided for @cbOptionStreetwear.
  ///
  /// In en, this message translates to:
  /// **'Streetwear'**
  String get cbOptionStreetwear;

  /// No description provided for @cbOptionWorkwear.
  ///
  /// In en, this message translates to:
  /// **'Workwear'**
  String get cbOptionWorkwear;

  /// No description provided for @cbOptionWoman.
  ///
  /// In en, this message translates to:
  /// **'Woman'**
  String get cbOptionWoman;

  /// No description provided for @cbOptionMan.
  ///
  /// In en, this message translates to:
  /// **'Man'**
  String get cbOptionMan;

  /// No description provided for @cbOptionChild.
  ///
  /// In en, this message translates to:
  /// **'Child'**
  String get cbOptionChild;

  /// No description provided for @cbOptionUnisex.
  ///
  /// In en, this message translates to:
  /// **'Unisex'**
  String get cbOptionUnisex;

  /// No description provided for @cbOptionTargetAge.
  ///
  /// In en, this message translates to:
  /// **'Target Age'**
  String get cbOptionTargetAge;

  /// No description provided for @cbOptionEverydayWear.
  ///
  /// In en, this message translates to:
  /// **'Everyday wear'**
  String get cbOptionEverydayWear;

  /// No description provided for @cbOptionSpecialEvent.
  ///
  /// In en, this message translates to:
  /// **'Special event'**
  String get cbOptionSpecialEvent;

  /// No description provided for @cbOptionSports.
  ///
  /// In en, this message translates to:
  /// **'Sports'**
  String get cbOptionSports;

  /// No description provided for @cbOptionActivity.
  ///
  /// In en, this message translates to:
  /// **'Activity'**
  String get cbOptionActivity;

  /// No description provided for @cbOptionFloral.
  ///
  /// In en, this message translates to:
  /// **'Floral'**
  String get cbOptionFloral;

  /// No description provided for @cbOptionAbstract.
  ///
  /// In en, this message translates to:
  /// **'Abstract'**
  String get cbOptionAbstract;

  /// No description provided for @cbOptionCamouflage.
  ///
  /// In en, this message translates to:
  /// **'Camouflage'**
  String get cbOptionCamouflage;

  /// No description provided for @cbOptionStripes.
  ///
  /// In en, this message translates to:
  /// **'Stripes'**
  String get cbOptionStripes;

  /// No description provided for @cbOptionPolkaDots.
  ///
  /// In en, this message translates to:
  /// **'Polka dots'**
  String get cbOptionPolkaDots;

  /// No description provided for @cbOptionTieDye.
  ///
  /// In en, this message translates to:
  /// **'Tie-dye'**
  String get cbOptionTieDye;

  /// No description provided for @cbOptionColorBlocking.
  ///
  /// In en, this message translates to:
  /// **'Color blocking'**
  String get cbOptionColorBlocking;

  /// No description provided for @cbOptionGradientOmbre.
  ///
  /// In en, this message translates to:
  /// **'Gradient/Ombré'**
  String get cbOptionGradientOmbre;

  /// No description provided for @cbOptionEmbroidery.
  ///
  /// In en, this message translates to:
  /// **'Embroidery'**
  String get cbOptionEmbroidery;

  /// No description provided for @cbOptionJacquard.
  ///
  /// In en, this message translates to:
  /// **'Jacquard'**
  String get cbOptionJacquard;

  /// No description provided for @cbOptionLightweight.
  ///
  /// In en, this message translates to:
  /// **'Lightweight (poplin, voile)'**
  String get cbOptionLightweight;

  /// No description provided for @cbOptionMedium.
  ///
  /// In en, this message translates to:
  /// **'Medium (twill)'**
  String get cbOptionMedium;

  /// No description provided for @cbOptionHeavy.
  ///
  /// In en, this message translates to:
  /// **'Heavy (denim, canvas)'**
  String get cbOptionHeavy;

  /// No description provided for @cbOptionMerino.
  ///
  /// In en, this message translates to:
  /// **'Merino'**
  String get cbOptionMerino;

  /// No description provided for @cbOptionCashmere.
  ///
  /// In en, this message translates to:
  /// **'Cashmere'**
  String get cbOptionCashmere;

  /// No description provided for @cbOptionTweed.
  ///
  /// In en, this message translates to:
  /// **'Tweed'**
  String get cbOptionTweed;

  /// No description provided for @cbOptionFelt.
  ///
  /// In en, this message translates to:
  /// **'Felt'**
  String get cbOptionFelt;

  /// No description provided for @cbOptionSatin.
  ///
  /// In en, this message translates to:
  /// **'Satin'**
  String get cbOptionSatin;

  /// No description provided for @cbOptionChiffon.
  ///
  /// In en, this message translates to:
  /// **'Chiffon'**
  String get cbOptionChiffon;

  /// No description provided for @cbOptionOrganza.
  ///
  /// In en, this message translates to:
  /// **'Organza'**
  String get cbOptionOrganza;

  /// No description provided for @cbOptionPlain.
  ///
  /// In en, this message translates to:
  /// **'Plain'**
  String get cbOptionPlain;

  /// No description provided for @cbOptionTextured.
  ///
  /// In en, this message translates to:
  /// **'Textured'**
  String get cbOptionTextured;

  /// No description provided for @cbOptionBlended.
  ///
  /// In en, this message translates to:
  /// **'Blended'**
  String get cbOptionBlended;

  /// No description provided for @cbOptionPolyester.
  ///
  /// In en, this message translates to:
  /// **'Polyester'**
  String get cbOptionPolyester;

  /// No description provided for @cbOptionNylon.
  ///
  /// In en, this message translates to:
  /// **'Nylon'**
  String get cbOptionNylon;

  /// No description provided for @cbOptionSpandex.
  ///
  /// In en, this message translates to:
  /// **'Spandex'**
  String get cbOptionSpandex;

  /// No description provided for @cbOptionNeoprene.
  ///
  /// In en, this message translates to:
  /// **'Neoprene'**
  String get cbOptionNeoprene;

  /// No description provided for @cbOptionOrganicCotton.
  ///
  /// In en, this message translates to:
  /// **'Organic cotton'**
  String get cbOptionOrganicCotton;

  /// No description provided for @cbOptionRecycledPolyester.
  ///
  /// In en, this message translates to:
  /// **'Recycled polyester'**
  String get cbOptionRecycledPolyester;

  /// No description provided for @cbOptionBamboo.
  ///
  /// In en, this message translates to:
  /// **'Bamboo'**
  String get cbOptionBamboo;

  /// No description provided for @cbOptionHemp.
  ///
  /// In en, this message translates to:
  /// **'Hemp'**
  String get cbOptionHemp;

  /// No description provided for @cbOptionLeather.
  ///
  /// In en, this message translates to:
  /// **'Leather'**
  String get cbOptionLeather;

  /// No description provided for @cbOptionFauxLeather.
  ///
  /// In en, this message translates to:
  /// **'Faux leather'**
  String get cbOptionFauxLeather;

  /// No description provided for @cbOptionJersey.
  ///
  /// In en, this message translates to:
  /// **'Jersey'**
  String get cbOptionJersey;

  /// No description provided for @cbOptionRibKnit.
  ///
  /// In en, this message translates to:
  /// **'Rib knit'**
  String get cbOptionRibKnit;

  /// No description provided for @cbOptionInterlock.
  ///
  /// In en, this message translates to:
  /// **'Interlock'**
  String get cbOptionInterlock;

  /// Custom option label
  ///
  /// In en, this message translates to:
  /// **'Custom'**
  String get cbOptionCustom;

  /// Placeholder for custom answer input
  ///
  /// In en, this message translates to:
  /// **'Enter your custom answer...'**
  String get enterYourCustomAnswer;

  /// Placeholder for custom category input
  ///
  /// In en, this message translates to:
  /// **'Enter custom {category}...'**
  String enterCustom(String category);

  /// Placeholder for colors input
  ///
  /// In en, this message translates to:
  /// **'Enter preferred colors...'**
  String get enterPreferredColors;

  /// Placeholder for image upload
  ///
  /// In en, this message translates to:
  /// **'Upload visual inspiration images (optional)'**
  String get uploadVisualInspirationImages;

  /// Placeholder for inspiration image upload
  ///
  /// In en, this message translates to:
  /// **'Upload visual inspiration images (optional)'**
  String get uploadInspirationImages;

  /// Skip button text for image upload
  ///
  /// In en, this message translates to:
  /// **'Skip - No reference images'**
  String get skipNoReferenceImages;

  /// Upload image button text
  ///
  /// In en, this message translates to:
  /// **'Upload image'**
  String get uploadImage;

  /// Next steps button text
  ///
  /// In en, this message translates to:
  /// **'Next Steps'**
  String get nextSteps;

  /// Button text to add more images
  ///
  /// In en, this message translates to:
  /// **'Add more images'**
  String get addMoreImages;

  /// Instruction text for image selection
  ///
  /// In en, this message translates to:
  /// **'Tap to select from gallery'**
  String get tapToSelectFromGallery;

  /// Success message for image added
  ///
  /// In en, this message translates to:
  /// **'Image Added'**
  String get imageAdded;

  /// Success message details for image added
  ///
  /// In en, this message translates to:
  /// **'Image added successfully'**
  String get imageAddedSuccessfully;

  /// Error message for failed image pick
  ///
  /// In en, this message translates to:
  /// **'Failed to pick image. Please try again.'**
  String get failedToPickImage;

  /// Error text for broken image
  ///
  /// In en, this message translates to:
  /// **'Error'**
  String get imageError;

  /// Success message for image selection
  ///
  /// In en, this message translates to:
  /// **'Image Selected'**
  String get imageSelected;

  /// Success message details for image selection
  ///
  /// In en, this message translates to:
  /// **'Image selected successfully'**
  String get imageSelectedSuccessfully;

  /// Error message for failed image load
  ///
  /// In en, this message translates to:
  /// **'Failed to load image'**
  String get failedToLoadImage;

  /// Change button text
  ///
  /// In en, this message translates to:
  /// **'Change'**
  String get change;

  /// Section title for solid colors
  ///
  /// In en, this message translates to:
  /// **'Solid colors'**
  String get solidColors;

  /// Button text to pick a color
  ///
  /// In en, this message translates to:
  /// **'Pick a color'**
  String get pickAColor;

  /// Dialog title for color picker
  ///
  /// In en, this message translates to:
  /// **'Select a Color'**
  String get selectAColor;

  /// Select button text
  ///
  /// In en, this message translates to:
  /// **'Select'**
  String get select;

  /// Loading message for existing design
  ///
  /// In en, this message translates to:
  /// **'Loading existing design data...'**
  String get loadingExistingDesignData;

  /// Edit mode title
  ///
  /// In en, this message translates to:
  /// **'Edit Mode'**
  String get editMode;

  /// Message showing which design is being edited
  ///
  /// In en, this message translates to:
  /// **'Editing design: {designName}'**
  String editingDesign(String designName);

  /// Error message for failed data load
  ///
  /// In en, this message translates to:
  /// **'Failed to load existing data. Using defaults.'**
  String get failedToLoadExistingData;

  /// Data loaded title
  ///
  /// In en, this message translates to:
  /// **'Data Loaded'**
  String get dataLoaded;

  /// Message for loaded previous answers
  ///
  /// In en, this message translates to:
  /// **'Previous answers have been loaded for editing'**
  String get previousAnswersLoadedForEditing;

  /// Brief completion title
  ///
  /// In en, this message translates to:
  /// **'Brief Complete!'**
  String get briefComplete;

  /// Brief completion message
  ///
  /// In en, this message translates to:
  /// **'Your creative brief has been completed successfully.'**
  String get briefCompletedSuccessfully;

  /// Invalid input title
  ///
  /// In en, this message translates to:
  /// **'Invalid Input'**
  String get invalidInput;

  /// Prompt to enter custom answer
  ///
  /// In en, this message translates to:
  /// **'Please enter a custom answer for {category}'**
  String pleaseEnterCustomAnswer(String category);

  /// Generic prompt to enter custom answer
  ///
  /// In en, this message translates to:
  /// **'Please enter a custom answer'**
  String get pleaseEnterCustomAnswerGeneric;

  /// Prompt to enter custom print
  ///
  /// In en, this message translates to:
  /// **'Please enter a custom print'**
  String get pleaseEnterCustomPrint;

  /// Prompt to enter custom technique
  ///
  /// In en, this message translates to:
  /// **'Please enter a custom technique'**
  String get pleaseEnterCustomTechnique;

  /// Answer updated title
  ///
  /// In en, this message translates to:
  /// **'Answer Updated'**
  String get answerUpdated;

  /// Answer updated message
  ///
  /// In en, this message translates to:
  /// **'Your answer has been updated successfully'**
  String get answerUpdatedSuccessfully;

  /// Prints and techniques updated message
  ///
  /// In en, this message translates to:
  /// **'Your prints and techniques have been updated successfully'**
  String get printsAndTechniquesUpdated;

  /// Title for refining concept screen
  ///
  /// In en, this message translates to:
  /// **'Refining the Concept'**
  String get rcRefiningTheConcept;

  /// Subtitle for refining concept intro
  ///
  /// In en, this message translates to:
  /// **'Now, to help me refine the 3D design'**
  String get rcNowToHelpMeRefine;

  /// Description text for refining concept intro
  ///
  /// In en, this message translates to:
  /// **'And propose 3 concept options, I need a few more details.'**
  String get rcProposeThreeConceptOptions;

  /// Continue button text for refining concept
  ///
  /// In en, this message translates to:
  /// **'Continue'**
  String get rcContinue;

  /// Placeholder for custom answer input in refining concept
  ///
  /// In en, this message translates to:
  /// **'Enter your custom answer...'**
  String get rcEnterYourCustomAnswer;

  /// Placeholder for custom category input in refining concept
  ///
  /// In en, this message translates to:
  /// **'Enter custom {category}...'**
  String rcEnterCustomCategory(String category);

  /// Button text to generate design in refining concept
  ///
  /// In en, this message translates to:
  /// **'Generate Design'**
  String get rcGenerateDesign;

  /// Refining Concept question: garment type/fit
  ///
  /// In en, this message translates to:
  /// **'What fit are you aiming for? (multiple selection) 📏'**
  String get rcQuestionGarmentType;

  /// Refining Concept question: specific features
  ///
  /// In en, this message translates to:
  /// **'Do you want to add special details? (multiple selection) ✂️'**
  String get rcQuestionSpecificFeatures;

  /// Refining Concept question: seasonal constraint
  ///
  /// In en, this message translates to:
  /// **'Is there a seasonal constraint? 🌤️'**
  String get rcQuestionSeasonalConstraint;

  /// Refining Concept question: target budget
  ///
  /// In en, this message translates to:
  /// **'What is your target budget per piece? 💵'**
  String get rcQuestionTargetBudget;

  /// Refining Concept question: functionalities or values
  ///
  /// In en, this message translates to:
  /// **'Would you like to include any specific functionalities or values? 🧶'**
  String get rcQuestionFunctionalitiesValues;

  /// Refining Concept category: Necklines
  ///
  /// In en, this message translates to:
  /// **'Necklines'**
  String get rcCategoryNecklines;

  /// Refining Concept category: Sleeves
  ///
  /// In en, this message translates to:
  /// **'Sleeves'**
  String get rcCategorySleeves;

  /// Refining Concept category: Closures
  ///
  /// In en, this message translates to:
  /// **'Closures'**
  String get rcCategoryClosures;

  /// Refining Concept category: Pockets
  ///
  /// In en, this message translates to:
  /// **'Pockets'**
  String get rcCategoryPockets;

  /// Refining Concept category: Waist
  ///
  /// In en, this message translates to:
  /// **'Waist'**
  String get rcCategoryWaist;

  /// Refining Concept category: Legs
  ///
  /// In en, this message translates to:
  /// **'Legs'**
  String get rcCategoryLegs;

  /// Refining Concept category: Finishes
  ///
  /// In en, this message translates to:
  /// **'Finishes'**
  String get rcCategoryFinishes;

  /// No description provided for @rcOptionSlim.
  ///
  /// In en, this message translates to:
  /// **'Slim'**
  String get rcOptionSlim;

  /// No description provided for @rcOptionOversized.
  ///
  /// In en, this message translates to:
  /// **'Oversized'**
  String get rcOptionOversized;

  /// No description provided for @rcOptionRegular.
  ///
  /// In en, this message translates to:
  /// **'Regular'**
  String get rcOptionRegular;

  /// No description provided for @rcOptionStraight.
  ///
  /// In en, this message translates to:
  /// **'Straight'**
  String get rcOptionStraight;

  /// No description provided for @rcOptionFitted.
  ///
  /// In en, this message translates to:
  /// **'Fitted'**
  String get rcOptionFitted;

  /// No description provided for @rcOptionTailored.
  ///
  /// In en, this message translates to:
  /// **'Tailored'**
  String get rcOptionTailored;

  /// No description provided for @rcOptionCropped.
  ///
  /// In en, this message translates to:
  /// **'Cropped'**
  String get rcOptionCropped;

  /// No description provided for @rcOptionRelaxed.
  ///
  /// In en, this message translates to:
  /// **'Relaxed'**
  String get rcOptionRelaxed;

  /// No description provided for @rcOptionLong.
  ///
  /// In en, this message translates to:
  /// **'Long'**
  String get rcOptionLong;

  /// No description provided for @rcOptionCrew.
  ///
  /// In en, this message translates to:
  /// **'Crew'**
  String get rcOptionCrew;

  /// No description provided for @rcOptionVNeck.
  ///
  /// In en, this message translates to:
  /// **'V-neck'**
  String get rcOptionVNeck;

  /// No description provided for @rcOptionSquare.
  ///
  /// In en, this message translates to:
  /// **'Square'**
  String get rcOptionSquare;

  /// No description provided for @rcOptionHalfShoulder.
  ///
  /// In en, this message translates to:
  /// **'Half-shoulder'**
  String get rcOptionHalfShoulder;

  /// No description provided for @rcOptionScoop.
  ///
  /// In en, this message translates to:
  /// **'Scoop'**
  String get rcOptionScoop;

  /// No description provided for @rcOptionBoatNeck.
  ///
  /// In en, this message translates to:
  /// **'Boat neck'**
  String get rcOptionBoatNeck;

  /// No description provided for @rcOptionSleeveless.
  ///
  /// In en, this message translates to:
  /// **'Sleeveless'**
  String get rcOptionSleeveless;

  /// No description provided for @rcOptionShortThreeQuarter.
  ///
  /// In en, this message translates to:
  /// **'Short ¾'**
  String get rcOptionShortThreeQuarter;

  /// No description provided for @rcOptionPuff.
  ///
  /// In en, this message translates to:
  /// **'Puff'**
  String get rcOptionPuff;

  /// No description provided for @rcOptionRaglan.
  ///
  /// In en, this message translates to:
  /// **'Raglan'**
  String get rcOptionRaglan;

  /// No description provided for @rcOptionCap.
  ///
  /// In en, this message translates to:
  /// **'Cap'**
  String get rcOptionCap;

  /// No description provided for @rcOptionZipper.
  ///
  /// In en, this message translates to:
  /// **'Zipper (metal/plastic/invisible)'**
  String get rcOptionZipper;

  /// No description provided for @rcOptionButtons.
  ///
  /// In en, this message translates to:
  /// **'Buttons'**
  String get rcOptionButtons;

  /// No description provided for @rcOptionHooks.
  ///
  /// In en, this message translates to:
  /// **'Hooks'**
  String get rcOptionHooks;

  /// No description provided for @rcOptionVelcro.
  ///
  /// In en, this message translates to:
  /// **'Velcro'**
  String get rcOptionVelcro;

  /// No description provided for @rcOptionSnaps.
  ///
  /// In en, this message translates to:
  /// **'Snaps'**
  String get rcOptionSnaps;

  /// No description provided for @rcOptionPatch.
  ///
  /// In en, this message translates to:
  /// **'Patch'**
  String get rcOptionPatch;

  /// No description provided for @rcOptionWelt.
  ///
  /// In en, this message translates to:
  /// **'Welt'**
  String get rcOptionWelt;

  /// No description provided for @rcOptionFlap.
  ///
  /// In en, this message translates to:
  /// **'Flap'**
  String get rcOptionFlap;

  /// No description provided for @rcOptionHidden.
  ///
  /// In en, this message translates to:
  /// **'Hidden'**
  String get rcOptionHidden;

  /// No description provided for @rcOptionCargo.
  ///
  /// In en, this message translates to:
  /// **'Cargo'**
  String get rcOptionCargo;

  /// No description provided for @rcOptionElastic.
  ///
  /// In en, this message translates to:
  /// **'Elastic'**
  String get rcOptionElastic;

  /// No description provided for @rcOptionHighWaist.
  ///
  /// In en, this message translates to:
  /// **'High-waist'**
  String get rcOptionHighWaist;

  /// No description provided for @rcOptionLowRise.
  ///
  /// In en, this message translates to:
  /// **'Low-rise'**
  String get rcOptionLowRise;

  /// No description provided for @rcOptionBelted.
  ///
  /// In en, this message translates to:
  /// **'Belted'**
  String get rcOptionBelted;

  /// No description provided for @rcOptionDrawstring.
  ///
  /// In en, this message translates to:
  /// **'Drawstring'**
  String get rcOptionDrawstring;

  /// No description provided for @rcOptionStraightLeg.
  ///
  /// In en, this message translates to:
  /// **'Straight leg'**
  String get rcOptionStraightLeg;

  /// No description provided for @rcOptionTapered.
  ///
  /// In en, this message translates to:
  /// **'Tapered'**
  String get rcOptionTapered;

  /// No description provided for @rcOptionWideLeg.
  ///
  /// In en, this message translates to:
  /// **'Wide leg'**
  String get rcOptionWideLeg;

  /// No description provided for @rcOptionBootcut.
  ///
  /// In en, this message translates to:
  /// **'Bootcut'**
  String get rcOptionBootcut;

  /// No description provided for @rcOptionFlared.
  ///
  /// In en, this message translates to:
  /// **'Flared'**
  String get rcOptionFlared;

  /// No description provided for @rcOptionLining.
  ///
  /// In en, this message translates to:
  /// **'Lining'**
  String get rcOptionLining;

  /// No description provided for @rcOptionTopstitching.
  ///
  /// In en, this message translates to:
  /// **'Topstitching'**
  String get rcOptionTopstitching;

  /// No description provided for @rcOptionEmbroidery.
  ///
  /// In en, this message translates to:
  /// **'Embroidery'**
  String get rcOptionEmbroidery;

  /// No description provided for @rcOptionLace.
  ///
  /// In en, this message translates to:
  /// **'Lace'**
  String get rcOptionLace;

  /// No description provided for @rcOptionSequins.
  ///
  /// In en, this message translates to:
  /// **'Sequins'**
  String get rcOptionSequins;

  /// No description provided for @rcOptionAppliques.
  ///
  /// In en, this message translates to:
  /// **'Appliqués'**
  String get rcOptionAppliques;

  /// No description provided for @rcOptionSummer.
  ///
  /// In en, this message translates to:
  /// **'Summer'**
  String get rcOptionSummer;

  /// No description provided for @rcOptionMidSeason.
  ///
  /// In en, this message translates to:
  /// **'Mid-Season'**
  String get rcOptionMidSeason;

  /// No description provided for @rcOptionAllSeason.
  ///
  /// In en, this message translates to:
  /// **'All-Season'**
  String get rcOptionAllSeason;

  /// No description provided for @rcOptionPriceRangeInEuro.
  ///
  /// In en, this message translates to:
  /// **'Price Range In €'**
  String get rcOptionPriceRangeInEuro;

  /// No description provided for @rcOptionIndicationOfMarketLevel.
  ///
  /// In en, this message translates to:
  /// **'An Indication Of The Market Level'**
  String get rcOptionIndicationOfMarketLevel;

  /// No description provided for @rcOptionEntry.
  ///
  /// In en, this message translates to:
  /// **'Entry'**
  String get rcOptionEntry;

  /// No description provided for @rcOptionMidRange.
  ///
  /// In en, this message translates to:
  /// **'Mid-Range'**
  String get rcOptionMidRange;

  /// No description provided for @rcOptionPremium.
  ///
  /// In en, this message translates to:
  /// **'Premium'**
  String get rcOptionPremium;

  /// No description provided for @rcOptionOrganicFabric.
  ///
  /// In en, this message translates to:
  /// **'Organic Fabric'**
  String get rcOptionOrganicFabric;

  /// No description provided for @rcOptionLocallyMade.
  ///
  /// In en, this message translates to:
  /// **'Locally Made'**
  String get rcOptionLocallyMade;

  /// No description provided for @rcOptionUpcycled.
  ///
  /// In en, this message translates to:
  /// **'Upcycled'**
  String get rcOptionUpcycled;

  /// No description provided for @rcOptionUVProtection.
  ///
  /// In en, this message translates to:
  /// **'UV Protection'**
  String get rcOptionUVProtection;

  /// No description provided for @rcOptionQuickDry.
  ///
  /// In en, this message translates to:
  /// **'Quick-Dry'**
  String get rcOptionQuickDry;

  /// No description provided for @rcOptionWrinkleFree.
  ///
  /// In en, this message translates to:
  /// **'Wrinkle-Free'**
  String get rcOptionWrinkleFree;

  /// No description provided for @rcOptionCustom.
  ///
  /// In en, this message translates to:
  /// **'Custom'**
  String get rcOptionCustom;

  /// Today text for time display
  ///
  /// In en, this message translates to:
  /// **'Today'**
  String get today;

  /// Snackbar title when refining is complete
  ///
  /// In en, this message translates to:
  /// **'Refining Complete!'**
  String get rcSnackbarRefiningComplete;

  /// Snackbar message when refining is complete
  ///
  /// In en, this message translates to:
  /// **'Your concept has been refined successfully.'**
  String get rcSnackbarRefiningCompleteMessage;

  /// Snackbar title when extra designs purchased
  ///
  /// In en, this message translates to:
  /// **'Extra Designs Added!'**
  String get rcSnackbarExtraDesignsAdded;

  /// Snackbar message when extra designs purchased
  ///
  /// In en, this message translates to:
  /// **'5 extra designs have been added to your account.'**
  String get rcSnackbarExtraDesignsAddedMessage;

  /// Snackbar title when regenerating designs
  ///
  /// In en, this message translates to:
  /// **'Regenerating Designs!'**
  String get rcSnackbarRegeneratingDesigns;

  /// Snackbar message when regenerating designs
  ///
  /// In en, this message translates to:
  /// **'Creating 3 new designs based on your updated preferences...'**
  String get rcSnackbarRegeneratingDesignsMessage;

  /// Snackbar title when generating designs
  ///
  /// In en, this message translates to:
  /// **'Generating Designs!'**
  String get rcSnackbarGeneratingDesigns;

  /// Snackbar message when generating designs
  ///
  /// In en, this message translates to:
  /// **'Creating 3 unique designs based on your preferences...'**
  String get rcSnackbarGeneratingDesignsMessage;

  /// Snackbar title for invalid input
  ///
  /// In en, this message translates to:
  /// **'Invalid Input'**
  String get rcSnackbarInvalidInput;

  /// Snackbar message for invalid input in category
  ///
  /// In en, this message translates to:
  /// **'Please enter a custom answer for {category}'**
  String rcSnackbarInvalidInputCategoryMessage(String category);

  /// Snackbar message for invalid input
  ///
  /// In en, this message translates to:
  /// **'Please enter a custom answer'**
  String get rcSnackbarInvalidInputMessage;

  /// Snackbar title when answer updated
  ///
  /// In en, this message translates to:
  /// **'Answer Updated'**
  String get rcSnackbarAnswerUpdated;

  /// Snackbar message when answer updated
  ///
  /// In en, this message translates to:
  /// **'Your answer has been updated successfully'**
  String get rcSnackbarAnswerUpdatedMessage;

  /// Edit answer dialog title
  ///
  /// In en, this message translates to:
  /// **'Edit Answer'**
  String get rcDialogEditAnswer;

  /// Instruction text in edit dialog
  ///
  /// In en, this message translates to:
  /// **'Select your answer:'**
  String get rcDialogSelectAnswer;

  /// Custom answer prompt in edit dialog
  ///
  /// In en, this message translates to:
  /// **'Enter custom answer:'**
  String get rcDialogEnterCustomAnswer;

  /// Placeholder for custom answer input in edit dialog
  ///
  /// In en, this message translates to:
  /// **'Type your custom answer...'**
  String get rcDialogCustomAnswerHint;

  /// Cancel button in edit dialog
  ///
  /// In en, this message translates to:
  /// **'Cancel'**
  String get rcDialogCancel;

  /// Save button in edit dialog
  ///
  /// In en, this message translates to:
  /// **'Save Changes'**
  String get rcDialogSaveChanges;

  /// Today text for timestamp
  ///
  /// In en, this message translates to:
  /// **'Today'**
  String get rcToday;

  /// Dialog title for editing an answer
  ///
  /// In en, this message translates to:
  /// **'Edit Answer'**
  String get cbDialogEditAnswer;

  /// Dialog instruction to select answer
  ///
  /// In en, this message translates to:
  /// **'Select your answer:'**
  String get cbDialogSelectAnswer;

  /// Label for custom answer input
  ///
  /// In en, this message translates to:
  /// **'Enter custom answer:'**
  String get cbDialogEnterCustomAnswer;

  /// Placeholder for custom answer input - Creative Brief
  ///
  /// In en, this message translates to:
  /// **'Type your custom answer...'**
  String get cbDialogCustomAnswerHint;

  /// Cancel button in dialog
  ///
  /// In en, this message translates to:
  /// **'Cancel'**
  String get cbDialogCancel;

  /// Save changes button in dialog
  ///
  /// In en, this message translates to:
  /// **'Save Changes'**
  String get cbDialogSaveChanges;

  /// Dialog title for editing prints and techniques
  ///
  /// In en, this message translates to:
  /// **'Edit Prints & Techniques'**
  String get cbDialogEditPrintsTechniques;

  /// Dialog instruction for prints and techniques
  ///
  /// In en, this message translates to:
  /// **'Select your prints and techniques'**
  String get cbDialogSelectPrintsTechniques;

  /// Prints category title in dialog
  ///
  /// In en, this message translates to:
  /// **'Prints'**
  String get cbDialogPrints;

  /// Techniques category title in dialog
  ///
  /// In en, this message translates to:
  /// **'Techniques'**
  String get cbDialogTechniques;

  /// Placeholder for custom print input
  ///
  /// In en, this message translates to:
  /// **'Enter custom print...'**
  String get cbDialogEnterCustomPrint;

  /// Placeholder for custom technique input
  ///
  /// In en, this message translates to:
  /// **'Enter custom technique...'**
  String get cbDialogEnterCustomTechnique;

  /// Final Details screen title
  ///
  /// In en, this message translates to:
  /// **'Final Details'**
  String get fdFinalDetails;

  /// Final Details onboard screen title
  ///
  /// In en, this message translates to:
  /// **'Final Details to Provide'**
  String get fdFinalDetailsToProvide;

  /// Continue button - Final Details
  ///
  /// In en, this message translates to:
  /// **'Continue'**
  String get fdContinue;

  /// Generate button - Final Details
  ///
  /// In en, this message translates to:
  /// **'Generate'**
  String get fdGenerate;

  /// Target Season section title
  ///
  /// In en, this message translates to:
  /// **'Target Season:'**
  String get fdTargetSeason;

  /// Target Budget section title
  ///
  /// In en, this message translates to:
  /// **'Target Budget per Piece:'**
  String get fdTargetBudget;

  /// Desired Features section title
  ///
  /// In en, this message translates to:
  /// **'Desired Features or Values:'**
  String get fdDesiredFeatures;

  /// Placeholder for custom features input
  ///
  /// In en, this message translates to:
  /// **'Type your custom features here...'**
  String get fdCustomFeaturesHint;

  /// Question 1 - Target Season
  ///
  /// In en, this message translates to:
  /// **'Great! Let\'s make sure your piece fits perfectly with the season. What kind of weather will it be designed for?'**
  String get fdQuestionSeason;

  /// Season option - Summer
  ///
  /// In en, this message translates to:
  /// **'Summer (Lightweight, Short Or Roll-Up Sleeves)'**
  String get fdOptionSummer;

  /// Season option - Mid-Season
  ///
  /// In en, this message translates to:
  /// **'Mid-Season'**
  String get fdOptionMidSeason;

  /// Season option - All-Season
  ///
  /// In en, this message translates to:
  /// **'All-Season (Layer-Friendly)'**
  String get fdOptionAllSeason;

  /// Question 2 - Target Budget
  ///
  /// In en, this message translates to:
  /// **'Got it. And what kind of budget are you working with for this design? I can tailor the fabrics and features accordingly.'**
  String get fdQuestionBudget;

  /// Budget option - Entry Level
  ///
  /// In en, this message translates to:
  /// **'Entry-Level (€15-30 Production / €35-60 Retail)'**
  String get fdOptionEntryLevel;

  /// Budget option - Mid Range
  ///
  /// In en, this message translates to:
  /// **'Mid-Range (€30-50 Production / €60-120 Retail)'**
  String get fdOptionMidRange;

  /// Budget option - Premium
  ///
  /// In en, this message translates to:
  /// **'Premium (€60+ Production / €120+ Retail)'**
  String get fdOptionPremium;

  /// Question 3 - Desired Features
  ///
  /// In en, this message translates to:
  /// **'Would you like to include any special values or features that matter to you or your brand? I can make sure they\'re part of the final concept'**
  String get fdQuestionFeatures;

  /// Feature option - Organic Fabric
  ///
  /// In en, this message translates to:
  /// **'Organic Fabric'**
  String get fdOptionOrganicFabric;

  /// Feature option - Upcycled Materials
  ///
  /// In en, this message translates to:
  /// **'Upcycled Materials'**
  String get fdOptionUpcycled;

  /// Feature option - Locally Made
  ///
  /// In en, this message translates to:
  /// **'Locally Made (Europe)'**
  String get fdOptionLocallyMade;

  /// Feature option - UV Protection
  ///
  /// In en, this message translates to:
  /// **'UV Protection'**
  String get fdOptionUVProtection;

  /// Feature option - Quick-Dry
  ///
  /// In en, this message translates to:
  /// **'Quick-Dry'**
  String get fdOptionQuickDry;

  /// Feature option - Wrinkle-Free
  ///
  /// In en, this message translates to:
  /// **'Wrinkle-Free'**
  String get fdOptionWrinkleFree;

  /// Feature option - Other/Custom
  ///
  /// In en, this message translates to:
  /// **'Other: ?'**
  String get fdOptionOther;

  /// Question 4 - Additional Details
  ///
  /// In en, this message translates to:
  /// **'Cool — feel free to type in anything else you have in mind!'**
  String get fdQuestionAdditional;

  /// Snackbar title when regenerating designs
  ///
  /// In en, this message translates to:
  /// **'Regenerating Designs!'**
  String get fdSnackbarRegeneratingDesigns;

  /// Snackbar message when regenerating designs
  ///
  /// In en, this message translates to:
  /// **'Creating 3 new designs based on your updated preferences...'**
  String get fdSnackbarRegeneratingMessage;

  /// Snackbar title when generating designs
  ///
  /// In en, this message translates to:
  /// **'Generating Designs!'**
  String get fdSnackbarGeneratingDesigns;

  /// Snackbar message when generating designs
  ///
  /// In en, this message translates to:
  /// **'Creating 3 unique designs based on your preferences...'**
  String get fdSnackbarGeneratingMessage;

  /// Snackbar title when extra designs added
  ///
  /// In en, this message translates to:
  /// **'Extra Designs Added!'**
  String get fdSnackbarExtraDesigns;

  /// Snackbar message when extra designs added
  ///
  /// In en, this message translates to:
  /// **'5 extra designs have been added to your account.'**
  String get fdSnackbarExtraDesignsMessage;

  /// Limit exceeded dialog title
  ///
  /// In en, this message translates to:
  /// **'Limit Exceeded'**
  String get fdDialogLimitExceeded;

  /// Limit exceeded dialog message for paid users
  ///
  /// In en, this message translates to:
  /// **'You have exceeded your limit for this month. You can pay €9.99 for 5 extra designs or upgrade your plan.'**
  String get fdDialogLimitMessage;

  /// Limit exceeded dialog message for FREE users
  ///
  /// In en, this message translates to:
  /// **'You have exceeded your free plan limit for this month. Upgrade to Starter or Pro to continue creating designs.'**
  String get fdDialogLimitMessageFree;

  /// Get extra designs button text
  ///
  /// In en, this message translates to:
  /// **'Get Extra Designs (€9.99)'**
  String get fdDialogGetExtraDesigns;

  /// Buy button label for free users purchasing a design add-on (no 'extra' wording)
  ///
  /// In en, this message translates to:
  /// **'+5 Designs (€9.99)'**
  String get fdDialogGetDesigns;

  /// Upgrade plan button text
  ///
  /// In en, this message translates to:
  /// **'Upgrade Plan'**
  String get fdDialogUpgradePlan;

  /// Maybe later button text
  ///
  /// In en, this message translates to:
  /// **'Maybe Later'**
  String get fdDialogMaybeLater;

  /// Title for 80% usage warning dialog
  ///
  /// In en, this message translates to:
  /// **'Almost at Your Limit!'**
  String get fdDialog80PercentTitle;

  /// Message for 80% design usage warning for paid users
  ///
  /// In en, this message translates to:
  /// **'You\'ve used {used} of {total} designs this month. Consider upgrading or purchasing extra designs to continue creating.'**
  String fdDialog80PercentMessage(int used, int total);

  /// Message for 80% design usage warning for FREE users
  ///
  /// In en, this message translates to:
  /// **'You\'ve used {used} of {total} designs this month. Upgrade to Starter or Pro for more designs.'**
  String fdDialog80PercentMessageFree(int used, int total);

  /// Button to dismiss 80% warning and continue
  ///
  /// In en, this message translates to:
  /// **'Continue Anyway'**
  String get fdDialog80PercentContinue;

  /// Title for 80% techpack usage warning dialog
  ///
  /// In en, this message translates to:
  /// **'Almost at Your Techpack Limit!'**
  String get tpDialog80PercentTitle;

  /// Message for 80% techpack usage warning
  ///
  /// In en, this message translates to:
  /// **'You\'ve used {used} of {total} techpacks this month. Consider upgrading to continue generating techpacks.'**
  String tpDialog80PercentMessage(int used, int total);

  /// Button to dismiss 80% techpack warning and continue
  ///
  /// In en, this message translates to:
  /// **'Continue Anyway'**
  String get tpDialog80PercentContinue;

  /// Tech Pack screen title
  ///
  /// In en, this message translates to:
  /// **'Design Assistant'**
  String get tpDesignAssistant;

  /// Instruction to choose favorite design
  ///
  /// In en, this message translates to:
  /// **'Choose your favorite design:'**
  String get tpChooseFavoriteDesign;

  /// Loading header when creating designs
  ///
  /// In en, this message translates to:
  /// **'Creating your designs...'**
  String get tpCreatingDesigns;

  /// Loading description
  ///
  /// In en, this message translates to:
  /// **'Please wait while we generate 3 unique designs based on your preferences.'**
  String get tpPleaseWaitGenerating;

  /// Error header
  ///
  /// In en, this message translates to:
  /// **'Something went wrong'**
  String get tpSomethingWentWrong;

  /// Retry button text
  ///
  /// In en, this message translates to:
  /// **'Retry'**
  String get tpRetry;

  /// Confirmation question before tech pack
  ///
  /// In en, this message translates to:
  /// **'Would you like to make any changes before I create the final tech pack?'**
  String get tpWouldYouLikeChanges;

  /// Button to make changes
  ///
  /// In en, this message translates to:
  /// **'Yes, I\'d like to make changes'**
  String get tpYesChanges;

  /// Button to continue with selected design
  ///
  /// In en, this message translates to:
  /// **'Continue with Selected Design'**
  String get tpContinueWithSelected;

  /// Button to continue without making changes
  ///
  /// In en, this message translates to:
  /// **'No, continue as is'**
  String get tpContinueAsIs;

  /// Tab label for recommended manufacturers
  ///
  /// In en, this message translates to:
  /// **'Recommended Manufacturers'**
  String get tpRecommendedManufacturers;

  /// Tab label for custom manufacturers
  ///
  /// In en, this message translates to:
  /// **'Custom'**
  String get tpCustomTab;

  /// Placeholder text for image upload
  ///
  /// In en, this message translates to:
  /// **'Select Image from Gallery'**
  String get tpSelectImageGallery;

  /// Manufacturer label with name and country
  ///
  /// In en, this message translates to:
  /// **'Manufacturer: {name} ({country})'**
  String tpManufacturerPrefix(String name, String country);

  /// Upgrade required dialog title
  ///
  /// In en, this message translates to:
  /// **'Upgrade Required'**
  String get tpUpgradeRequired;

  /// Upgrade required message
  ///
  /// In en, this message translates to:
  /// **'Upgrade to Starter or Pro to generate tech packs'**
  String get tpUpgradeToGenerate;

  /// Get extra designs button text
  ///
  /// In en, this message translates to:
  /// **'Get 5 Extra Designs'**
  String get tpGetExtraDesigns;

  /// View plans button text
  ///
  /// In en, this message translates to:
  /// **'View Plans'**
  String get tpViewPlans;

  /// Maybe later button text
  ///
  /// In en, this message translates to:
  /// **'Maybe Later'**
  String get tpMaybeLater;

  /// Free plan limit dialog title
  ///
  /// In en, this message translates to:
  /// **'Free Plan Limit'**
  String get tpFreePlanLimit;

  /// Free plan limit message
  ///
  /// In en, this message translates to:
  /// **'Free plan users can generate up to 3 designs per month. Upgrade for more designs and tech packs!'**
  String get tpFreePlanMessage;

  /// Pro limit dialog title
  ///
  /// In en, this message translates to:
  /// **'Pro Limit Reached'**
  String get tpProLimitReached;

  /// Pro limit message
  ///
  /// In en, this message translates to:
  /// **'You\'ve reached your monthly limit. Get 5 extra designs for €9.99!'**
  String get tpProLimitMessage;

  /// Snackbar title when design updated
  ///
  /// In en, this message translates to:
  /// **'Design Updated'**
  String get tpSnackbarDesignUpdated;

  /// Snackbar message when design updated
  ///
  /// In en, this message translates to:
  /// **'Your design has been updated with new preferences'**
  String get tpSnackbarDesignUpdatedMessage;

  /// Snackbar title when design saved
  ///
  /// In en, this message translates to:
  /// **'Design Saved'**
  String get tpSnackbarDesignSaved;

  /// Snackbar message when design saved
  ///
  /// In en, this message translates to:
  /// **'Your selected design has been saved successfully'**
  String get tpSnackbarDesignSavedMessage;

  /// Snackbar title when generation fails
  ///
  /// In en, this message translates to:
  /// **'Generation Failed'**
  String get tpSnackbarGenerationFailed;

  /// Snackbar message when generation fails
  ///
  /// In en, this message translates to:
  /// **'Failed to generate designs. Please try again.'**
  String get tpSnackbarGenerationFailedMessage;

  /// Snackbar title when no design selected
  ///
  /// In en, this message translates to:
  /// **'No Design Selected'**
  String get tpSnackbarNoDesignSelected;

  /// Snackbar message when no design selected
  ///
  /// In en, this message translates to:
  /// **'Please select a design before continuing'**
  String get tpSnackbarNoDesignSelectedMessage;

  /// Snackbar title when purchase successful
  ///
  /// In en, this message translates to:
  /// **'Purchase Successful!'**
  String get tpSnackbarPurchaseSuccess;

  /// Snackbar message when purchase successful
  ///
  /// In en, this message translates to:
  /// **'5 extra designs added to your account'**
  String get tpSnackbarPurchaseSuccessMessage;

  /// Snackbar title when purchase fails
  ///
  /// In en, this message translates to:
  /// **'Purchase Failed'**
  String get tpSnackbarPurchaseFailed;

  /// Snackbar message when purchase fails
  ///
  /// In en, this message translates to:
  /// **'Failed to process purchase. Please try again.'**
  String get tpSnackbarPurchaseFailedMessage;

  /// Free plan name (display only)
  ///
  /// In en, this message translates to:
  /// **'Free'**
  String get tpPlanFree;

  /// Starter plan name (display only)
  ///
  /// In en, this message translates to:
  /// **'Starter'**
  String get tpPlanStarter;

  /// Pro plan name (display only)
  ///
  /// In en, this message translates to:
  /// **'Pro'**
  String get tpPlanPro;

  /// Upgrade dialog title
  ///
  /// In en, this message translates to:
  /// **'Choose Your Upgrade'**
  String get tpDialogChooseUpgrade;

  /// Upgrade dialog description
  ///
  /// In en, this message translates to:
  /// **'Unlock unlimited tech pack generation and more features!'**
  String get tpDialogUpgradeDescription;

  /// Starter plan feature - 3 tech packs
  ///
  /// In en, this message translates to:
  /// **'3 tech packs/month'**
  String get tpDialogFeature3TechPacks;

  /// Starter plan feature - Basic PDF
  ///
  /// In en, this message translates to:
  /// **'Basic PDF export'**
  String get tpDialogFeatureBasicPDF;

  /// Starter plan feature - Manufacturers
  ///
  /// In en, this message translates to:
  /// **'Manufacturer access'**
  String get tpDialogFeatureManufacturers;

  /// Pro plan feature - 10 tech packs
  ///
  /// In en, this message translates to:
  /// **'10 tech packs/month'**
  String get tpDialogFeature10TechPacks;

  /// Pro plan feature - Custom PDF
  ///
  /// In en, this message translates to:
  /// **'Custom PDF with logo'**
  String get tpDialogFeatureCustomPDF;

  /// Pro plan feature - Priority support
  ///
  /// In en, this message translates to:
  /// **'Priority support'**
  String get tpDialogFeaturePriority;

  /// Extra tech packs dialog title
  ///
  /// In en, this message translates to:
  /// **'Need More Designs This Month?'**
  String get tpDialogExtraTechPacksTitle;

  /// Extra tech packs dialog description
  ///
  /// In en, this message translates to:
  /// **'Get 5 extra designs for just €9.99'**
  String get tpDialogExtraTechPacksDescription;

  /// Extra tech packs feature - one-time
  ///
  /// In en, this message translates to:
  /// **'One-time purchase'**
  String get tpDialogExtraTechPacksOneTime;

  /// Extra tech packs feature - no subscription
  ///
  /// In en, this message translates to:
  /// **'No subscription required'**
  String get tpDialogExtraTechPacksNoSubscription;

  /// Extra tech packs feature - expiration
  ///
  /// In en, this message translates to:
  /// **'Does not expire until fully used'**
  String get tpDialogExtraTechPacksExpires;

  /// Purchase button text with price
  ///
  /// In en, this message translates to:
  /// **'Purchase for €9.99'**
  String get tpDialogPurchaseFor;

  /// Upgrade instead button text
  ///
  /// In en, this message translates to:
  /// **'Upgrade Instead'**
  String get tpDialogUpgradeInstead;

  /// Message shown to free users about techpack being premium
  ///
  /// In en, this message translates to:
  /// **'Techpack generation is a premium feature.'**
  String get tpTechpackFeaturePremium;

  /// Message shown to free users in the techpack limit dialog — does not imply it is premium-only
  ///
  /// In en, this message translates to:
  /// **'You currently have no techpacks. See purchase options below.'**
  String get tpFreeUserTechpackMessage;

  /// Message shown to Pro users when monthly techpack limit reached
  ///
  /// In en, this message translates to:
  /// **'Your monthly techpack generation limit has been reached.'**
  String get tpProMonthlyLimitReached;

  /// Message shown to Starter yearly users when monthly techpack limit reached
  ///
  /// In en, this message translates to:
  /// **'Your monthly techpack generation limit has been reached.'**
  String get tpStarterYearlyLimitReached;

  /// Message shown to Starter monthly users when monthly techpack limit reached
  ///
  /// In en, this message translates to:
  /// **'Your monthly techpack generation limit has been reached.'**
  String get tpStarterMonthlyLimitReached;

  /// Header text when showing plan options to free users
  ///
  /// In en, this message translates to:
  /// **'Choose a plan:'**
  String get tpDialogChoosePlan;

  /// Header text when showing Pro upgrade option
  ///
  /// In en, this message translates to:
  /// **'Upgrade to Pro:'**
  String get tpDialogUpgradeToPro;

  /// Shows user's current plan
  ///
  /// In en, this message translates to:
  /// **'Current Plan: {plan}'**
  String tpDialogCurrentPlan(String plan);

  /// Shows remaining techpacks for Pro users
  ///
  /// In en, this message translates to:
  /// **'Remaining: {remaining}/6 techpacks this month'**
  String tpDialogRemainingTechpacksPro(int remaining);

  /// Shows remaining techpacks for Starter users
  ///
  /// In en, this message translates to:
  /// **'Remaining: {remaining}/2 this month'**
  String tpDialogRemainingTechpacksStarter(int remaining);

  /// Starter plan option in upgrade dialog
  ///
  /// In en, this message translates to:
  /// **'Starter: 2 techpacks/month (€19.99/mo or €199.99/yr)'**
  String get tpDialogStarterPlanOption;

  /// Pro plan option in upgrade dialog
  ///
  /// In en, this message translates to:
  /// **'Pro: 6 techpacks/month (€49.99/mo or €499.99/yr)'**
  String get tpDialogProPlanOption;

  /// Studio plan option in upgrade dialog
  ///
  /// In en, this message translates to:
  /// **'Studio: 10 techpacks/month (€99.99/mo or €999.99/yr)'**
  String get tpDialogStudioPlanOption;

  /// Shows remaining techpacks for Studio users
  ///
  /// In en, this message translates to:
  /// **'Remaining: {remaining}/10 this month'**
  String tpDialogRemainingTechpacksStudio(int remaining);

  /// Pro upgrade option for Starter users
  ///
  /// In en, this message translates to:
  /// **'Pro: 8 techpacks/month'**
  String get tpDialogProUpgradeOption;

  /// Extra techpack purchase option for Pro users
  ///
  /// In en, this message translates to:
  /// **'Purchase extra +1 techpack (€5.99)'**
  String get tpDialogExtraTechpackOption;

  /// Buy button label for free users purchasing a techpack add-on (no 'extra' wording)
  ///
  /// In en, this message translates to:
  /// **'+1 Techpack (€5.99)'**
  String get tpDialogGetTechpackOption;

  /// Feature description for custom PDF export
  ///
  /// In en, this message translates to:
  /// **'Custom PDF export with your logo'**
  String get tpDialogFeatureCustomPDFExport;

  /// Feature description for manufacturer access
  ///
  /// In en, this message translates to:
  /// **'Access to manufacturers list'**
  String get tpDialogFeatureManufacturerAccess;

  /// Feature description for unlimited 3D visualization
  ///
  /// In en, this message translates to:
  /// **'Unlimited 3D visualization'**
  String get tpDialogFeatureUnlimited3D;

  /// Feature description for professional PDF exports
  ///
  /// In en, this message translates to:
  /// **'Professional PDF techpack exports'**
  String get tpDialogFeatureProfessionalPDF;

  /// Feature description for manufacturer database access
  ///
  /// In en, this message translates to:
  /// **'Access to manufacturer database'**
  String get tpDialogFeatureManufacturerDB;

  /// Button text to upgrade plan
  ///
  /// In en, this message translates to:
  /// **'Upgrade Now'**
  String get tpDialogUpgradeNow;

  /// Message shown when techpack generation requires premium
  ///
  /// In en, this message translates to:
  /// **'Final techpack generation requires a premium plan.'**
  String get tpDialogTechpackPremiumRequired;

  /// Title for PRO plan limit dialog
  ///
  /// In en, this message translates to:
  /// **'Monthly Limit Reached'**
  String get tpProLimitDialogTitle;

  /// Pro plan label in limit dialog
  ///
  /// In en, this message translates to:
  /// **'Pro Plan: '**
  String get tpProLimitDialogProPlan;

  /// Shows techpacks used this month for Pro users
  ///
  /// In en, this message translates to:
  /// **'Monthly limit reached: {used}/8 techpacks used'**
  String tpProLimitDialogMonthlyUsed(int used);

  /// Message explaining Pro limit and purchase option
  ///
  /// In en, this message translates to:
  /// **'You\'ve reached your Pro plan monthly limit of 8 techpacks. Purchase additional techpacks to continue:'**
  String get tpProLimitDialogMessage;

  /// Price display for single techpack add-on
  ///
  /// In en, this message translates to:
  /// **'+1 Techpack: €5.99'**
  String get tpProLimitDialogTechpackPrice;

  /// Description of techpack add-on purchase
  ///
  /// In en, this message translates to:
  /// **'Get 1 additional techpack (one-time purchase, does not auto-renew)'**
  String get tpProLimitDialogTechpackDescription;

  /// Button text to purchase single techpack
  ///
  /// In en, this message translates to:
  /// **'Purchase +1 Techpack'**
  String get tpProLimitDialogPurchaseButton;

  /// Manufacturer suggestions screen title
  ///
  /// In en, this message translates to:
  /// **'Manufacturer Suggestions'**
  String get mfManufacturerSuggestions;

  /// Loading message for manufacturers
  ///
  /// In en, this message translates to:
  /// **'Loading manufacturers...'**
  String get mfLoadingManufacturers;

  /// Message showing manufacturer count
  ///
  /// In en, this message translates to:
  /// **'We found {count} manufacturers from around the world.'**
  String mfFoundManufacturers(int count);

  /// Empty state when no manufacturers
  ///
  /// In en, this message translates to:
  /// **'No manufacturers available'**
  String get mfNoManufacturersAvailable;

  /// Message when all manufacturers loaded
  ///
  /// In en, this message translates to:
  /// **'All manufacturers loaded'**
  String get mfAllManufacturersLoaded;

  /// Filter manufacturers title
  ///
  /// In en, this message translates to:
  /// **'Filter Manufacturers'**
  String get mfFilterManufacturers;

  /// Filter instructions
  ///
  /// In en, this message translates to:
  /// **'Use filters below to search our manufacturer directory:'**
  String get mfUseFiltersBelow;

  /// Country filter label
  ///
  /// In en, this message translates to:
  /// **'Country or Region'**
  String get mfCountryOrRegion;

  /// Country search label
  ///
  /// In en, this message translates to:
  /// **'Search'**
  String get mfSearchCountry;

  /// Country search hint
  ///
  /// In en, this message translates to:
  /// **'Start typing to search'**
  String get mfSearchCountryHint;

  /// Manufacturer search hint
  ///
  /// In en, this message translates to:
  /// **'Search manufacturers by name...'**
  String get mfSearchManufacturer;

  /// All countries option
  ///
  /// In en, this message translates to:
  /// **'All Countries'**
  String get mfAllCountries;

  /// Search label
  ///
  /// In en, this message translates to:
  /// **'Search'**
  String get mfSearch;

  /// Search placeholder
  ///
  /// In en, this message translates to:
  /// **'Start typing to search'**
  String get mfStartTypingToSearch;

  /// Clear filter button
  ///
  /// In en, this message translates to:
  /// **'Clear Filter'**
  String get mfClearFilter;

  /// Show all manufacturers button
  ///
  /// In en, this message translates to:
  /// **'Show All'**
  String get mfShowAll;

  /// No manufacturers match the garment type
  ///
  /// In en, this message translates to:
  /// **'No suggested manufacturers found'**
  String get mfNoSuggestedManufacturers;

  /// Count of recommended manufacturers based on filter
  ///
  /// In en, this message translates to:
  /// **'Found {count} recommended manufacturer{plural} for you'**
  String mfRecommendedForYou(int count, String plural);

  /// Message when no manufacturers match the filter with action hint
  ///
  /// In en, this message translates to:
  /// **'No recommended manufacturers found. Click Show All to view all manufacturers'**
  String get mfNoRecommendedClickShowAll;

  /// Empty search results
  ///
  /// In en, this message translates to:
  /// **'No manufacturers found'**
  String get mfNoManufacturersFound;

  /// Empty search suggestion
  ///
  /// In en, this message translates to:
  /// **'Try adjusting your filters'**
  String get mfTryAdjustingFilters;

  /// Filtered results count
  ///
  /// In en, this message translates to:
  /// **'{count} manufacturer{plural} found'**
  String mfManufacturersFound(int count, String plural);

  /// Sending email loading title
  ///
  /// In en, this message translates to:
  /// **'Sending Email...'**
  String get mfSendingEmail;

  /// Sending email loading message
  ///
  /// In en, this message translates to:
  /// **'Preparing your tech pack\nand sending to manufacturer'**
  String get mfPreparingTechPack;

  /// Send via email button
  ///
  /// In en, this message translates to:
  /// **'Send via Email'**
  String get mfSendViaEmail;

  /// Contact button
  ///
  /// In en, this message translates to:
  /// **'Contact'**
  String get mfContact;

  /// Hide details button
  ///
  /// In en, this message translates to:
  /// **'Hide Details'**
  String get mfHideDetails;

  /// More details button
  ///
  /// In en, this message translates to:
  /// **'More Details'**
  String get mfMoreDetails;

  /// MOQ label
  ///
  /// In en, this message translates to:
  /// **'Minimum Order Quantity'**
  String get mfMinimumOrderQuantity;

  /// Certifications label
  ///
  /// In en, this message translates to:
  /// **'Certifications'**
  String get mfCertifications;

  /// Products label
  ///
  /// In en, this message translates to:
  /// **'Products & Capabilities'**
  String get mfProductsCapabilities;

  /// Contact dialog title
  ///
  /// In en, this message translates to:
  /// **'Contact {name}'**
  String mfContactManufacturer(String name);

  /// Email label
  ///
  /// In en, this message translates to:
  /// **'Email'**
  String get mfEmail;

  /// Website label
  ///
  /// In en, this message translates to:
  /// **'Website'**
  String get mfWebsite;

  /// Instagram label
  ///
  /// In en, this message translates to:
  /// **'Instagram'**
  String get mfInstagram;

  /// Not available text
  ///
  /// In en, this message translates to:
  /// **'Not available'**
  String get mfNotAvailable;

  /// Close button
  ///
  /// In en, this message translates to:
  /// **'Close'**
  String get mfClose;

  /// Error title
  ///
  /// In en, this message translates to:
  /// **'Error'**
  String get mfError;

  /// Email not available error
  ///
  /// In en, this message translates to:
  /// **'Email not available'**
  String get mfEmailNotAvailable;

  /// Website not available error
  ///
  /// In en, this message translates to:
  /// **'Website not available'**
  String get mfWebsiteNotAvailable;

  /// Link open error
  ///
  /// In en, this message translates to:
  /// **'Could not open link'**
  String get mfCouldNotOpenLink;

  /// No email available snackbar title
  ///
  /// In en, this message translates to:
  /// **'No Email Available'**
  String get mfNoEmailAvailable;

  /// No email message
  ///
  /// In en, this message translates to:
  /// **'This manufacturer does not have an email address on file.'**
  String get mfManufacturerNoEmail;

  /// Email sent success title
  ///
  /// In en, this message translates to:
  /// **'Email Sent Successfully!'**
  String get mfEmailSentSuccessfully;

  /// Email sent success message
  ///
  /// In en, this message translates to:
  /// **'Your tech pack has been sent to {name} at {email}'**
  String mfTechPackSentTo(String name, String email);

  /// Email failed title
  ///
  /// In en, this message translates to:
  /// **'Email Failed'**
  String get mfEmailFailed;

  /// Email failed message
  ///
  /// In en, this message translates to:
  /// **'Failed to send email to {name}. Please try again.'**
  String mfFailedToSendEmail(String name);

  /// Email error message
  ///
  /// In en, this message translates to:
  /// **'An error occurred while sending email: {error}'**
  String mfErrorSendingEmail(String error);

  /// Preview email dialog title
  ///
  /// In en, this message translates to:
  /// **'Preview Email'**
  String get mfPreviewEmail;

  /// Cancel button
  ///
  /// In en, this message translates to:
  /// **'Cancel'**
  String get mfCancel;

  /// Send email button
  ///
  /// In en, this message translates to:
  /// **'Send Email'**
  String get mfSendEmail;

  /// Tech pack summary label
  ///
  /// In en, this message translates to:
  /// **'Tech Pack Summary'**
  String get mfTechPackSummary;

  /// Material label
  ///
  /// In en, this message translates to:
  /// **'Material'**
  String get mfMaterial;

  /// Primary color label
  ///
  /// In en, this message translates to:
  /// **'Primary Color'**
  String get mfPrimaryColor;

  /// Size range label
  ///
  /// In en, this message translates to:
  /// **'Size Range'**
  String get mfSizeRange;

  /// Quantity label
  ///
  /// In en, this message translates to:
  /// **'Quantity'**
  String get mfQuantity;

  /// Target cost label
  ///
  /// In en, this message translates to:
  /// **'Target Cost'**
  String get mfTargetCost;

  /// Delivery label
  ///
  /// In en, this message translates to:
  /// **'Delivery'**
  String get mfDelivery;

  /// PDF attachment info
  ///
  /// In en, this message translates to:
  /// **'PDF attachment: {name} ({size} KB)'**
  String mfPDFAttachment(String name, String size);

  /// Images attached count
  ///
  /// In en, this message translates to:
  /// **'Images attached: {count}'**
  String mfImagesAttached(int count);

  /// Tech Pack Details screen title
  ///
  /// In en, this message translates to:
  /// **'Final Design Validated'**
  String get tpdFinalDesignValidated;

  /// Materials section title
  ///
  /// In en, this message translates to:
  /// **'Materials & Fabrics'**
  String get tpdMaterialsFabrics;

  /// Main fabric question label
  ///
  /// In en, this message translates to:
  /// **'What is the main fabric used?'**
  String get tpdMainFabricLabel;

  /// Main fabric hint text
  ///
  /// In en, this message translates to:
  /// **'Main Fabric: Organic cotton twill'**
  String get tpdMainFabricHint;

  /// Secondary materials question label
  ///
  /// In en, this message translates to:
  /// **'Are there any secondary materials or linings?'**
  String get tpdSecondaryMaterialsLabel;

  /// Secondary materials hint text
  ///
  /// In en, this message translates to:
  /// **'Polyester mesh lining'**
  String get tpdSecondaryMaterialsHint;

  /// Fabric properties question label
  ///
  /// In en, this message translates to:
  /// **'Does the fabric have any technical properties? (e.g. organic, stretch, water-repellent)'**
  String get tpdFabricPropertiesLabel;

  /// Fabric properties hint text
  ///
  /// In en, this message translates to:
  /// **'Breathable, stretchable, water-repellent'**
  String get tpdFabricPropertiesHint;

  /// Colors section title
  ///
  /// In en, this message translates to:
  /// **'Colors'**
  String get tpdColors;

  /// Primary color question label
  ///
  /// In en, this message translates to:
  /// **'What is the primary color of the garment?'**
  String get tpdPrimaryColorLabel;

  /// Primary color hint text
  ///
  /// In en, this message translates to:
  /// **'Sky blue'**
  String get tpdPrimaryColorHint;

  /// Alternate colorways question label
  ///
  /// In en, this message translates to:
  /// **'Are there any alternate colorways to produce?'**
  String get tpdAlternateColorwaysLabel;

  /// Alternate colorways hint text
  ///
  /// In en, this message translates to:
  /// **'Sage green, off-white'**
  String get tpdAlternateColorwaysHint;

  /// Pantone question label
  ///
  /// In en, this message translates to:
  /// **'Do you have Pantone references or HEX codes for the colors?'**
  String get tpdPantoneLabel;

  /// Pantone hint text
  ///
  /// In en, this message translates to:
  /// **'Pantone 290C, #C1DAD6'**
  String get tpdPantoneHint;

  /// Sizes section title
  ///
  /// In en, this message translates to:
  /// **'Sizes & Measurements'**
  String get tpdSizesMeasurements;

  /// Size range question label
  ///
  /// In en, this message translates to:
  /// **'Do you want to use standard size charts or enter custom measurements? (e.g. XS–XL)'**
  String get tpdSizeRangeLabel;

  /// Size range hint text
  ///
  /// In en, this message translates to:
  /// **'Size Range: XS, S, M, L, XL'**
  String get tpdSizeRangeHint;

  /// Measurement chart question label
  ///
  /// In en, this message translates to:
  /// **'Will you provide a measurement chart by size?'**
  String get tpdMeasurementChartLabel;

  /// Measurement chart hint text
  ///
  /// In en, this message translates to:
  /// **'No'**
  String get tpdMeasurementChartHint;

  /// Or separator text
  ///
  /// In en, this message translates to:
  /// **'or'**
  String get tpdOr;

  /// Auto-generated question label
  ///
  /// In en, this message translates to:
  /// **'Or should the AI auto-generate one from the 3D model?'**
  String get tpdAutogeneratedLabel;

  /// Auto-generated hint text
  ///
  /// In en, this message translates to:
  /// **'Yes'**
  String get tpdAutogeneratedHint;

  /// Technical details section title
  ///
  /// In en, this message translates to:
  /// **'Technical Details'**
  String get tpdTechnicalDetails;

  /// Accessories question label
  ///
  /// In en, this message translates to:
  /// **'Are there any accessories?'**
  String get tpdAccessoriesLabel;

  /// Accessories hint text
  ///
  /// In en, this message translates to:
  /// **'Zipper, buttons, drawcord'**
  String get tpdAccessoriesHint;

  /// Stitching question label
  ///
  /// In en, this message translates to:
  /// **'Which stitch type should be used?'**
  String get tpdStitchingLabel;

  /// Stitching hint text
  ///
  /// In en, this message translates to:
  /// **'Single, double, overlock etc'**
  String get tpdStitchingHint;

  /// Decorative stitching question label
  ///
  /// In en, this message translates to:
  /// **'Do you require visible, reinforced, or decorative stitching?'**
  String get tpdDecorativeStitchingLabel;

  /// Decorative stitching hint text
  ///
  /// In en, this message translates to:
  /// **'Contrast topstitching sleeves'**
  String get tpdDecorativeStitchingHint;

  /// Labeling section title
  ///
  /// In en, this message translates to:
  /// **'Labeling & Branding'**
  String get tpdLabelingBranding;

  /// Logo placement question label
  ///
  /// In en, this message translates to:
  /// **'Where should the logo or brand name appear?'**
  String get tpdLogoPlacementLabel;

  /// Logo placement hint text
  ///
  /// In en, this message translates to:
  /// **'Logo Placement: Chest & neck'**
  String get tpdLogoPlacementHint;

  /// Labels needed question label
  ///
  /// In en, this message translates to:
  /// **'What types of labels are needed?'**
  String get tpdLabelsNeededLabel;

  /// Labels needed hint text
  ///
  /// In en, this message translates to:
  /// **'Brand, care, size'**
  String get tpdLabelsNeededHint;

  /// Upload image instruction
  ///
  /// In en, this message translates to:
  /// **'Upload reference image (optional)'**
  String get tpdUploadReferenceImage;

  /// QR code question label
  ///
  /// In en, this message translates to:
  /// **'Should a QR code, barcode, or NFC chip be included?'**
  String get tpdQrCodeLabel;

  /// QR code hint text
  ///
  /// In en, this message translates to:
  /// **'Add QR code'**
  String get tpdQrCodeHint;

  /// Packaging section title
  ///
  /// In en, this message translates to:
  /// **'Packaging & Shipping'**
  String get tpdPackagingShipping;

  /// Packaging type question label
  ///
  /// In en, this message translates to:
  /// **'What type of packaging is required?'**
  String get tpdPackagingTypeLabel;

  /// Packaging type hint text
  ///
  /// In en, this message translates to:
  /// **'Kraft box + polybag'**
  String get tpdPackagingTypeHint;

  /// Folding instructions question label
  ///
  /// In en, this message translates to:
  /// **'Any specific folding or packing instructions?'**
  String get tpdFoldingInstructionsLabel;

  /// Folding instructions hint text
  ///
  /// In en, this message translates to:
  /// **'Fold across chest'**
  String get tpdFoldingInstructionsHint;

  /// Inserts question label
  ///
  /// In en, this message translates to:
  /// **'Would you like to include a product sheet or flyer?'**
  String get tpdInsertsLabel;

  /// Inserts hint text
  ///
  /// In en, this message translates to:
  /// **'Inserts: Thank-you card, care sheet'**
  String get tpdInsertsHint;

  /// Production details section title
  ///
  /// In en, this message translates to:
  /// **'Production Details'**
  String get tpdProductionDetails;

  /// Cost per piece question label
  ///
  /// In en, this message translates to:
  /// **'What is the target cost per piece?'**
  String get tpdCostPerPieceLabel;

  /// Cost per piece hint text
  ///
  /// In en, this message translates to:
  /// **'Cost per Piece: €3.8'**
  String get tpdCostPerPieceHint;

  /// Quantity question label
  ///
  /// In en, this message translates to:
  /// **'How many units do you plan to produce?'**
  String get tpdQuantityLabel;

  /// Quantity hint text
  ///
  /// In en, this message translates to:
  /// **'Quantity: 1,000 units'**
  String get tpdQuantityHint;

  /// Delivery date question label
  ///
  /// In en, this message translates to:
  /// **'What is your desired delivery date?'**
  String get tpdDeliveryDateLabel;

  /// Delivery date hint text
  ///
  /// In en, this message translates to:
  /// **'Delivery: 30 Sept 2025'**
  String get tpdDeliveryDateHint;

  /// Manufacturers section title
  ///
  /// In en, this message translates to:
  /// **'Manufacturers'**
  String get tpdManufacturers;

  /// Manufacturer country selection instruction
  ///
  /// In en, this message translates to:
  /// **'Select a country for manufacturer suggestions'**
  String get tpdSelectCountryForManufacturers;

  /// Country search label
  ///
  /// In en, this message translates to:
  /// **'Search'**
  String get tpdSearchCountry;

  /// Country search hint
  ///
  /// In en, this message translates to:
  /// **'Start typing to search'**
  String get tpdSearchCountryHint;

  /// Country selection placeholder
  ///
  /// In en, this message translates to:
  /// **'Select a country'**
  String get tpdSelectACountry;

  /// Generate tech pack button
  ///
  /// In en, this message translates to:
  /// **'Generate Tech Pack'**
  String get tpdGenerateTechPack;

  /// Tech pack ready screen title
  ///
  /// In en, this message translates to:
  /// **'Your Tech Pack Is \nReady'**
  String get tprYourTechPackReady;

  /// Generated images section title
  ///
  /// In en, this message translates to:
  /// **'Generated Tech Pack Images'**
  String get tprGeneratedTechPackImages;

  /// Creating tech pack loading message
  ///
  /// In en, this message translates to:
  /// **'Creating your tech pack...'**
  String get tprCreatingTechPack;

  /// Tech pack generation wait message
  ///
  /// In en, this message translates to:
  /// **'Please wait while we generate your tech pack images with all specifications.'**
  String get tprPleaseWaitGenerating;

  /// Tech pack details section title
  ///
  /// In en, this message translates to:
  /// **'Tech Pack Details'**
  String get tprTechPackDetails;

  /// Technical flat drawing section title
  ///
  /// In en, this message translates to:
  /// **'Technical Flat Drawing'**
  String get tprTechnicalFlatDrawing;

  /// Generating status text
  ///
  /// In en, this message translates to:
  /// **'Generating'**
  String get tprGenerating;

  /// Logo with placement text
  ///
  /// In en, this message translates to:
  /// **'Logo / {placement}'**
  String tprLogoPlacement(String placement);

  /// Empty state message for tech pack images
  ///
  /// In en, this message translates to:
  /// **'No tech pack images generated yet'**
  String get tprNoTechPackImages;

  /// Warning dialog title
  ///
  /// In en, this message translates to:
  /// **'Warning'**
  String get tprWarningTitle;

  /// Warning message when user tries to navigate back during generation
  ///
  /// In en, this message translates to:
  /// **'Generation is in progress. Going back will cancel the generation and you will lose your tech pack. Are you sure?'**
  String get tprNavigationWarningMessage;

  /// Button to stay on current screen
  ///
  /// In en, this message translates to:
  /// **'Stay Here'**
  String get tprStayHere;

  /// Button to go back and cancel generation
  ///
  /// In en, this message translates to:
  /// **'Go Back'**
  String get tprGoBack;

  /// Message shown when user tries to generate while generation is already in progress
  ///
  /// In en, this message translates to:
  /// **'Tech pack generation already in progress. Please wait...'**
  String get tprGenerationInProgress;

  /// Get manufacturer suggestions button text
  ///
  /// In en, this message translates to:
  /// **'Get Manufacturer Suggestions'**
  String get tprGetManufacturerSuggestions;

  /// Collection exists snackbar title
  ///
  /// In en, this message translates to:
  /// **'Collection Exists'**
  String get tprCollectionExists;

  /// Collection exists snackbar message
  ///
  /// In en, this message translates to:
  /// **'This collection already exists'**
  String get tprCollectionAlreadyExists;

  /// Error snackbar title
  ///
  /// In en, this message translates to:
  /// **'Error'**
  String get tprError;

  /// Failed to add collection error message
  ///
  /// In en, this message translates to:
  /// **'Failed to add collection'**
  String get tprFailedToAddCollection;

  /// No images snackbar title
  ///
  /// In en, this message translates to:
  /// **'No Images'**
  String get tprNoImages;

  /// Generate images first message
  ///
  /// In en, this message translates to:
  /// **'Please generate tech pack images first'**
  String get tprGenerateImagesFirst;

  /// Updated success snackbar title
  ///
  /// In en, this message translates to:
  /// **'Updated!'**
  String get tprUpdated;

  /// Tech pack updated success message
  ///
  /// In en, this message translates to:
  /// **'Tech pack updated successfully!'**
  String get tprTechPackUpdatedSuccessfully;

  /// Success snackbar title
  ///
  /// In en, this message translates to:
  /// **'Success'**
  String get tprSuccess;

  /// Tech pack saved success message
  ///
  /// In en, this message translates to:
  /// **'Tech pack saved successfully!'**
  String get tprTechPackSavedSuccessfully;

  /// Failed to save tech pack error message
  ///
  /// In en, this message translates to:
  /// **'Failed to save tech pack: {error}'**
  String tprFailedToSaveTechPack(String error);

  /// PDF saved success message
  ///
  /// In en, this message translates to:
  /// **'Tech pack PDF saved successfully!'**
  String get tprPdfSavedSuccessfully;

  /// Failed to export PDF error message
  ///
  /// In en, this message translates to:
  /// **'Failed to export PDF: {error}'**
  String tprFailedToExportPdf(String error);

  /// Failed to export Word document error message
  ///
  /// In en, this message translates to:
  /// **'Failed to export Word document: {error}'**
  String tprFailedToExportWord(String error);

  /// Failed to share file error message
  ///
  /// In en, this message translates to:
  /// **'Failed to share file: {error}'**
  String tprFailedToShareFile(String error);

  /// Tech pack document share text
  ///
  /// In en, this message translates to:
  /// **'Tech Pack Document'**
  String get tprTechPackDocument;

  /// Saving design snackbar title
  ///
  /// In en, this message translates to:
  /// **'Saving Design'**
  String get tprSavingDesign;

  /// Saving design snackbar message
  ///
  /// In en, this message translates to:
  /// **'Please wait while we finish saving your design...'**
  String get tprSavingDesignMessage;

  /// Save failed snackbar title
  ///
  /// In en, this message translates to:
  /// **'Save Failed'**
  String get tprSaveFailed;

  /// Design save failed error message
  ///
  /// In en, this message translates to:
  /// **'Failed to verify design save status. Please try again.'**
  String get tprDesignSaveFailedMessage;

  /// Design save timeout error message
  ///
  /// In en, this message translates to:
  /// **'Design save is taking too long. Please try again.'**
  String get tprDesignSaveTimeoutMessage;

  /// Manufacturer profile title
  ///
  /// In en, this message translates to:
  /// **'Manufacturer Profile'**
  String get vpManufacturerProfile;

  /// Company label
  ///
  /// In en, this message translates to:
  /// **'Company'**
  String get vpCompany;

  /// Location label
  ///
  /// In en, this message translates to:
  /// **'Location'**
  String get vpLocation;

  /// Minimum order quantity label
  ///
  /// In en, this message translates to:
  /// **'Minimum Order Quantity'**
  String get vpMinimumOrderQuantity;

  /// Lead time label
  ///
  /// In en, this message translates to:
  /// **'Lead Time'**
  String get vpLeadTime;

  /// About section label
  ///
  /// In en, this message translates to:
  /// **'About'**
  String get vpAbout;

  /// Contact button text
  ///
  /// In en, this message translates to:
  /// **'Contact'**
  String get vpContact;

  /// Save tech pack dialog title
  ///
  /// In en, this message translates to:
  /// **'Save Tech Pack'**
  String get tpwSaveTechPack;

  /// Project name field label
  ///
  /// In en, this message translates to:
  /// **'Project Name'**
  String get tpwProjectName;

  /// Project name field hint
  ///
  /// In en, this message translates to:
  /// **'Enter project name'**
  String get tpwEnterProjectName;

  /// Collection name field label
  ///
  /// In en, this message translates to:
  /// **'Collection Name'**
  String get tpwCollectionName;

  /// Add collection button text
  ///
  /// In en, this message translates to:
  /// **'ADD'**
  String get tpwAdd;

  /// Save button text
  ///
  /// In en, this message translates to:
  /// **'SAVE'**
  String get tpwSave;

  /// Error snackbar title
  ///
  /// In en, this message translates to:
  /// **'Error'**
  String get tpwError;

  /// Project name validation error message
  ///
  /// In en, this message translates to:
  /// **'Please enter a project name'**
  String get tpwPleaseEnterProjectName;

  /// Add collection dialog title
  ///
  /// In en, this message translates to:
  /// **'ADD COLLECTION'**
  String get tpwAddCollection;

  /// Collection name field hint
  ///
  /// In en, this message translates to:
  /// **'Enter collection name'**
  String get tpwEnterCollectionName;

  /// Collection name validation error message
  ///
  /// In en, this message translates to:
  /// **'Please enter a collection name'**
  String get tpwPleaseEnterCollectionName;

  /// Export options dialog title
  ///
  /// In en, this message translates to:
  /// **'Export Options'**
  String get tpwExportOptions;

  /// Export options dialog subtitle
  ///
  /// In en, this message translates to:
  /// **'Select your preferred export format'**
  String get tpwSelectExportFormat;

  /// PDF with logo export option label
  ///
  /// In en, this message translates to:
  /// **'PDF with logo/branding'**
  String get tpwPdfWithLogo;

  /// PDF with logo export option description
  ///
  /// In en, this message translates to:
  /// **'Includes ATELIA branding and logo'**
  String get tpwIncludesAtellaBranding;

  /// Neutral PDF export option label
  ///
  /// In en, this message translates to:
  /// **'Neutral PDF'**
  String get tpwNeutralPdf;

  /// Neutral PDF export option description
  ///
  /// In en, this message translates to:
  /// **'Clean PDF without branding'**
  String get tpwCleanPdfWithoutBranding;

  /// Word export option label
  ///
  /// In en, this message translates to:
  /// **'Editable Format (Word)'**
  String get tpwEditableFormatWord;

  /// Word export option description
  ///
  /// In en, this message translates to:
  /// **'Editable Word document with cover page and images'**
  String get tpwEditableWordDocument;

  /// Cancel button text
  ///
  /// In en, this message translates to:
  /// **'Cancel'**
  String get tpwCancel;

  /// OK button text
  ///
  /// In en, this message translates to:
  /// **'OK'**
  String get tpwOk;

  /// Save button label
  ///
  /// In en, this message translates to:
  /// **'Save'**
  String get tpwSaveButton;

  /// Export button label
  ///
  /// In en, this message translates to:
  /// **'Export'**
  String get tpwExportButton;

  /// Generating status text
  ///
  /// In en, this message translates to:
  /// **'Generating..'**
  String get tpwGenerating;

  /// Edit mode snackbar title
  ///
  /// In en, this message translates to:
  /// **'Edit Mode'**
  String get tpdEditMode;

  /// Loading existing tech pack message
  ///
  /// In en, this message translates to:
  /// **'Loading existing tech pack data...'**
  String get tpdLoadingExistingTechPack;

  /// Notice snackbar title
  ///
  /// In en, this message translates to:
  /// **'Notice'**
  String get tpdNotice;

  /// Starting with empty form message
  ///
  /// In en, this message translates to:
  /// **'Starting with empty tech pack form'**
  String get tpdStartingWithEmptyForm;

  /// Success snackbar title
  ///
  /// In en, this message translates to:
  /// **'Success'**
  String get tpdSuccess;

  /// Tech pack images generated success message
  ///
  /// In en, this message translates to:
  /// **'Detailed tech pack images generated with professional labeling!'**
  String get tpdTechPackImagesGenerated;

  /// Partial success snackbar title
  ///
  /// In en, this message translates to:
  /// **'Partial Success'**
  String get tpdPartialSuccess;

  /// Partial tech pack generation message
  ///
  /// In en, this message translates to:
  /// **'Some tech pack images generated. Check results.'**
  String get tpdSomeTechPackImagesGenerated;

  /// Error snackbar title
  ///
  /// In en, this message translates to:
  /// **'Error'**
  String get tpdError;

  /// Failed to generate tech pack error message
  ///
  /// In en, this message translates to:
  /// **'Failed to generate detailed tech pack images: {error}'**
  String tpdFailedToGenerateTechPack(String error);

  /// Failed to pick image error message
  ///
  /// In en, this message translates to:
  /// **'Failed to pick image: {error}'**
  String tpdFailedToPickImage(String error);

  /// Processing snackbar title
  ///
  /// In en, this message translates to:
  /// **'Processing'**
  String get tpdProcessing;

  /// Processing purchase message
  ///
  /// In en, this message translates to:
  /// **'Processing your purchase...'**
  String get tpdProcessingYourPurchase;

  /// Success with exclamation snackbar title
  ///
  /// In en, this message translates to:
  /// **'Success!'**
  String get tpdSuccessExclamation;

  /// Additional tech packs added success message
  ///
  /// In en, this message translates to:
  /// **'You now have {count} additional techpacks for this month!'**
  String tpdAdditionalTechPacksAdded(String count);

  /// Purchase failed snackbar title
  ///
  /// In en, this message translates to:
  /// **'Purchase Failed'**
  String get tpdPurchaseFailed;

  /// Unable to process purchase message
  ///
  /// In en, this message translates to:
  /// **'Unable to process your purchase. Please try again.'**
  String get tpdUnableToProcessPurchase;

  /// Purchase error message
  ///
  /// In en, this message translates to:
  /// **'An error occurred during purchase: {error}'**
  String tpdPurchaseError(String error);

  /// Design number label
  ///
  /// In en, this message translates to:
  /// **'Design {number}'**
  String tpgDesignNumber(String number);

  /// Generating status text
  ///
  /// In en, this message translates to:
  /// **'Generating'**
  String get tpgGenerating;

  /// Failed to generate error message
  ///
  /// In en, this message translates to:
  /// **'Failed to generate'**
  String get tpgFailedToGenerate;

  /// Failed to load image error message
  ///
  /// In en, this message translates to:
  /// **'Failed to load image'**
  String get tpgFailedToLoadImage;

  /// Cancellation reason option
  ///
  /// In en, this message translates to:
  /// **'Too expensive'**
  String get cancellationReasonTooExpensive;

  /// Cancellation reason option
  ///
  /// In en, this message translates to:
  /// **'Not using it enough'**
  String get cancellationReasonNotUsing;

  /// Cancellation reason option
  ///
  /// In en, this message translates to:
  /// **'Missing features I need'**
  String get cancellationReasonMissingFeatures;

  /// Cancellation reason option
  ///
  /// In en, this message translates to:
  /// **'Found a better alternative'**
  String get cancellationReasonBetterAlternative;

  /// Cancellation reason option
  ///
  /// In en, this message translates to:
  /// **'Technical issues'**
  String get cancellationReasonTechnicalIssues;

  /// Cancellation reason option
  ///
  /// In en, this message translates to:
  /// **'Other'**
  String get cancellationReasonOther;

  /// Studio plan description
  ///
  /// In en, this message translates to:
  /// **'For studios, agencies, and power users'**
  String get studioDescription;

  /// Studio plan feature - design limit
  ///
  /// In en, this message translates to:
  /// **'25 AI design generations per month'**
  String get studioFeatureAiDesignLimit;

  /// Studio plan feature - monthly techpack limit
  ///
  /// In en, this message translates to:
  /// **'10 techpacks per month'**
  String get studioFeatureTechpackMonthly;

  /// Studio plan feature - yearly techpack limit
  ///
  /// In en, this message translates to:
  /// **'10 techpacks per month (120 per year)'**
  String get studioFeatureTechpackYearly;

  /// Studio plan name
  ///
  /// In en, this message translates to:
  /// **'Studio'**
  String get studio;

  /// Dynamic placeholder for custom category input
  ///
  /// In en, this message translates to:
  /// **'Enter custom {category}...'**
  String cbEnterCustom(String category);

  /// Question about target season for the design
  ///
  /// In en, this message translates to:
  /// **'Great! Let\'s make sure your piece fits perfectly with the season. What kind of weather will it be designed for?'**
  String get fdQuestionTargetSeason;

  /// Summer season option
  ///
  /// In en, this message translates to:
  /// **'Summer (Lightweight, Short Or Roll-Up Sleeves)'**
  String get fdSeasonSummer;

  /// Mid-season option
  ///
  /// In en, this message translates to:
  /// **'Mid-Season'**
  String get fdSeasonMid;

  /// All-season option
  ///
  /// In en, this message translates to:
  /// **'All-Season (Layer-Friendly)'**
  String get fdSeasonAll;

  /// Question about target budget for the design
  ///
  /// In en, this message translates to:
  /// **'Got it. And what kind of budget are you working with for this design? I can tailor the fabrics and features accordingly.'**
  String get fdQuestionTargetBudget;

  /// Entry-level budget option
  ///
  /// In en, this message translates to:
  /// **'Entry-Level (€15-30 Production / €35-60 Retail)'**
  String get fdBudgetEntry;

  /// Mid-range budget option
  ///
  /// In en, this message translates to:
  /// **'Mid-Range (€30-50 Production / €60-120 Retail)'**
  String get fdBudgetMid;

  /// Premium budget option
  ///
  /// In en, this message translates to:
  /// **'Premium (€60+ Production / €120+ Retail)'**
  String get fdBudgetPremium;

  /// Question about desired features for the design
  ///
  /// In en, this message translates to:
  /// **'Would you like to include any special values or features that matter to you or your brand? I can make sure they\'re part of the final concept'**
  String get fdQuestionDesiredFeatures;

  /// Organic fabric feature option
  ///
  /// In en, this message translates to:
  /// **'Organic Fabric'**
  String get fdFeatureOrganic;

  /// Upcycled materials feature option
  ///
  /// In en, this message translates to:
  /// **'Upcycled Materials'**
  String get fdFeatureUpcycled;

  /// Locally made feature option
  ///
  /// In en, this message translates to:
  /// **'Locally Made (Europe)'**
  String get fdFeatureLocallyMade;

  /// UV protection feature option
  ///
  /// In en, this message translates to:
  /// **'UV Protection'**
  String get fdFeatureUvProtection;

  /// Quick-dry feature option
  ///
  /// In en, this message translates to:
  /// **'Quick-Dry'**
  String get fdFeatureQuickDry;

  /// Wrinkle-free feature option
  ///
  /// In en, this message translates to:
  /// **'Wrinkle-Free'**
  String get fdFeatureWrinkleFree;

  /// Other feature option with custom input
  ///
  /// In en, this message translates to:
  /// **'Other: ?'**
  String get fdFeatureOther;

  /// Question for additional details/custom input
  ///
  /// In en, this message translates to:
  /// **'Cool — feel free to type in anything else you have in mind!'**
  String get fdQuestionAdditionalDetails;

  /// Snackbar title when regenerating designs in edit mode
  ///
  /// In en, this message translates to:
  /// **'Regenerating Designs!'**
  String get fdRegeneratingDesigns;

  /// Snackbar message when regenerating designs
  ///
  /// In en, this message translates to:
  /// **'Creating 3 new designs based on your updated preferences...'**
  String get fdRegeneratingDesignsMessage;

  /// Snackbar title when generating new designs
  ///
  /// In en, this message translates to:
  /// **'Generating Designs!'**
  String get fdGeneratingDesigns;

  /// Snackbar message when generating designs
  ///
  /// In en, this message translates to:
  /// **'Creating 3 unique designs based on your preferences...'**
  String get fdGeneratingDesignsMessage;

  /// Snackbar title when extra designs are purchased
  ///
  /// In en, this message translates to:
  /// **'Extra Designs Added!'**
  String get fdExtraDesignsAdded;

  /// Snackbar message when extra designs are added
  ///
  /// In en, this message translates to:
  /// **'5 extra designs have been added to your account.'**
  String get fdExtraDesignsAddedMessage;

  /// Today timestamp format
  ///
  /// In en, this message translates to:
  /// **'Today, {time}'**
  String fdToday(String time);

  /// Error when Firebase user creation fails
  ///
  /// In en, this message translates to:
  /// **'User creation failed. Please try again.'**
  String get authUserCreationFailed;

  /// Generic authentication error message
  ///
  /// In en, this message translates to:
  /// **'An error occurred. Please try again.'**
  String get authGenericError;

  /// Error when email is already registered
  ///
  /// In en, this message translates to:
  /// **'This email is already registered. Please sign in instead.'**
  String get authEmailAlreadyInUse;

  /// Error when password doesn't meet requirements
  ///
  /// In en, this message translates to:
  /// **'Password is too weak. Please use a stronger password.'**
  String get authWeakPassword;

  /// Error when email format is invalid
  ///
  /// In en, this message translates to:
  /// **'Invalid email address. Please check and try again.'**
  String get authInvalidEmail;

  /// Error when operation is disabled
  ///
  /// In en, this message translates to:
  /// **'This operation is not allowed. Please contact support.'**
  String get authOperationNotAllowed;

  /// Error when email doesn't exist
  ///
  /// In en, this message translates to:
  /// **'No user found with this email. Please sign up first.'**
  String get authUserNotFound;

  /// Error when wrong password is entered
  ///
  /// In en, this message translates to:
  /// **'Incorrect password. Please try again.'**
  String get authWrongPassword;

  /// Error when account is disabled
  ///
  /// In en, this message translates to:
  /// **'This account has been disabled. Please contact support.'**
  String get authUserDisabled;

  /// Error when too many login attempts
  ///
  /// In en, this message translates to:
  /// **'Too many failed attempts. Please try again later.'**
  String get authTooManyRequests;

  /// Error when network request fails
  ///
  /// In en, this message translates to:
  /// **'Network error. Please check your internet connection.'**
  String get authNetworkError;

  /// Error when user cancels Google sign-in
  ///
  /// In en, this message translates to:
  /// **'Google sign-in was cancelled.'**
  String get authGoogleSignInCancelled;

  /// Error when Google authentication fails
  ///
  /// In en, this message translates to:
  /// **'Google sign-in failed. Please try again.'**
  String get authGoogleSignInFailed;

  /// Error when SHA-1 not configured
  ///
  /// In en, this message translates to:
  /// **'Configuration error. Please contact support.'**
  String get authGoogleConfigError;

  /// Generic Google sign-in error
  ///
  /// In en, this message translates to:
  /// **'An error occurred during Google sign-in. Please try again.'**
  String get authGoogleGenericError;

  /// Apple sign-in cancelled by user
  ///
  /// In en, this message translates to:
  /// **'Apple sign-in was cancelled.'**
  String get authAppleSignInCancelled;

  /// Apple sign-in failed error
  ///
  /// In en, this message translates to:
  /// **'Apple sign-in failed. Please try again.'**
  String get authAppleSignInFailed;

  /// Error when login credentials are invalid (user not found or wrong password)
  ///
  /// In en, this message translates to:
  /// **'Incorrect email or password. Please try again.'**
  String get authInvalidCredentials;

  /// Name of the summer collection
  ///
  /// In en, this message translates to:
  /// **'SUMMER COLLECTION'**
  String get collectionSummer;

  /// Name of the winter collection
  ///
  /// In en, this message translates to:
  /// **'WINTER COLLECTION'**
  String get collectionWinter;

  /// Terms and Conditions screen title
  ///
  /// In en, this message translates to:
  /// **'Terms & Conditions'**
  String get termsAndConditions;

  /// Last updated date for terms and conditions
  ///
  /// In en, this message translates to:
  /// **'Last updated: January 2025'**
  String get tcLastUpdated;

  /// Introduction text for terms and conditions
  ///
  /// In en, this message translates to:
  /// **'These Terms & Conditions govern your access to and use of the Atelia mobile application, website, and services.\n\nBy downloading, accessing, or using Atelia, you agree to these Terms.'**
  String get tcIntroduction;

  /// Section title: Company Information
  ///
  /// In en, this message translates to:
  /// **'Company Information'**
  String get tcCompanyInformation;

  /// Content for Company Information section
  ///
  /// In en, this message translates to:
  /// **'Atelia SAS – France\nRegistered office: Guérande, France\nContact email: ateliadesign.contact@gmail.com'**
  String get tcCompanyInformationContent;

  /// Section title: Description of the Service
  ///
  /// In en, this message translates to:
  /// **'Description of the Service'**
  String get tcDescriptionOfService;

  /// Content for Description of Service section
  ///
  /// In en, this message translates to:
  /// **'Atelia is a SaaS platform that allows users to:\n• Generate fashion designs using AI\n• Create technical packs (techpacks)\n• Visualize designs in 3D\n• Access a directory of garment manufacturers\n• Export files and documents related to production\n\nAtelia provides assistance tools and does not replace professional designers, manufacturers, or consultants.'**
  String get tcDescriptionOfServiceContent;

  /// Section title: Eligibility
  ///
  /// In en, this message translates to:
  /// **'Eligibility'**
  String get tcEligibility;

  /// Content for Eligibility section
  ///
  /// In en, this message translates to:
  /// **'• You must be at least 16 years old\n• You must have the legal capacity to enter into a contract\n• You are responsible for ensuring your use complies with local laws'**
  String get tcEligibilityContent;

  /// Section title: User Account
  ///
  /// In en, this message translates to:
  /// **'User Account'**
  String get tcUserAccount;

  /// Content for User Account section
  ///
  /// In en, this message translates to:
  /// **'• You are responsible for maintaining the confidentiality of your login credentials\n• You are responsible for all activity under your account\n• Atelia reserves the right to suspend or terminate accounts for misuse or violation of these Terms'**
  String get tcUserAccountContent;

  /// Section title: Subscriptions & Payments
  ///
  /// In en, this message translates to:
  /// **'Subscriptions & Payments'**
  String get tcSubscriptionsAndPayments;

  /// Content for Subscriptions & Payments section
  ///
  /// In en, this message translates to:
  /// **'Atelia offers free and paid subscription plans. Details of pricing, limits, and features are displayed inside the app.\n\nSubscriptions may include:\n• Monthly or yearly billing\n• Usage limits (designs, techpacks, exports)\n• Optional add-ons\n\nPayments are processed through Apple App Store (iOS) or Google Play Store (Android). Atelia does not store payment information.\n\nSubscriptions automatically renew unless canceled at least 24 hours before the end of the current period. You can manage or cancel your subscription via Apple ID settings or Google Play account settings.\n\nRefunds are managed exclusively by Apple or Google, according to their respective policies. Atelia cannot issue refunds directly.'**
  String get tcSubscriptionsAndPaymentsContent;

  /// Section title: Usage Limits & Fair Use
  ///
  /// In en, this message translates to:
  /// **'Usage Limits & Fair Use'**
  String get tcUsageLimits;

  /// Content for Usage Limits section
  ///
  /// In en, this message translates to:
  /// **'Each subscription plan includes usage limits.\n• Unused credits do not roll over\n• Abuse or excessive usage may result in temporary limitations or account suspension\n• Atelia reserves the right to modify usage limits to ensure service stability'**
  String get tcUsageLimitsContent;

  /// Section title: Intellectual Property
  ///
  /// In en, this message translates to:
  /// **'Intellectual Property'**
  String get tcIntellectualProperty;

  /// Content for Intellectual Property section
  ///
  /// In en, this message translates to:
  /// **'All software, trademarks, logos, and content are owned by Atelia. You may not copy, modify, or redistribute Atelia\'s platform without authorization.\n\nYou retain ownership of the content you create. You grant Atelia a non-exclusive license to process and store content to provide the service. Atelia does not claim ownership over your designs.'**
  String get tcIntellectualPropertyContent;

  /// Section title: AI-Generated Content Disclaimer
  ///
  /// In en, this message translates to:
  /// **'AI-Generated Content Disclaimer'**
  String get tcAIContentDisclaimer;

  /// Content for AI-Generated Content Disclaimer section
  ///
  /// In en, this message translates to:
  /// **'• AI-generated designs and techpacks are suggestions, not guarantees\n• Atelia does not guarantee manufacturability, compliance, or production success\n• Users remain fully responsible for verifying outputs before production'**
  String get tcAIContentDisclaimerContent;

  /// Section title: Factory Directory Disclaimer
  ///
  /// In en, this message translates to:
  /// **'Factory Directory Disclaimer'**
  String get tcFactoryDirectoryDisclaimer;

  /// Content for Factory Directory Disclaimer section
  ///
  /// In en, this message translates to:
  /// **'• Atelia does not own or operate the listed factories\n• Atelia is not responsible for contracts, pricing, quality, or disputes between users and manufacturers\n• Any collaboration is strictly between the user and the factory'**
  String get tcFactoryDirectoryDisclaimerContent;

  /// Section title: Limitation of Liability
  ///
  /// In en, this message translates to:
  /// **'Limitation of Liability'**
  String get tcLimitationOfLiability;

  /// Content for Limitation of Liability section
  ///
  /// In en, this message translates to:
  /// **'To the maximum extent permitted by law:\n• Atelia is not liable for indirect or consequential damages\n• Atelia is not responsible for financial losses, production issues, or business failure\n• Total liability shall not exceed the amount paid by the user in the last 12 months'**
  String get tcLimitationOfLiabilityContent;

  /// Section title: Service Availability
  ///
  /// In en, this message translates to:
  /// **'Service Availability'**
  String get tcServiceAvailability;

  /// Content for Service Availability section
  ///
  /// In en, this message translates to:
  /// **'• Atelia strives for high availability but does not guarantee uninterrupted access\n• Features may be modified, suspended, or discontinued at any time'**
  String get tcServiceAvailabilityContent;

  /// Section title: Termination
  ///
  /// In en, this message translates to:
  /// **'Termination'**
  String get tcTermination;

  /// Content for Termination section
  ///
  /// In en, this message translates to:
  /// **'You may stop using Atelia at any time.\n\nAtelia may terminate access in case of:\n• Breach of these Terms\n• Fraud or abuse\n• Legal obligations'**
  String get tcTerminationContent;

  /// Section title: Privacy
  ///
  /// In en, this message translates to:
  /// **'Privacy'**
  String get tcPrivacy;

  /// Content for Privacy section
  ///
  /// In en, this message translates to:
  /// **'Your use of Atelia is governed by our Privacy Policy, available at:\nhttps://www.atelia.ai/privacy'**
  String get tcPrivacyContent;

  /// Section title: Governing Law
  ///
  /// In en, this message translates to:
  /// **'Governing Law'**
  String get tcGoverningLaw;

  /// Content for Governing Law section
  ///
  /// In en, this message translates to:
  /// **'These Terms are governed by French law.\n\nAny dispute shall be subject to the jurisdiction of the courts of France.'**
  String get tcGoverningLawContent;

  /// Section title: Changes to Terms
  ///
  /// In en, this message translates to:
  /// **'Changes to Terms'**
  String get tcChangesToTerms;

  /// Content for Changes to Terms section
  ///
  /// In en, this message translates to:
  /// **'Atelia may update these Terms at any time. Continued use of the app constitutes acceptance of the updated Terms.'**
  String get tcChangesToTermsContent;

  /// Section title: Contact
  ///
  /// In en, this message translates to:
  /// **'Contact'**
  String get tcContact;

  /// Content for Contact section
  ///
  /// In en, this message translates to:
  /// **'For any questions or concerns regarding these Terms & Conditions, please contact us at:\n\nateliadesign.contact@gmail.com'**
  String get tcContactContent;

  /// Last updated date for privacy policy
  ///
  /// In en, this message translates to:
  /// **'Last updated: January 2025'**
  String get ppLastUpdated;

  /// Introduction text for privacy policy
  ///
  /// In en, this message translates to:
  /// **'Atelia operates the Atelia mobile application and web platform.\n\nThis Privacy Policy explains how we collect, use, disclose, and protect your information when you use our Service.\n\nBy accessing or using Atelia, you agree to the collection and use of information in accordance with this Privacy Policy.'**
  String get ppIntroduction;

  /// Section title: Information We Collect
  ///
  /// In en, this message translates to:
  /// **'1. Information We Collect'**
  String get ppInformationWeCollect;

  /// Content for Information We Collect section
  ///
  /// In en, this message translates to:
  /// **'a. Personal Information\n\nWhen you create an account or use our Service, we may collect:\n• Name or username\n• Email address\n• Payment and billing information (processed securely by third-party providers)\n• Account preferences\n\nb. Usage Data\n\nWe automatically collect information such as:\n• Device type, operating system, and app version\n• IP address and approximate location\n• Pages/screens viewed and features used\n• Time and date of usage\n\nc. User Content\n\nWhen you use Atelia, you may provide:\n• Design prompts and inputs\n• Generated designs and techpacks\n• Files or content uploaded to the platform\n\nWe do not claim ownership over your content.'**
  String get ppInformationWeCollectContent;

  /// Section title: How We Use Your Information
  ///
  /// In en, this message translates to:
  /// **'2. How We Use Your Information'**
  String get ppHowWeUseYourInformation;

  /// Content for How We Use Your Information section
  ///
  /// In en, this message translates to:
  /// **'We use your data to:\n• Provide and operate the Service\n• Generate AI-based designs and techpacks\n• Manage subscriptions and payments\n• Improve product performance and user experience\n• Communicate updates, support messages, and important notices\n• Detect fraud, abuse, or misuse of the Service'**
  String get ppHowWeUseYourInformationContent;

  /// Section title: AI & Third-Party Services
  ///
  /// In en, this message translates to:
  /// **'3. AI & Third-Party Services'**
  String get ppAIAndThirdPartyServices;

  /// Content for AI & Third-Party Services section
  ///
  /// In en, this message translates to:
  /// **'Atelia uses third-party services to operate:\n• AI model providers\n• Cloud infrastructure and hosting\n• Analytics and performance monitoring\n• Payment processors\n\nYour data may be processed by these providers only to deliver the Service and in accordance with applicable data protection laws.'**
  String get ppAIAndThirdPartyServicesContent;

  /// Section title: Data Retention
  ///
  /// In en, this message translates to:
  /// **'4. Data Retention'**
  String get ppDataRetention;

  /// Content for Data Retention section
  ///
  /// In en, this message translates to:
  /// **'We retain personal data only for as long as necessary to:\n• Provide the Service\n• Comply with legal obligations\n• Resolve disputes\n• Enforce agreements\n\nYou may request deletion of your account and data at any time.'**
  String get ppDataRetentionContent;

  /// Section title: Data Sharing & Disclosure
  ///
  /// In en, this message translates to:
  /// **'5. Data Sharing & Disclosure'**
  String get ppDataSharingAndDisclosure;

  /// Content for Data Sharing & Disclosure section
  ///
  /// In en, this message translates to:
  /// **'We do not sell your personal data.\n\nWe may share data only:\n• With trusted service providers under confidentiality agreements\n• To comply with legal obligations\n• To protect our rights, users, or platform security'**
  String get ppDataSharingAndDisclosureContent;

  /// Section title: Security
  ///
  /// In en, this message translates to:
  /// **'6. Security'**
  String get ppSecurity;

  /// Content for Security section
  ///
  /// In en, this message translates to:
  /// **'We implement industry-standard security measures to protect your data.\n\nHowever, no method of transmission or storage is 100% secure.'**
  String get ppSecurityContent;

  /// Section title: Your Rights
  ///
  /// In en, this message translates to:
  /// **'7. Your Rights'**
  String get ppYourRights;

  /// Content for Your Rights section
  ///
  /// In en, this message translates to:
  /// **'Depending on your location, you may have the right to:\n• Access your personal data\n• Correct inaccurate data\n• Request deletion of your data\n• Object to or restrict processing\n\nTo exercise these rights, contact us at:\nateliadesign.contact@gmail.com'**
  String get ppYourRightsContent;

  /// Section title: Children's Privacy
  ///
  /// In en, this message translates to:
  /// **'8. Children\'s Privacy'**
  String get ppChildrensPrivacy;

  /// Content for Children's Privacy section
  ///
  /// In en, this message translates to:
  /// **'Atelia is not intended for users under the age of 16.\n\nWe do not knowingly collect personal data from children under 16. If we become aware of such data, we will delete it immediately.'**
  String get ppChildrensPrivacyContent;

  /// Section title: International Data Transfers
  ///
  /// In en, this message translates to:
  /// **'9. International Data Transfers'**
  String get ppInternationalDataTransfers;

  /// Content for International Data Transfers section
  ///
  /// In en, this message translates to:
  /// **'Your information may be transferred and stored on servers located outside your country.\n\nBy using Atelia, you consent to such transfers.'**
  String get ppInternationalDataTransfersContent;

  /// Section title: Changes to This Privacy Policy
  ///
  /// In en, this message translates to:
  /// **'10. Changes to This Privacy Policy'**
  String get ppChangesToThisPrivacyPolicy;

  /// Content for Changes to This Privacy Policy section
  ///
  /// In en, this message translates to:
  /// **'We may update this Privacy Policy from time to time. Any changes will be posted within the app or on our website.\n\nContinued use of the Service after changes constitutes acceptance.'**
  String get ppChangesToThisPrivacyPolicyContent;

  /// Section title: Contact Us
  ///
  /// In en, this message translates to:
  /// **'11. Contact Us'**
  String get ppContactUs;

  /// Content for Contact Us section
  ///
  /// In en, this message translates to:
  /// **'If you have questions about this Privacy Policy, contact us:\n\nEmail: ateliadesign.contact@gmail.com'**
  String get ppContactUsContent;

  /// Delete account button label
  ///
  /// In en, this message translates to:
  /// **'Delete Account'**
  String get deleteAccount;

  /// Title for delete account dialog
  ///
  /// In en, this message translates to:
  /// **'Delete Your Account'**
  String get deleteAccountTitle;

  /// Warning message for account deletion
  ///
  /// In en, this message translates to:
  /// **'Are you sure you want to delete your account?\n\nThis action cannot be undone and will permanently delete all your data including your profile, designs, tech packs, and subscription.'**
  String get deleteAccountWarning;

  /// Confirm delete button text
  ///
  /// In en, this message translates to:
  /// **'Yes, Delete My Account'**
  String get confirmDelete;

  /// Cancel delete button text
  ///
  /// In en, this message translates to:
  /// **'Cancel'**
  String get cancelDelete;

  /// Enter password dialog title
  ///
  /// In en, this message translates to:
  /// **'Enter Your Password'**
  String get enterPassword;

  /// Password confirmation message
  ///
  /// In en, this message translates to:
  /// **'Please enter your password to confirm account deletion:'**
  String get enterPasswordToConfirm;

  /// Final delete button text
  ///
  /// In en, this message translates to:
  /// **'Delete My Account'**
  String get deleteMyAccount;

  /// Google confirmation dialog title
  ///
  /// In en, this message translates to:
  /// **'Confirm with Google'**
  String get confirmWithGoogle;

  /// Google confirmation message
  ///
  /// In en, this message translates to:
  /// **'Please sign in with Google to confirm account deletion:'**
  String get signInWithGoogleToConfirm;

  /// Account deleted success title
  ///
  /// In en, this message translates to:
  /// **'Account Deleted'**
  String get accountDeleted;

  /// Account deleted success message
  ///
  /// In en, this message translates to:
  /// **'Your account has been successfully deleted. We\'re sorry to see you go!'**
  String get accountDeletedSuccess;

  /// Account deletion failed message
  ///
  /// In en, this message translates to:
  /// **'Failed to delete account. Please try again.'**
  String get accountDeleteFailed;

  /// Wrong password error message
  ///
  /// In en, this message translates to:
  /// **'Incorrect password. Please try again.'**
  String get wrongPassword;

  /// Requires recent login error message
  ///
  /// In en, this message translates to:
  /// **'For security reasons, please log out and log back in before deleting your account.'**
  String get requiresRecentLogin;

  /// User not found error message
  ///
  /// In en, this message translates to:
  /// **'User account not found.'**
  String get userNotFound;

  /// Network error message
  ///
  /// In en, this message translates to:
  /// **'Network error. Please check your connection and try again.'**
  String get networkError;

  /// No internet connection title
  ///
  /// In en, this message translates to:
  /// **'No Internet Connection'**
  String get noInternetConnection;

  /// No internet connection message
  ///
  /// In en, this message translates to:
  /// **'Please check your internet connection and try again.'**
  String get noInternetConnectionMessage;

  /// Google re-authentication cancelled message
  ///
  /// In en, this message translates to:
  /// **'Google sign-in was cancelled. Account deletion aborted.'**
  String get googleReauthCancelled;

  /// Apple re-authentication cancelled message
  ///
  /// In en, this message translates to:
  /// **'Apple sign-in was cancelled. Account deletion aborted.'**
  String get appleReauthCancelled;

  /// Confirm with Apple button text
  ///
  /// In en, this message translates to:
  /// **'Confirm with Apple'**
  String get confirmWithApple;

  /// Apple re-authentication prompt for account deletion
  ///
  /// In en, this message translates to:
  /// **'Please sign in with Apple to confirm account deletion:'**
  String get signInWithAppleToConfirm;

  /// Deleting account loading message
  ///
  /// In en, this message translates to:
  /// **'Deleting account...'**
  String get deletingAccount;

  /// Error message when a link cannot be opened
  ///
  /// In en, this message translates to:
  /// **'Could not open link'**
  String get couldNotOpenLink;

  /// Button label to learn more about a subscription plan
  ///
  /// In en, this message translates to:
  /// **'Explore'**
  String get learnMore;

  /// Title for the free user monthly design limit dialog
  ///
  /// In en, this message translates to:
  /// **'Monthly Limit Reached'**
  String get freeUserLimitTitle;

  /// Body message for the free user monthly design limit dialog
  ///
  /// In en, this message translates to:
  /// **'You\'ve used all your free designs for this month.'**
  String get freeUserLimitBody;

  /// Call to action in the free user monthly design limit dialog
  ///
  /// In en, this message translates to:
  /// **'To continue creating, visit us at www.atelia.app'**
  String get freeUserLimitCta;

  /// Dismiss button label for informational dialogs
  ///
  /// In en, this message translates to:
  /// **'Got it'**
  String get gotIt;

  /// Settings section header for the user's active subscription
  ///
  /// In en, this message translates to:
  /// **'My Plan'**
  String get myPlan;

  /// Settings card label to open the subscription detail screen
  ///
  /// In en, this message translates to:
  /// **'View Plan'**
  String get viewPlan;

  /// Plan label for free users in the settings card
  ///
  /// In en, this message translates to:
  /// **'Free Plan'**
  String get settingsFreePlan;

  /// Label for the free monthly allowance section in the settings card
  ///
  /// In en, this message translates to:
  /// **'Monthly free'**
  String get settingsFreeMonthly;

  /// Label for the add-ons section in the free user settings card
  ///
  /// In en, this message translates to:
  /// **'Add-ons'**
  String get settingsAddOns;

  /// Title of the subscription detail screen
  ///
  /// In en, this message translates to:
  /// **'My Subscription'**
  String get subscriptionDetailTitle;

  /// Section header on the subscription detail screen
  ///
  /// In en, this message translates to:
  /// **'Plan Details'**
  String get planDetails;

  /// Section header for quota usage on the subscription detail screen
  ///
  /// In en, this message translates to:
  /// **'Usage This Month'**
  String get usageThisMonth;

  /// Badge label for monthly billing period
  ///
  /// In en, this message translates to:
  /// **'Monthly'**
  String get billingMonthly;

  /// Badge label for yearly billing period
  ///
  /// In en, this message translates to:
  /// **'Annual'**
  String get billingYearly;

  /// Subscription renewal date label
  ///
  /// In en, this message translates to:
  /// **'Renews on {date}'**
  String renewsOn(String date);

  /// Label for the designs usage counter
  ///
  /// In en, this message translates to:
  /// **'Designs'**
  String get designsLabel;

  /// Label for the tech packs usage counter
  ///
  /// In en, this message translates to:
  /// **'Tech Packs'**
  String get techPacksLabel;

  /// Display name for the Starter subscription plan
  ///
  /// In en, this message translates to:
  /// **'Starter Plan'**
  String get planNameStarter;

  /// Display name for the Pro subscription plan
  ///
  /// In en, this message translates to:
  /// **'Pro Plan'**
  String get planNamePro;

  /// Display name for the Studio subscription plan
  ///
  /// In en, this message translates to:
  /// **'Studio Plan'**
  String get planNameStudio;

  /// Confirm button label in the cancel subscription dialog
  ///
  /// In en, this message translates to:
  /// **'Yes, Cancel'**
  String get cancelSubscriptionConfirm;

  /// Snackbar message shown after a subscription is successfully cancelled
  ///
  /// In en, this message translates to:
  /// **'Subscription cancelled successfully.'**
  String get subscriptionCancelledSuccess;

  /// Snackbar message shown when subscription cancellation fails
  ///
  /// In en, this message translates to:
  /// **'Failed to cancel subscription. Please try again.'**
  String get subscriptionCancelError;

  /// Label for the free subscription plan
  ///
  /// In en, this message translates to:
  /// **'Free Plan'**
  String get freePlan;

  /// Shows how many free designs have been used vs total allowed
  ///
  /// In en, this message translates to:
  /// **'{used} of {total} designs'**
  String freeDesignsCounter(int used, int total);

  /// CTA shown to paid users who have hit their plan limit, pointing them to upgrade at the website
  ///
  /// In en, this message translates to:
  /// **'Ready to upgrade? Visit www.atelia.app'**
  String get paidUserUpgradeCta;

  /// Divider word shown between two options
  ///
  /// In en, this message translates to:
  /// **'OR'**
  String get orDivider;

  /// Hint shown above the cancel button on the subscription detail screen
  ///
  /// In en, this message translates to:
  /// **'To change or upgrade your plan, visit us at www.atelia.app'**
  String get subscriptionDetailUpgradeHint;
}

class _AppLocalizationsDelegate
    extends LocalizationsDelegate<AppLocalizations> {
  const _AppLocalizationsDelegate();

  @override
  Future<AppLocalizations> load(Locale locale) {
    return SynchronousFuture<AppLocalizations>(lookupAppLocalizations(locale));
  }

  @override
  bool isSupported(Locale locale) =>
      <String>['en', 'fr'].contains(locale.languageCode);

  @override
  bool shouldReload(_AppLocalizationsDelegate old) => false;
}

AppLocalizations lookupAppLocalizations(Locale locale) {
  // Lookup logic when only language code is specified.
  switch (locale.languageCode) {
    case 'en':
      return AppLocalizationsEn();
    case 'fr':
      return AppLocalizationsFr();
  }

  throw FlutterError(
    'AppLocalizations.delegate failed to load unsupported locale "$locale". This is likely '
    'an issue with the localizations generation tool. Please file an issue '
    'on GitHub with a reproducible sample app and the gen-l10n configuration '
    'that was used.',
  );
}
