import 'package:flutter_specialized_temp/core/exceptions/app_exceptions.dart';
import 'package:flutter_specialized_temp/features/auth/domain/usecases/logout_usecase.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';

import '../../../../helpers/mocks.dart';

void main() {
  late MockAuthRepository mockRepository;
  late LogoutUseCase useCase;

  setUp(() {
    mockRepository = MockAuthRepository();
    useCase = LogoutUseCase(mockRepository);
  });

  group('LogoutUseCase', () {
    test('completes without error on successful logout', () async {
      when(() => mockRepository.logout()).thenAnswer((_) async {});

      await expectLater(useCase(), completes);

      verify(() => mockRepository.logout()).called(1);
      verifyNoMoreInteractions(mockRepository);
    });

    test('calls repository logout exactly once', () async {
      when(() => mockRepository.logout()).thenAnswer((_) async {});

      await useCase();

      verify(() => mockRepository.logout()).called(1);
    });

    test('propagates NetworkException when remote logout fails', () async {
      when(
        () => mockRepository.logout(),
      ).thenThrow(NetworkException('No connection'));

      expect(() => useCase(), throwsA(isA<NetworkException>()));
    });
  });
}
