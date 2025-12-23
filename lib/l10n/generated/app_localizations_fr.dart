// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for French (`fr`).
class AppLocalizationsFr extends AppLocalizations {
  AppLocalizationsFr([String locale = 'fr']) : super(locale);

  @override
  String get appName => 'Atelia';

  @override
  String get welcomeToAtelia => 'Bienvenue sur ATELIA !';

  @override
  String get welcomeMessage => 'Bienvenue sur Atelia';

  @override
  String get login => 'Connexion';

  @override
  String get logIn => 'Se connecter';

  @override
  String get loggingIn => 'Connexion en cours...';

  @override
  String get signUp => 'S\'inscrire';

  @override
  String get signingUp => 'Inscription en cours...';

  @override
  String get signIn => 'Se connecter';

  @override
  String get email => 'E-mail';

  @override
  String get password => 'Mot de passe';

  @override
  String get confirmPassword => 'Confirmer le mot de passe';

  @override
  String get fullName => 'Nom complet';

  @override
  String get forgotPassword => 'Mot de passe oublié ?';

  @override
  String get continueWithGoogle => 'Continuer avec Google';

  @override
  String get continueWithApple => 'Continuer avec Apple';

  @override
  String get orContinueWith => 'Ou continuer avec';

  @override
  String get createAccount => 'Créer un compte';

  @override
  String get createYourAccount => 'Créez votre compte';

  @override
  String get alreadyHaveAccount => 'Vous avez déjà un compte ?';

  @override
  String get alreadyJoined => 'Déjà inscrit ?';

  @override
  String get dontHaveAccount => 'Vous n\'avez pas de compte ?';

  @override
  String get joinNow => 'Rejoindre maintenant';

  @override
  String get onboardingTitle =>
      'Bienvenue sur AteliA — Votre\nmarque de mode commence ici.';

  @override
  String get onboardingSubtitle =>
      'Transformez vos idées en vêtements réels — avec des outils de design alimentés par l\'IA et un support fabricant.';

  @override
  String get verification => 'Vérification';

  @override
  String get verificationDescription =>
      'Entrez votre adresse e-mail et nous vous enverrons un lien de vérification pour réinitialiser votre mot de passe.';

  @override
  String get sendVerificationLink => 'Envoyer le lien de vérification';

  @override
  String get home => 'Accueil';

  @override
  String get profile => 'Profil';

  @override
  String get settings => 'Paramètres';

  @override
  String get logout => 'Déconnexion';

  @override
  String get logoutConfirmation =>
      'Êtes-vous sûr de vouloir vous déconnecter ?';

  @override
  String get cancel => 'Annuler';

  @override
  String get confirm => 'Confirmer';

  @override
  String get save => 'Enregistrer';

  @override
  String get delete => 'Supprimer';

  @override
  String get edit => 'Modifier';

  @override
  String get editProfile => 'Modifier le profil';

  @override
  String get download => 'Télécharger';

  @override
  String get preview => 'Aperçu';

  @override
  String get loading => 'Chargement...';

  @override
  String get error => 'Erreur';

  @override
  String get success => 'Succès';

  @override
  String get retry => 'Réessayer';

  @override
  String get next => 'Suivant';

  @override
  String get back => 'Retour';

  @override
  String get done => 'Terminé';

  @override
  String get skip => 'Passer';

  @override
  String get language => 'Langue';

  @override
  String get english => 'Anglais';

  @override
  String get french => 'Français';

  @override
  String get selectLanguage => 'Sélectionner la langue';

  @override
  String get techPack => 'Dossier technique';

  @override
  String get designImage => 'Image de conception';

  @override
  String techPackImageN(int number) {
    return 'Image du dossier technique $number';
  }

  @override
  String get manufactureSuggestions => 'Suggestions de fabricants';

  @override
  String get noImagesAvailable => 'Aucune image disponible à télécharger';

  @override
  String downloadingNOfTotal(int current, int total) {
    return 'Téléchargement $current sur $total...';
  }

  @override
  String imagesSavedToGallery(int count) {
    return '$count images enregistrées dans la galerie dans l\'album \"Atelia\"';
  }

  @override
  String get myDesigns => 'Mes designs';

  @override
  String get myCollections => 'Mes collections';

  @override
  String get seeAll => 'Voir tout';

  @override
  String get startNewProject => 'Démarrer un nouveau projet';

  @override
  String get createNewDesign => 'Créer un nouveau design';

  @override
  String get createNewProject => 'Créer un nouveau projet';

  @override
  String get favorites => 'Favoris';

  @override
  String get noFavoritesYet => 'Pas encore de projets favoris';

  @override
  String get noFavoritesSubtitle =>
      'Commencez à créer des projets et marquez vos favoris pour les voir ici.';

  @override
  String get homeEmptyStateTitle =>
      'Ici pour vous guider dans la création du vêtement que vous avez en tête.';

  @override
  String noResultsFor(String query) {
    return 'Aucun résultat trouvé pour \"$query\"';
  }

  @override
  String get tryAdjustingSearch =>
      'Essayez d\'ajuster vos termes de recherche ou créez un nouveau projet.';

  @override
  String get clearSearch => 'Effacer la recherche';

  @override
  String get personalInformation => 'Informations personnelles';

  @override
  String get subscriptionPlan => 'Plan d\'abonnement';

  @override
  String get termsOfUse => 'Conditions d\'utilisation';

  @override
  String get privacyPolicy => 'Politique de confidentialité';

  @override
  String get allowAnalytics => 'Autoriser les analyses';

  @override
  String get analyticsDescription =>
      'Nous enregistrons les sessions pour améliorer votre expérience. Désactivez cette option pour arrêter toutes les analyses et enregistrements.';

  @override
  String get update => 'Mettre à jour';

  @override
  String get updating => 'Mise à jour...';

  @override
  String get subscribe => 'S\'abonner';

  @override
  String get chooseYourPlan => 'Choisissez votre plan';

  @override
  String get startForFree =>
      'Commencez gratuitement. Mettez à niveau à tout moment.';

  @override
  String get current => 'Actuel';

  @override
  String get free => 'Gratuit';

  @override
  String get starter => 'Starter';

  @override
  String get pro => 'Pro';

  @override
  String get monthly => 'Mensuel';

  @override
  String get yearlySavePercent => 'Annuel (Économisez 17%)';

  @override
  String get featuresInclude => 'Fonctionnalités incluses :';

  @override
  String get idealForLaunching =>
      'Idéal pour lancer vos premières productions.';

  @override
  String get forCreatorsReady =>
      'Pour les créateurs prêts à développer leur vision.';

  @override
  String get perfectToTest =>
      'Parfait pour tester, imaginer et créer librement.';

  @override
  String techpacksPerMonth(int count) {
    return '$count dossiers techniques par mois';
  }

  @override
  String techpacksPerMonthYearly(int count, int total) {
    return '$count dossiers techniques par mois ($total total par an)';
  }

  @override
  String get unlimited3DVisualization => 'Visualisation 3D illimitée';

  @override
  String get customPdfExport =>
      'Export PDF personnalisé (avec le logo de l\'utilisateur)';

  @override
  String get fullyCustomizedPdfExports =>
      'Exports PDF entièrement personnalisés';

  @override
  String get accessToManufacturers => 'Accès à la liste des fabricants';

  @override
  String get upTo10Designs => 'Jusqu\'à 10 designs 3D / mois';

  @override
  String get visualization3DIncluded => 'Visualisation 3D incluse';

  @override
  String get noTechpackGeneration => 'Pas de génération de dossier technique';

  @override
  String get noPdfExport => 'Pas d\'export PDF';

  @override
  String get noAccessToManufacturers => 'Pas d\'accès aux fabricants';

  @override
  String get start => 'Commencer';

  @override
  String get currentPlan => 'Plan actuel';

  @override
  String get cancelMonthlyPlanFirst => 'Annulez d\'abord le plan mensuel';

  @override
  String get cancelYearlyPlanFirst => 'Annulez d\'abord le plan annuel';

  @override
  String get cancelSubscriptionFirst => 'Annulez d\'abord l\'abonnement';

  @override
  String get upgradePlan => 'Mettre à niveau le plan';

  @override
  String get cancelSubscription => 'Annuler l\'abonnement';

  @override
  String get keepSubscription => 'Garder l\'abonnement';

  @override
  String get cancelSubscriptionTitle => 'Annuler l\'abonnement';

  @override
  String get cancelSubscriptionMessage =>
      'Nous sommes désolés de vous voir partir. Veuillez nous dire pourquoi :';

  @override
  String get pleaseSpecify => 'Veuillez préciser...';

  @override
  String get termsAgreement => 'En passant cette commande, vous acceptez les ';

  @override
  String get termsOfService => 'Conditions de service';

  @override
  String get and => ' et\n';

  @override
  String get upgradeMessage =>
      'Vous pouvez mettre à niveau votre plan pour générer des PDF techniques et accéder aux fabricants';

  @override
  String get freePerMonth => 'Gratuit/Mois';

  @override
  String get gatheringCreativeBrief => 'Rassembler le brief créatif ';

  @override
  String get asYourExpertDesigner =>
      'En tant que votre styliste virtuel expert.';

  @override
  String get hereToHelpCreate =>
      'Je suis ici pour vous aider à créer un vêtement ou une collection sur mesure.';

  @override
  String get getStarted => 'Commencer';

  @override
  String get info => 'Info';

  @override
  String get allImagesLocalAssets =>
      'Toutes les images sont des ressources locales et ne peuvent pas être téléchargées';

  @override
  String get partialSuccess => 'Succès partiel';

  @override
  String imagesSavedFailed(int saved, int failed) {
    return '$saved images enregistrées dans la galerie. $failed échec(s).';
  }

  @override
  String get failedToSaveImages =>
      'Échec de l\'enregistrement des images dans la galerie.';

  @override
  String downloadFailed(String error) {
    return 'Échec du téléchargement : $error';
  }

  @override
  String failedToDownload(String error) {
    return 'Échec du téléchargement des images : $error';
  }

  @override
  String designs(String display) {
    return 'Designs : $display';
  }

  @override
  String get other => 'Autre';

  @override
  String get tooExpensive => 'Trop cher';

  @override
  String get notUsingEnough => 'Je ne l\'utilise pas assez';

  @override
  String get missingFeatures => 'Fonctionnalités manquantes dont j\'ai besoin';

  @override
  String get foundBetterAlternative => 'J\'ai trouvé une meilleure alternative';

  @override
  String get technicalIssues => 'Problèmes techniques';

  @override
  String get allImagesLocal =>
      'Toutes les images sont des ressources locales et ne peuvent pas être téléchargées';

  @override
  String downloading(int current, int total) {
    return 'Téléchargement $current sur $total...';
  }

  @override
  String failedToDownloadImages(String error) {
    return 'Échec du téléchargement des images : $error';
  }

  @override
  String partialDownloadSuccess(int downloaded, int failed) {
    return '$downloaded images enregistrées dans la galerie. $failed échouées.';
  }

  @override
  String techPackImage(int number) {
    return 'Image de Tech Pack $number';
  }

  @override
  String get searchDesigns => 'Rechercher des designs';
}
