import 'package:shared_preferences/shared_preferences.dart';

class OnboardingStorageService {
  static const _keyGoal = 'onboarding_goal';
  static const _keyProduction = 'onboarding_production';
  static const _keyDiscovery = 'onboarding_discovery';
  static const _keyExperience = 'onboarding_experience';

  Future<void> saveGoal(String value) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_keyGoal, value);
  }

  Future<void> saveProduction(String value) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_keyProduction, value);
  }

  Future<void> saveDiscovery(String value) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_keyDiscovery, value);
  }

  Future<void> saveExperience(String value) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_keyExperience, value);
  }

  // Returns the 4 onboarding values if ALL of them exist, otherwise null.
  Future<Map<String, String>?> getOnboardingData() async {
    final prefs = await SharedPreferences.getInstance();
    final goal = prefs.getString(_keyGoal);
    final production = prefs.getString(_keyProduction);
    final discovery = prefs.getString(_keyDiscovery);
    final experience = prefs.getString(_keyExperience);

    if (goal == null || production == null || discovery == null || experience == null) {
      return null;
    }

    return {
      'onboardingGoal': goal,
      'onboardingProduction': production,
      'onboardingDiscovery': discovery,
      'onboardingExperience': experience,
    };
  }

  Future<void> clearOnboardingData() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_keyGoal);
    await prefs.remove(_keyProduction);
    await prefs.remove(_keyDiscovery);
    await prefs.remove(_keyExperience);
  }
}
