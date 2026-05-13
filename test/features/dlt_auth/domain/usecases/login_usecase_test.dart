import 'package:flutter_specialized_temp/core/exceptions/app_exceptions.dart';
import 'package:flutter_specialized_temp/features/dlt_auth/domain/entities/user_entity.dart';
import 'package:flutter_specialized_temp/features/dlt_auth/domain/usecases/login_usecase.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';

import '../../../../helpers/mocks.dart';

void main() {
  late MockAuthRepository mockRepository;
  late LoginUseCase useCase;

  const tUser = UserEntity(
    id: 'user-123',
    email: 'test@example.com',
    name: 'Test User',
    accessToken: 'access-token-abc',
    refreshToken: 'refresh-token-xyz',
  );

  setUp(() {
    mockRepository = MockAuthRepository();
    useCase = LoginUseCase(mockRepository);
  });

  group('LoginUseCase', () {
    test('returns UserEntity from repository on success', () async {
      when(
        () => mockRepository.login(
          email: 'test@example.com',
          password: 'password123',
        ),
      ).thenAnswer((_) async => tUser);

      final result = await useCase(
        email: 'test@example.com',
        password: 'password123',
      );

      expect(result, equals(tUser));
      verify(
        () => mockRepository.login(
          email: 'test@example.com',
          password: 'password123',
        ),
      ).called(1);
      verifyNoMoreInteractions(mockRepository);
    });

    test('propagates UnauthorizedException on invalid credentials', () async {
      when(
        () => mockRepository.login(
          email: any(named: 'email'),
          password: any(named: 'password'),
        ),
      ).thenThrow(UnauthorizedException('Invalid credentials'));

      expect(
        () => useCase(email: 'wrong@email.com', password: 'bad'),
        throwsA(isA<UnauthorizedException>()),
      );
    });

    test('propagates NetworkException on network failure', () async {
      when(
        () => mockRepository.login(
          email: any(named: 'email'),
          password: any(named: 'password'),
        ),
      ).thenThrow(NetworkException('No connection'));

      expect(
        () => useCase(email: 'test@example.com', password: 'pass'),
        throwsA(isA<NetworkException>()),
      );
    });

    test('delegates credentials to repository without modification', () async {
      const email = 'user@test.com';
      const password = 'P@ssw0rd!';

      when(
        () => mockRepository.login(email: email, password: password),
      ).thenAnswer((_) async => tUser);

      await useCase(email: email, password: password);

      verify(
        () => mockRepository.login(email: email, password: password),
      ).called(1);
    });
  });
}
