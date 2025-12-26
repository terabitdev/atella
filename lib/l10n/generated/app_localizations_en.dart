// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for English (`en`).
class AppLocalizationsEn extends AppLocalizations {
  AppLocalizationsEn([String locale = 'en']) : super(locale);

  @override
  String get appName => 'Atelia';

  @override
  String get welcomeToAtelia => 'Welcome to ATELIA!';

  @override
  String get welcomeMessage => 'Welcome to Atelia';

  @override
  String get login => 'Login';

  @override
  String get logIn => 'Log In';

  @override
  String get loggingIn => 'Logging In...';

  @override
  String get signUp => 'Sign Up';

  @override
  String get signingUp => 'Signing Up...';

  @override
  String get signIn => 'Sign In';

  @override
  String get email => 'Email';

  @override
  String get password => 'Password';

  @override
  String get confirmPassword => 'Confirm Password';

  @override
  String get fullName => 'Full Name';

  @override
  String get forgotPassword => 'Forgot Password?';

  @override
  String get continueWithGoogle => 'Continue with Google';

  @override
  String get continueWithApple => 'Continue with Apple';

  @override
  String get orContinueWith => 'Or continue with';

  @override
  String get createAccount => 'Create Account';

  @override
  String get createYourAccount => 'Create your account';

  @override
  String get alreadyHaveAccount => 'Already have an account?';

  @override
  String get alreadyJoined => 'Already Joined?';

  @override
  String get dontHaveAccount => 'Don\'t have an account?';

  @override
  String get joinNow => 'Join Now';

  @override
  String get onboardingTitle =>
      'Welcome to AteliA — Your\nFashion Brand Starts Here.';

  @override
  String get onboardingSubtitle =>
      'Turn your ideas into real clothing — with AI-powered design tools and manufacturer support.';

  @override
  String get verification => 'Verification';

  @override
  String get verificationDescription =>
      'Enter your email address and we\'ll send you a verification link to reset your password.';

  @override
  String get sendVerificationLink => 'Send Verification Link';

  @override
  String get home => 'Home';

  @override
  String get profile => 'Profile';

  @override
  String get settings => 'Settings';

  @override
  String get logout => 'Logout';

  @override
  String get logoutConfirmation => 'Are you sure you want to logout?';

  @override
  String get cancel => 'Cancel';

  @override
  String get confirm => 'Confirm';

  @override
  String get save => 'Save';

  @override
  String get delete => 'Delete';

  @override
  String get edit => 'Edit';

  @override
  String get editProfile => 'Edit Profile';

  @override
  String get download => 'Download';

  @override
  String get preview => 'Preview';

  @override
  String get loading => 'Loading...';

  @override
  String get error => 'Error';

  @override
  String get success => 'Success';

  @override
  String get retry => 'Retry';

  @override
  String get next => 'Next';

  @override
  String get back => 'Back';

  @override
  String get done => 'Done';

  @override
  String get skip => 'Skip';

  @override
  String get language => 'Language';

  @override
  String get english => 'English';

  @override
  String get french => 'French';

  @override
  String get selectLanguage => 'Select Language';

  @override
  String get techPack => 'Tech Pack';

  @override
  String get designImage => 'Design Image';

  @override
  String techPackImageN(int number) {
    return 'Tech Pack Image $number';
  }

  @override
  String get manufactureSuggestions => 'Manufacture suggestions';

  @override
  String get noImagesAvailable => 'No images available to download';

  @override
  String downloadingNOfTotal(int current, int total) {
    return 'Downloading $current of $total...';
  }

  @override
  String imagesSavedToGallery(int count) {
    return '$count images saved to gallery in \"Atelia\" album';
  }

  @override
  String get myDesigns => 'My Designs';

  @override
  String get myCollections => 'My Collections';

  @override
  String get seeAll => 'See All';

  @override
  String get startNewProject => 'Start New Project';

  @override
  String get createNewDesign => 'Create New Design';

  @override
  String get createNewProject => 'Create a  new Project';

  @override
  String get favorites => 'Favorites';

  @override
  String get noFavoritesYet => 'No favorite projects yet';

  @override
  String get noFavoritesSubtitle =>
      'Start creating projects and mark your favorites to see them here.';

  @override
  String get homeEmptyStateTitle =>
      'Here to guide you through creating the garment you have in mind.';

  @override
  String noResultsFor(String query) {
    return 'No results found for \"$query\"';
  }

  @override
  String get tryAdjustingSearch =>
      'Try adjusting your search terms or create a new project.';

  @override
  String get clearSearch => 'Clear Search';

  @override
  String get personalInformation => 'Personal Information';

  @override
  String get subscriptionPlan => 'Subscription Plan';

  @override
  String get termsOfUse => 'Terms of use';

  @override
  String get privacyPolicy => 'Privacy Policy';

  @override
  String get allowAnalytics => 'Allow analytics';

  @override
  String get analyticsDescription =>
      'We record sessions to improve your experience. Turn this off to stop all analytics and recordings.';

  @override
  String get update => 'Update';

  @override
  String get updating => 'Updating...';

  @override
  String get subscribe => 'Subscribe';

  @override
  String get chooseYourPlan => 'Choose Your Plan';

  @override
  String get startForFree => 'Start for free. Upgrade anytime.';

  @override
  String get current => 'Current';

  @override
  String get free => 'Free';

  @override
  String get starter => 'Starter';

  @override
  String get pro => 'Pro';

  @override
  String get monthly => 'Monthly';

  @override
  String get yearlySavePercent => 'Yearly (Save 17%)';

  @override
  String get featuresInclude => 'Features include:';

  @override
  String get idealForLaunching => 'Ideal for launching your first productions.';

  @override
  String get forCreatorsReady => 'For creators ready to scale their vision.';

  @override
  String get perfectToTest => 'Perfect to test, imagine, and create freely.';

  @override
  String techpacksPerMonth(int count) {
    return '$count techpacks per month';
  }

  @override
  String techpacksPerMonthYearly(int count, int total) {
    return '$count techpacks per month ($total total per year)';
  }

  @override
  String get unlimited3DVisualization => 'Unlimited 3D visualization';

  @override
  String get customPdfExport => 'Custom PDF export (with user\'s logo)';

  @override
  String get fullyCustomizedPdfExports => 'Fully customized PDF exports';

  @override
  String get accessToManufacturers => 'Access to manufacturers list';

  @override
  String get upTo10Designs => 'Up to 10 3D designs / month';

  @override
  String get visualization3DIncluded => '3D Visualization included';

  @override
  String get noTechpackGeneration => 'No techpack generation';

  @override
  String get noPdfExport => 'No PDF export';

  @override
  String get noAccessToManufacturers => 'No access to manufacturers';

  @override
  String get start => 'Start';

  @override
  String get currentPlan => 'Current Plan';

  @override
  String get cancelMonthlyPlanFirst => 'Cancel Monthly plan first';

  @override
  String get cancelYearlyPlanFirst => 'Cancel Yearly plan first';

  @override
  String get cancelSubscriptionFirst => 'Cancel subscription first';

  @override
  String get upgradePlan => 'Upgrade Plan';

  @override
  String get cancelSubscription => 'Cancel Subscription';

  @override
  String get keepSubscription => 'Keep Subscription';

  @override
  String get cancelSubscriptionTitle => 'Cancel Subscription';

  @override
  String get cancelSubscriptionMessage =>
      'We\'re sorry to see you go. Please let us know why:';

  @override
  String get pleaseSpecify => 'Please specify...';

  @override
  String get termsAgreement => 'By placing this order, you agree to the ';

  @override
  String get termsOfService => 'Terms of Service';

  @override
  String get and => ' and\n';

  @override
  String get upgradeMessage =>
      'You can upgrade your plan to generate tech PDF\'s and access to manufacturers';

  @override
  String get freePerMonth => 'Free/Month';

  @override
  String get gatheringCreativeBrief => 'Gathering the Creative Brief ';

  @override
  String get asYourExpertDesigner => 'As your expert virtual fashion designer.';

  @override
  String get hereToHelpCreate =>
      'I\'m here to help you create a custom garment or collection.';

  @override
  String get getStarted => 'Get Started';

  @override
  String get info => 'Info';

  @override
  String get allImagesLocalAssets =>
      'All images are local assets and cannot be downloaded';

  @override
  String get partialSuccess => 'Partial Success';

  @override
  String imagesSavedFailed(int saved, int failed) {
    return '$saved images saved to gallery. $failed failed.';
  }

  @override
  String get failedToSaveImages => 'Failed to save images to gallery.';

  @override
  String downloadFailed(String error) {
    return 'Download failed: $error';
  }

  @override
  String failedToDownload(String error) {
    return 'Failed to download images: $error';
  }

  @override
  String designs(String display) {
    return 'Designs: $display';
  }

  @override
  String get other => 'Other';

  @override
  String get tooExpensive => 'Too expensive';

  @override
  String get notUsingEnough => 'Not using it enough';

  @override
  String get missingFeatures => 'Missing features I need';

  @override
  String get foundBetterAlternative => 'Found a better alternative';

  @override
  String get technicalIssues => 'Technical issues';

  @override
  String get allImagesLocal =>
      'All images are local assets and cannot be downloaded';

  @override
  String downloading(int current, int total) {
    return 'Downloading $current of $total...';
  }

  @override
  String failedToDownloadImages(String error) {
    return 'Failed to download images: $error';
  }

  @override
  String partialDownloadSuccess(int downloaded, int failed) {
    return '$downloaded images saved to gallery. $failed failed.';
  }

  @override
  String techPackImage(int number) {
    return 'Tech Pack Image $number';
  }

  @override
  String get searchDesigns => 'Search Designs';

  @override
  String get emailIsRequired => 'Email is required';

  @override
  String get enterValidEmail => 'Enter a valid email';

  @override
  String get passwordIsRequired => 'Password is required';

  @override
  String get passwordMinLength => 'Password must be at least 6 characters';

  @override
  String get nameIsRequired => 'Name is required';

  @override
  String get confirmYourPassword => 'Confirm your password';

  @override
  String get passwordsDoNotMatch => 'Passwords do not match';

  @override
  String get userSuccessfullyLoggedIn => 'User successfully logged in';

  @override
  String get successfullySignedInWithGoogle =>
      'Successfully signed in with Google';

  @override
  String get userRegisteredSuccessfully => 'User registered successfully';

  @override
  String get userAlreadyExistsWithEmail =>
      'User already exists with this email';

  @override
  String get verificationLinkSent => 'Verification Link Sent';

  @override
  String passwordResetLinkSent(String email) {
    return 'A password reset link has been sent to $email.';
  }

  @override
  String get failedToSendVerificationLink =>
      'Failed to send verification link. Please try again.';

  @override
  String get failedToUpdateFavorite => 'Failed to update favorite status';

  @override
  String get failedToLoadProfile => 'Failed to load profile data';

  @override
  String get profileUpdatedSuccessfully => 'Profile updated successfully';

  @override
  String get failedToUpdateProfile =>
      'Failed to update profile. Please try again.';

  @override
  String get errorUpdatingProfile => 'An error occurred while updating profile';

  @override
  String get pleaseEnterFullName => 'Please enter your full name';

  @override
  String get analyticsEnabled => 'Analytics enabled';

  @override
  String get analyticsDisabled => 'Analytics disabled';

  @override
  String get analyticsEnabledMessage =>
      'Helps improve the app. Session replays remain sampled.';

  @override
  String get analyticsDisabledMessage =>
      'We will stop sending analytics and session replays.';

  @override
  String get infoMessage => 'Info';

  @override
  String get youAreOnFreePlan => 'You are on the free plan';

  @override
  String get subscriptionSuccessTitle => 'Success! 🎉';

  @override
  String welcomeToPlan(String plan) {
    return 'Welcome to $plan! You can now generate techpacks.';
  }

  @override
  String get subscriptionActive => 'Subscription Active! 🎉';

  @override
  String get canNowGenerateTechpack =>
      'You can now generate your techpack. Click \"Generate Tech Pack\" button.';

  @override
  String get failedToCompleteSubscription => 'Failed to complete subscription';

  @override
  String get subscriptionCancelledSuccessfully =>
      'Subscription cancelled successfully';

  @override
  String get failedToCancelSubscription => 'Failed to cancel subscription';

  @override
  String get failedToLoadSubscription => 'Failed to load subscription details';

  @override
  String anErrorOccurred(String error) {
    return 'An error occurred: $error';
  }
}
