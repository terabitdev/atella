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
  String get loading => 'Loading';

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
  String get createNewProject => 'Create New Project';

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
  String get subscriptionPlan => 'Premium Plans';

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
  String get subscribe => 'Premium Plans';

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
  String get upTo10Designs => '3 AI design generations / month';

  @override
  String get starterDesignLimit => '5 AI design generations per month';

  @override
  String get starterMonthlyPrice => 'Starter €19.99/Month';

  @override
  String get starterYearlyPrice => 'Starter €199.99/Year';

  @override
  String get proMonthlyPrice => 'Pro €49.99/Month';

  @override
  String get proYearlyPrice => 'Pro €499.99/Year';

  @override
  String get proDesignLimit => '12 AI design generations per month';

  @override
  String get studioMonthlyPrice => 'Studio €99.99/Month';

  @override
  String get studioYearlyPrice => 'Studio €999.99/Year';

  @override
  String get studioDesignLimit => '25 AI design generations per month';

  @override
  String get perMonth => '/Month';

  @override
  String get perYear => '/Year';

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
  String get cancelSubscriptionFirst => 'Cancel current plan first';

  @override
  String get upgradePlan => 'Upgrade';

  @override
  String get cancelSubscription => 'Cancel Subscription';

  @override
  String get keepSubscription => 'Keep Subscription';

  @override
  String get cancelSubscriptionTitle => 'Cancel Subscription';

  @override
  String get cancelSubscriptionMessage =>
      'We\'re sorry to see you go. Please let us know why:\n\n⚠️ Warning: Upon canceling, any purchased extra designs and techpacks will be lost.';

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
    return '$display';
  }

  @override
  String designsUsed(String used, String total) {
    return 'Designs used: $used / $total this month';
  }

  @override
  String techpacksUsed(String used, String total) {
    return 'Techpacks used: $used / $total this month';
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
  String get imageFailed => 'Image failed';

  @override
  String get searchDesigns => 'Search Designs';

  @override
  String get emailIsRequired => 'Email is required';

  @override
  String get enterValidEmail => 'Enter a valid email';

  @override
  String get passwordIsRequired => 'Password is required';

  @override
  String get passwordMinLength => 'Password must be at least 8 characters';

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
  String get successfullySignedInWithApple =>
      'Successfully signed in with Apple';

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

  @override
  String get creativeBrief => 'Creative Brief';

  @override
  String get gatheringTheCreativeBrief => 'Gathering the Creative Brief';

  @override
  String get asYourExpertVirtualFashionDesigner =>
      'As your expert virtual fashion designer.';

  @override
  String get imHereToHelpCreateCustomGarment =>
      'I\'m here to help you create a custom garment or collection.';

  @override
  String get cbQuestionGarmentType =>
      'What type of garment are you creating? 👕';

  @override
  String get cbQuestionStyle => 'What is the overall desired style? ✨';

  @override
  String get cbQuestionTargetAudience => 'Who is this garment intended for? 👤';

  @override
  String get cbQuestionOccasion => 'What is the intended occasion or use? 📅';

  @override
  String get cbQuestionInspiration =>
      'Do you have any visual inspirations or references? 🖼️';

  @override
  String get cbQuestionColors =>
      'What colors and patterns should the design include? 🎨';

  @override
  String get cbQuestionFabrics =>
      'Which fabric or material would you like to use? 🧵';

  @override
  String get cbCategoryTops => 'Tops';

  @override
  String get cbCategoryBottoms => 'Bottoms';

  @override
  String get cbCategoryDresses => 'Dresses';

  @override
  String get cbCategoryJumpsuits => 'Jumpsuits';

  @override
  String get cbCategoryOuterwear => 'Outerwear';

  @override
  String get cbCategorySportswear => 'Sportswear';

  @override
  String get cbCategoryAccessories => 'Accessories';

  @override
  String get cbCategoryCotton => 'Cotton';

  @override
  String get cbCategoryWool => 'Wool';

  @override
  String get cbCategorySilk => 'Silk';

  @override
  String get cbCategoryLinen => 'Linen';

  @override
  String get cbCategorySynthetic => 'Synthetic';

  @override
  String get cbCategoryEcoOptions => 'Eco options';

  @override
  String get cbCategoryLeatherFauxLeather => 'Leather/Faux leather';

  @override
  String get cbCategoryKnitwear => 'Knitwear';

  @override
  String get cbCategoryPrints => 'Prints';

  @override
  String get cbCategoryTechniques => 'Techniques';

  @override
  String get cbOptionTShirt => 'T-shirt';

  @override
  String get cbOptionShirt => 'Shirt';

  @override
  String get cbOptionBlouse => 'Blouse';

  @override
  String get cbOptionHoodie => 'Hoodie';

  @override
  String get cbOptionJacket => 'Jacket';

  @override
  String get cbOptionCoat => 'Coat';

  @override
  String get cbOptionVest => 'Vest';

  @override
  String get cbOptionTankTop => 'Tank top';

  @override
  String get cbOptionCropTop => 'Crop top';

  @override
  String get cbOptionSweater => 'Sweater';

  @override
  String get cbOptionPants => 'Pants';

  @override
  String get cbOptionJeans => 'Jeans';

  @override
  String get cbOptionSkirts => 'Skirts';

  @override
  String get cbOptionShorts => 'Shorts';

  @override
  String get cbOptionLeggings => 'Leggings';

  @override
  String get cbOptionCulottes => 'Culottes';

  @override
  String get cbOptionPalazzo => 'Palazzo';

  @override
  String get cbOptionJoggers => 'Joggers';

  @override
  String get cbOptionCasualDress => 'Casual dress';

  @override
  String get cbOptionEvening => 'Evening';

  @override
  String get cbOptionCocktailDress => 'Cocktail dress';

  @override
  String get cbOptionGown => 'Gown';

  @override
  String get cbOptionMaxiDress => 'Maxi dress';

  @override
  String get cbOptionMidiDress => 'Midi dress';

  @override
  String get cbOptionMiniDress => 'Mini dress';

  @override
  String get cbOptionJumpsuit => 'Jumpsuit';

  @override
  String get cbOptionRomper => 'Romper';

  @override
  String get cbOptionPlaysuit => 'Playsuit';

  @override
  String get cbOptionOveralls => 'Overalls';

  @override
  String get cbOptionTrenchCoat => 'Trench coat';

  @override
  String get cbOptionBomberJacket => 'Bomber jacket';

  @override
  String get cbOptionBlazer => 'Blazer';

  @override
  String get cbOptionPufferJacket => 'Puffer jacket';

  @override
  String get cbOptionTracksuit => 'Tracksuit';

  @override
  String get cbOptionActivewear => 'Activewear';

  @override
  String get cbOptionSwimwear => 'Swimwear';

  @override
  String get cbOptionHat => 'Hat';

  @override
  String get cbOptionBag => 'Bag';

  @override
  String get cbOptionScarf => 'Scarf';

  @override
  String get cbOptionGloves => 'Gloves';

  @override
  String get cbOptionCasual => 'Casual';

  @override
  String get cbOptionChic => 'Chic';

  @override
  String get cbOptionSporty => 'Sporty';

  @override
  String get cbOptionStreetwear => 'Streetwear';

  @override
  String get cbOptionWorkwear => 'Workwear';

  @override
  String get cbOptionWoman => 'Woman';

  @override
  String get cbOptionMan => 'Man';

  @override
  String get cbOptionChild => 'Child';

  @override
  String get cbOptionUnisex => 'Unisex';

  @override
  String get cbOptionTargetAge => 'Target Age';

  @override
  String get cbOptionEverydayWear => 'Everyday wear';

  @override
  String get cbOptionSpecialEvent => 'Special event';

  @override
  String get cbOptionSports => 'Sports';

  @override
  String get cbOptionActivity => 'Activity';

  @override
  String get cbOptionFloral => 'Floral';

  @override
  String get cbOptionAbstract => 'Abstract';

  @override
  String get cbOptionCamouflage => 'Camouflage';

  @override
  String get cbOptionStripes => 'Stripes';

  @override
  String get cbOptionPolkaDots => 'Polka dots';

  @override
  String get cbOptionTieDye => 'Tie-dye';

  @override
  String get cbOptionColorBlocking => 'Color blocking';

  @override
  String get cbOptionGradientOmbre => 'Gradient/Ombré';

  @override
  String get cbOptionEmbroidery => 'Embroidery';

  @override
  String get cbOptionJacquard => 'Jacquard';

  @override
  String get cbOptionLightweight => 'Lightweight (poplin, voile)';

  @override
  String get cbOptionMedium => 'Medium (twill)';

  @override
  String get cbOptionHeavy => 'Heavy (denim, canvas)';

  @override
  String get cbOptionMerino => 'Merino';

  @override
  String get cbOptionCashmere => 'Cashmere';

  @override
  String get cbOptionTweed => 'Tweed';

  @override
  String get cbOptionFelt => 'Felt';

  @override
  String get cbOptionSatin => 'Satin';

  @override
  String get cbOptionChiffon => 'Chiffon';

  @override
  String get cbOptionOrganza => 'Organza';

  @override
  String get cbOptionPlain => 'Plain';

  @override
  String get cbOptionTextured => 'Textured';

  @override
  String get cbOptionBlended => 'Blended';

  @override
  String get cbOptionPolyester => 'Polyester';

  @override
  String get cbOptionNylon => 'Nylon';

  @override
  String get cbOptionSpandex => 'Spandex';

  @override
  String get cbOptionNeoprene => 'Neoprene';

  @override
  String get cbOptionOrganicCotton => 'Organic cotton';

  @override
  String get cbOptionRecycledPolyester => 'Recycled polyester';

  @override
  String get cbOptionBamboo => 'Bamboo';

  @override
  String get cbOptionHemp => 'Hemp';

  @override
  String get cbOptionLeather => 'Leather';

  @override
  String get cbOptionFauxLeather => 'Faux leather';

  @override
  String get cbOptionJersey => 'Jersey';

  @override
  String get cbOptionRibKnit => 'Rib knit';

  @override
  String get cbOptionInterlock => 'Interlock';

  @override
  String get cbOptionCustom => 'Custom';

  @override
  String get enterYourCustomAnswer => 'Enter your custom answer...';

  @override
  String enterCustom(String category) {
    return 'Enter custom $category...';
  }

  @override
  String get enterPreferredColors => 'Enter preferred colors...';

  @override
  String get uploadVisualInspirationImages =>
      'Upload visual inspiration images (optional)';

  @override
  String get uploadInspirationImages =>
      'Upload visual inspiration images (optional)';

  @override
  String get skipNoReferenceImages => 'Skip - No reference images';

  @override
  String get uploadImage => 'Upload image';

  @override
  String get nextSteps => 'Next Steps';

  @override
  String get addMoreImages => 'Add more images';

  @override
  String get tapToSelectFromGallery => 'Tap to select from gallery';

  @override
  String get imageAdded => 'Image Added';

  @override
  String get imageAddedSuccessfully => 'Image added successfully';

  @override
  String get failedToPickImage => 'Failed to pick image. Please try again.';

  @override
  String get imageError => 'Error';

  @override
  String get imageSelected => 'Image Selected';

  @override
  String get imageSelectedSuccessfully => 'Image selected successfully';

  @override
  String get failedToLoadImage => 'Failed to load image';

  @override
  String get change => 'Change';

  @override
  String get solidColors => 'Solid colors';

  @override
  String get pickAColor => 'Pick a color';

  @override
  String get selectAColor => 'Select a Color';

  @override
  String get select => 'Select';

  @override
  String get loadingExistingDesignData => 'Loading existing design data...';

  @override
  String get editMode => 'Edit Mode';

  @override
  String editingDesign(String designName) {
    return 'Editing design: $designName';
  }

  @override
  String get failedToLoadExistingData =>
      'Failed to load existing data. Using defaults.';

  @override
  String get dataLoaded => 'Data Loaded';

  @override
  String get previousAnswersLoadedForEditing =>
      'Previous answers have been loaded for editing';

  @override
  String get briefComplete => 'Brief Complete!';

  @override
  String get briefCompletedSuccessfully =>
      'Your creative brief has been completed successfully.';

  @override
  String get invalidInput => 'Invalid Input';

  @override
  String pleaseEnterCustomAnswer(String category) {
    return 'Please enter a custom answer for $category';
  }

  @override
  String get pleaseEnterCustomAnswerGeneric => 'Please enter a custom answer';

  @override
  String get pleaseEnterCustomPrint => 'Please enter a custom print';

  @override
  String get pleaseEnterCustomTechnique => 'Please enter a custom technique';

  @override
  String get answerUpdated => 'Answer Updated';

  @override
  String get answerUpdatedSuccessfully =>
      'Your answer has been updated successfully';

  @override
  String get printsAndTechniquesUpdated =>
      'Your prints and techniques have been updated successfully';

  @override
  String get rcRefiningTheConcept => 'Refining the Concept';

  @override
  String get rcNowToHelpMeRefine => 'Now, to help me refine the 3D design';

  @override
  String get rcProposeThreeConceptOptions =>
      'And propose 3 concept options, I need a few more details.';

  @override
  String get rcContinue => 'Continue';

  @override
  String get rcEnterYourCustomAnswer => 'Enter your custom answer...';

  @override
  String rcEnterCustomCategory(String category) {
    return 'Enter custom $category...';
  }

  @override
  String get rcGenerateDesign => 'Generate Design';

  @override
  String get rcQuestionGarmentType =>
      'What fit are you aiming for? (multiple selection) 📏';

  @override
  String get rcQuestionSpecificFeatures =>
      'Do you want to add special details? (multiple selection) ✂️';

  @override
  String get rcQuestionSeasonalConstraint =>
      'Is there a seasonal constraint? 🌤️';

  @override
  String get rcQuestionTargetBudget =>
      'What is your target budget per piece? 💵';

  @override
  String get rcQuestionFunctionalitiesValues =>
      'Would you like to include any specific functionalities or values? 🧶';

  @override
  String get rcCategoryNecklines => 'Necklines';

  @override
  String get rcCategorySleeves => 'Sleeves';

  @override
  String get rcCategoryClosures => 'Closures';

  @override
  String get rcCategoryPockets => 'Pockets';

  @override
  String get rcCategoryWaist => 'Waist';

  @override
  String get rcCategoryLegs => 'Legs';

  @override
  String get rcCategoryFinishes => 'Finishes';

  @override
  String get rcOptionSlim => 'Slim';

  @override
  String get rcOptionOversized => 'Oversized';

  @override
  String get rcOptionRegular => 'Regular';

  @override
  String get rcOptionStraight => 'Straight';

  @override
  String get rcOptionFitted => 'Fitted';

  @override
  String get rcOptionTailored => 'Tailored';

  @override
  String get rcOptionCropped => 'Cropped';

  @override
  String get rcOptionRelaxed => 'Relaxed';

  @override
  String get rcOptionLong => 'Long';

  @override
  String get rcOptionCrew => 'Crew';

  @override
  String get rcOptionVNeck => 'V-neck';

  @override
  String get rcOptionSquare => 'Square';

  @override
  String get rcOptionHalfShoulder => 'Half-shoulder';

  @override
  String get rcOptionScoop => 'Scoop';

  @override
  String get rcOptionBoatNeck => 'Boat neck';

  @override
  String get rcOptionSleeveless => 'Sleeveless';

  @override
  String get rcOptionShortThreeQuarter => 'Short ¾';

  @override
  String get rcOptionPuff => 'Puff';

  @override
  String get rcOptionRaglan => 'Raglan';

  @override
  String get rcOptionCap => 'Cap';

  @override
  String get rcOptionZipper => 'Zipper (metal/plastic/invisible)';

  @override
  String get rcOptionButtons => 'Buttons';

  @override
  String get rcOptionHooks => 'Hooks';

  @override
  String get rcOptionVelcro => 'Velcro';

  @override
  String get rcOptionSnaps => 'Snaps';

  @override
  String get rcOptionPatch => 'Patch';

  @override
  String get rcOptionWelt => 'Welt';

  @override
  String get rcOptionFlap => 'Flap';

  @override
  String get rcOptionHidden => 'Hidden';

  @override
  String get rcOptionCargo => 'Cargo';

  @override
  String get rcOptionElastic => 'Elastic';

  @override
  String get rcOptionHighWaist => 'High-waist';

  @override
  String get rcOptionLowRise => 'Low-rise';

  @override
  String get rcOptionBelted => 'Belted';

  @override
  String get rcOptionDrawstring => 'Drawstring';

  @override
  String get rcOptionStraightLeg => 'Straight leg';

  @override
  String get rcOptionTapered => 'Tapered';

  @override
  String get rcOptionWideLeg => 'Wide leg';

  @override
  String get rcOptionBootcut => 'Bootcut';

  @override
  String get rcOptionFlared => 'Flared';

  @override
  String get rcOptionLining => 'Lining';

  @override
  String get rcOptionTopstitching => 'Topstitching';

  @override
  String get rcOptionEmbroidery => 'Embroidery';

  @override
  String get rcOptionLace => 'Lace';

  @override
  String get rcOptionSequins => 'Sequins';

  @override
  String get rcOptionAppliques => 'Appliqués';

  @override
  String get rcOptionSummer => 'Summer';

  @override
  String get rcOptionMidSeason => 'Mid-Season';

  @override
  String get rcOptionAllSeason => 'All-Season';

  @override
  String get rcOptionPriceRangeInEuro => 'Price Range In €';

  @override
  String get rcOptionIndicationOfMarketLevel =>
      'An Indication Of The Market Level';

  @override
  String get rcOptionEntry => 'Entry';

  @override
  String get rcOptionMidRange => 'Mid-Range';

  @override
  String get rcOptionPremium => 'Premium';

  @override
  String get rcOptionOrganicFabric => 'Organic Fabric';

  @override
  String get rcOptionLocallyMade => 'Locally Made';

  @override
  String get rcOptionUpcycled => 'Upcycled';

  @override
  String get rcOptionUVProtection => 'UV Protection';

  @override
  String get rcOptionQuickDry => 'Quick-Dry';

  @override
  String get rcOptionWrinkleFree => 'Wrinkle-Free';

  @override
  String get rcOptionCustom => 'Custom';

  @override
  String get today => 'Today';

  @override
  String get rcSnackbarRefiningComplete => 'Refining Complete!';

  @override
  String get rcSnackbarRefiningCompleteMessage =>
      'Your concept has been refined successfully.';

  @override
  String get rcSnackbarExtraDesignsAdded => 'Extra Designs Added!';

  @override
  String get rcSnackbarExtraDesignsAddedMessage =>
      '5 extra designs have been added to your account.';

  @override
  String get rcSnackbarRegeneratingDesigns => 'Regenerating Designs!';

  @override
  String get rcSnackbarRegeneratingDesignsMessage =>
      'Creating 3 new designs based on your updated preferences...';

  @override
  String get rcSnackbarGeneratingDesigns => 'Generating Designs!';

  @override
  String get rcSnackbarGeneratingDesignsMessage =>
      'Creating 3 unique designs based on your preferences...';

  @override
  String get rcSnackbarInvalidInput => 'Invalid Input';

  @override
  String rcSnackbarInvalidInputCategoryMessage(String category) {
    return 'Please enter a custom answer for $category';
  }

  @override
  String get rcSnackbarInvalidInputMessage => 'Please enter a custom answer';

  @override
  String get rcSnackbarAnswerUpdated => 'Answer Updated';

  @override
  String get rcSnackbarAnswerUpdatedMessage =>
      'Your answer has been updated successfully';

  @override
  String get rcDialogEditAnswer => 'Edit Answer';

  @override
  String get rcDialogSelectAnswer => 'Select your answer:';

  @override
  String get rcDialogEnterCustomAnswer => 'Enter custom answer:';

  @override
  String get rcDialogCustomAnswerHint => 'Type your custom answer...';

  @override
  String get rcDialogCancel => 'Cancel';

  @override
  String get rcDialogSaveChanges => 'Save Changes';

  @override
  String get rcToday => 'Today';

  @override
  String get cbDialogEditAnswer => 'Edit Answer';

  @override
  String get cbDialogSelectAnswer => 'Select your answer:';

  @override
  String get cbDialogEnterCustomAnswer => 'Enter custom answer:';

  @override
  String get cbDialogCustomAnswerHint => 'Type your custom answer...';

  @override
  String get cbDialogCancel => 'Cancel';

  @override
  String get cbDialogSaveChanges => 'Save Changes';

  @override
  String get cbDialogEditPrintsTechniques => 'Edit Prints & Techniques';

  @override
  String get cbDialogSelectPrintsTechniques =>
      'Select your prints and techniques';

  @override
  String get cbDialogPrints => 'Prints';

  @override
  String get cbDialogTechniques => 'Techniques';

  @override
  String get cbDialogEnterCustomPrint => 'Enter custom print...';

  @override
  String get cbDialogEnterCustomTechnique => 'Enter custom technique...';

  @override
  String get fdFinalDetails => 'Final Details';

  @override
  String get fdFinalDetailsToProvide => 'Final Details to Provide';

  @override
  String get fdContinue => 'Continue';

  @override
  String get fdGenerate => 'Generate';

  @override
  String get fdTargetSeason => 'Target Season:';

  @override
  String get fdTargetBudget => 'Target Budget per Piece:';

  @override
  String get fdDesiredFeatures => 'Desired Features or Values:';

  @override
  String get fdCustomFeaturesHint => 'Type your custom features here...';

  @override
  String get fdQuestionSeason =>
      'Great! Let\'s make sure your piece fits perfectly with the season. What kind of weather will it be designed for?';

  @override
  String get fdOptionSummer => 'Summer (Lightweight, Short Or Roll-Up Sleeves)';

  @override
  String get fdOptionMidSeason => 'Mid-Season';

  @override
  String get fdOptionAllSeason => 'All-Season (Layer-Friendly)';

  @override
  String get fdQuestionBudget =>
      'Got it. And what kind of budget are you working with for this design? I can tailor the fabrics and features accordingly.';

  @override
  String get fdOptionEntryLevel =>
      'Entry-Level (€15-30 Production / €35-60 Retail)';

  @override
  String get fdOptionMidRange =>
      'Mid-Range (€30-50 Production / €60-120 Retail)';

  @override
  String get fdOptionPremium => 'Premium (€60+ Production / €120+ Retail)';

  @override
  String get fdQuestionFeatures =>
      'Would you like to include any special values or features that matter to you or your brand? I can make sure they\'re part of the final concept';

  @override
  String get fdOptionOrganicFabric => 'Organic Fabric';

  @override
  String get fdOptionUpcycled => 'Upcycled Materials';

  @override
  String get fdOptionLocallyMade => 'Locally Made (Europe)';

  @override
  String get fdOptionUVProtection => 'UV Protection';

  @override
  String get fdOptionQuickDry => 'Quick-Dry';

  @override
  String get fdOptionWrinkleFree => 'Wrinkle-Free';

  @override
  String get fdOptionOther => 'Other: ?';

  @override
  String get fdQuestionAdditional =>
      'Cool — feel free to type in anything else you have in mind!';

  @override
  String get fdSnackbarRegeneratingDesigns => 'Regenerating Designs!';

  @override
  String get fdSnackbarRegeneratingMessage =>
      'Creating 3 new designs based on your updated preferences...';

  @override
  String get fdSnackbarGeneratingDesigns => 'Generating Designs!';

  @override
  String get fdSnackbarGeneratingMessage =>
      'Creating 3 unique designs based on your preferences...';

  @override
  String get fdSnackbarExtraDesigns => 'Extra Designs Added!';

  @override
  String get fdSnackbarExtraDesignsMessage =>
      '5 extra designs have been added to your account.';

  @override
  String get fdDialogLimitExceeded => 'Limit Exceeded';

  @override
  String get fdDialogLimitMessage =>
      'You have exceeded your limit for this month. You can pay €9.99 for 5 extra designs or upgrade your plan.';

  @override
  String get fdDialogLimitMessageFree =>
      'You have exceeded your free plan limit for this month. Upgrade to Starter or Pro to continue creating designs.';

  @override
  String get fdDialogGetExtraDesigns => 'Get Extra Designs (€9.99)';

  @override
  String get fdDialogUpgradePlan => 'Upgrade Plan';

  @override
  String get fdDialogMaybeLater => 'Maybe Later';

  @override
  String get fdDialog80PercentTitle => 'Almost at Your Limit!';

  @override
  String fdDialog80PercentMessage(int used, int total) {
    return 'You\'ve used $used of $total designs this month. Consider upgrading or purchasing extra designs to continue creating.';
  }

  @override
  String fdDialog80PercentMessageFree(int used, int total) {
    return 'You\'ve used $used of $total designs this month. Upgrade to Starter or Pro for more designs.';
  }

  @override
  String get fdDialog80PercentContinue => 'Continue Anyway';

  @override
  String get tpDialog80PercentTitle => 'Almost at Your Techpack Limit!';

  @override
  String tpDialog80PercentMessage(int used, int total) {
    return 'You\'ve used $used of $total techpacks this month. Consider upgrading to continue generating techpacks.';
  }

  @override
  String get tpDialog80PercentContinue => 'Continue Anyway';

  @override
  String get tpDesignAssistant => 'Design Assistant';

  @override
  String get tpChooseFavoriteDesign => 'Choose your favorite design:';

  @override
  String get tpCreatingDesigns => 'Creating your designs...';

  @override
  String get tpPleaseWaitGenerating =>
      'Please wait while we generate 3 unique designs based on your preferences.';

  @override
  String get tpSomethingWentWrong => 'Something went wrong';

  @override
  String get tpRetry => 'Retry';

  @override
  String get tpWouldYouLikeChanges =>
      'Would you like to make any changes before I create the final tech pack?';

  @override
  String get tpYesChanges => 'Yes, I\'d like to make changes';

  @override
  String get tpContinueWithSelected => 'Continue with Selected Design';

  @override
  String get tpContinueAsIs => 'No, continue as is';

  @override
  String get tpRecommendedManufacturers => 'Recommended Manufacturers';

  @override
  String get tpCustomTab => 'Custom';

  @override
  String get tpSelectImageGallery => 'Select Image from Gallery';

  @override
  String tpManufacturerPrefix(String name, String country) {
    return 'Manufacturer: $name ($country)';
  }

  @override
  String get tpUpgradeRequired => 'Upgrade Required';

  @override
  String get tpUpgradeToGenerate =>
      'Upgrade to Starter or Pro to generate tech packs';

  @override
  String get tpGetExtraDesigns => 'Get 5 Extra Designs';

  @override
  String get tpViewPlans => 'View Plans';

  @override
  String get tpMaybeLater => 'Maybe Later';

  @override
  String get tpFreePlanLimit => 'Free Plan Limit';

  @override
  String get tpFreePlanMessage =>
      'Free plan users can generate up to 3 designs per month. Upgrade for more designs and tech packs!';

  @override
  String get tpProLimitReached => 'Pro Limit Reached';

  @override
  String get tpProLimitMessage =>
      'You\'ve reached your monthly limit. Get 5 extra designs for €9.99!';

  @override
  String get tpSnackbarDesignUpdated => 'Design Updated';

  @override
  String get tpSnackbarDesignUpdatedMessage =>
      'Your design has been updated with new preferences';

  @override
  String get tpSnackbarDesignSaved => 'Design Saved';

  @override
  String get tpSnackbarDesignSavedMessage =>
      'Your selected design has been saved successfully';

  @override
  String get tpSnackbarGenerationFailed => 'Generation Failed';

  @override
  String get tpSnackbarGenerationFailedMessage =>
      'Failed to generate designs. Please try again.';

  @override
  String get tpSnackbarNoDesignSelected => 'No Design Selected';

  @override
  String get tpSnackbarNoDesignSelectedMessage =>
      'Please select a design before continuing';

  @override
  String get tpSnackbarPurchaseSuccess => 'Purchase Successful!';

  @override
  String get tpSnackbarPurchaseSuccessMessage =>
      '5 extra designs added to your account';

  @override
  String get tpSnackbarPurchaseFailed => 'Purchase Failed';

  @override
  String get tpSnackbarPurchaseFailedMessage =>
      'Failed to process purchase. Please try again.';

  @override
  String get tpPlanFree => 'Free';

  @override
  String get tpPlanStarter => 'Starter';

  @override
  String get tpPlanPro => 'Pro';

  @override
  String get tpDialogChooseUpgrade => 'Choose Your Upgrade';

  @override
  String get tpDialogUpgradeDescription =>
      'Unlock unlimited tech pack generation and more features!';

  @override
  String get tpDialogFeature3TechPacks => '3 tech packs/month';

  @override
  String get tpDialogFeatureBasicPDF => 'Basic PDF export';

  @override
  String get tpDialogFeatureManufacturers => 'Manufacturer access';

  @override
  String get tpDialogFeature10TechPacks => '10 tech packs/month';

  @override
  String get tpDialogFeatureCustomPDF => 'Custom PDF with logo';

  @override
  String get tpDialogFeaturePriority => 'Priority support';

  @override
  String get tpDialogExtraTechPacksTitle => 'Need More Designs This Month?';

  @override
  String get tpDialogExtraTechPacksDescription =>
      'Get 5 extra designs for just €9.99';

  @override
  String get tpDialogExtraTechPacksOneTime => 'One-time purchase';

  @override
  String get tpDialogExtraTechPacksNoSubscription => 'No subscription required';

  @override
  String get tpDialogExtraTechPacksExpires =>
      'Does not expire until fully used';

  @override
  String get tpDialogPurchaseFor => 'Purchase for €9.99';

  @override
  String get tpDialogUpgradeInstead => 'Upgrade Instead';

  @override
  String get tpTechpackFeaturePremium =>
      'Techpack generation is a premium feature.';

  @override
  String get tpProMonthlyLimitReached =>
      'Your monthly techpack generation limit has been reached.';

  @override
  String get tpStarterYearlyLimitReached =>
      'Your monthly techpack generation limit has been reached.';

  @override
  String get tpStarterMonthlyLimitReached =>
      'Your monthly techpack generation limit has been reached.';

  @override
  String get tpDialogChoosePlan => 'Choose a plan:';

  @override
  String get tpDialogUpgradeToPro => 'Upgrade to Pro:';

  @override
  String tpDialogCurrentPlan(String plan) {
    return 'Current Plan: $plan';
  }

  @override
  String tpDialogRemainingTechpacksPro(int remaining) {
    return 'Remaining: $remaining/6 techpacks this month';
  }

  @override
  String tpDialogRemainingTechpacksStarter(int remaining) {
    return 'Remaining: $remaining/2 this month';
  }

  @override
  String get tpDialogStarterPlanOption =>
      'Starter: 2 techpacks/month (€19.99/mo or €199.99/yr)';

  @override
  String get tpDialogProPlanOption =>
      'Pro: 6 techpacks/month (€49.99/mo or €499.99/yr)';

  @override
  String get tpDialogStudioPlanOption =>
      'Studio: 10 techpacks/month (€99.99/mo or €999.99/yr)';

  @override
  String tpDialogRemainingTechpacksStudio(int remaining) {
    return 'Remaining: $remaining/10 this month';
  }

  @override
  String get tpDialogProUpgradeOption => 'Pro: 8 techpacks/month';

  @override
  String get tpDialogExtraTechpackOption =>
      'Purchase extra +1 techpack (€5.99)';

  @override
  String get tpDialogFeatureCustomPDFExport =>
      'Custom PDF export with your logo';

  @override
  String get tpDialogFeatureManufacturerAccess =>
      'Access to manufacturers list';

  @override
  String get tpDialogFeatureUnlimited3D => 'Unlimited 3D visualization';

  @override
  String get tpDialogFeatureProfessionalPDF =>
      'Professional PDF techpack exports';

  @override
  String get tpDialogFeatureManufacturerDB => 'Access to manufacturer database';

  @override
  String get tpDialogUpgradeNow => 'Upgrade Now';

  @override
  String get tpDialogTechpackPremiumRequired =>
      'Final techpack generation requires a premium plan.';

  @override
  String get tpProLimitDialogTitle => 'Monthly Limit Reached';

  @override
  String get tpProLimitDialogProPlan => 'Pro Plan: ';

  @override
  String tpProLimitDialogMonthlyUsed(int used) {
    return 'Monthly limit reached: $used/8 techpacks used';
  }

  @override
  String get tpProLimitDialogMessage =>
      'You\'ve reached your Pro plan monthly limit of 8 techpacks. Purchase additional techpacks to continue:';

  @override
  String get tpProLimitDialogTechpackPrice => '+1 Techpack: €5.99';

  @override
  String get tpProLimitDialogTechpackDescription =>
      'Get 1 additional techpack (one-time purchase, does not auto-renew)';

  @override
  String get tpProLimitDialogPurchaseButton => 'Purchase +1 Techpack';

  @override
  String get mfManufacturerSuggestions => 'Manufacturer Suggestions';

  @override
  String get mfLoadingManufacturers => 'Loading manufacturers...';

  @override
  String mfFoundManufacturers(int count) {
    return 'We found $count manufacturers from around the world.';
  }

  @override
  String get mfNoManufacturersAvailable => 'No manufacturers available';

  @override
  String get mfAllManufacturersLoaded => 'All manufacturers loaded';

  @override
  String get mfFilterManufacturers => 'Filter Manufacturers';

  @override
  String get mfUseFiltersBelow =>
      'Use filters below to search our manufacturer directory:';

  @override
  String get mfCountryOrRegion => 'Country or Region';

  @override
  String get mfSearchCountry => 'Search';

  @override
  String get mfSearchCountryHint => 'Start typing to search';

  @override
  String get mfSearchManufacturer => 'Search manufacturers by name...';

  @override
  String get mfAllCountries => 'All Countries';

  @override
  String get mfSearch => 'Search';

  @override
  String get mfStartTypingToSearch => 'Start typing to search';

  @override
  String get mfClearFilter => 'Clear Filter';

  @override
  String get mfShowAll => 'Show All';

  @override
  String get mfNoSuggestedManufacturers => 'No suggested manufacturers found';

  @override
  String mfRecommendedForYou(int count, String plural) {
    return 'Found $count recommended manufacturer$plural for you';
  }

  @override
  String get mfNoRecommendedClickShowAll =>
      'No recommended manufacturers found. Click Show All to view all manufacturers';

  @override
  String get mfNoManufacturersFound => 'No manufacturers found';

  @override
  String get mfTryAdjustingFilters => 'Try adjusting your filters';

  @override
  String mfManufacturersFound(int count, String plural) {
    return '$count manufacturer$plural found';
  }

  @override
  String get mfSendingEmail => 'Sending Email...';

  @override
  String get mfPreparingTechPack =>
      'Preparing your tech pack\nand sending to manufacturer';

  @override
  String get mfSendViaEmail => 'Send via Email';

  @override
  String get mfContact => 'Contact';

  @override
  String get mfHideDetails => 'Hide Details';

  @override
  String get mfMoreDetails => 'More Details';

  @override
  String get mfMinimumOrderQuantity => 'Minimum Order Quantity';

  @override
  String get mfCertifications => 'Certifications';

  @override
  String get mfProductsCapabilities => 'Products & Capabilities';

  @override
  String mfContactManufacturer(String name) {
    return 'Contact $name';
  }

  @override
  String get mfEmail => 'Email';

  @override
  String get mfWebsite => 'Website';

  @override
  String get mfInstagram => 'Instagram';

  @override
  String get mfNotAvailable => 'Not available';

  @override
  String get mfClose => 'Close';

  @override
  String get mfError => 'Error';

  @override
  String get mfEmailNotAvailable => 'Email not available';

  @override
  String get mfWebsiteNotAvailable => 'Website not available';

  @override
  String get mfCouldNotOpenLink => 'Could not open link';

  @override
  String get mfNoEmailAvailable => 'No Email Available';

  @override
  String get mfManufacturerNoEmail =>
      'This manufacturer does not have an email address on file.';

  @override
  String get mfEmailSentSuccessfully => 'Email Sent Successfully!';

  @override
  String mfTechPackSentTo(String name, String email) {
    return 'Your tech pack has been sent to $name at $email';
  }

  @override
  String get mfEmailFailed => 'Email Failed';

  @override
  String mfFailedToSendEmail(String name) {
    return 'Failed to send email to $name. Please try again.';
  }

  @override
  String mfErrorSendingEmail(String error) {
    return 'An error occurred while sending email: $error';
  }

  @override
  String get mfPreviewEmail => 'Preview Email';

  @override
  String get mfCancel => 'Cancel';

  @override
  String get mfSendEmail => 'Send Email';

  @override
  String get mfTechPackSummary => 'Tech Pack Summary';

  @override
  String get mfMaterial => 'Material';

  @override
  String get mfPrimaryColor => 'Primary Color';

  @override
  String get mfSizeRange => 'Size Range';

  @override
  String get mfQuantity => 'Quantity';

  @override
  String get mfTargetCost => 'Target Cost';

  @override
  String get mfDelivery => 'Delivery';

  @override
  String mfPDFAttachment(String name, String size) {
    return 'PDF attachment: $name ($size KB)';
  }

  @override
  String mfImagesAttached(int count) {
    return 'Images attached: $count';
  }

  @override
  String get tpdFinalDesignValidated => 'Final Design Validated';

  @override
  String get tpdMaterialsFabrics => 'Materials & Fabrics';

  @override
  String get tpdMainFabricLabel => 'What is the main fabric used?';

  @override
  String get tpdMainFabricHint => 'Main Fabric: Organic cotton twill';

  @override
  String get tpdSecondaryMaterialsLabel =>
      'Are there any secondary materials or linings?';

  @override
  String get tpdSecondaryMaterialsHint => 'Polyester mesh lining';

  @override
  String get tpdFabricPropertiesLabel =>
      'Does the fabric have any technical properties? (e.g. organic, stretch, water-repellent)';

  @override
  String get tpdFabricPropertiesHint =>
      'Breathable, stretchable, water-repellent';

  @override
  String get tpdColors => 'Colors';

  @override
  String get tpdPrimaryColorLabel =>
      'What is the primary color of the garment?';

  @override
  String get tpdPrimaryColorHint => 'Sky blue';

  @override
  String get tpdAlternateColorwaysLabel =>
      'Are there any alternate colorways to produce?';

  @override
  String get tpdAlternateColorwaysHint => 'Sage green, off-white';

  @override
  String get tpdPantoneLabel =>
      'Do you have Pantone references or HEX codes for the colors?';

  @override
  String get tpdPantoneHint => 'Pantone 290C, #C1DAD6';

  @override
  String get tpdSizesMeasurements => 'Sizes & Measurements';

  @override
  String get tpdSizeRangeLabel =>
      'Do you want to use standard size charts or enter custom measurements? (e.g. XS–XL)';

  @override
  String get tpdSizeRangeHint => 'Size Range: XS, S, M, L, XL';

  @override
  String get tpdMeasurementChartLabel =>
      'Will you provide a measurement chart by size?';

  @override
  String get tpdMeasurementChartHint => 'No';

  @override
  String get tpdOr => 'or';

  @override
  String get tpdAutogeneratedLabel =>
      'Or should the AI auto-generate one from the 3D model?';

  @override
  String get tpdAutogeneratedHint => 'Yes';

  @override
  String get tpdTechnicalDetails => 'Technical Details';

  @override
  String get tpdAccessoriesLabel => 'Are there any accessories?';

  @override
  String get tpdAccessoriesHint => 'Zipper, buttons, drawcord';

  @override
  String get tpdStitchingLabel => 'Which stitch type should be used?';

  @override
  String get tpdStitchingHint => 'Single, double, overlock etc';

  @override
  String get tpdDecorativeStitchingLabel =>
      'Do you require visible, reinforced, or decorative stitching?';

  @override
  String get tpdDecorativeStitchingHint => 'Contrast topstitching sleeves';

  @override
  String get tpdLabelingBranding => 'Labeling & Branding';

  @override
  String get tpdLogoPlacementLabel =>
      'Where should the logo or brand name appear?';

  @override
  String get tpdLogoPlacementHint => 'Logo Placement: Chest & neck';

  @override
  String get tpdLabelsNeededLabel => 'What types of labels are needed?';

  @override
  String get tpdLabelsNeededHint => 'Brand, care, size';

  @override
  String get tpdUploadReferenceImage => 'Upload reference image (optional)';

  @override
  String get tpdQrCodeLabel =>
      'Should a QR code, barcode, or NFC chip be included?';

  @override
  String get tpdQrCodeHint => 'Add QR code';

  @override
  String get tpdPackagingShipping => 'Packaging & Shipping';

  @override
  String get tpdPackagingTypeLabel => 'What type of packaging is required?';

  @override
  String get tpdPackagingTypeHint => 'Kraft box + polybag';

  @override
  String get tpdFoldingInstructionsLabel =>
      'Any specific folding or packing instructions?';

  @override
  String get tpdFoldingInstructionsHint => 'Fold across chest';

  @override
  String get tpdInsertsLabel =>
      'Would you like to include a product sheet or flyer?';

  @override
  String get tpdInsertsHint => 'Inserts: Thank-you card, care sheet';

  @override
  String get tpdProductionDetails => 'Production Details';

  @override
  String get tpdCostPerPieceLabel => 'What is the target cost per piece?';

  @override
  String get tpdCostPerPieceHint => 'Cost per Piece: €3.8';

  @override
  String get tpdQuantityLabel => 'How many units do you plan to produce?';

  @override
  String get tpdQuantityHint => 'Quantity: 1,000 units';

  @override
  String get tpdDeliveryDateLabel => 'What is your desired delivery date?';

  @override
  String get tpdDeliveryDateHint => 'Delivery: 30 Sept 2025';

  @override
  String get tpdManufacturers => 'Manufacturers';

  @override
  String get tpdSelectCountryForManufacturers =>
      'Select a country for manufacturer suggestions';

  @override
  String get tpdSearchCountry => 'Search';

  @override
  String get tpdSearchCountryHint => 'Start typing to search';

  @override
  String get tpdSelectACountry => 'Select a country';

  @override
  String get tpdGenerateTechPack => 'Generate Tech Pack';

  @override
  String get tprYourTechPackReady => 'Your Tech Pack Is \nReady';

  @override
  String get tprGeneratedTechPackImages => 'Generated Tech Pack Images';

  @override
  String get tprCreatingTechPack => 'Creating your tech pack...';

  @override
  String get tprPleaseWaitGenerating =>
      'Please wait while we generate your tech pack images with all specifications.';

  @override
  String get tprTechPackDetails => 'Tech Pack Details';

  @override
  String get tprTechnicalFlatDrawing => 'Technical Flat Drawing';

  @override
  String get tprGenerating => 'Generating';

  @override
  String tprLogoPlacement(String placement) {
    return 'Logo / $placement';
  }

  @override
  String get tprNoTechPackImages => 'No tech pack images generated yet';

  @override
  String get tprWarningTitle => 'Warning';

  @override
  String get tprNavigationWarningMessage =>
      'Generation is in progress. Going back will cancel the generation and you will lose your tech pack. Are you sure?';

  @override
  String get tprStayHere => 'Stay Here';

  @override
  String get tprGoBack => 'Go Back';

  @override
  String get tprGenerationInProgress =>
      'Tech pack generation already in progress. Please wait...';

  @override
  String get tprGetManufacturerSuggestions => 'Get Manufacturer Suggestions';

  @override
  String get tprCollectionExists => 'Collection Exists';

  @override
  String get tprCollectionAlreadyExists => 'This collection already exists';

  @override
  String get tprError => 'Error';

  @override
  String get tprFailedToAddCollection => 'Failed to add collection';

  @override
  String get tprNoImages => 'No Images';

  @override
  String get tprGenerateImagesFirst => 'Please generate tech pack images first';

  @override
  String get tprUpdated => 'Updated!';

  @override
  String get tprTechPackUpdatedSuccessfully =>
      'Tech pack updated successfully!';

  @override
  String get tprSuccess => 'Success';

  @override
  String get tprTechPackSavedSuccessfully => 'Tech pack saved successfully!';

  @override
  String tprFailedToSaveTechPack(String error) {
    return 'Failed to save tech pack: $error';
  }

  @override
  String get tprPdfSavedSuccessfully => 'Tech pack PDF saved successfully!';

  @override
  String tprFailedToExportPdf(String error) {
    return 'Failed to export PDF: $error';
  }

  @override
  String tprFailedToExportWord(String error) {
    return 'Failed to export Word document: $error';
  }

  @override
  String tprFailedToShareFile(String error) {
    return 'Failed to share file: $error';
  }

  @override
  String get tprTechPackDocument => 'Tech Pack Document';

  @override
  String get tprSavingDesign => 'Saving Design';

  @override
  String get tprSavingDesignMessage =>
      'Please wait while we finish saving your design...';

  @override
  String get tprSaveFailed => 'Save Failed';

  @override
  String get tprDesignSaveFailedMessage =>
      'Failed to verify design save status. Please try again.';

  @override
  String get tprDesignSaveTimeoutMessage =>
      'Design save is taking too long. Please try again.';

  @override
  String get vpManufacturerProfile => 'Manufacturer Profile';

  @override
  String get vpCompany => 'Company';

  @override
  String get vpLocation => 'Location';

  @override
  String get vpMinimumOrderQuantity => 'Minimum Order Quantity';

  @override
  String get vpLeadTime => 'Lead Time';

  @override
  String get vpAbout => 'About';

  @override
  String get vpContact => 'Contact';

  @override
  String get tpwSaveTechPack => 'Save Tech Pack';

  @override
  String get tpwProjectName => 'Project Name';

  @override
  String get tpwEnterProjectName => 'Enter project name';

  @override
  String get tpwCollectionName => 'Collection Name';

  @override
  String get tpwAdd => 'ADD';

  @override
  String get tpwSave => 'SAVE';

  @override
  String get tpwError => 'Error';

  @override
  String get tpwPleaseEnterProjectName => 'Please enter a project name';

  @override
  String get tpwAddCollection => 'ADD COLLECTION';

  @override
  String get tpwEnterCollectionName => 'Enter collection name';

  @override
  String get tpwPleaseEnterCollectionName => 'Please enter a collection name';

  @override
  String get tpwExportOptions => 'Export Options';

  @override
  String get tpwSelectExportFormat => 'Select your preferred export format';

  @override
  String get tpwPdfWithLogo => 'PDF with logo/branding';

  @override
  String get tpwIncludesAtellaBranding => 'Includes ATELIA branding and logo';

  @override
  String get tpwNeutralPdf => 'Neutral PDF';

  @override
  String get tpwCleanPdfWithoutBranding => 'Clean PDF without branding';

  @override
  String get tpwEditableFormatWord => 'Editable Format (Word)';

  @override
  String get tpwEditableWordDocument =>
      'Editable Word document with cover page and images';

  @override
  String get tpwCancel => 'Cancel';

  @override
  String get tpwOk => 'OK';

  @override
  String get tpwSaveButton => 'Save';

  @override
  String get tpwExportButton => 'Export';

  @override
  String get tpwGenerating => 'Generating..';

  @override
  String get tpdEditMode => 'Edit Mode';

  @override
  String get tpdLoadingExistingTechPack => 'Loading existing tech pack data...';

  @override
  String get tpdNotice => 'Notice';

  @override
  String get tpdStartingWithEmptyForm => 'Starting with empty tech pack form';

  @override
  String get tpdSuccess => 'Success';

  @override
  String get tpdTechPackImagesGenerated =>
      'Detailed tech pack images generated with professional labeling!';

  @override
  String get tpdPartialSuccess => 'Partial Success';

  @override
  String get tpdSomeTechPackImagesGenerated =>
      'Some tech pack images generated. Check results.';

  @override
  String get tpdError => 'Error';

  @override
  String tpdFailedToGenerateTechPack(String error) {
    return 'Failed to generate detailed tech pack images: $error';
  }

  @override
  String tpdFailedToPickImage(String error) {
    return 'Failed to pick image: $error';
  }

  @override
  String get tpdProcessing => 'Processing';

  @override
  String get tpdProcessingYourPurchase => 'Processing your purchase...';

  @override
  String get tpdSuccessExclamation => 'Success!';

  @override
  String tpdAdditionalTechPacksAdded(String count) {
    return 'You now have $count additional techpacks for this month!';
  }

  @override
  String get tpdPurchaseFailed => 'Purchase Failed';

  @override
  String get tpdUnableToProcessPurchase =>
      'Unable to process your purchase. Please try again.';

  @override
  String tpdPurchaseError(String error) {
    return 'An error occurred during purchase: $error';
  }

  @override
  String tpgDesignNumber(String number) {
    return 'Design $number';
  }

  @override
  String get tpgGenerating => 'Generating';

  @override
  String get tpgFailedToGenerate => 'Failed to generate';

  @override
  String get tpgFailedToLoadImage => 'Failed to load image';

  @override
  String get cancellationReasonTooExpensive => 'Too expensive';

  @override
  String get cancellationReasonNotUsing => 'Not using it enough';

  @override
  String get cancellationReasonMissingFeatures => 'Missing features I need';

  @override
  String get cancellationReasonBetterAlternative =>
      'Found a better alternative';

  @override
  String get cancellationReasonTechnicalIssues => 'Technical issues';

  @override
  String get cancellationReasonOther => 'Other';

  @override
  String get studioDescription => 'For studios, agencies, and power users';

  @override
  String get studioFeatureAiDesignLimit => '25 AI design generations per month';

  @override
  String get studioFeatureTechpackMonthly => '10 techpacks per month';

  @override
  String get studioFeatureTechpackYearly =>
      '10 techpacks per month (120 per year)';

  @override
  String get studio => 'Studio';

  @override
  String cbEnterCustom(String category) {
    return 'Enter custom $category...';
  }

  @override
  String get fdQuestionTargetSeason =>
      'Great! Let\'s make sure your piece fits perfectly with the season. What kind of weather will it be designed for?';

  @override
  String get fdSeasonSummer => 'Summer (Lightweight, Short Or Roll-Up Sleeves)';

  @override
  String get fdSeasonMid => 'Mid-Season';

  @override
  String get fdSeasonAll => 'All-Season (Layer-Friendly)';

  @override
  String get fdQuestionTargetBudget =>
      'Got it. And what kind of budget are you working with for this design? I can tailor the fabrics and features accordingly.';

  @override
  String get fdBudgetEntry => 'Entry-Level (€15-30 Production / €35-60 Retail)';

  @override
  String get fdBudgetMid => 'Mid-Range (€30-50 Production / €60-120 Retail)';

  @override
  String get fdBudgetPremium => 'Premium (€60+ Production / €120+ Retail)';

  @override
  String get fdQuestionDesiredFeatures =>
      'Would you like to include any special values or features that matter to you or your brand? I can make sure they\'re part of the final concept';

  @override
  String get fdFeatureOrganic => 'Organic Fabric';

  @override
  String get fdFeatureUpcycled => 'Upcycled Materials';

  @override
  String get fdFeatureLocallyMade => 'Locally Made (Europe)';

  @override
  String get fdFeatureUvProtection => 'UV Protection';

  @override
  String get fdFeatureQuickDry => 'Quick-Dry';

  @override
  String get fdFeatureWrinkleFree => 'Wrinkle-Free';

  @override
  String get fdFeatureOther => 'Other: ?';

  @override
  String get fdQuestionAdditionalDetails =>
      'Cool — feel free to type in anything else you have in mind!';

  @override
  String get fdRegeneratingDesigns => 'Regenerating Designs!';

  @override
  String get fdRegeneratingDesignsMessage =>
      'Creating 3 new designs based on your updated preferences...';

  @override
  String get fdGeneratingDesigns => 'Generating Designs!';

  @override
  String get fdGeneratingDesignsMessage =>
      'Creating 3 unique designs based on your preferences...';

  @override
  String get fdExtraDesignsAdded => 'Extra Designs Added!';

  @override
  String get fdExtraDesignsAddedMessage =>
      '5 extra designs have been added to your account.';

  @override
  String fdToday(String time) {
    return 'Today, $time';
  }

  @override
  String get authUserCreationFailed =>
      'User creation failed. Please try again.';

  @override
  String get authGenericError => 'An error occurred. Please try again.';

  @override
  String get authEmailAlreadyInUse =>
      'This email is already registered. Please sign in instead.';

  @override
  String get authWeakPassword =>
      'Password is too weak. Please use a stronger password.';

  @override
  String get authInvalidEmail =>
      'Invalid email address. Please check and try again.';

  @override
  String get authOperationNotAllowed =>
      'This operation is not allowed. Please contact support.';

  @override
  String get authUserNotFound =>
      'No user found with this email. Please sign up first.';

  @override
  String get authWrongPassword => 'Incorrect password. Please try again.';

  @override
  String get authUserDisabled =>
      'This account has been disabled. Please contact support.';

  @override
  String get authTooManyRequests =>
      'Too many failed attempts. Please try again later.';

  @override
  String get authNetworkError =>
      'Network error. Please check your internet connection.';

  @override
  String get authGoogleSignInCancelled => 'Google sign-in was cancelled.';

  @override
  String get authGoogleSignInFailed =>
      'Google sign-in failed. Please try again.';

  @override
  String get authGoogleConfigError =>
      'Configuration error. Please contact support.';

  @override
  String get authGoogleGenericError =>
      'An error occurred during Google sign-in. Please try again.';

  @override
  String get authAppleSignInCancelled => 'Apple sign-in was cancelled.';

  @override
  String get authAppleSignInFailed => 'Apple sign-in failed. Please try again.';

  @override
  String get authInvalidCredentials =>
      'Incorrect email or password. Please try again.';

  @override
  String get collectionSummer => 'SUMMER COLLECTION';

  @override
  String get collectionWinter => 'WINTER COLLECTION';

  @override
  String get termsAndConditions => 'Terms & Conditions';

  @override
  String get tcLastUpdated => 'Last updated: January 2025';

  @override
  String get tcIntroduction =>
      'These Terms & Conditions govern your access to and use of the Atelia mobile application, website, and services.\n\nBy downloading, accessing, or using Atelia, you agree to these Terms.';

  @override
  String get tcCompanyInformation => 'Company Information';

  @override
  String get tcCompanyInformationContent =>
      'Atelia SAS – France\nRegistered office: Guérande, France\nContact email: ateliadesign.contact@gmail.com';

  @override
  String get tcDescriptionOfService => 'Description of the Service';

  @override
  String get tcDescriptionOfServiceContent =>
      'Atelia is a SaaS platform that allows users to:\n• Generate fashion designs using AI\n• Create technical packs (techpacks)\n• Visualize designs in 3D\n• Access a directory of garment manufacturers\n• Export files and documents related to production\n\nAtelia provides assistance tools and does not replace professional designers, manufacturers, or consultants.';

  @override
  String get tcEligibility => 'Eligibility';

  @override
  String get tcEligibilityContent =>
      '• You must be at least 16 years old\n• You must have the legal capacity to enter into a contract\n• You are responsible for ensuring your use complies with local laws';

  @override
  String get tcUserAccount => 'User Account';

  @override
  String get tcUserAccountContent =>
      '• You are responsible for maintaining the confidentiality of your login credentials\n• You are responsible for all activity under your account\n• Atelia reserves the right to suspend or terminate accounts for misuse or violation of these Terms';

  @override
  String get tcSubscriptionsAndPayments => 'Subscriptions & Payments';

  @override
  String get tcSubscriptionsAndPaymentsContent =>
      'Atelia offers free and paid subscription plans. Details of pricing, limits, and features are displayed inside the app.\n\nSubscriptions may include:\n• Monthly or yearly billing\n• Usage limits (designs, techpacks, exports)\n• Optional add-ons\n\nPayments are processed through Apple App Store (iOS) or Google Play Store (Android). Atelia does not store payment information.\n\nSubscriptions automatically renew unless canceled at least 24 hours before the end of the current period. You can manage or cancel your subscription via Apple ID settings or Google Play account settings.\n\nRefunds are managed exclusively by Apple or Google, according to their respective policies. Atelia cannot issue refunds directly.';

  @override
  String get tcUsageLimits => 'Usage Limits & Fair Use';

  @override
  String get tcUsageLimitsContent =>
      'Each subscription plan includes usage limits.\n• Unused credits do not roll over\n• Abuse or excessive usage may result in temporary limitations or account suspension\n• Atelia reserves the right to modify usage limits to ensure service stability';

  @override
  String get tcIntellectualProperty => 'Intellectual Property';

  @override
  String get tcIntellectualPropertyContent =>
      'All software, trademarks, logos, and content are owned by Atelia. You may not copy, modify, or redistribute Atelia\'s platform without authorization.\n\nYou retain ownership of the content you create. You grant Atelia a non-exclusive license to process and store content to provide the service. Atelia does not claim ownership over your designs.';

  @override
  String get tcAIContentDisclaimer => 'AI-Generated Content Disclaimer';

  @override
  String get tcAIContentDisclaimerContent =>
      '• AI-generated designs and techpacks are suggestions, not guarantees\n• Atelia does not guarantee manufacturability, compliance, or production success\n• Users remain fully responsible for verifying outputs before production';

  @override
  String get tcFactoryDirectoryDisclaimer => 'Factory Directory Disclaimer';

  @override
  String get tcFactoryDirectoryDisclaimerContent =>
      '• Atelia does not own or operate the listed factories\n• Atelia is not responsible for contracts, pricing, quality, or disputes between users and manufacturers\n• Any collaboration is strictly between the user and the factory';

  @override
  String get tcLimitationOfLiability => 'Limitation of Liability';

  @override
  String get tcLimitationOfLiabilityContent =>
      'To the maximum extent permitted by law:\n• Atelia is not liable for indirect or consequential damages\n• Atelia is not responsible for financial losses, production issues, or business failure\n• Total liability shall not exceed the amount paid by the user in the last 12 months';

  @override
  String get tcServiceAvailability => 'Service Availability';

  @override
  String get tcServiceAvailabilityContent =>
      '• Atelia strives for high availability but does not guarantee uninterrupted access\n• Features may be modified, suspended, or discontinued at any time';

  @override
  String get tcTermination => 'Termination';

  @override
  String get tcTerminationContent =>
      'You may stop using Atelia at any time.\n\nAtelia may terminate access in case of:\n• Breach of these Terms\n• Fraud or abuse\n• Legal obligations';

  @override
  String get tcPrivacy => 'Privacy';

  @override
  String get tcPrivacyContent =>
      'Your use of Atelia is governed by our Privacy Policy, available at:\nhttps://www.atelia.ai/privacy';

  @override
  String get tcGoverningLaw => 'Governing Law';

  @override
  String get tcGoverningLawContent =>
      'These Terms are governed by French law.\n\nAny dispute shall be subject to the jurisdiction of the courts of France.';

  @override
  String get tcChangesToTerms => 'Changes to Terms';

  @override
  String get tcChangesToTermsContent =>
      'Atelia may update these Terms at any time. Continued use of the app constitutes acceptance of the updated Terms.';

  @override
  String get tcContact => 'Contact';

  @override
  String get tcContactContent =>
      'For any questions or concerns regarding these Terms & Conditions, please contact us at:\n\nateliadesign.contact@gmail.com';

  @override
  String get ppLastUpdated => 'Last updated: January 2025';

  @override
  String get ppIntroduction =>
      'Atelia operates the Atelia mobile application and web platform.\n\nThis Privacy Policy explains how we collect, use, disclose, and protect your information when you use our Service.\n\nBy accessing or using Atelia, you agree to the collection and use of information in accordance with this Privacy Policy.';

  @override
  String get ppInformationWeCollect => '1. Information We Collect';

  @override
  String get ppInformationWeCollectContent =>
      'a. Personal Information\n\nWhen you create an account or use our Service, we may collect:\n• Name or username\n• Email address\n• Payment and billing information (processed securely by third-party providers)\n• Account preferences\n\nb. Usage Data\n\nWe automatically collect information such as:\n• Device type, operating system, and app version\n• IP address and approximate location\n• Pages/screens viewed and features used\n• Time and date of usage\n\nc. User Content\n\nWhen you use Atelia, you may provide:\n• Design prompts and inputs\n• Generated designs and techpacks\n• Files or content uploaded to the platform\n\nWe do not claim ownership over your content.';

  @override
  String get ppHowWeUseYourInformation => '2. How We Use Your Information';

  @override
  String get ppHowWeUseYourInformationContent =>
      'We use your data to:\n• Provide and operate the Service\n• Generate AI-based designs and techpacks\n• Manage subscriptions and payments\n• Improve product performance and user experience\n• Communicate updates, support messages, and important notices\n• Detect fraud, abuse, or misuse of the Service';

  @override
  String get ppAIAndThirdPartyServices => '3. AI & Third-Party Services';

  @override
  String get ppAIAndThirdPartyServicesContent =>
      'Atelia uses third-party services to operate:\n• AI model providers\n• Cloud infrastructure and hosting\n• Analytics and performance monitoring\n• Payment processors\n\nYour data may be processed by these providers only to deliver the Service and in accordance with applicable data protection laws.';

  @override
  String get ppDataRetention => '4. Data Retention';

  @override
  String get ppDataRetentionContent =>
      'We retain personal data only for as long as necessary to:\n• Provide the Service\n• Comply with legal obligations\n• Resolve disputes\n• Enforce agreements\n\nYou may request deletion of your account and data at any time.';

  @override
  String get ppDataSharingAndDisclosure => '5. Data Sharing & Disclosure';

  @override
  String get ppDataSharingAndDisclosureContent =>
      'We do not sell your personal data.\n\nWe may share data only:\n• With trusted service providers under confidentiality agreements\n• To comply with legal obligations\n• To protect our rights, users, or platform security';

  @override
  String get ppSecurity => '6. Security';

  @override
  String get ppSecurityContent =>
      'We implement industry-standard security measures to protect your data.\n\nHowever, no method of transmission or storage is 100% secure.';

  @override
  String get ppYourRights => '7. Your Rights';

  @override
  String get ppYourRightsContent =>
      'Depending on your location, you may have the right to:\n• Access your personal data\n• Correct inaccurate data\n• Request deletion of your data\n• Object to or restrict processing\n\nTo exercise these rights, contact us at:\nateliadesign.contact@gmail.com';

  @override
  String get ppChildrensPrivacy => '8. Children\'s Privacy';

  @override
  String get ppChildrensPrivacyContent =>
      'Atelia is not intended for users under the age of 16.\n\nWe do not knowingly collect personal data from children under 16. If we become aware of such data, we will delete it immediately.';

  @override
  String get ppInternationalDataTransfers => '9. International Data Transfers';

  @override
  String get ppInternationalDataTransfersContent =>
      'Your information may be transferred and stored on servers located outside your country.\n\nBy using Atelia, you consent to such transfers.';

  @override
  String get ppChangesToThisPrivacyPolicy =>
      '10. Changes to This Privacy Policy';

  @override
  String get ppChangesToThisPrivacyPolicyContent =>
      'We may update this Privacy Policy from time to time. Any changes will be posted within the app or on our website.\n\nContinued use of the Service after changes constitutes acceptance.';

  @override
  String get ppContactUs => '11. Contact Us';

  @override
  String get ppContactUsContent =>
      'If you have questions about this Privacy Policy, contact us:\n\nEmail: ateliadesign.contact@gmail.com';

  @override
  String get deleteAccount => 'Delete Account';

  @override
  String get deleteAccountTitle => 'Delete Your Account';

  @override
  String get deleteAccountWarning =>
      'Are you sure you want to delete your account?\n\nThis action cannot be undone and will permanently delete all your data including your profile, designs, tech packs, and subscription.';

  @override
  String get confirmDelete => 'Yes, Delete My Account';

  @override
  String get cancelDelete => 'Cancel';

  @override
  String get enterPassword => 'Enter Your Password';

  @override
  String get enterPasswordToConfirm =>
      'Please enter your password to confirm account deletion:';

  @override
  String get deleteMyAccount => 'Delete My Account';

  @override
  String get confirmWithGoogle => 'Confirm with Google';

  @override
  String get signInWithGoogleToConfirm =>
      'Please sign in with Google to confirm account deletion:';

  @override
  String get accountDeleted => 'Account Deleted';

  @override
  String get accountDeletedSuccess =>
      'Your account has been successfully deleted. We\'re sorry to see you go!';

  @override
  String get accountDeleteFailed =>
      'Failed to delete account. Please try again.';

  @override
  String get wrongPassword => 'Incorrect password. Please try again.';

  @override
  String get requiresRecentLogin =>
      'For security reasons, please log out and log back in before deleting your account.';

  @override
  String get userNotFound => 'User account not found.';

  @override
  String get networkError =>
      'Network error. Please check your connection and try again.';

  @override
  String get noInternetConnection => 'No Internet Connection';

  @override
  String get noInternetConnectionMessage =>
      'Please check your internet connection and try again.';

  @override
  String get googleReauthCancelled =>
      'Google sign-in was cancelled. Account deletion aborted.';

  @override
  String get appleReauthCancelled =>
      'Apple sign-in was cancelled. Account deletion aborted.';

  @override
  String get confirmWithApple => 'Confirm with Apple';

  @override
  String get signInWithAppleToConfirm =>
      'Please sign in with Apple to confirm account deletion:';

  @override
  String get deletingAccount => 'Deleting account...';

  @override
  String get couldNotOpenLink => 'Could not open link';

  @override
  String get learnMore => 'Explore';
}
