import 'package:flutter_specialized_temp/features/auth/data/datasources/auth_local_datasource.dart';
import 'package:flutter_specialized_temp/features/auth/data/datasources/auth_remote_datasource.dart';
import 'package:flutter_specialized_temp/features/auth/data/models/login_request_model.dart';
import 'package:flutter_specialized_temp/features/auth/data/models/register_request_model.dart';
import 'package:flutter_specialized_temp/features/auth/domain/entities/user_entity.dart';
import 'package:flutter_specialized_temp/features/auth/domain/repositories/auth_repository.dart';
import 'package:injectable/injectable.dart';

@LazySingleton(as: AuthRepository)
class AuthRepositoryImpl implements AuthRepository {
  const AuthRepositoryImpl(this._remoteDataSource, this._localDataSource);

  final AuthRemoteDataSource _remoteDataSource;
  final AuthLocalDataSource _localDataSource;

  @override
  Future<UserEntity> login({
    required String email,
    required String password,
  }) async {
    final model = await _remoteDataSource.login(
      LoginRequestModel(email: email, password: password),
    );
    await _localDataSource.saveUser(model);
    return model.toEntity();
  }

  @override
  Future<UserEntity> register({
    required String email,
    required String password,
    String? name,
    String? phone,
  }) async {
    final model = await _remoteDataSource.register(
      RegisterRequestModel(
        email: email,
        password: password,
        name: name,
        phone: phone,
      ),
    );
    await _localDataSource.saveUser(model);
    return model.toEntity();
  }

  @override
  Future<void> logout() async {
    try {
      await _remoteDataSource.logout();
    } catch (_) {
      // Best-effort server call — clear local data regardless
    }
    await _localDataSource.clearUser();
  }

  @override
  Future<UserEntity?> getCurrentUser() async {
    final model = await _localDataSource.getCachedUser();
    return model?.toEntity();
  }
}
