import 'package:bloc_test/bloc_test.dart';
import 'package:flutter_specialized_temp/core/exceptions/app_exceptions.dart';
import 'package:flutter_specialized_temp/features/dlt_auth/domain/entities/user_entity.dart';
import 'package:flutter_specialized_temp/features/dlt_auth/domain/usecases/login_usecase.dart';
import 'package:flutter_specialized_temp/features/dlt_auth/domain/usecases/logout_usecase.dart';
import 'package:flutter_specialized_temp/features/dlt_auth/domain/usecases/register_usecase.dart';
import 'package:flutter_specialized_temp/features/dlt_auth/presentation/bloc/bloc/auth_bloc.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';

import '../../../../helpers/mocks.dart';

void main() {
  late MockAuthRepository mockRepository;
  late LoginUseCase loginUseCase;
  late RegisterUseCase registerUseCase;
  late LogoutUseCase logoutUseCase;

  const tUser = UserEntity(
    id: 'user-123',
    email: 'test@example.com',
    name: 'Test User',
    accessToken: 'access-token-abc',
    refreshToken: 'refresh-token-xyz',
  );

  setUp(() {
    mockRepository = MockAuthRepository();
    loginUseCase = LoginUseCase(mockRepository);
    registerUseCase = RegisterUseCase(mockRepository);
    logoutUseCase = LogoutUseCase(mockRepository);
  });

  AuthBloc buildBloc() =>
      AuthBloc(loginUseCase, registerUseCase, logoutUseCase);

  group('AuthBloc', () {
    test('initial state is AuthInitial', () {
      final bloc = buildBloc();
      expect(bloc.state, isA<AuthInitial>());
      bloc.close();
    });

    // --- Login ---

    blocTest<AuthBloc, AuthState>(
      'emits [AuthLoading, AuthAuthenticated] on successful login',
      build: () {
        when(
          () => mockRepository.login(
            email: any(named: 'email'),
            password: any(named: 'password'),
          ),
        ).thenAnswer((_) async => tUser);
        return buildBloc();
      },
      act: (bloc) => bloc.add(
        const LoginRequested(email: 'test@example.com', password: 'pass'),
      ),
      expect: () => [isA<AuthLoading>(), isA<AuthAuthenticated>()],
    );

    blocTest<AuthBloc, AuthState>(
      'AuthAuthenticated carries the returned user',
      build: () {
        when(
          () => mockRepository.login(
            email: any(named: 'email'),
            password: any(named: 'password'),
          ),
        ).thenAnswer((_) async => tUser);
        return buildBloc();
      },
      act: (bloc) => bloc.add(
        const LoginRequested(email: 'test@example.com', password: 'pass'),
      ),
      expect: () => [isA<AuthLoading>(), const AuthAuthenticated(user: tUser)],
    );

    blocTest<AuthBloc, AuthState>(
      'emits [AuthLoading, AuthError] when login throws AppException',
      build: () {
        when(
          () => mockRepository.login(
            email: any(named: 'email'),
            password: any(named: 'password'),
          ),
        ).thenThrow(UnauthorizedException('Invalid credentials'));
        return buildBloc();
      },
      act: (bloc) => bloc.add(
        const LoginRequested(email: 'bad@email.com', password: 'wrong'),
      ),
      expect: () => [
        isA<AuthLoading>(),
        isA<AuthError>().having(
          (s) => s.message,
          'message',
          equals('Invalid credentials'),
        ),
      ],
    );

    blocTest<AuthBloc, AuthState>(
      'emits [AuthLoading, AuthError] when login throws generic exception',
      build: () {
        when(
          () => mockRepository.login(
            email: any(named: 'email'),
            password: any(named: 'password'),
          ),
        ).thenThrow(Exception('Unexpected'));
        return buildBloc();
      },
      act: (bloc) => bloc.add(
        const LoginRequested(email: 'test@example.com', password: 'pass'),
      ),
      expect: () => [isA<AuthLoading>(), isA<AuthError>()],
    );

    // --- Register ---

    blocTest<AuthBloc, AuthState>(
      'emits [AuthLoading, AuthAuthenticated] on successful register',
      build: () {
        when(
          () => mockRepository.register(
            email: any(named: 'email'),
            password: any(named: 'password'),
            name: any(named: 'name'),
            phone: any(named: 'phone'),
          ),
        ).thenAnswer((_) async => tUser);
        return buildBloc();
      },
      act: (bloc) => bloc.add(
        const RegisterRequested(
          email: 'new@example.com',
          password: 'pass',
          name: 'Test User',
        ),
      ),
      expect: () => [isA<AuthLoading>(), const AuthAuthenticated(user: tUser)],
    );

    blocTest<AuthBloc, AuthState>(
      'emits [AuthLoading, AuthError] when register throws',
      build: () {
        when(
          () => mockRepository.register(
            email: any(named: 'email'),
            password: any(named: 'password'),
            name: any(named: 'name'),
            phone: any(named: 'phone'),
          ),
        ).thenThrow(ServerException('Registration failed'));
        return buildBloc();
      },
      act: (bloc) => bloc.add(
        const RegisterRequested(email: 'new@example.com', password: 'pass'),
      ),
      expect: () => [isA<AuthLoading>(), isA<AuthError>()],
    );

    // --- Logout ---

    blocTest<AuthBloc, AuthState>(
      'emits [AuthLoading, AuthUnauthenticated] on successful logout',
      build: () {
        when(() => mockRepository.logout()).thenAnswer((_) async {});
        return buildBloc();
      },
      act: (bloc) => bloc.add(const LogoutRequested()),
      expect: () => [isA<AuthLoading>(), isA<AuthUnauthenticated>()],
    );

    blocTest<AuthBloc, AuthState>(
      'emits [AuthLoading, AuthError] when logout throws',
      build: () {
        when(
          () => mockRepository.logout(),
        ).thenThrow(NetworkException('No connection'));
        return buildBloc();
      },
      act: (bloc) => bloc.add(const LogoutRequested()),
      expect: () => [isA<AuthLoading>(), isA<AuthError>()],
    );
  });
}
