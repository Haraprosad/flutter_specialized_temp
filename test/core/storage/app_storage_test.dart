// app_storage_test.dart

import 'package:flutter_specialized_temp/core/storage/app_storage.dart';
import 'package:flutter_specialized_temp/core/storage/secure_storage_manager.dart';
import 'package:flutter_specialized_temp/core/storage/preferences_manager.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/mockito.dart';
import 'package:mockito/annotations.dart';

// Generate the mock classes
@GenerateMocks([SecureStorageManager, PreferencesManager])
import 'app_storage_test.mocks.dart';

void main() {
  late AppStorage appStorage;
  late MockSecureStorageManager mockSecureStorage;
  late MockPreferencesManager mockPreferences;

  setUp(() {
    mockSecureStorage = MockSecureStorageManager();
    mockPreferences = MockPreferencesManager();
    appStorage = AppStorage(mockSecureStorage, mockPreferences);
  });

  group('AppStorage', () {
    test('should call deleteAllSecureData and clearAll in clearAllData', () async {
      // Arrange
      when(mockSecureStorage.deleteAllSecureData()).thenAnswer((_) async => Future.value());
      when(mockPreferences.clearAll()).thenAnswer((_) async => Future.value());

      // Act
      await appStorage.clearAllData();

      // Assert
      verify(mockSecureStorage.deleteAllSecureData()).called(1);
      verify(mockPreferences.clearAll()).called(1);
    });

    test('should propagate exceptions if deleteAllSecureData fails', () async {
      // Arrange
      when(mockSecureStorage.deleteAllSecureData()).thenThrow(Exception('Failed to delete secure data'));
      when(mockPreferences.clearAll()).thenAnswer((_) async => Future.value());

      // Act & Assert
      await expectLater(
        appStorage.clearAllData(),
        throwsA(isA<Exception>()),
      );

      // Ensure deleteAllSecureData was called but clearAll was not called due to the exception
      verify(mockSecureStorage.deleteAllSecureData()).called(1);
      verifyNever(mockPreferences.clearAll());
    });

    test('should propagate exceptions if clearAll fails', () async {
      // Arrange
      when(mockSecureStorage.deleteAllSecureData()).thenAnswer((_) async => Future.value());
      when(mockPreferences.clearAll()).thenThrow(Exception('Failed to clear preferences'));

      // Act & Assert
      await expectLater(
        appStorage.clearAllData(),
        throwsA(isA<Exception>()),
      );

      // Verify both methods were called, and exception propagated from clearAll
      verify(mockSecureStorage.deleteAllSecureData()).called(1);
      verify(mockPreferences.clearAll()).called(1);
    });
  });
}
