import 'package:flutter_specialized_temp/features/dlt_auth/domain/entities/user_entity.dart';

abstract class AuthRepository {
  Future<UserEntity> login({required String email, required String password});

  Future<UserEntity> register({
    required String email,
    required String password,
    String? name,
    String? phone,
  });

  Future<void> logout();

  Future<UserEntity?> getCurrentUser();
}
