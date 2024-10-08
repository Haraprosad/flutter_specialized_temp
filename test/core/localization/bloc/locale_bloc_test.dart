import 'package:bloc_test/bloc_test.dart';
import 'package:flutter/material.dart';
import 'package:flutter_specialized_temp/core/localization/bloc/locale_bloc.dart';
import 'package:flutter_specialized_temp/core/localization/locale_constants.dart';
import 'package:flutter_test/flutter_test.dart';
// Adjust the import according to your project structure

void main() {
  group('LocaleBloc', () {
    late LocaleBloc localeBloc;

    setUp(() {
      localeBloc = LocaleBloc();
    });

    tearDown(() {
      localeBloc.close();
    });

    test('initial state is LocaleState(Locale(\'en\'))', () {
      expect(localeBloc.state, const LocaleState(Locale('en')));
    });

    blocTest<LocaleBloc, LocaleState>(
      'emits [LocaleState(Locale(\'bn\'))] when ChangeLocaleEvent is added',
      build: () => localeBloc,
      act: (bloc) => bloc.add(const ChangeLocaleEvent(Locale('bn'))),
      expect: () => [const LocaleState(Locale('bn'))],
    );

    blocTest<LocaleBloc, LocaleState>(
      'emits fallback state LocaleState(LocaleConstants.english) on error',
      build: () => localeBloc,
      act: (bloc) {
        // Simulate an error by dispatching an invalid event or causing an exception
        bloc.add(const ChangeLocaleEvent(Locale('invalid')));
      },
      expect: () => [const LocaleState(LocaleConstants.english)],
    );
  });
}