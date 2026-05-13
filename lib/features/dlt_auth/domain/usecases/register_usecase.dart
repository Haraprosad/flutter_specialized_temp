import 'package:flutter_specialized_temp/features/dlt_auth/domain/entities/user_entity.dart';
import 'package:flutter_specialized_temp/features/dlt_auth/domain/repositories/auth_repository.dart';
import 'package:injectable/injectable.dart';

@injectable
class RegisterUseCase {
  const RegisterUseCase(this._repository);

  final AuthRepository _repository;

  Future<UserEntity> call({
    required String email,
    required String password,
    String? name,
    String? phone,
  }) => _repository.register(
    email: email,
    password: password,
    name: name,
    phone: phone,
  );
}
