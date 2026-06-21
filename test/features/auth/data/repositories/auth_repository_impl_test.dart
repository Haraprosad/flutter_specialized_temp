import 'dart:convert';

import 'package:flutter_specialized_temp/features/auth/data/models/login_request_model.dart';
import 'package:flutter_specialized_temp/features/auth/data/models/register_request_model.dart';
import 'package:flutter_specialized_temp/features/auth/data/models/user_model.dart';
import 'package:flutter_specialized_temp/features/auth/data/repositories/auth_repository_impl.dart';
import 'package:flutter_specialized_temp/features/auth/domain/entities/user_entity.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';

import '../../../../helpers/mocks.dart';
import '../../../../helpers/test_helpers.dart';

void main() {
  late MockAuthRemoteDataSource mockRemote;
  late MockAuthLocalDataSource mockLocal;
  late AuthRepositoryImpl repository;

  late UserModel tUserModel;
  late UserEntity tUserEntity;

  setUpAll(() {
    registerFallbackValue(
      const LoginRequestModel(email: 'a@b.com', password: 'pass'),
    );
    registerFallbackValue(
      const RegisterRequestModel(email: 'a@b.com', password: 'pass'),
    );
    registerFallbackValue(
      const UserModel(
        id: 'x',
        email: 'x@x.com',
        accessToken: 'a',
        refreshToken: 'r',
      ),
    );
  });

  setUp(() {
    final json =
        jsonDecode(readFixture('auth_fixture.json')) as Map<String, dynamic>;
    tUserModel = UserModel.fromJson(json);
    tUserEntity = tUserModel.toEntity();

    mockRemote = MockAuthRemoteDataSource();
    mockLocal = MockAuthLocalDataSource();
    repository = AuthRepositoryImpl(mockRemote, mockLocal);
  });

  group('AuthRepositoryImpl', () {
    group('login', () {
      test('calls remote data source and saves user locally', () async {
        when(() => mockRemote.login(any())).thenAnswer((_) async => tUserModel);
        when(() => mockLocal.saveUser(any())).thenAnswer((_) async {});

        final result = await repository.login(
          email: 'test@example.com',
          password: 'password123',
        );

        expect(result, equals(tUserEntity));
        verify(() => mockRemote.login(any())).called(1);
        verify(() => mockLocal.saveUser(any())).called(1);
      });

      test('propagates exception when remote login fails', () async {
        when(() => mockRemote.login(any())).thenThrow(Exception('Auth error'));

        expect(
          () => repository.login(email: 'test@example.com', password: 'wrong'),
          throwsA(isA<Exception>()),
        );
        verifyNever(() => mockLocal.saveUser(any()));
      });
    });

    group('register', () {
      test('calls remote data source and saves user locally', () async {
        when(
          () => mockRemote.register(any()),
        ).thenAnswer((_) async => tUserModel);
        when(() => mockLocal.saveUser(any())).thenAnswer((_) async {});

        final result = await repository.register(
          email: 'new@example.com',
          password: 'pass',
          name: 'New User',
        );

        expect(result, isA<UserEntity>());
        verify(() => mockRemote.register(any())).called(1);
        verify(() => mockLocal.saveUser(any())).called(1);
      });
    });

    group('logout', () {
      test('calls remote logout and clears local data', () async {
        when(() => mockRemote.logout()).thenAnswer((_) async {});
        when(() => mockLocal.clearUser()).thenAnswer((_) async {});

        await repository.logout();

        verify(() => mockRemote.logout()).called(1);
        verify(() => mockLocal.clearUser()).called(1);
      });

      test('clears local data even when remote logout throws', () async {
        when(() => mockRemote.logout()).thenThrow(Exception('Server down'));
        when(() => mockLocal.clearUser()).thenAnswer((_) async {});

        await repository.logout();

        verify(() => mockLocal.clearUser()).called(1);
      });
    });

    group('getCurrentUser', () {
      test('returns UserEntity when cached user exists', () async {
        when(
          () => mockLocal.getCachedUser(),
        ).thenAnswer((_) async => tUserModel);

        final result = await repository.getCurrentUser();

        expect(result, equals(tUserEntity));
      });

      test('returns null when no cached user', () async {
        when(() => mockLocal.getCachedUser()).thenAnswer((_) async => null);

        final result = await repository.getCurrentUser();

        expect(result, isNull);
      });
    });
  });
}
