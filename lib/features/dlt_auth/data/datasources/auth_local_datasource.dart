import 'package:flutter_specialized_temp/core/storage/app_storage.dart';
import 'package:flutter_specialized_temp/features/dlt_auth/data/models/user_model.dart';
import 'package:injectable/injectable.dart';

abstract class AuthLocalDataSource {
  Future<void> saveUser(UserModel user);
  Future<UserModel?> getCachedUser();
  Future<void> clearUser();
}

@LazySingleton(as: AuthLocalDataSource)
class AuthLocalDataSourceImpl implements AuthLocalDataSource {
  const AuthLocalDataSourceImpl(this._storage);

  final AppStorage _storage;

  @override
  Future<void> saveUser(UserModel user) async {
    await _storage.secure.saveAuthTokens(
      accessToken: user.accessToken,
      refreshToken: user.refreshToken,
    );
    await _storage.preferences.setIsAuthenticated(true);
    await _storage.preferences.setUserEmail(user.email);
    await _storage.preferences.setUserId(user.id);
    if (user.role != null) {
      await _storage.preferences.setUserRole(user.role!);
    }
  }

  @override
  Future<UserModel?> getCachedUser() async {
    final isAuthenticated = _storage.preferences.getIsAuthenticated();
    if (!isAuthenticated) return null;

    final tokens = await _storage.secure.getAuthTokens();
    final accessToken = tokens['accessToken'];
    final refreshToken = tokens['refreshToken'];

    if (accessToken == null || refreshToken == null) return null;

    return UserModel(
      id: _storage.preferences.getUserId() ?? '',
      email: _storage.preferences.getUserEmail() ?? '',
      role: _storage.preferences.getUserRole(),
      accessToken: accessToken,
      refreshToken: refreshToken,
    );
  }

  @override
  Future<void> clearUser() => _storage.clearAllData();
}
