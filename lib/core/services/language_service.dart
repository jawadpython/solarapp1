import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

/// Language Service manages app language preferences
class LanguageService extends ChangeNotifier {
  static LanguageService? _instance;
  static LanguageService get instance {
    _instance ??= LanguageService._();
    return _instance!;
  }

  LanguageService._();

  static const String _languageKey = 'app_language';
  
  Locale _currentLocale = const Locale('fr'); // Default to French

  Locale get currentLocale => _currentLocale;

  /// Initialize language from preferences
  Future<void> initialize() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final languageCode = prefs.getString(_languageKey);
      if (languageCode != null) {
        _currentLocale = Locale(languageCode);
        notifyListeners();
      }
    } catch (e) {
      // Use default locale on error
      _currentLocale = const Locale('fr');
    }
  }

  /// Set app language
  Future<void> setLanguage(Locale locale) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString(_languageKey, locale.languageCode);
      _currentLocale = locale;
      notifyListeners(); // Notify listeners that language has changed
    } catch (e) {
      // Silently fail
    }
  }

  /// Get supported locales
  static List<Locale> get supportedLocales => [
    const Locale('fr'),
    const Locale('ar'),
    const Locale('en'),
  ];
}

