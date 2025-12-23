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
  String get designImage => 'Image du design';

  @override
  String techPackImageN(int number) {
    return 'Image du dossier technique $number';
  }

  @override
  String get manufactureSuggestions => 'Suggestions de fabrication';

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
}
