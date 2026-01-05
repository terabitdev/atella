import 'package:flutter/material.dart';
import 'package:google_mlkit_translation/google_mlkit_translation.dart';

/// Service for translating dynamic Firebase data using Google ML Kit
/// Supports English to French translation for on-device processing
class MLTranslationService {
  static final MLTranslationService _instance = MLTranslationService._internal();
  factory MLTranslationService() => _instance;
  MLTranslationService._internal();

  OnDeviceTranslator? _translator;
  bool _isInitialized = false;
  bool _isModelDownloaded = false;

  /// Initialize the translator for English to French
  Future<void> initialize() async {
    if (_isInitialized) return;

    try {
      _translator = OnDeviceTranslator(
        sourceLanguage: TranslateLanguage.english,
        targetLanguage: TranslateLanguage.french,
      );
      _isInitialized = true;
    } catch (e) {
      debugPrint('Error initializing ML translator: $e');
      rethrow;
    }
  }

  /// Check if the French language model is downloaded
  Future<bool> isModelDownloaded() async {
    if (_isModelDownloaded) return true;

    try {
      final modelManager = OnDeviceTranslatorModelManager();
      _isModelDownloaded = await modelManager.isModelDownloaded(
        TranslateLanguage.french.bcpCode,
      );
      return _isModelDownloaded;
    } catch (e) {
      debugPrint('Error checking model download status: $e');
      return false;
    }
  }

  /// Download the French language model (required for offline translation)
  /// Returns true if successful, false otherwise
  Future<bool> downloadModel() async {
    try {
      final modelManager = OnDeviceTranslatorModelManager();

      // Check if already downloaded
      final isDownloaded = await modelManager.isModelDownloaded(
        TranslateLanguage.french.bcpCode,
      );

      if (isDownloaded) {
        _isModelDownloaded = true;
        return true;
      }

      // Download the model
      final success = await modelManager.downloadModel(
        TranslateLanguage.french.bcpCode,
      );

      _isModelDownloaded = success;
      return success;
    } catch (e) {
      debugPrint('Error downloading translation model: $e');
      return false;
    }
  }

  /// Translate text from English to French
  /// Returns the translated text or original text if translation fails
  Future<String> translateToFrench(String text, {String locale = 'en'}) async {
    // If locale is not French, return original text
    if (locale != 'fr') return text;

    // If text is empty, return as is
    if (text.trim().isEmpty) return text;

    try {
      // Initialize if not done
      if (!_isInitialized) {
        await initialize();
      }

      // Check if model is downloaded
      if (!_isModelDownloaded) {
        final downloaded = await isModelDownloaded();
        if (!downloaded) {
          debugPrint('French translation model not downloaded. Returning original text.');
          return text;
        }
      }

      // Translate the text
      final translatedText = await _translator!.translateText(text);
      return translatedText;
    } catch (e) {
      debugPrint('Error translating text: $e');
      // Return original text if translation fails
      return text;
    }
  }

  /// Translate a map of data (useful for Firebase documents)
  /// Only translates String values, preserves other types
  Future<Map<String, dynamic>> translateMap(
    Map<String, dynamic> data, {
    String locale = 'en',
    List<String>? fieldsToTranslate,
  }) async {
    if (locale != 'fr') return data;

    final translatedData = <String, dynamic>{};

    for (final entry in data.entries) {
      final key = entry.key;
      final value = entry.value;

      // Only translate if field is in the list (or translate all if list is null)
      final shouldTranslate = fieldsToTranslate == null ||
                              fieldsToTranslate.contains(key);

      if (shouldTranslate && value is String) {
        translatedData[key] = await translateToFrench(value, locale: locale);
      } else {
        translatedData[key] = value;
      }
    }

    return translatedData;
  }

  /// Translate a list of strings
  Future<List<String>> translateList(
    List<String> texts, {
    String locale = 'en',
  }) async {
    if (locale != 'fr') return texts;

    final translatedTexts = <String>[];

    for (final text in texts) {
      final translated = await translateToFrench(text, locale: locale);
      translatedTexts.add(translated);
    }

    return translatedTexts;
  }

  /// Delete the downloaded French model to free up space
  Future<bool> deleteModel() async {
    try {
      final modelManager = OnDeviceTranslatorModelManager();
      final deleted = await modelManager.deleteModel(
        TranslateLanguage.french.bcpCode,
      );

      if (deleted) {
        _isModelDownloaded = false;
      }

      return deleted;
    } catch (e) {
      debugPrint('Error deleting translation model: $e');
      return false;
    }
  }

  /// Get the size of the French translation model in bytes
  /// Returns null if model is not downloaded
  Future<int?> getModelSize() async {
    try {
      final modelManager = OnDeviceTranslatorModelManager();
      final isDownloaded = await modelManager.isModelDownloaded(
        TranslateLanguage.french.bcpCode,
      );

      if (!isDownloaded) return null;

      // ML Kit models are typically ~30MB
      // Return approximate size (actual size varies by model)
      return 30 * 1024 * 1024; // 30MB in bytes
    } catch (e) {
      debugPrint('Error getting model size: $e');
      return null;
    }
  }

  /// Clean up resources
  void dispose() {
    _translator?.close();
    _translator = null;
    _isInitialized = false;
  }
}
