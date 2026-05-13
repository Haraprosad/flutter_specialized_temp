import 'package:flutter_specialized_temp/core/exceptions/app_exceptions.dart';
import 'package:flutter_specialized_temp/features/dlt_auth/domain/entities/user_entity.dart';
import 'package:flutter_specialized_temp/features/dlt_auth/domain/usecases/register_usecase.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';

import '../../../../helpers/mocks.dart';

void main() {
  late MockAuthRepository mockRepository;
  late RegisterUseCase useCase;

  const tUser = UserEntity(
    id: 'user-456',
    email: 'new@example.com',
    name: 'New User',
    phone: '+1234567890',
    accessToken: 'access-new',
    refreshToken: 'refresh-new',
  );

  setUp(() {
    mockRepository = MockAuthRepository();
    useCase = RegisterUseCase(mockRepository);
  });

  group('RegisterUseCase', () {
    test(
      'returns UserEntity from repository on successful registration',
      () async {
        when(
          () => mockRepository.register(
            email: 'new@example.com',
            password: 'Password1!',
            name: 'New User',
            phone: '+1234567890',
          ),
        ).thenAnswer((_) async => tUser);

        final result = await useCase(
          email: 'new@example.com',
          password: 'Password1!',
          name: 'New User',
          phone: '+1234567890',
        );

        expect(result, equals(tUser));
        verify(
          () => mockRepository.register(
            email: 'new@example.com',
            password: 'Password1!',
            name: 'New User',
            phone: '+1234567890',
          ),
        ).called(1);
      },
    );

    test('registers without optional name and phone fields', () async {
      when(
        () =>
            mockRepository.register(email: 'min@example.com', password: 'pass'),
      ).thenAnswer((_) async => tUser);

      final result = await useCase(email: 'min@example.com', password: 'pass');

      expect(result, isA<UserEntity>());
    });

    test('propagates ValidationException on invalid input', () async {
      when(
        () => mockRepository.register(
          email: any(named: 'email'),
          password: any(named: 'password'),
          name: any(named: 'name'),
          phone: any(named: 'phone'),
        ),
      ).thenThrow(
        ValidationException(
          'Validation failed',
          fieldErrors: {
            'email': ['Already taken'],
          },
        ),
      );

      expect(
        () => useCase(email: 'taken@email.com', password: 'pass'),
        throwsA(isA<ValidationException>()),
      );
    });

    test('propagates ServerException on server error', () async {
      when(
        () => mockRepository.register(
          email: any(named: 'email'),
          password: any(named: 'password'),
          name: any(named: 'name'),
          phone: any(named: 'phone'),
        ),
      ).thenThrow(ServerException('Internal server error'));

      expect(
        () => useCase(email: 'test@example.com', password: 'pass'),
        throwsA(isA<ServerException>()),
      );
    });
  });
}
