import 'package:bloc_test/bloc_test.dart';
import 'package:flutter/material.dart';
import 'package:flutter_specialized_temp/core/localization/bloc/locale_bloc.dart';
import 'package:flutter_specialized_temp/core/localization/locale_constants.dart';
import 'package:flutter_specialized_temp/core/storage/app_storage.dart';
import 'package:flutter_specialized_temp/core/storage/preferences_manager.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';

class MockAppStorage extends Mock implements AppStorage {}
class MockPreferencesManager extends Mock implements PreferencesManager {}

void main() {
  late LocaleBloc localeBloc;
  late MockAppStorage mockAppStorage;
  late MockPreferencesManager mockPreferencesManager;

  setUp(() {
    mockAppStorage = MockAppStorage();
    mockPreferencesManager = MockPreferencesManager();
    
    // Set up the base stubs
    when(() => mockAppStorage.preferences).thenReturn(mockPreferencesManager);
    when(() => mockPreferencesManager.getLanguage()).thenReturn('en');
    when(() => mockPreferencesManager.setLanguage(any())).thenAnswer((_) async {});
    
    localeBloc = LocaleBloc(mockAppStorage);
  });

  tearDown(() {
    localeBloc.close();
  });

  group('LocaleBloc', () {
    test('initial state is English', () {
      expect(localeBloc.state.locale.languageCode, equals('en'));
    });

    group('InitializeLocale', () {
      blocTest<LocaleBloc, LocaleState>(
        'emits correct locale state when stored preference exists',
        setUp: () {
          when(() => mockPreferencesManager.getLanguage()).thenReturn('fr');
        },
        build: () => LocaleBloc(mockAppStorage),
        act: (bloc) => bloc.add(const InitializeLocale()),
        expect: () => [
          predicate<LocaleState>(
            (state) => state.locale.languageCode == 'fr',
            'state has fr locale',
          ),
        ],
      );
    });

    group('ChangeLocaleEvent', () {
      blocTest<LocaleBloc, LocaleState>(
        'changes locale to Bengali (supported language)',
        build: () => LocaleBloc(mockAppStorage),
        act: (bloc) => bloc.add(ChangeLocaleEvent(const Locale('bn'))),
        expect: () => [
          predicate<LocaleState>(
            (state) => state.locale.languageCode == 'bn',
            'state has bn locale',
          ),
        ],
      );

      blocTest<LocaleBloc, LocaleState>(
        'falls back to English when unsupported locale is provided',
        build: () => LocaleBloc(mockAppStorage),
        act: (bloc) => bloc.add(ChangeLocaleEvent(const Locale('fr'))),
        expect: () => [
          predicate<LocaleState>(
            (state) => state.locale.languageCode == 'en',
            'state has en locale',
          ),
        ],
      );

      blocTest<LocaleBloc, LocaleState>(
        'handles storage errors gracefully',
        setUp: () {
          when(() => mockPreferencesManager.setLanguage(any()))
              .thenThrow(Exception('Storage error'));
          when(() => mockPreferencesManager.setLanguage('en'))
              .thenAnswer((_) async {});
        },
        build: () => LocaleBloc(mockAppStorage),
        act: (bloc) => bloc.add(ChangeLocaleEvent(const Locale('bn'))),
        expect: () => [
          predicate<LocaleState>(
            (state) => state.locale.languageCode == 'en',
            'state has en locale',
          ),
        ],
      );

      blocTest<LocaleBloc, LocaleState>(
        'does not emit new state when same locale is selected',
        build: () => LocaleBloc(mockAppStorage),
        seed: () => const LocaleState(LocaleConstants.english),
        act: (bloc) => bloc.add(const ChangeLocaleEvent(LocaleConstants.english)),
        expect: () => [],
      );
    });
  });
}