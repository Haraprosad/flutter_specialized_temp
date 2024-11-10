import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/annotations.dart';
import 'package:mockito/mockito.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:flutter_specialized_temp/core/exceptions/storage_exception.dart';
import 'package:flutter_specialized_temp/core/storage/storage_keys.dart';
import 'package:flutter_specialized_temp/core/storage/preferences_manager.dart';

import 'preferences_manager_test.mocks.dart';

@GenerateMocks([SharedPreferences])
void main() {
  late PreferencesManager preferencesManager;
  late MockSharedPreferences mockPrefs;

  setUp(() {
    mockPrefs = MockSharedPreferences();
    preferencesManager = PreferencesManager(mockPrefs);
  });

  group('Theme preferences', () {
    test('setDarkMode should save dark mode preference', () async {
      // Arrange
      when(mockPrefs.setBool(StorageKeys.isDarkMode, true))
          .thenAnswer((_) async => true);

      // Act
      await preferencesManager.setDarkMode(true);

      // Assert
      verify(mockPrefs.setBool(StorageKeys.isDarkMode, true)).called(1);
    });

    test('setDarkMode should throw PreferencesException when save fails', () {
      // Arrange
      when(mockPrefs.setBool(StorageKeys.isDarkMode, true))
          .thenThrow(Exception('Save failed'));

      // Act & Assert
      expect(
        () => preferencesManager.setDarkMode(true),
        throwsA(isA<PreferencesException>()),
      );
    });

    test('getDarkMode should return saved preference', () {
      // Arrange
      when(mockPrefs.getBool(StorageKeys.isDarkMode)).thenReturn(true);

      // Act
      final result = preferencesManager.getDarkMode();

      // Assert
      expect(result, true);
      verify(mockPrefs.getBool(StorageKeys.isDarkMode)).called(1);
    });

    test('getDarkMode should return false when no preference is saved', () {
      // Arrange
      when(mockPrefs.getBool(StorageKeys.isDarkMode)).thenReturn(null);

      // Act
      final result = preferencesManager.getDarkMode();

      // Assert
      expect(result, false);
    });
  });

  group('Language preferences', () {
    test('setLanguage should save language preference', () async {
      // Arrange
      when(mockPrefs.setString(StorageKeys.language, 'fr'))
          .thenAnswer((_) async => true);

      // Act
      await preferencesManager.setLanguage('fr');

      // Assert
      verify(mockPrefs.setString(StorageKeys.language, 'fr')).called(1);
    });

    test('setLanguage should throw PreferencesException when save fails', () {
      // Arrange
      when(mockPrefs.setString(StorageKeys.language, 'fr'))
          .thenThrow(Exception('Save failed'));

      // Act & Assert
      expect(
        () => preferencesManager.setLanguage('fr'),
        throwsA(isA<PreferencesException>()),
      );
    });

    test('getLanguage should return saved preference', () {
      // Arrange
      when(mockPrefs.getString(StorageKeys.language)).thenReturn('fr');

      // Act
      final result = preferencesManager.getLanguage();

      // Assert
      expect(result, 'fr');
      verify(mockPrefs.getString(StorageKeys.language)).called(1);
    });

    test('getLanguage should return "en" when no preference is saved', () {
      // Arrange
      when(mockPrefs.getString(StorageKeys.language)).thenReturn(null);

      // Act
      final result = preferencesManager.getLanguage();

      // Assert
      expect(result, 'en');
    });
  });

  group('Clear preferences', () {
    test('clearAll should clear all preferences', () async {
      // Arrange
      when(mockPrefs.clear()).thenAnswer((_) async => true);

      // Act
      await preferencesManager.clearAll();

      // Assert
      verify(mockPrefs.clear()).called(1);
    });

    test('clearAll should throw PreferencesException when clear fails', () {
      // Arrange
      when(mockPrefs.clear()).thenThrow(Exception('Clear failed'));

      // Act & Assert
      expect(
        () => preferencesManager.clearAll(),
        throwsA(isA<PreferencesException>()),
      );
    });
  });
}