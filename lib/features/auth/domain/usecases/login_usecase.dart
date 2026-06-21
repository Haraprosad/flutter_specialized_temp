import 'package:flutter_specialized_temp/features/auth/domain/entities/user_entity.dart';
import 'package:flutter_specialized_temp/features/auth/domain/repositories/auth_repository.dart';
import 'package:injectable/injectable.dart';

@injectable
class LoginUseCase {
  const LoginUseCase(this._repository);

  final AuthRepository _repository;

  Future<UserEntity> call({required String email, required String password}) =>
      _repository.login(email: email, password: password);
}
