import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:shared_preferences/shared_preferences.dart';

class LocaleController extends GetxController {
  static const String _localeKey = 'app_locale';

  // Supported locales
  static const Locale englishLocale = Locale('en');
  static const Locale frenchLocale = Locale('fr');

  static const List<Locale> supportedLocales = [
    englishLocale,
    frenchLocale,
  ];

  final Rx<Locale> _currentLocale = englishLocale.obs;
  Locale get currentLocale => _currentLocale.value;

  @override
  void onInit() {
    super.onInit();
    _loadSavedLocale();
  }

  Future<void> _loadSavedLocale() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final savedLocaleCode = prefs.getString(_localeKey);

      if (savedLocaleCode != null) {
        final savedLocale = Locale(savedLocaleCode);
        if (supportedLocales.contains(savedLocale)) {
          _currentLocale.value = savedLocale;
          Get.updateLocale(savedLocale);
        }
      } else {
        // Use device locale if supported, otherwise default to English
        final deviceLocale = PlatformDispatcher.instance.locale;
        final matchedLocale = supportedLocales.firstWhere(
          (locale) => locale.languageCode == deviceLocale.languageCode,
          orElse: () => englishLocale,
        );
        _currentLocale.value = matchedLocale;
      }
    } catch (e) {
      debugPrint('Error loading saved locale: $e');
    }
  }

  Future<void> changeLocale(Locale locale) async {
    if (!supportedLocales.contains(locale)) return;

    _currentLocale.value = locale;
    Get.updateLocale(locale);

    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString(_localeKey, locale.languageCode);
    } catch (e) {
      debugPrint('Error saving locale: $e');
    }
  }

  void setEnglish() => changeLocale(englishLocale);
  void setFrench() => changeLocale(frenchLocale);

  bool get isEnglish => _currentLocale.value.languageCode == 'en';
  bool get isFrench => _currentLocale.value.languageCode == 'fr';

  String get currentLanguageName {
    switch (_currentLocale.value.languageCode) {
      case 'fr':
        return 'Français';
      case 'en':
      default:
        return 'English';
    }
  }
}