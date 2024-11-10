import 'package:flutter_specialized_temp/core/exceptions/storage_exception.dart';
import 'package:flutter_specialized_temp/core/storage/storage_keys.dart';
import 'package:injectable/injectable.dart';
import 'package:shared_preferences/shared_preferences.dart';

@lazySingleton
class PreferencesManager {
  final SharedPreferences _prefs;

  PreferencesManager(this._prefs);

  // Theme preferences
  Future<void> setDarkMode(bool isDark) async {
    try {
      await _prefs.setBool(StorageKeys.isDarkMode, isDark);
    } catch (e) {
      throw PreferencesException(
        'Failed to save dark mode preference',
        e,
      );
    }
  }

  bool getDarkMode() {
    return _prefs.getBool(StorageKeys.isDarkMode) ?? false;
  }

  // App preferences
  Future<void> setLanguage(String languageCode) async {
    try {
      await _prefs.setString(StorageKeys.language, languageCode);
    } catch (e) {
      throw PreferencesException(
        'Failed to save language preference',
        e,
      );
    }
  }

  String getLanguage() {
    return _prefs.getString(StorageKeys.language) ?? 'en';
  }

  // Clear all preferences
  Future<void> clearAll() async {
    try {
      await _prefs.clear();
    } catch (e) {
      throw PreferencesException(
        'Failed to clear preferences',
        e,
      );
    }
  }
}