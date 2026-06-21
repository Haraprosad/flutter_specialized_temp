import 'package:flutter_specialized_temp/features/auth/data/datasources/auth_local_datasource.dart';
import 'package:flutter_specialized_temp/features/auth/data/datasources/auth_remote_datasource.dart';
import 'package:flutter_specialized_temp/features/auth/domain/repositories/auth_repository.dart';
import 'package:flutter_specialized_temp/features/auth/domain/usecases/login_usecase.dart';
import 'package:flutter_specialized_temp/features/auth/domain/usecases/logout_usecase.dart';
import 'package:flutter_specialized_temp/features/auth/domain/usecases/register_usecase.dart';
import 'package:flutter_specialized_temp/features/tasks/data/datasources/task_local_datasources.dart';
import 'package:flutter_specialized_temp/features/tasks/domain/repositories/task_repository.dart';
import 'package:mocktail/mocktail.dart';

class MockTaskRepository extends Mock implements TaskRepository {}

class MockTaskLocalDataSource extends Mock implements TaskLocalDataSource {}

class MockAuthRepository extends Mock implements AuthRepository {}

class MockAuthRemoteDataSource extends Mock implements AuthRemoteDataSource {}

class MockAuthLocalDataSource extends Mock implements AuthLocalDataSource {}

class MockLoginUseCase extends Mock implements LoginUseCase {}

class MockRegisterUseCase extends Mock implements RegisterUseCase {}

class MockLogoutUseCase extends Mock implements LogoutUseCase {}
