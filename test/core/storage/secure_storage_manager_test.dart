import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:flutter_specialized_temp/core/exceptions/storage_exception.dart';
import 'package:flutter_specialized_temp/core/storage/secure_storage_manager.dart';
import 'package:flutter_specialized_temp/core/storage/storage_keys.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/annotations.dart';
import 'package:mockito/mockito.dart';

import 'secure_storage_manager_test.mocks.dart';

@GenerateMocks([FlutterSecureStorage])
void main() {
  late SecureStorageManager storageManager;
  late MockFlutterSecureStorage mockStorage;

  setUp(() {
    mockStorage = MockFlutterSecureStorage();
    storageManager = SecureStorageManager(mockStorage);
  });

  group('writeSecureData', () {
    test('should write data successfully', () async {
      // Arrange
      const key = 'testKey';
      const value = 'testValue';
      when(mockStorage.write(key: key, value: value))
          .thenAnswer((_) => Future.value());

      // Act
      await storageManager.writeSecureData(key, value);

      // Assert
      verify(mockStorage.write(key: key, value: value)).called(1);
    });

    test('should throw SecureStorageException when write fails', () async {
      // Arrange
      const key = 'testKey';
      const value = 'testValue';
      when(mockStorage.write(key: key, value: value))
          .thenThrow(Exception('Test error'));

      // Act & Assert
      expect(
        () => storageManager.writeSecureData(key, value),
        throwsA(isA<SecureStorageException>()),
      );
    });
  });

  group('readSecureData', () {
    test('should read data successfully', () async {
      // Arrange
      const key = 'testKey';
      const value = 'testValue';
      when(mockStorage.read(key: key)).thenAnswer((_) => Future.value(value));

      // Act
      final result = await storageManager.readSecureData(key);

      // Assert
      expect(result, equals(value));
      verify(mockStorage.read(key: key)).called(1);
    });

    test('should throw SecureStorageException when read fails', () async {
      // Arrange
      const key = 'testKey';
      when(mockStorage.read(key: key)).thenThrow(Exception('Test error'));

      // Act & Assert
      expect(
        () => storageManager.readSecureData(key),
        throwsA(isA<SecureStorageException>()),
      );
    });
  });

  group('deleteSecureData', () {
    test('should delete data successfully', () async {
      // Arrange
      const key = 'testKey';
      when(mockStorage.delete(key: key)).thenAnswer((_) => Future.value());

      // Act
      await storageManager.deleteSecureData(key);

      // Assert
      verify(mockStorage.delete(key: key)).called(1);
    });

    test('should throw SecureStorageException when delete fails', () async {
      // Arrange
      const key = 'testKey';
      when(mockStorage.delete(key: key)).thenThrow(Exception('Test error'));

      // Act & Assert
      expect(
        () => storageManager.deleteSecureData(key),
        throwsA(isA<SecureStorageException>()),
      );
    });
  });

  group('deleteAllSecureData', () {
    test('should delete all data successfully', () async {
      // Arrange
      when(mockStorage.deleteAll()).thenAnswer((_) => Future.value());

      // Act
      await storageManager.deleteAllSecureData();

      // Assert
      verify(mockStorage.deleteAll()).called(1);
    });

    test('should throw SecureStorageException when deleteAll fails', () async {
      // Arrange
      when(mockStorage.deleteAll()).thenThrow(Exception('Test error'));

      // Act & Assert
      expect(
        () => storageManager.deleteAllSecureData(),
        throwsA(isA<SecureStorageException>()),
      );
    });
  });

  group('saveAuthTokens', () {
    test('should save auth tokens successfully', () async {
      // Arrange
      const accessToken = 'testAccessToken';
      const refreshToken = 'testRefreshToken';
      
      // Setup mocks with specific values
      when(mockStorage.write(
        key: StorageKeys.authToken,
        value: accessToken,
      )).thenAnswer((_) => Future.value());
      
      when(mockStorage.write(
        key: StorageKeys.refreshToken,
        value: refreshToken,
      )).thenAnswer((_) => Future.value());

      // Act
      await storageManager.saveAuthTokens(
        accessToken: accessToken,
        refreshToken: refreshToken,
      );

      // Assert
      verify(mockStorage.write(
        key: StorageKeys.authToken,
        value: accessToken,
      )).called(1);
      verify(mockStorage.write(
        key: StorageKeys.refreshToken,
        value: refreshToken,
      )).called(1);
    });
  });

  group('getAuthTokens', () {
    test('should retrieve auth tokens successfully', () async {
      // Arrange
      const accessToken = 'testAccessToken';
      const refreshToken = 'testRefreshToken';
      when(mockStorage.read(key: StorageKeys.authToken))
          .thenAnswer((_) => Future.value(accessToken));
      when(mockStorage.read(key: StorageKeys.refreshToken))
          .thenAnswer((_) => Future.value(refreshToken));

      // Act
      final result = await storageManager.getAuthTokens();

      // Assert
      expect(result, equals({
        'accessToken': accessToken,
        'refreshToken': refreshToken,
      }));
      verify(mockStorage.read(key: StorageKeys.authToken)).called(1);
      verify(mockStorage.read(key: StorageKeys.refreshToken)).called(1);
    });

    test('should handle null tokens', () async {
      // Arrange
      when(mockStorage.read(key: StorageKeys.authToken))
          .thenAnswer((_) => Future.value(null));
      when(mockStorage.read(key: StorageKeys.refreshToken))
          .thenAnswer((_) => Future.value(null));

      // Act
      final result = await storageManager.getAuthTokens();

      // Assert
      expect(result, equals({
        'accessToken': null,
        'refreshToken': null,
      }));
    });
  });
}