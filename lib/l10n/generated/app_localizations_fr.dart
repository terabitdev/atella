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
  String get password => 'Mot de Passe';

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
  String get loading => 'Chargement';

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
  String get upTo10Designs => '3 générations de designs IA / mois';

  @override
  String get starterDesignLimit => '5 générations de designs IA par mois';

  @override
  String get starterMonthlyPrice => 'Starter €19.99/Mois';

  @override
  String get starterYearlyPrice => 'Starter €199.99/An';

  @override
  String get proMonthlyPrice => 'Pro €49.99/Mois';

  @override
  String get proYearlyPrice => 'Pro €499.99/An';

  @override
  String get proDesignLimit => '12 générations de designs IA par mois';

  @override
  String get studioMonthlyPrice => 'Studio €99,99/Mois';

  @override
  String get studioYearlyPrice => 'Studio €999,99/An';

  @override
  String get studioDesignLimit => '25 générations de designs IA par mois';

  @override
  String get perMonth => '/Mois';

  @override
  String get perYear => '/An';

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
  String get cancelSubscriptionFirst => 'Annulez d\'abord le plan actuel';

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
      'Nous sommes désolés de vous voir partir. Veuillez nous dire pourquoi :\n\n⚠️ Attention : En annulant, tous les designs et techpacks supplémentaires achetés seront perdus.';

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
    return '$display';
  }

  @override
  String designsUsed(String used, String total) {
    return 'Designs utilisés : $used / $total ce mois';
  }

  @override
  String techpacksUsed(String used, String total) {
    return 'Dossiers techniques utilisés : $used / $total ce mois';
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
  String get imageFailed => 'Image failed';

  @override
  String get searchDesigns => 'Rechercher des designs';

  @override
  String get emailIsRequired => 'L\'e-mail est requis';

  @override
  String get enterValidEmail => 'Entrez un e-mail valide';

  @override
  String get passwordIsRequired => 'Le mot de passe est requis';

  @override
  String get passwordMinLength =>
      'Le mot de passe doit contenir au moins 8 caractères';

  @override
  String get nameIsRequired => 'Le nom est requis';

  @override
  String get confirmYourPassword => 'Confirmez votre mot de passe';

  @override
  String get passwordsDoNotMatch => 'Les mots de passe ne correspondent pas';

  @override
  String get userSuccessfullyLoggedIn => 'Utilisateur connecté avec succès';

  @override
  String get successfullySignedInWithGoogle => 'Connexion réussie avec Google';

  @override
  String get userRegisteredSuccessfully => 'Utilisateur enregistré avec succès';

  @override
  String get userAlreadyExistsWithEmail =>
      'Un utilisateur existe déjà avec cet e-mail';

  @override
  String get verificationLinkSent => 'Lien de vérification envoyé';

  @override
  String passwordResetLinkSent(String email) {
    return 'Un lien de réinitialisation du mot de passe a été envoyé à $email.';
  }

  @override
  String get failedToSendVerificationLink =>
      'Échec de l\'envoi du lien de vérification. Veuillez réessayer.';

  @override
  String get failedToUpdateFavorite =>
      'Échec de la mise à jour du statut favori';

  @override
  String get failedToLoadProfile => 'Échec du chargement des données du profil';

  @override
  String get profileUpdatedSuccessfully => 'Profil mis à jour avec succès';

  @override
  String get failedToUpdateProfile =>
      'Échec de la mise à jour du profil. Veuillez réessayer.';

  @override
  String get errorUpdatingProfile =>
      'Une erreur s\'est produite lors de la mise à jour du profil';

  @override
  String get pleaseEnterFullName => 'Veuillez entrer votre nom complet';

  @override
  String get analyticsEnabled => 'Analytique activée';

  @override
  String get analyticsDisabled => 'Analytique désactivée';

  @override
  String get analyticsEnabledMessage =>
      'Aide à améliorer l\'application. Les replays de session restent échantillonnés.';

  @override
  String get analyticsDisabledMessage =>
      'Nous arrêterons d\'envoyer des analyses et des replays de session.';

  @override
  String get infoMessage => 'Info';

  @override
  String get youAreOnFreePlan => 'Vous êtes sur le plan gratuit';

  @override
  String get subscriptionSuccessTitle => 'Succès! 🎉';

  @override
  String welcomeToPlan(String plan) {
    return 'Bienvenue dans $plan! Vous pouvez maintenant générer des techpacks.';
  }

  @override
  String get subscriptionActive => 'Abonnement actif! 🎉';

  @override
  String get canNowGenerateTechpack =>
      'Vous pouvez maintenant générer votre techpack. Cliquez sur le bouton \"Générer Tech Pack\".';

  @override
  String get failedToCompleteSubscription =>
      'Échec de la finalisation de l\'abonnement';

  @override
  String get subscriptionCancelledSuccessfully =>
      'Abonnement annulé avec succès';

  @override
  String get failedToCancelSubscription =>
      'Échec de l\'annulation de l\'abonnement';

  @override
  String get failedToLoadSubscription =>
      'Échec du chargement des détails de l\'abonnement';

  @override
  String anErrorOccurred(String error) {
    return 'Une erreur s\'est produite: $error';
  }

  @override
  String get creativeBrief => 'Brief créatif';

  @override
  String get gatheringTheCreativeBrief => 'Rassemblement du brief créatif';

  @override
  String get asYourExpertVirtualFashionDesigner =>
      'En tant que votre styliste virtuel expert.';

  @override
  String get imHereToHelpCreateCustomGarment =>
      'Je suis là pour vous aider à créer un vêtement ou une collection personnalisée.';

  @override
  String get cbQuestionGarmentType => 'Quel type de vêtement créez-vous ? 👕';

  @override
  String get cbQuestionStyle => 'Quel est le style souhaité ? ✨';

  @override
  String get cbQuestionTargetAudience =>
      'À qui ce vêtement est-il destiné ? 👤';

  @override
  String get cbQuestionOccasion =>
      'Quelle est l\'occasion ou l\'utilisation prévue ? 📅';

  @override
  String get cbQuestionInspiration =>
      'Avez-vous des inspirations ou références visuelles ? 🖼️';

  @override
  String get cbQuestionColors =>
      'Quelles couleurs et motifs le design doit-il inclure ? 🎨';

  @override
  String get cbQuestionFabrics =>
      'Quel tissu ou matériau souhaitez-vous utiliser ? 🧵';

  @override
  String get cbCategoryTops => 'Hauts';

  @override
  String get cbCategoryBottoms => 'Bas';

  @override
  String get cbCategoryDresses => 'Robes';

  @override
  String get cbCategoryJumpsuits => 'Combinaisons';

  @override
  String get cbCategoryOuterwear => 'Vêtements d\'extérieur';

  @override
  String get cbCategorySportswear => 'Vêtements de sport';

  @override
  String get cbCategoryAccessories => 'Accessoires';

  @override
  String get cbCategoryCotton => 'Coton';

  @override
  String get cbCategoryWool => 'Laine';

  @override
  String get cbCategorySilk => 'Soie';

  @override
  String get cbCategoryLinen => 'Lin';

  @override
  String get cbCategorySynthetic => 'Synthétique';

  @override
  String get cbCategoryEcoOptions => 'Options écologiques';

  @override
  String get cbCategoryLeatherFauxLeather => 'Cuir/Simili cuir';

  @override
  String get cbCategoryKnitwear => 'Tricot';

  @override
  String get cbCategoryPrints => 'Imprimés';

  @override
  String get cbCategoryTechniques => 'Techniques';

  @override
  String get cbOptionTShirt => 'T-shirt';

  @override
  String get cbOptionShirt => 'Chemise';

  @override
  String get cbOptionBlouse => 'Chemisier';

  @override
  String get cbOptionHoodie => 'Sweat à capuche';

  @override
  String get cbOptionJacket => 'Veste';

  @override
  String get cbOptionCoat => 'Manteau';

  @override
  String get cbOptionVest => 'Gilet';

  @override
  String get cbOptionTankTop => 'Débardeur';

  @override
  String get cbOptionCropTop => 'Haut court';

  @override
  String get cbOptionSweater => 'Pull';

  @override
  String get cbOptionPants => 'Pantalon';

  @override
  String get cbOptionJeans => 'Jeans';

  @override
  String get cbOptionSkirts => 'Jupes';

  @override
  String get cbOptionShorts => 'Shorts';

  @override
  String get cbOptionLeggings => 'Leggings';

  @override
  String get cbOptionCulottes => 'Culottes';

  @override
  String get cbOptionPalazzo => 'Palazzo';

  @override
  String get cbOptionJoggers => 'Joggings';

  @override
  String get cbOptionCasualDress => 'Robe décontractée';

  @override
  String get cbOptionEvening => 'Soirée';

  @override
  String get cbOptionCocktailDress => 'Robe de cocktail';

  @override
  String get cbOptionGown => 'Robe de soirée';

  @override
  String get cbOptionMaxiDress => 'Robe longue';

  @override
  String get cbOptionMidiDress => 'Robe midi';

  @override
  String get cbOptionMiniDress => 'Mini robe';

  @override
  String get cbOptionJumpsuit => 'Combinaison';

  @override
  String get cbOptionRomper => 'Barboteuse';

  @override
  String get cbOptionPlaysuit => 'Combishort';

  @override
  String get cbOptionOveralls => 'Salopette';

  @override
  String get cbOptionTrenchCoat => 'Trench-coat';

  @override
  String get cbOptionBomberJacket => 'Blouson bomber';

  @override
  String get cbOptionBlazer => 'Blazer';

  @override
  String get cbOptionPufferJacket => 'Doudoune';

  @override
  String get cbOptionTracksuit => 'Survêtement';

  @override
  String get cbOptionActivewear => 'Vêtements de sport';

  @override
  String get cbOptionSwimwear => 'Maillots de bain';

  @override
  String get cbOptionHat => 'Chapeau';

  @override
  String get cbOptionBag => 'Sac';

  @override
  String get cbOptionScarf => 'Écharpe';

  @override
  String get cbOptionGloves => 'Gants';

  @override
  String get cbOptionCasual => 'Décontracté';

  @override
  String get cbOptionChic => 'Chic';

  @override
  String get cbOptionSporty => 'Sportif';

  @override
  String get cbOptionStreetwear => 'Streetwear';

  @override
  String get cbOptionWorkwear => 'Workwear';

  @override
  String get cbOptionWoman => 'Femme';

  @override
  String get cbOptionMan => 'Homme';

  @override
  String get cbOptionChild => 'Enfant';

  @override
  String get cbOptionUnisex => 'Unisexe';

  @override
  String get cbOptionTargetAge => 'Âge cible';

  @override
  String get cbOptionEverydayWear => 'Tenue quotidienne';

  @override
  String get cbOptionSpecialEvent => 'Événement spécial';

  @override
  String get cbOptionSports => 'Sports';

  @override
  String get cbOptionActivity => 'Activité';

  @override
  String get cbOptionFloral => 'Floral';

  @override
  String get cbOptionAbstract => 'Abstrait';

  @override
  String get cbOptionCamouflage => 'Camouflage';

  @override
  String get cbOptionStripes => 'Rayures';

  @override
  String get cbOptionPolkaDots => 'Pois';

  @override
  String get cbOptionTieDye => 'Tie-dye';

  @override
  String get cbOptionColorBlocking => 'Blocage de couleur';

  @override
  String get cbOptionGradientOmbre => 'Dégradé/Ombré';

  @override
  String get cbOptionEmbroidery => 'Broderie';

  @override
  String get cbOptionJacquard => 'Jacquard';

  @override
  String get cbOptionLightweight => 'Léger (popeline, voile)';

  @override
  String get cbOptionMedium => 'Moyen (sergé)';

  @override
  String get cbOptionHeavy => 'Lourd (denim, toile)';

  @override
  String get cbOptionMerino => 'Mérinos';

  @override
  String get cbOptionCashmere => 'Cachemire';

  @override
  String get cbOptionTweed => 'Tweed';

  @override
  String get cbOptionFelt => 'Feutre';

  @override
  String get cbOptionSatin => 'Satin';

  @override
  String get cbOptionChiffon => 'Mousseline';

  @override
  String get cbOptionOrganza => 'Organza';

  @override
  String get cbOptionPlain => 'Uni';

  @override
  String get cbOptionTextured => 'Texturé';

  @override
  String get cbOptionBlended => 'Mélangé';

  @override
  String get cbOptionPolyester => 'Polyester';

  @override
  String get cbOptionNylon => 'Nylon';

  @override
  String get cbOptionSpandex => 'Spandex';

  @override
  String get cbOptionNeoprene => 'Néoprène';

  @override
  String get cbOptionOrganicCotton => 'Coton biologique';

  @override
  String get cbOptionRecycledPolyester => 'Polyester recyclé';

  @override
  String get cbOptionBamboo => 'Bambou';

  @override
  String get cbOptionHemp => 'Chanvre';

  @override
  String get cbOptionLeather => 'Cuir';

  @override
  String get cbOptionFauxLeather => 'Simili cuir';

  @override
  String get cbOptionJersey => 'Jersey';

  @override
  String get cbOptionRibKnit => 'Côtes';

  @override
  String get cbOptionInterlock => 'Interlock';

  @override
  String get cbOptionCustom => 'Personnalisé';

  @override
  String get enterYourCustomAnswer => 'Entrez votre réponse personnalisée...';

  @override
  String enterCustom(String category) {
    return 'Entrez $category personnalisé...';
  }

  @override
  String get enterPreferredColors => 'Entrez les couleurs préférées...';

  @override
  String get uploadVisualInspirationImages =>
      'Télécharger des images d\'inspiration visuelles (optionnel)';

  @override
  String get uploadInspirationImages =>
      'Télécharger des images d\'inspiration visuelles (optionnel)';

  @override
  String get skipNoReferenceImages => 'Passer - Aucune image de référence';

  @override
  String get uploadImage => 'Télécharger une image';

  @override
  String get nextSteps => 'Étapes suivantes';

  @override
  String get addMoreImages => 'Ajouter plus d\'images';

  @override
  String get tapToSelectFromGallery =>
      'Appuyez pour sélectionner depuis la galerie';

  @override
  String get imageAdded => 'Image ajoutée';

  @override
  String get imageAddedSuccessfully => 'Image ajoutée avec succès';

  @override
  String get failedToPickImage =>
      'Échec de la sélection de l\'image. Veuillez réessayer.';

  @override
  String get imageError => 'Erreur';

  @override
  String get imageSelected => 'Image sélectionnée';

  @override
  String get imageSelectedSuccessfully => 'Image sélectionnée avec succès';

  @override
  String get failedToLoadImage => 'Échec du chargement de l\'image';

  @override
  String get change => 'Changer';

  @override
  String get solidColors => 'Couleurs unies';

  @override
  String get pickAColor => 'Choisir une couleur';

  @override
  String get selectAColor => 'Sélectionner une couleur';

  @override
  String get select => 'Sélectionner';

  @override
  String get loadingExistingDesignData =>
      'Chargement des données de conception existantes...';

  @override
  String get editMode => 'Mode Édition';

  @override
  String editingDesign(String designName) {
    return 'Modification de la conception : $designName';
  }

  @override
  String get failedToLoadExistingData =>
      'Échec du chargement des données existantes. Utilisation des valeurs par défaut.';

  @override
  String get dataLoaded => 'Données chargées';

  @override
  String get previousAnswersLoadedForEditing =>
      'Les réponses précédentes ont été chargées pour modification';

  @override
  String get briefComplete => 'Brief terminé !';

  @override
  String get briefCompletedSuccessfully =>
      'Votre brief créatif a été complété avec succès.';

  @override
  String get invalidInput => 'Entrée invalide';

  @override
  String pleaseEnterCustomAnswer(String category) {
    return 'Veuillez entrer une réponse personnalisée pour $category';
  }

  @override
  String get pleaseEnterCustomAnswerGeneric =>
      'Veuillez entrer une réponse personnalisée';

  @override
  String get pleaseEnterCustomPrint =>
      'Veuillez entrer une impression personnalisée';

  @override
  String get pleaseEnterCustomTechnique =>
      'Veuillez entrer une technique personnalisée';

  @override
  String get answerUpdated => 'Réponse mise à jour';

  @override
  String get answerUpdatedSuccessfully =>
      'Votre réponse a été mise à jour avec succès';

  @override
  String get printsAndTechniquesUpdated =>
      'Vos impressions et techniques ont été mises à jour avec succès';

  @override
  String get rcRefiningTheConcept => 'Affiner le concept';

  @override
  String get rcNowToHelpMeRefine =>
      'Maintenant, pour m\'aider à affiner le design 3D';

  @override
  String get rcProposeThreeConceptOptions =>
      'Et proposer 3 options de concept, j\'ai besoin de quelques détails supplémentaires.';

  @override
  String get rcContinue => 'Continuer';

  @override
  String get rcEnterYourCustomAnswer => 'Entrez votre réponse personnalisée...';

  @override
  String rcEnterCustomCategory(String category) {
    return 'Entrez $category personnalisé...';
  }

  @override
  String get rcGenerateDesign => 'Générer le design';

  @override
  String get rcQuestionGarmentType =>
      'Quelle coupe visez-vous ? (sélection multiple) 📏';

  @override
  String get rcQuestionSpecificFeatures =>
      'Voulez-vous ajouter des détails spéciaux ? (sélection multiple) ✂️';

  @override
  String get rcQuestionSeasonalConstraint =>
      'Y a-t-il une contrainte saisonnière ? 🌤️';

  @override
  String get rcQuestionTargetBudget =>
      'Quel est votre budget cible par pièce ? 💵';

  @override
  String get rcQuestionFunctionalitiesValues =>
      'Souhaitez-vous inclure des fonctionnalités ou valeurs spécifiques ? 🧶';

  @override
  String get rcCategoryNecklines => 'Encolures';

  @override
  String get rcCategorySleeves => 'Manches';

  @override
  String get rcCategoryClosures => 'Fermetures';

  @override
  String get rcCategoryPockets => 'Poches';

  @override
  String get rcCategoryWaist => 'Taille';

  @override
  String get rcCategoryLegs => 'Jambes';

  @override
  String get rcCategoryFinishes => 'Finitions';

  @override
  String get rcOptionSlim => 'Ajusté';

  @override
  String get rcOptionOversized => 'Oversize';

  @override
  String get rcOptionRegular => 'Regular';

  @override
  String get rcOptionStraight => 'Droit';

  @override
  String get rcOptionFitted => 'Cintré';

  @override
  String get rcOptionTailored => 'Sur mesure';

  @override
  String get rcOptionCropped => 'Court';

  @override
  String get rcOptionRelaxed => 'Décontracté';

  @override
  String get rcOptionLong => 'Long';

  @override
  String get rcOptionCrew => 'Ras du cou';

  @override
  String get rcOptionVNeck => 'Col en V';

  @override
  String get rcOptionSquare => 'Carré';

  @override
  String get rcOptionHalfShoulder => 'Demi-épaule';

  @override
  String get rcOptionScoop => 'Évasé';

  @override
  String get rcOptionBoatNeck => 'Col bateau';

  @override
  String get rcOptionSleeveless => 'Sans manches';

  @override
  String get rcOptionShortThreeQuarter => 'Court ¾';

  @override
  String get rcOptionPuff => 'Bouffant';

  @override
  String get rcOptionRaglan => 'Raglan';

  @override
  String get rcOptionCap => 'Mancheron';

  @override
  String get rcOptionZipper => 'Fermeture éclair (métal/plastique/invisible)';

  @override
  String get rcOptionButtons => 'Boutons';

  @override
  String get rcOptionHooks => 'Crochets';

  @override
  String get rcOptionVelcro => 'Velcro';

  @override
  String get rcOptionSnaps => 'Pressions';

  @override
  String get rcOptionPatch => 'Plaquée';

  @override
  String get rcOptionWelt => 'Passepoilée';

  @override
  String get rcOptionFlap => 'À rabat';

  @override
  String get rcOptionHidden => 'Cachée';

  @override
  String get rcOptionCargo => 'Cargo';

  @override
  String get rcOptionElastic => 'Élastique';

  @override
  String get rcOptionHighWaist => 'Taille haute';

  @override
  String get rcOptionLowRise => 'Taille basse';

  @override
  String get rcOptionBelted => 'Avec ceinture';

  @override
  String get rcOptionDrawstring => 'Cordon de serrage';

  @override
  String get rcOptionStraightLeg => 'Jambe droite';

  @override
  String get rcOptionTapered => 'Fuselé';

  @override
  String get rcOptionWideLeg => 'Jambe large';

  @override
  String get rcOptionBootcut => 'Évasé';

  @override
  String get rcOptionFlared => 'Évasé';

  @override
  String get rcOptionLining => 'Doublure';

  @override
  String get rcOptionTopstitching => 'Surpiqûre';

  @override
  String get rcOptionEmbroidery => 'Broderie';

  @override
  String get rcOptionLace => 'Dentelle';

  @override
  String get rcOptionSequins => 'Paillettes';

  @override
  String get rcOptionAppliques => 'Appliqués';

  @override
  String get rcOptionSummer => 'Été';

  @override
  String get rcOptionMidSeason => 'Mi-saison';

  @override
  String get rcOptionAllSeason => 'Toute saison';

  @override
  String get rcOptionPriceRangeInEuro => 'Fourchette de prix en €';

  @override
  String get rcOptionIndicationOfMarketLevel =>
      'Une indication du niveau de marché';

  @override
  String get rcOptionEntry => 'Entrée de gamme';

  @override
  String get rcOptionMidRange => 'Milieu de gamme';

  @override
  String get rcOptionPremium => 'Premium';

  @override
  String get rcOptionOrganicFabric => 'Tissu biologique';

  @override
  String get rcOptionLocallyMade => 'Fabriqué localement';

  @override
  String get rcOptionUpcycled => 'Recyclé';

  @override
  String get rcOptionUVProtection => 'Protection UV';

  @override
  String get rcOptionQuickDry => 'Séchage rapide';

  @override
  String get rcOptionWrinkleFree => 'Anti-froissement';

  @override
  String get rcOptionCustom => 'Personnalisé';

  @override
  String get today => 'Aujourd\'hui';

  @override
  String get rcSnackbarRefiningComplete => 'Affinage terminé !';

  @override
  String get rcSnackbarRefiningCompleteMessage =>
      'Votre concept a été affiné avec succès.';

  @override
  String get rcSnackbarExtraDesignsAdded => 'Designs supplémentaires ajoutés !';

  @override
  String get rcSnackbarExtraDesignsAddedMessage =>
      '5 designs supplémentaires ont été ajoutés à votre compte.';

  @override
  String get rcSnackbarRegeneratingDesigns => 'Régénération des designs !';

  @override
  String get rcSnackbarRegeneratingDesignsMessage =>
      'Création de 3 nouveaux designs basés sur vos préférences mises à jour...';

  @override
  String get rcSnackbarGeneratingDesigns => 'Génération des designs !';

  @override
  String get rcSnackbarGeneratingDesignsMessage =>
      'Création de 3 designs uniques basés sur vos préférences...';

  @override
  String get rcSnackbarInvalidInput => 'Entrée invalide';

  @override
  String rcSnackbarInvalidInputCategoryMessage(String category) {
    return 'Veuillez entrer une réponse personnalisée pour $category';
  }

  @override
  String get rcSnackbarInvalidInputMessage =>
      'Veuillez entrer une réponse personnalisée';

  @override
  String get rcSnackbarAnswerUpdated => 'Réponse mise à jour';

  @override
  String get rcSnackbarAnswerUpdatedMessage =>
      'Votre réponse a été mise à jour avec succès';

  @override
  String get rcDialogEditAnswer => 'Modifier la réponse';

  @override
  String get rcDialogSelectAnswer => 'Sélectionnez votre réponse :';

  @override
  String get rcDialogEnterCustomAnswer => 'Entrez une réponse personnalisée :';

  @override
  String get rcDialogCustomAnswerHint => 'Tapez votre réponse personnalisée...';

  @override
  String get rcDialogCancel => 'Annuler';

  @override
  String get rcDialogSaveChanges => 'Enregistrer les modifications';

  @override
  String get rcToday => 'Aujourd\'hui';

  @override
  String get cbDialogEditAnswer => 'Modifier la Réponse';

  @override
  String get cbDialogSelectAnswer => 'Sélectionnez votre réponse:';

  @override
  String get cbDialogEnterCustomAnswer => 'Entrez une réponse personnalisée:';

  @override
  String get cbDialogCustomAnswerHint => 'Tapez votre réponse personnalisée...';

  @override
  String get cbDialogCancel => 'Annuler';

  @override
  String get cbDialogSaveChanges => 'Enregistrer les Modifications';

  @override
  String get cbDialogEditPrintsTechniques => 'Modifier Imprimés & Techniques';

  @override
  String get cbDialogSelectPrintsTechniques =>
      'Sélectionnez vos imprimés et techniques';

  @override
  String get cbDialogPrints => 'Imprimés';

  @override
  String get cbDialogTechniques => 'Techniques';

  @override
  String get cbDialogEnterCustomPrint => 'Entrez un imprimé personnalisé...';

  @override
  String get cbDialogEnterCustomTechnique =>
      'Entrez une technique personnalisée...';

  @override
  String get fdFinalDetails => 'Détails Finaux';

  @override
  String get fdFinalDetailsToProvide => 'Détails Finaux à Fournir';

  @override
  String get fdContinue => 'Continuer';

  @override
  String get fdGenerate => 'Générer';

  @override
  String get fdTargetSeason => 'Saison Cible :';

  @override
  String get fdTargetBudget => 'Budget Cible par Pièce :';

  @override
  String get fdDesiredFeatures => 'Fonctionnalités ou Valeurs Souhaitées :';

  @override
  String get fdCustomFeaturesHint =>
      'Tapez vos fonctionnalités personnalisées ici...';

  @override
  String get fdQuestionSeason =>
      'Parfait ! Assurons-nous que votre pièce s\'adapte parfaitement à la saison. Pour quel type de temps sera-t-elle conçue ?';

  @override
  String get fdOptionSummer => 'Été (Léger, Manches Courtes ou Retroussables)';

  @override
  String get fdOptionMidSeason => 'Mi-Saison';

  @override
  String get fdOptionAllSeason => 'Toute Saison (Superposable)';

  @override
  String get fdQuestionBudget =>
      'Compris. Et quel type de budget avez-vous pour ce design ? Je peux adapter les tissus et les fonctionnalités en conséquence.';

  @override
  String get fdOptionEntryLevel =>
      'Entrée de Gamme (15-30€ Production / 35-60€ Vente)';

  @override
  String get fdOptionMidRange =>
      'Milieu de Gamme (30-50€ Production / 60-120€ Vente)';

  @override
  String get fdOptionPremium => 'Premium (60€+ Production / 120€+ Vente)';

  @override
  String get fdQuestionFeatures =>
      'Souhaitez-vous inclure des valeurs ou fonctionnalités spéciales qui comptent pour vous ou votre marque ? Je peux m\'assurer qu\'elles font partie du concept final';

  @override
  String get fdOptionOrganicFabric => 'Tissu Biologique';

  @override
  String get fdOptionUpcycled => 'Matériaux Recyclés';

  @override
  String get fdOptionLocallyMade => 'Fabriqué Localement (Europe)';

  @override
  String get fdOptionUVProtection => 'Protection UV';

  @override
  String get fdOptionQuickDry => 'Séchage Rapide';

  @override
  String get fdOptionWrinkleFree => 'Infroissable';

  @override
  String get fdOptionOther => 'Autre : ?';

  @override
  String get fdQuestionAdditional =>
      'Super — n\'hésitez pas à taper tout ce que vous avez en tête !';

  @override
  String get fdSnackbarRegeneratingDesigns => 'Régénération des Designs !';

  @override
  String get fdSnackbarRegeneratingMessage =>
      'Création de 3 nouveaux designs basés sur vos préférences mises à jour...';

  @override
  String get fdSnackbarGeneratingDesigns => 'Génération des Designs !';

  @override
  String get fdSnackbarGeneratingMessage =>
      'Création de 3 designs uniques basés sur vos préférences...';

  @override
  String get fdSnackbarExtraDesigns => 'Designs Supplémentaires Ajoutés !';

  @override
  String get fdSnackbarExtraDesignsMessage =>
      '5 designs supplémentaires ont été ajoutés à votre compte.';

  @override
  String get fdDialogLimitExceeded => 'Limite Dépassée';

  @override
  String get fdDialogLimitMessage =>
      'Vous avez dépassé votre limite pour ce mois. Vous pouvez payer 9,99€ pour 5 designs supplémentaires ou mettre à niveau votre forfait.';

  @override
  String get fdDialogLimitMessageFree =>
      'Vous avez dépassé votre limite de forfait gratuit pour ce mois. Passez à Starter ou Pro pour continuer à créer des designs.';

  @override
  String get fdDialogGetExtraDesigns =>
      'Obtenir des Designs Supplémentaires (9,99€)';

  @override
  String get fdDialogUpgradePlan => 'Mettre à Niveau le Forfait';

  @override
  String get fdDialogMaybeLater => 'Peut-être Plus Tard';

  @override
  String get fdDialog80PercentTitle => 'Presque à Votre Limite !';

  @override
  String fdDialog80PercentMessage(int used, int total) {
    return 'Vous avez utilisé $used designs sur $total ce mois-ci. Pensez à mettre à niveau ou à acheter des designs supplémentaires pour continuer à créer.';
  }

  @override
  String fdDialog80PercentMessageFree(int used, int total) {
    return 'Vous avez utilisé $used designs sur $total ce mois-ci. Passez à Starter ou Pro pour plus de designs.';
  }

  @override
  String get fdDialog80PercentContinue => 'Continuer Quand Même';

  @override
  String get tpDialog80PercentTitle =>
      'Presque à Votre Limite de Dossiers Techniques !';

  @override
  String tpDialog80PercentMessage(int used, int total) {
    return 'Vous avez utilisé $used dossiers techniques sur $total ce mois-ci. Pensez à mettre à niveau pour continuer à générer des dossiers techniques.';
  }

  @override
  String get tpDialog80PercentContinue => 'Continuer Quand Même';

  @override
  String get tpDesignAssistant => 'Assistant Design';

  @override
  String get tpChooseFavoriteDesign => 'Choisissez votre design préféré :';

  @override
  String get tpCreatingDesigns => 'Création de vos designs...';

  @override
  String get tpPleaseWaitGenerating =>
      'Veuillez patienter pendant que nous générons 3 designs uniques basés sur vos préférences.';

  @override
  String get tpSomethingWentWrong => 'Une erreur s\'est produite';

  @override
  String get tpRetry => 'Réessayer';

  @override
  String get tpWouldYouLikeChanges =>
      'Souhaitez-vous apporter des modifications avant que je crée le dossier technique final ?';

  @override
  String get tpYesChanges => 'Oui, je voudrais apporter des modifications';

  @override
  String get tpContinueWithSelected => 'Continuer avec le Design Sélectionné';

  @override
  String get tpContinueAsIs => 'Non, continuer tel quel';

  @override
  String get tpRecommendedManufacturers => 'Fabricants Recommandés';

  @override
  String get tpCustomTab => 'Personnalisé';

  @override
  String get tpSelectImageGallery => 'Sélectionner une image depuis la galerie';

  @override
  String tpManufacturerPrefix(String name, String country) {
    return 'Fabricant: $name ($country)';
  }

  @override
  String get tpUpgradeRequired => 'Mise à Niveau Requise';

  @override
  String get tpUpgradeToGenerate =>
      'Passez à Starter ou Pro pour générer des dossiers techniques';

  @override
  String get tpGetExtraDesigns => 'Obtenir 5 Designs Supplémentaires';

  @override
  String get tpViewPlans => 'Voir les Forfaits';

  @override
  String get tpMaybeLater => 'Peut-être Plus Tard';

  @override
  String get tpFreePlanLimit => 'Limite du Forfait Gratuit';

  @override
  String get tpFreePlanMessage =>
      'Les utilisateurs du forfait gratuit peuvent générer jusqu\'à 3 designs par mois. Passez à la version supérieure pour plus de designs et des dossiers techniques !';

  @override
  String get tpProLimitReached => 'Limite Pro Atteinte';

  @override
  String get tpProLimitMessage =>
      'Vous avez atteint votre limite mensuelle. Obtenez 5 designs supplémentaires pour 9,99€ !';

  @override
  String get tpSnackbarDesignUpdated => 'Design Mis à Jour';

  @override
  String get tpSnackbarDesignUpdatedMessage =>
      'Votre design a été mis à jour avec de nouvelles préférences';

  @override
  String get tpSnackbarDesignSaved => 'Design Enregistré';

  @override
  String get tpSnackbarDesignSavedMessage =>
      'Votre design sélectionné a été enregistré avec succès';

  @override
  String get tpSnackbarGenerationFailed => 'Échec de la Génération';

  @override
  String get tpSnackbarGenerationFailedMessage =>
      'Échec de la génération des designs. Veuillez réessayer.';

  @override
  String get tpSnackbarNoDesignSelected => 'Aucun Design Sélectionné';

  @override
  String get tpSnackbarNoDesignSelectedMessage =>
      'Veuillez sélectionner un design avant de continuer';

  @override
  String get tpSnackbarPurchaseSuccess => 'Achat Réussi !';

  @override
  String get tpSnackbarPurchaseSuccessMessage =>
      '5 designs supplémentaires ajoutés à votre compte';

  @override
  String get tpSnackbarPurchaseFailed => 'Échec de l\'Achat';

  @override
  String get tpSnackbarPurchaseFailedMessage =>
      'Échec du traitement de l\'achat. Veuillez réessayer.';

  @override
  String get tpPlanFree => 'Gratuit';

  @override
  String get tpPlanStarter => 'Starter';

  @override
  String get tpPlanPro => 'Pro';

  @override
  String get tpDialogChooseUpgrade => 'Choisissez Votre Mise à Niveau';

  @override
  String get tpDialogUpgradeDescription =>
      'Débloquez la génération illimitée de dossiers techniques et plus de fonctionnalités !';

  @override
  String get tpDialogFeature3TechPacks => '3 dossiers techniques/mois';

  @override
  String get tpDialogFeatureBasicPDF => 'Export PDF basique';

  @override
  String get tpDialogFeatureManufacturers => 'Accès aux fabricants';

  @override
  String get tpDialogFeature10TechPacks => '10 dossiers techniques/mois';

  @override
  String get tpDialogFeatureCustomPDF => 'PDF personnalisé avec logo';

  @override
  String get tpDialogFeaturePriority => 'Support prioritaire';

  @override
  String get tpDialogExtraTechPacksTitle =>
      'Besoin de Plus de Designs Ce Mois-ci ?';

  @override
  String get tpDialogExtraTechPacksDescription =>
      'Obtenez 5 designs supplémentaires pour seulement 9,99€';

  @override
  String get tpDialogExtraTechPacksOneTime => 'Achat unique';

  @override
  String get tpDialogExtraTechPacksNoSubscription => 'Aucun abonnement requis';

  @override
  String get tpDialogExtraTechPacksExpires =>
      'Ne expire pas jusqu\'à ce qu\'il soit utilisé';

  @override
  String get tpDialogPurchaseFor => 'Acheter pour 9,99€';

  @override
  String get tpDialogUpgradeInstead => 'Mettre à Niveau à la Place';

  @override
  String get tpTechpackFeaturePremium =>
      'La génération de dossiers techniques est une fonctionnalité premium.';

  @override
  String get tpProMonthlyLimitReached =>
      'Votre limite mensuelle de génération de dossiers techniques a été atteinte.';

  @override
  String get tpStarterYearlyLimitReached =>
      'Votre limite mensuelle de génération de dossiers techniques a été atteinte.';

  @override
  String get tpStarterMonthlyLimitReached =>
      'Votre limite mensuelle de génération de dossiers techniques a été atteinte.';

  @override
  String get tpDialogChoosePlan => 'Choisissez un forfait :';

  @override
  String get tpDialogUpgradeToPro => 'Passer au forfait Pro :';

  @override
  String tpDialogCurrentPlan(String plan) {
    return 'Forfait actuel : $plan';
  }

  @override
  String tpDialogRemainingTechpacksPro(int remaining) {
    return 'Restant : $remaining/6 dossiers techniques ce mois-ci';
  }

  @override
  String tpDialogRemainingTechpacksStarter(int remaining) {
    return 'Restant : $remaining/2 ce mois-ci';
  }

  @override
  String get tpDialogStarterPlanOption =>
      'Starter : 2 dossiers techniques/mois (19,99€/mois ou 199,99€/an)';

  @override
  String get tpDialogProPlanOption =>
      'Pro : 6 dossiers techniques/mois (49,99€/mois ou 499,99€/an)';

  @override
  String get tpDialogStudioPlanOption =>
      'Studio : 10 dossiers techniques/mois (99,99€/mois ou 999,99€/an)';

  @override
  String tpDialogRemainingTechpacksStudio(int remaining) {
    return 'Restant : $remaining/10 ce mois-ci';
  }

  @override
  String get tpDialogProUpgradeOption => 'Pro : 8 dossiers techniques/mois';

  @override
  String get tpDialogExtraTechpackOption =>
      'Achetez un pack technologique +1 supplémentaire (5,99 €)';

  @override
  String get tpDialogFeatureCustomPDFExport =>
      'Export PDF personnalisé avec votre logo';

  @override
  String get tpDialogFeatureManufacturerAccess =>
      'Accès à la liste des fabricants';

  @override
  String get tpDialogFeatureUnlimited3D => 'Visualisation 3D illimitée';

  @override
  String get tpDialogFeatureProfessionalPDF =>
      'Exports PDF professionnels de dossiers techniques';

  @override
  String get tpDialogFeatureManufacturerDB =>
      'Accès à la base de données des fabricants';

  @override
  String get tpDialogUpgradeNow => 'Mettre à Niveau Maintenant';

  @override
  String get tpDialogTechpackPremiumRequired =>
      'La génération finale du dossier technique nécessite un forfait premium.';

  @override
  String get tpProLimitDialogTitle => 'Limite Mensuelle Atteinte';

  @override
  String get tpProLimitDialogProPlan => 'Forfait Pro : ';

  @override
  String tpProLimitDialogMonthlyUsed(int used) {
    return 'Limite mensuelle atteinte : $used/8 dossiers techniques utilisés';
  }

  @override
  String get tpProLimitDialogMessage =>
      'Vous avez atteint votre limite mensuelle de 8 dossiers techniques du forfait Pro. Achetez des dossiers techniques supplémentaires pour continuer :';

  @override
  String get tpProLimitDialogTechpackPrice => '+1 Dossier Technique : 5,99€';

  @override
  String get tpProLimitDialogTechpackDescription =>
      'Obtenez 1 dossier technique supplémentaire (achat unique, ne se renouvelle pas automatiquement)';

  @override
  String get tpProLimitDialogPurchaseButton => 'Acheter +1 Dossier Technique';

  @override
  String get mfManufacturerSuggestions => 'Suggestions de Fabricants';

  @override
  String get mfLoadingManufacturers => 'Chargement des fabricants...';

  @override
  String mfFoundManufacturers(int count) {
    return 'Nous avons trouvé $count fabricants dans le monde entier.';
  }

  @override
  String get mfNoManufacturersAvailable => 'Aucun fabricant disponible';

  @override
  String get mfAllManufacturersLoaded => 'Tous les fabricants chargés';

  @override
  String get mfFilterManufacturers => 'Filtrer les Fabricants';

  @override
  String get mfUseFiltersBelow =>
      'Utilisez les filtres ci-dessous pour rechercher dans notre répertoire de fabricants :';

  @override
  String get mfCountryOrRegion => 'Pays ou Région';

  @override
  String get mfSearchCountry => 'Rechercher';

  @override
  String get mfSearchCountryHint => 'Commencez à taper pour rechercher';

  @override
  String get mfAllCountries => 'Tous les Pays';

  @override
  String get mfSearch => 'Rechercher';

  @override
  String get mfStartTypingToSearch => 'Commencez à taper pour rechercher';

  @override
  String get mfClearFilter => 'Effacer le Filtre';

  @override
  String get mfNoManufacturersFound => 'Aucun fabricant trouvé';

  @override
  String get mfTryAdjustingFilters => 'Essayez d\'ajuster vos filtres';

  @override
  String mfManufacturersFound(int count, String plural) {
    return '$count fabricant$plural trouvé$plural';
  }

  @override
  String get mfSendingEmail => 'Envoi de l\'Email...';

  @override
  String get mfPreparingTechPack =>
      'Préparation de votre dossier technique\net envoi au fabricant';

  @override
  String get mfSendViaEmail => 'Envoyer par Email';

  @override
  String get mfContact => 'Contacter';

  @override
  String get mfHideDetails => 'Masquer les Détails';

  @override
  String get mfMoreDetails => 'Plus de Détails';

  @override
  String get mfMinimumOrderQuantity => 'Quantité Minimale de Commande';

  @override
  String get mfCertifications => 'Certifications';

  @override
  String get mfProductsCapabilities => 'Produits et Capacités';

  @override
  String mfContactManufacturer(String name) {
    return 'Contacter $name';
  }

  @override
  String get mfEmail => 'Email';

  @override
  String get mfWebsite => 'Site Web';

  @override
  String get mfInstagram => 'Instagram';

  @override
  String get mfNotAvailable => 'Non disponible';

  @override
  String get mfClose => 'Fermer';

  @override
  String get mfError => 'Erreur';

  @override
  String get mfEmailNotAvailable => 'Email non disponible';

  @override
  String get mfWebsiteNotAvailable => 'Site web non disponible';

  @override
  String get mfCouldNotOpenLink => 'Impossible d\'ouvrir le lien';

  @override
  String get mfNoEmailAvailable => 'Aucun Email Disponible';

  @override
  String get mfManufacturerNoEmail =>
      'Ce fabricant n\'a pas d\'adresse email enregistrée.';

  @override
  String get mfEmailSentSuccessfully => 'Email Envoyé avec Succès !';

  @override
  String mfTechPackSentTo(String name, String email) {
    return 'Votre dossier technique a été envoyé à $name à $email';
  }

  @override
  String get mfEmailFailed => 'Échec de l\'Email';

  @override
  String mfFailedToSendEmail(String name) {
    return 'Échec de l\'envoi de l\'email à $name. Veuillez réessayer.';
  }

  @override
  String mfErrorSendingEmail(String error) {
    return 'Une erreur s\'est produite lors de l\'envoi de l\'email : $error';
  }

  @override
  String get mfPreviewEmail => 'Aperçu de l\'Email';

  @override
  String get mfCancel => 'Annuler';

  @override
  String get mfSendEmail => 'Envoyer l\'Email';

  @override
  String get mfTechPackSummary => 'Résumé du Dossier Technique';

  @override
  String get mfMaterial => 'Matériau';

  @override
  String get mfPrimaryColor => 'Couleur Principale';

  @override
  String get mfSizeRange => 'Gamme de Tailles';

  @override
  String get mfQuantity => 'Quantité';

  @override
  String get mfTargetCost => 'Coût Cible';

  @override
  String get mfDelivery => 'Livraison';

  @override
  String mfPDFAttachment(String name, String size) {
    return 'Pièce jointe PDF : $name ($size KB)';
  }

  @override
  String mfImagesAttached(int count) {
    return 'Images jointes : $count';
  }

  @override
  String get tpdFinalDesignValidated => 'Design Final Validé';

  @override
  String get tpdMaterialsFabrics => 'Matériaux et Tissus';

  @override
  String get tpdMainFabricLabel => 'Quel est le tissu principal utilisé ?';

  @override
  String get tpdMainFabricHint => 'Tissu Principal : Sergé de coton bio';

  @override
  String get tpdSecondaryMaterialsLabel =>
      'Y a-t-il des matériaux secondaires ou des doublures ?';

  @override
  String get tpdSecondaryMaterialsHint => 'Doublure en mesh polyester';

  @override
  String get tpdFabricPropertiesLabel =>
      'Le tissu a-t-il des propriétés techniques ? (ex : bio, extensible, imperméable)';

  @override
  String get tpdFabricPropertiesHint => 'Respirant, extensible, hydrofuge';

  @override
  String get tpdColors => 'Couleurs';

  @override
  String get tpdPrimaryColorLabel =>
      'Quelle est la couleur principale du vêtement ?';

  @override
  String get tpdPrimaryColorHint => 'Bleu ciel';

  @override
  String get tpdAlternateColorwaysLabel =>
      'Y a-t-il des coloris alternatifs à produire ?';

  @override
  String get tpdAlternateColorwaysHint => 'Vert sauge, blanc cassé';

  @override
  String get tpdPantoneLabel =>
      'Avez-vous des références Pantone ou des codes HEX pour les couleurs ?';

  @override
  String get tpdPantoneHint => 'Pantone 290C, #C1DAD6';

  @override
  String get tpdSizesMeasurements => 'Tailles et Mesures';

  @override
  String get tpdSizeRangeLabel =>
      'Voulez-vous utiliser des tableaux de tailles standard ou entrer des mesures personnalisées ? (ex : XS–XL)';

  @override
  String get tpdSizeRangeHint => 'Gamme de Tailles : XS, S, M, L, XL';

  @override
  String get tpdMeasurementChartLabel =>
      'Fournirez-vous un tableau de mesures par taille ?';

  @override
  String get tpdMeasurementChartHint => 'Non';

  @override
  String get tpdOr => 'ou';

  @override
  String get tpdAutogeneratedLabel =>
      'Ou l\'IA devrait-elle en générer un automatiquement à partir du modèle 3D ?';

  @override
  String get tpdAutogeneratedHint => 'Oui';

  @override
  String get tpdTechnicalDetails => 'Détails Techniques';

  @override
  String get tpdAccessoriesLabel => 'Y a-t-il des accessoires ?';

  @override
  String get tpdAccessoriesHint => 'Fermeture éclair, boutons, cordon';

  @override
  String get tpdStitchingLabel => 'Quel type de point doit être utilisé ?';

  @override
  String get tpdStitchingHint => 'Simple, double, surjet, etc.';

  @override
  String get tpdDecorativeStitchingLabel =>
      'Avez-vous besoin de coutures visibles, renforcées ou décoratives ?';

  @override
  String get tpdDecorativeStitchingHint =>
      'Surpiqûre contrastée sur les manches';

  @override
  String get tpdLabelingBranding => 'Étiquetage et Image de Marque';

  @override
  String get tpdLogoPlacementLabel =>
      'Où le logo ou le nom de la marque doit-il apparaître ?';

  @override
  String get tpdLogoPlacementHint => 'Placement du logo : Poitrine et cou';

  @override
  String get tpdLabelsNeededLabel =>
      'Quels types d\'étiquettes sont nécessaires ?';

  @override
  String get tpdLabelsNeededHint => 'Marque, entretien, taille';

  @override
  String get tpdUploadReferenceImage =>
      'Télécharger une image de référence (optionnel)';

  @override
  String get tpdQrCodeLabel =>
      'Un code QR, un code-barres ou une puce NFC doivent-ils être inclus ?';

  @override
  String get tpdQrCodeHint => 'Ajouter un code QR';

  @override
  String get tpdPackagingShipping => 'Emballage et Expédition';

  @override
  String get tpdPackagingTypeLabel => 'Quel type d\'emballage est requis ?';

  @override
  String get tpdPackagingTypeHint => 'Boîte kraft + sachet plastique';

  @override
  String get tpdFoldingInstructionsLabel =>
      'Des instructions spécifiques de pliage ou d\'emballage ?';

  @override
  String get tpdFoldingInstructionsHint => 'Plier sur la poitrine';

  @override
  String get tpdInsertsLabel =>
      'Souhaitez-vous inclure une fiche produit ou un dépliant ?';

  @override
  String get tpdInsertsHint =>
      'Encarts : Carte de remerciement, fiche d\'entretien';

  @override
  String get tpdProductionDetails => 'Détails de Production';

  @override
  String get tpdCostPerPieceLabel => 'Quel est le coût cible par pièce ?';

  @override
  String get tpdCostPerPieceHint => 'Coût par Pièce : 3,8 €';

  @override
  String get tpdQuantityLabel =>
      'Combien d\'unités prévoyez-vous de produire ?';

  @override
  String get tpdQuantityHint => 'Quantité : 1 000 unités';

  @override
  String get tpdDeliveryDateLabel =>
      'Quelle est votre date de livraison souhaitée ?';

  @override
  String get tpdDeliveryDateHint => 'Livraison : 30 septembre 2025';

  @override
  String get tpdManufacturers => 'Fabricants';

  @override
  String get tpdSelectCountryForManufacturers =>
      'Sélectionnez un pays pour les suggestions de fabricants';

  @override
  String get tpdSearchCountry => 'Rechercher';

  @override
  String get tpdSearchCountryHint => 'Commencez à taper pour rechercher';

  @override
  String get tpdSelectACountry => 'Sélectionnez un pays';

  @override
  String get tpdGenerateTechPack => 'Générer le Dossier Technique';

  @override
  String get tprYourTechPackReady => 'Votre Dossier Technique \nEst Prêt';

  @override
  String get tprGeneratedTechPackImages =>
      'Images du Dossier Technique Générées';

  @override
  String get tprCreatingTechPack => 'Création de votre dossier technique...';

  @override
  String get tprPleaseWaitGenerating =>
      'Veuillez patienter pendant que nous générons vos images de dossier technique avec toutes les spécifications.';

  @override
  String get tprTechPackDetails => 'Détails du Dossier Technique';

  @override
  String get tprTechnicalFlatDrawing => 'Dessin Technique à Plat';

  @override
  String get tprGenerating => 'Génération en cours';

  @override
  String tprLogoPlacement(String placement) {
    return 'Logo / $placement';
  }

  @override
  String get tprNoTechPackImages =>
      'Aucune image de dossier technique générée pour le moment';

  @override
  String get tprWarningTitle => 'Avertissement';

  @override
  String get tprNavigationWarningMessage =>
      'La génération est en cours. Revenir en arrière annulera la génération et vous perdrez votre dossier technique. Êtes-vous sûr ?';

  @override
  String get tprStayHere => 'Rester Ici';

  @override
  String get tprGoBack => 'Revenir';

  @override
  String get tprGetManufacturerSuggestions =>
      'Obtenir des Suggestions de Fabricants';

  @override
  String get tprCollectionExists => 'Collection Existante';

  @override
  String get tprCollectionAlreadyExists => 'Cette collection existe déjà';

  @override
  String get tprError => 'Erreur';

  @override
  String get tprFailedToAddCollection => 'Échec de l\'ajout de la collection';

  @override
  String get tprNoImages => 'Aucune Image';

  @override
  String get tprGenerateImagesFirst =>
      'Veuillez d\'abord générer les images du dossier technique';

  @override
  String get tprUpdated => 'Mis à jour !';

  @override
  String get tprTechPackUpdatedSuccessfully =>
      'Dossier technique mis à jour avec succès !';

  @override
  String get tprSuccess => 'Succès';

  @override
  String get tprTechPackSavedSuccessfully =>
      'Dossier technique enregistré avec succès !';

  @override
  String tprFailedToSaveTechPack(String error) {
    return 'Échec de l\'enregistrement du dossier technique : $error';
  }

  @override
  String get tprPdfSavedSuccessfully =>
      'PDF du dossier technique enregistré avec succès !';

  @override
  String tprFailedToExportPdf(String error) {
    return 'Échec de l\'exportation du PDF : $error';
  }

  @override
  String tprFailedToExportWord(String error) {
    return 'Échec de l\'exportation du document Word : $error';
  }

  @override
  String tprFailedToShareFile(String error) {
    return 'Échec du partage du fichier : $error';
  }

  @override
  String get tprTechPackDocument => 'Document de Dossier Technique';

  @override
  String get vpManufacturerProfile => 'Profil du Fabricant';

  @override
  String get vpCompany => 'Entreprise';

  @override
  String get vpLocation => 'Localisation';

  @override
  String get vpMinimumOrderQuantity => 'Quantité Minimale de Commande';

  @override
  String get vpLeadTime => 'Délai de Production';

  @override
  String get vpAbout => 'À Propos';

  @override
  String get vpContact => 'Contact';

  @override
  String get tpwSaveTechPack => 'Enregistrer le Tech Pack';

  @override
  String get tpwProjectName => 'Nom du Projet';

  @override
  String get tpwEnterProjectName => 'Entrez le nom du projet';

  @override
  String get tpwCollectionName => 'Nom de la Collection';

  @override
  String get tpwAdd => 'AJOUTER';

  @override
  String get tpwSave => 'ENREGISTRER';

  @override
  String get tpwError => 'Erreur';

  @override
  String get tpwPleaseEnterProjectName => 'Veuillez entrer un nom de projet';

  @override
  String get tpwAddCollection => 'AJOUTER UNE COLLECTION';

  @override
  String get tpwEnterCollectionName => 'Entrez le nom de la collection';

  @override
  String get tpwPleaseEnterCollectionName =>
      'Veuillez entrer un nom de collection';

  @override
  String get tpwExportOptions => 'Options d\'Exportation';

  @override
  String get tpwSelectExportFormat =>
      'Sélectionnez votre format d\'exportation préféré';

  @override
  String get tpwPdfWithLogo => 'PDF avec logo/branding';

  @override
  String get tpwIncludesAtellaBranding =>
      'Inclut le branding et le logo ATELIA';

  @override
  String get tpwNeutralPdf => 'PDF Neutre';

  @override
  String get tpwCleanPdfWithoutBranding => 'PDF propre sans branding';

  @override
  String get tpwEditableFormatWord => 'Format Éditable (Word)';

  @override
  String get tpwEditableWordDocument =>
      'Document Word éditable avec page de couverture et images';

  @override
  String get tpwCancel => 'Annuler';

  @override
  String get tpwOk => 'OK';

  @override
  String get tpwSaveButton => 'Enregistrer';

  @override
  String get tpwExportButton => 'Exporter';

  @override
  String get tpwGenerating => 'Génération..';

  @override
  String get tpdEditMode => 'Mode Édition';

  @override
  String get tpdLoadingExistingTechPack =>
      'Chargement des données du tech pack existant...';

  @override
  String get tpdNotice => 'Avis';

  @override
  String get tpdStartingWithEmptyForm =>
      'Démarrage avec un formulaire de tech pack vide';

  @override
  String get tpdSuccess => 'Succès';

  @override
  String get tpdTechPackImagesGenerated =>
      'Images de dossier technique détaillées générées avec étiquetage professionnel !';

  @override
  String get tpdPartialSuccess => 'Succès Partiel';

  @override
  String get tpdSomeTechPackImagesGenerated =>
      'Certaines images de tech pack générées. Vérifiez les résultats.';

  @override
  String get tpdError => 'Erreur';

  @override
  String tpdFailedToGenerateTechPack(String error) {
    return 'Échec de la génération des images de tech pack détaillées : $error';
  }

  @override
  String tpdFailedToPickImage(String error) {
    return 'Échec de la sélection de l\'image : $error';
  }

  @override
  String get tpdProcessing => 'Traitement';

  @override
  String get tpdProcessingYourPurchase => 'Traitement de votre achat...';

  @override
  String get tpdSuccessExclamation => 'Succès !';

  @override
  String tpdAdditionalTechPacksAdded(String count) {
    return 'Vous avez maintenant $count tech packs supplémentaires pour ce mois !';
  }

  @override
  String get tpdPurchaseFailed => 'Achat Échoué';

  @override
  String get tpdUnableToProcessPurchase =>
      'Impossible de traiter votre achat. Veuillez réessayer.';

  @override
  String tpdPurchaseError(String error) {
    return 'Une erreur s\'est produite lors de l\'achat : $error';
  }

  @override
  String tpgDesignNumber(String number) {
    return 'Design $number';
  }

  @override
  String get tpgGenerating => 'Génération en cours';

  @override
  String get tpgFailedToGenerate => 'Échec de la génération';

  @override
  String get tpgFailedToLoadImage => 'Échec du chargement de l\'image';

  @override
  String get cancellationReasonTooExpensive => 'Trop cher';

  @override
  String get cancellationReasonNotUsing => 'Pas assez utilisé';

  @override
  String get cancellationReasonMissingFeatures =>
      'Fonctionnalités manquantes dont j\'ai besoin';

  @override
  String get cancellationReasonBetterAlternative =>
      'Trouvé une meilleure alternative';

  @override
  String get cancellationReasonTechnicalIssues => 'Problèmes techniques';

  @override
  String get cancellationReasonOther => 'Autre';

  @override
  String get studioDescription =>
      'Pour les studios, agences et utilisateurs intensifs';

  @override
  String get studioFeatureAiDesignLimit =>
      '25 générations de designs IA par mois';

  @override
  String get studioFeatureTechpackMonthly => '10 techpacks par mois';

  @override
  String get studioFeatureTechpackYearly =>
      '10 techpacks par mois (120 par an)';

  @override
  String get studio => 'Studio';

  @override
  String cbEnterCustom(String category) {
    return 'Entrez $category personnalisé...';
  }

  @override
  String get fdQuestionTargetSeason =>
      'Parfait! Assurons-nous que votre pièce s\'adapte parfaitement à la saison. Pour quel type de météo sera-t-elle conçue?';

  @override
  String get fdSeasonSummer => 'Été (Léger, Manches Courtes Ou Retroussables)';

  @override
  String get fdSeasonMid => 'Mi-Saison';

  @override
  String get fdSeasonAll => 'Toutes Saisons (Adapté aux Couches)';

  @override
  String get fdQuestionTargetBudget =>
      'Compris. Et quel type de budget envisagez-vous pour ce design? Je peux adapter les tissus et les caractéristiques en conséquence.';

  @override
  String get fdBudgetEntry =>
      'Entrée de Gamme (€15-30 Production / €35-60 Vente)';

  @override
  String get fdBudgetMid =>
      'Milieu de Gamme (€30-50 Production / €60-120 Vente)';

  @override
  String get fdBudgetPremium => 'Premium (€60+ Production / €120+ Vente)';

  @override
  String get fdQuestionDesiredFeatures =>
      'Souhaitez-vous inclure des valeurs ou des caractéristiques spéciales qui comptent pour vous ou votre marque? Je peux m\'assurer qu\'elles font partie du concept final';

  @override
  String get fdFeatureOrganic => 'Tissu Biologique';

  @override
  String get fdFeatureUpcycled => 'Matériaux Recyclés';

  @override
  String get fdFeatureLocallyMade => 'Fabriqué Localement (Europe)';

  @override
  String get fdFeatureUvProtection => 'Protection UV';

  @override
  String get fdFeatureQuickDry => 'Séchage Rapide';

  @override
  String get fdFeatureWrinkleFree => 'Sans Plis';

  @override
  String get fdFeatureOther => 'Autre: ?';

  @override
  String get fdQuestionAdditionalDetails =>
      'Cool — n\'hésitez pas à taper tout ce que vous avez en tête!';

  @override
  String get fdRegeneratingDesigns => 'Régénération des Designs!';

  @override
  String get fdRegeneratingDesignsMessage =>
      'Création de 3 nouveaux designs basés sur vos préférences mises à jour...';

  @override
  String get fdGeneratingDesigns => 'Génération des Designs!';

  @override
  String get fdGeneratingDesignsMessage =>
      'Création de 3 designs uniques basés sur vos préférences...';

  @override
  String get fdExtraDesignsAdded => 'Designs Supplémentaires Ajoutés!';

  @override
  String get fdExtraDesignsAddedMessage =>
      '5 designs supplémentaires ont été ajoutés à votre compte.';

  @override
  String fdToday(String time) {
    return 'Aujourd\'hui, $time';
  }

  @override
  String get authUserCreationFailed =>
      'La création de l\'utilisateur a échoué. Veuillez réessayer.';

  @override
  String get authGenericError =>
      'Une erreur s\'est produite. Veuillez réessayer.';

  @override
  String get authEmailAlreadyInUse =>
      'Cet email est déjà enregistré. Veuillez vous connecter à la place.';

  @override
  String get authWeakPassword =>
      'Le mot de passe est trop faible. Veuillez utiliser un mot de passe plus fort.';

  @override
  String get authInvalidEmail =>
      'Adresse email invalide. Veuillez vérifier et réessayer.';

  @override
  String get authOperationNotAllowed =>
      'Cette opération n\'est pas autorisée. Veuillez contacter le support.';

  @override
  String get authUserNotFound =>
      'Aucun utilisateur trouvé avec cet email. Veuillez d\'abord vous inscrire.';

  @override
  String get authWrongPassword => 'Mot de passe incorrect. Veuillez réessayer.';

  @override
  String get authUserDisabled =>
      'Ce compte a été désactivé. Veuillez contacter le support.';

  @override
  String get authTooManyRequests =>
      'Trop de tentatives échouées. Veuillez réessayer plus tard.';

  @override
  String get authNetworkError =>
      'Erreur réseau. Veuillez vérifier votre connexion Internet.';

  @override
  String get authGoogleSignInCancelled => 'La connexion Google a été annulée.';

  @override
  String get authGoogleSignInFailed =>
      'La connexion Google a échoué. Veuillez réessayer.';

  @override
  String get authGoogleConfigError =>
      'Erreur de configuration. Veuillez contacter le support.';

  @override
  String get authGoogleGenericError =>
      'Une erreur s\'est produite lors de la connexion Google. Veuillez réessayer.';

  @override
  String get authInvalidCredentials =>
      'Email ou mot de passe incorrect. Veuillez réessayer.';

  @override
  String get collectionSummer => 'COLLECTION ÉTÉ';

  @override
  String get collectionWinter => 'COLLECTION HIVER';

  @override
  String get termsAndConditions => 'Conditions Générales';

  @override
  String get tcLastUpdated => 'Dernière mise à jour : janvier 2025';

  @override
  String get tcIntroduction =>
      'Ces Conditions Générales régissent votre accès et votre utilisation de l\'application mobile Atelia, du site web et des services.\n\nEn téléchargeant, en accédant ou en utilisant Atelia, vous acceptez ces Conditions.';

  @override
  String get tcCompanyInformation => 'Informations sur l\'Entreprise';

  @override
  String get tcCompanyInformationContent =>
      'Atelia SAS – France\nSiège social : Guérande, France\nEmail de contact : ateliadesign.contact@gmail.com';

  @override
  String get tcDescriptionOfService => 'Description du Service';

  @override
  String get tcDescriptionOfServiceContent =>
      'Atelia est une plateforme SaaS qui permet aux utilisateurs de :\n• Générer des designs de mode à l\'aide de l\'IA\n• Créer des fiches techniques (techpacks)\n• Visualiser les designs en 3D\n• Accéder à un répertoire de fabricants de vêtements\n• Exporter des fichiers et documents liés à la production\n\nAtelia fournit des outils d\'assistance et ne remplace pas les designers, fabricants ou consultants professionnels.';

  @override
  String get tcEligibility => 'Éligibilité';

  @override
  String get tcEligibilityContent =>
      '• Vous devez avoir au moins 16 ans\n• Vous devez avoir la capacité juridique de conclure un contrat\n• Vous êtes responsable de vous assurer que votre utilisation est conforme aux lois locales';

  @override
  String get tcUserAccount => 'Compte Utilisateur';

  @override
  String get tcUserAccountContent =>
      '• Vous êtes responsable du maintien de la confidentialité de vos identifiants de connexion\n• Vous êtes responsable de toute activité sur votre compte\n• Atelia se réserve le droit de suspendre ou de résilier les comptes en cas d\'utilisation abusive ou de violation de ces Conditions';

  @override
  String get tcSubscriptionsAndPayments => 'Abonnements et Paiements';

  @override
  String get tcSubscriptionsAndPaymentsContent =>
      'Atelia propose des plans d\'abonnement gratuits et payants. Les détails sur les tarifs, les limites et les fonctionnalités sont affichés dans l\'application.\n\nLes abonnements peuvent inclure :\n• Facturation mensuelle ou annuelle\n• Limites d\'utilisation (designs, techpacks, exports)\n• Options supplémentaires\n\nLes paiements sont traités via l\'App Store d\'Apple (iOS) ou le Google Play Store (Android). Atelia ne stocke pas les informations de paiement.\n\nLes abonnements se renouvellent automatiquement sauf annulation au moins 24 heures avant la fin de la période en cours. Vous pouvez gérer ou annuler votre abonnement via les paramètres de l\'identifiant Apple ou du compte Google Play.\n\nLes remboursements sont gérés exclusivement par Apple ou Google, selon leurs politiques respectives. Atelia ne peut pas émettre de remboursements directement.';

  @override
  String get tcUsageLimits => 'Limites d\'Utilisation et Usage Raisonnable';

  @override
  String get tcUsageLimitsContent =>
      'Chaque plan d\'abonnement comprend des limites d\'utilisation.\n• Les crédits inutilisés ne sont pas reportés\n• Un abus ou une utilisation excessive peut entraîner des limitations temporaires ou une suspension du compte\n• Atelia se réserve le droit de modifier les limites d\'utilisation pour assurer la stabilité du service';

  @override
  String get tcIntellectualProperty => 'Propriété Intellectuelle';

  @override
  String get tcIntellectualPropertyContent =>
      'Tous les logiciels, marques de commerce, logos et contenus appartiennent à Atelia. Vous ne pouvez pas copier, modifier ou redistribuer la plateforme d\'Atelia sans autorisation.\n\nVous conservez la propriété du contenu que vous créez. Vous accordez à Atelia une licence non exclusive pour traiter et stocker le contenu afin de fournir le service. Atelia ne revendique pas la propriété de vos designs.';

  @override
  String get tcAIContentDisclaimer =>
      'Avertissement sur le Contenu Généré par l\'IA';

  @override
  String get tcAIContentDisclaimerContent =>
      '• Les designs et techpacks générés par l\'IA sont des suggestions, pas des garanties\n• Atelia ne garantit pas la fabricabilité, la conformité ou le succès de la production\n• Les utilisateurs restent entièrement responsables de la vérification des résultats avant la production';

  @override
  String get tcFactoryDirectoryDisclaimer =>
      'Avertissement sur le Répertoire d\'Usines';

  @override
  String get tcFactoryDirectoryDisclaimerContent =>
      '• Atelia ne possède ni n\'exploite les usines répertoriées\n• Atelia n\'est pas responsable des contrats, des prix, de la qualité ou des litiges entre les utilisateurs et les fabricants\n• Toute collaboration est strictement entre l\'utilisateur et l\'usine';

  @override
  String get tcLimitationOfLiability => 'Limitation de Responsabilité';

  @override
  String get tcLimitationOfLiabilityContent =>
      'Dans toute la mesure permise par la loi :\n• Atelia n\'est pas responsable des dommages indirects ou consécutifs\n• Atelia n\'est pas responsable des pertes financières, des problèmes de production ou de l\'échec commercial\n• La responsabilité totale ne doit pas dépasser le montant payé par l\'utilisateur au cours des 12 derniers mois';

  @override
  String get tcServiceAvailability => 'Disponibilité du Service';

  @override
  String get tcServiceAvailabilityContent =>
      '• Atelia s\'efforce d\'assurer une haute disponibilité mais ne garantit pas un accès ininterrompu\n• Les fonctionnalités peuvent être modifiées, suspendues ou interrompues à tout moment';

  @override
  String get tcTermination => 'Résiliation';

  @override
  String get tcTerminationContent =>
      'Vous pouvez arrêter d\'utiliser Atelia à tout moment.\n\nAtelia peut résilier l\'accès en cas de :\n• Violation de ces Conditions\n• Fraude ou abus\n• Obligations légales';

  @override
  String get tcPrivacy => 'Confidentialité';

  @override
  String get tcPrivacyContent =>
      'Votre utilisation d\'Atelia est régie par notre Politique de Confidentialité, disponible à :\nhttps://www.atelia.ai/privacy';

  @override
  String get tcGoverningLaw => 'Loi Applicable';

  @override
  String get tcGoverningLawContent =>
      'Ces Conditions sont régies par le droit français.\n\nTout litige sera soumis à la juridiction des tribunaux de France.';

  @override
  String get tcChangesToTerms => 'Modifications des Conditions';

  @override
  String get tcChangesToTermsContent =>
      'Atelia peut mettre à jour ces Conditions à tout moment. L\'utilisation continue de l\'application constitue l\'acceptation des Conditions mises à jour.';

  @override
  String get tcContact => 'Contact';

  @override
  String get tcContactContent =>
      'Pour toute question ou préoccupation concernant ces Conditions Générales, veuillez nous contacter à :\n\nateliadesign.contact@gmail.com';

  @override
  String get ppLastUpdated => 'Dernière mise à jour : janvier 2025';

  @override
  String get ppIntroduction =>
      'Atelia exploite l\'application mobile Atelia et la plateforme web.\n\nCette Politique de Confidentialité explique comment nous collectons, utilisons, divulguons et protégeons vos informations lorsque vous utilisez notre Service.\n\nEn accédant ou en utilisant Atelia, vous acceptez la collecte et l\'utilisation des informations conformément à cette Politique de Confidentialité.';

  @override
  String get ppInformationWeCollect => '1. Informations que Nous Collectons';

  @override
  String get ppInformationWeCollectContent =>
      'a. Informations Personnelles\n\nLorsque vous créez un compte ou utilisez notre Service, nous pouvons collecter :\n• Nom ou nom d\'utilisateur\n• Adresse e-mail\n• Informations de paiement et de facturation (traitées en toute sécurité par des fournisseurs tiers)\n• Préférences du compte\n\nb. Données d\'Utilisation\n\nNous collectons automatiquement des informations telles que :\n• Type d\'appareil, système d\'exploitation et version de l\'application\n• Adresse IP et localisation approximative\n• Pages/écrans consultés et fonctionnalités utilisées\n• Heure et date d\'utilisation\n\nc. Contenu Utilisateur\n\nLorsque vous utilisez Atelia, vous pouvez fournir :\n• Invites et entrées de design\n• Designs et fiches techniques générés\n• Fichiers ou contenu téléchargé sur la plateforme\n\nNous ne revendiquons pas la propriété de votre contenu.';

  @override
  String get ppHowWeUseYourInformation =>
      '2. Comment Nous Utilisons Vos Informations';

  @override
  String get ppHowWeUseYourInformationContent =>
      'Nous utilisons vos données pour :\n• Fournir et exploiter le Service\n• Générer des designs et des fiches techniques basés sur l\'IA\n• Gérer les abonnements et les paiements\n• Améliorer les performances du produit et l\'expérience utilisateur\n• Communiquer les mises à jour, les messages d\'assistance et les avis importants\n• Détecter la fraude, l\'abus ou l\'utilisation abusive du Service';

  @override
  String get ppAIAndThirdPartyServices => '3. IA et Services Tiers';

  @override
  String get ppAIAndThirdPartyServicesContent =>
      'Atelia utilise des services tiers pour fonctionner :\n• Fournisseurs de modèles d\'IA\n• Infrastructure cloud et hébergement\n• Analytique et surveillance des performances\n• Processeurs de paiement\n\nVos données peuvent être traitées par ces fournisseurs uniquement pour fournir le Service et conformément aux lois applicables sur la protection des données.';

  @override
  String get ppDataRetention => '4. Conservation des Données';

  @override
  String get ppDataRetentionContent =>
      'Nous ne conservons les données personnelles que le temps nécessaire pour :\n• Fournir le Service\n• Se conformer aux obligations légales\n• Résoudre les litiges\n• Faire respecter les accords\n\nVous pouvez demander la suppression de votre compte et de vos données à tout moment.';

  @override
  String get ppDataSharingAndDisclosure =>
      '5. Partage et Divulgation des Données';

  @override
  String get ppDataSharingAndDisclosureContent =>
      'Nous ne vendons pas vos données personnelles.\n\nNous ne partageons les données que :\n• Avec des fournisseurs de services de confiance sous accords de confidentialité\n• Pour se conformer aux obligations légales\n• Pour protéger nos droits, les utilisateurs ou la sécurité de la plateforme';

  @override
  String get ppSecurity => '6. Sécurité';

  @override
  String get ppSecurityContent =>
      'Nous mettons en œuvre des mesures de sécurité conformes aux normes de l\'industrie pour protéger vos données.\n\nCependant, aucune méthode de transmission ou de stockage n\'est sécurisée à 100%.';

  @override
  String get ppYourRights => '7. Vos Droits';

  @override
  String get ppYourRightsContent =>
      'Selon votre emplacement, vous pouvez avoir le droit de :\n• Accéder à vos données personnelles\n• Corriger les données inexactes\n• Demander la suppression de vos données\n• Vous opposer ou restreindre le traitement\n\nPour exercer ces droits, contactez-nous à :\nateliadesign.contact@gmail.com';

  @override
  String get ppChildrensPrivacy => '8. Confidentialité des Enfants';

  @override
  String get ppChildrensPrivacyContent =>
      'Atelia n\'est pas destiné aux utilisateurs de moins de 16 ans.\n\nNous ne collectons pas sciemment de données personnelles auprès d\'enfants de moins de 16 ans. Si nous en prenons connaissance, nous les supprimerons immédiatement.';

  @override
  String get ppInternationalDataTransfers =>
      '9. Transferts Internationaux de Données';

  @override
  String get ppInternationalDataTransfersContent =>
      'Vos informations peuvent être transférées et stockées sur des serveurs situés en dehors de votre pays.\n\nEn utilisant Atelia, vous consentez à ces transferts.';

  @override
  String get ppChangesToThisPrivacyPolicy =>
      '10. Modifications de Cette Politique de Confidentialité';

  @override
  String get ppChangesToThisPrivacyPolicyContent =>
      'Nous pouvons mettre à jour cette Politique de Confidentialité de temps à autre. Toute modification sera publiée dans l\'application ou sur notre site web.\n\nL\'utilisation continue du Service après les modifications constitue une acceptation.';

  @override
  String get ppContactUs => '11. Nous Contacter';

  @override
  String get ppContactUsContent =>
      'Si vous avez des questions concernant cette Politique de Confidentialité, contactez-nous :\n\nEmail : ateliadesign.contact@gmail.com';

  @override
  String get deleteAccount => 'Supprimer le Compte';

  @override
  String get deleteAccountTitle => 'Supprimer Votre Compte';

  @override
  String get deleteAccountWarning =>
      'Êtes-vous sûr de vouloir supprimer votre compte ?\n\nCette action est irréversible et supprimera définitivement toutes vos données, y compris votre profil, vos designs, vos fiches techniques et votre abonnement.';

  @override
  String get confirmDelete => 'Oui, Supprimer Mon Compte';

  @override
  String get cancelDelete => 'Annuler';

  @override
  String get enterPassword => 'Entrez Votre Mot de Passe';

  @override
  String get enterPasswordToConfirm =>
      'Veuillez entrer votre mot de passe pour confirmer la suppression du compte :';

  @override
  String get deleteMyAccount => 'Supprimer Mon Compte';

  @override
  String get confirmWithGoogle => 'Confirmer avec Google';

  @override
  String get signInWithGoogleToConfirm =>
      'Veuillez vous connecter avec Google pour confirmer la suppression du compte :';

  @override
  String get accountDeleted => 'Compte Supprimé';

  @override
  String get accountDeletedSuccess =>
      'Votre compte a été supprimé avec succès. Nous sommes désolés de vous voir partir !';

  @override
  String get accountDeleteFailed =>
      'Échec de la suppression du compte. Veuillez réessayer.';

  @override
  String get wrongPassword => 'Mot de passe incorrect. Veuillez réessayer.';

  @override
  String get requiresRecentLogin =>
      'Pour des raisons de sécurité, veuillez vous déconnecter et vous reconnecter avant de supprimer votre compte.';

  @override
  String get userNotFound => 'Compte utilisateur introuvable.';

  @override
  String get networkError =>
      'Erreur réseau. Veuillez vérifier votre connexion et réessayer.';

  @override
  String get googleReauthCancelled =>
      'La connexion Google a été annulée. Suppression du compte annulée.';

  @override
  String get deletingAccount => 'Suppression du compte...';

  @override
  String get couldNotOpenLink => 'Impossible d\'ouvrir le lien';
}
