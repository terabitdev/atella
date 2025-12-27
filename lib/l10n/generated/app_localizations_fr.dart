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

  @override
  String get emailIsRequired => 'L\'e-mail est requis';

  @override
  String get enterValidEmail => 'Entrez un e-mail valide';

  @override
  String get passwordIsRequired => 'Le mot de passe est requis';

  @override
  String get passwordMinLength =>
      'Le mot de passe doit contenir au moins 6 caractères';

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
}
