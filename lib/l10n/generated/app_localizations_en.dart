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
}
