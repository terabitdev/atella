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

  /// Google sign in button text
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
  /// **'Create a  new Project'**
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
  /// **'Subscription Plan'**
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
  /// **'Subscribe'**
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
  /// **'Up to 10 3D designs / month'**
  String get upTo10Designs;

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

  /// Cancel subscription first message
  ///
  /// In en, this message translates to:
  /// **'Cancel subscription first'**
  String get cancelSubscriptionFirst;

  /// Upgrade plan button
  ///
  /// In en, this message translates to:
  /// **'Upgrade Plan'**
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
  /// **'We\'re sorry to see you go. Please let us know why:'**
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
  /// **'Designs: {display}'**
  String designs(String display);

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
  /// **'Password must be at least 6 characters'**
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
