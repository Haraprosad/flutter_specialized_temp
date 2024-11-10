import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:flutter_specialized_temp/core/exceptions/storage_exception.dart';
import 'package:flutter_specialized_temp/core/storage/storage_keys.dart';
import 'package:injectable/injectable.dart';

@lazySingleton
class SecureStorageManager {
  final FlutterSecureStorage _storage;

  SecureStorageManager(this._storage);

  Future<void> writeSecureData(String key, String value) async {
    try {
      await _storage.write(key: key, value: value);
    } catch (e) {
      throw SecureStorageException('Failed to write secure data for key "$key": $e');
    }
  }

  Future<String?> readSecureData(String key) async {
    try {
      return await _storage.read(key: key);
    } catch (e) {
      throw SecureStorageException('Failed to read secure data for key "$key": $e');
    }
  }

  Future<void> deleteSecureData(String key) async {
    try {
      await _storage.delete(key: key);
    } catch (e) {
      throw SecureStorageException('Failed to delete secure data for key "$key": $e');
    }
  }

  Future<void> deleteAllSecureData() async {
    try {
      await _storage.deleteAll();
    } catch (e) {
      throw SecureStorageException('Failed to delete all secure data: $e');
    }
  }

  // Specialized methods for storing and retrieving authentication tokens
  Future<void> saveAuthTokens({
    required String accessToken,
    required String refreshToken,
  }) async {
    await writeSecureData(StorageKeys.authToken, accessToken);
    await writeSecureData(StorageKeys.refreshToken, refreshToken);
  }

  Future<Map<String, String?>> getAuthTokens() async {
    return {
      'accessToken': await readSecureData(StorageKeys.authToken),
      'refreshToken': await readSecureData(StorageKeys.refreshToken),
    };
  }
}
