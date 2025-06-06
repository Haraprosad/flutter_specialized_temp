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

  // Authentication state methods
  Future<void> setIsAuthenticated(bool isAuthenticated) async {
    try {
      await _prefs.setBool(StorageKeys.isAuthenticated, isAuthenticated);
    } catch (e) {
      throw PreferencesException(
        'Failed to save authentication state',
        e,
      );
    }
  }

  bool getIsAuthenticated() {
    return _prefs.getBool(StorageKeys.isAuthenticated) ?? false;
  }

  // User role methods
  Future<void> setUserRole(String role) async {
    try {
      await _prefs.setString(StorageKeys.userRole, role);
    } catch (e) {
      throw PreferencesException(
        'Failed to save user role',
        e,
      );
    }
  }

  String? getUserRole() {
    return _prefs.getString(StorageKeys.userRole);
  }

  // User info methods
  Future<void> setUserId(String userId) async {
    try {
      await _prefs.setString(StorageKeys.userId, userId);
    } catch (e) {
      throw PreferencesException(
        'Failed to save user ID',
        e,
      );
    }
  }

  String? getUserId() {
    return _prefs.getString(StorageKeys.userId);
  }

  Future<void> setUserEmail(String email) async {
    try {
      await _prefs.setString(StorageKeys.userEmail, email);
    } catch (e) {
      throw PreferencesException(
        'Failed to save user email',
        e,
      );
    }
  }

  String? getUserEmail() {
    return _prefs.getString(StorageKeys.userEmail);
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
