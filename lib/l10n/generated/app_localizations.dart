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

  /// Loading indicator text
  ///
  /// In en, this message translates to:
  /// **'Loading...'**
  String get loading;

  /// Error message title
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
