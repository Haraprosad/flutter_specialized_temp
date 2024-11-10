import 'package:bloc_test/bloc_test.dart';
import 'package:flutter/material.dart';
import 'package:flutter_specialized_temp/core/storage/app_storage.dart';
import 'package:flutter_specialized_temp/core/storage/preferences_manager.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:flutter_specialized_temp/core/theme/bloc/theme_bloc.dart';

class MockAppStorage extends Mock implements AppStorage {}
class MockPreferencesManager extends Mock implements PreferencesManager {}

void main() {
  late ThemeBloc themeBloc;
  late MockAppStorage mockAppStorage;
  late MockPreferencesManager mockPreferencesManager;

  setUp(() {
    mockAppStorage = MockAppStorage();
    mockPreferencesManager = MockPreferencesManager();
    when(() => mockAppStorage.preferences).thenReturn(mockPreferencesManager);
    themeBloc = ThemeBloc(mockAppStorage);
  });

  tearDown(() {
    themeBloc.close();
  });

  group('ThemeBloc', () {
    test('initial state is correct', () {
      expect(
        themeBloc.state,
        equals(const ThemeState.initial()),
      );
      expect(themeBloc.state.isDark, isFalse);
      expect(themeBloc.state.themeMode, equals(ThemeMode.light));
    });

    group('InitializeTheme', () {
      blocTest<ThemeBloc, ThemeState>(
        'emits light theme state when stored preference is false',
        setUp: () {
          when(() => mockPreferencesManager.getDarkMode())
              .thenReturn(false);
        },
        build: () => ThemeBloc(mockAppStorage),
        act: (bloc) => bloc.add(const InitializeTheme()),
        expect: () => [
          const ThemeState(
            themeMode: ThemeMode.light,
            isDark: false,
          ),
        ],
        verify: (_) {
          verify(() => mockPreferencesManager.getDarkMode()).called(1);
        },
      );

      blocTest<ThemeBloc, ThemeState>(
        'emits dark theme state when stored preference is true',
        setUp: () {
          when(() => mockPreferencesManager.getDarkMode())
              .thenReturn(true);
        },
        build: () => ThemeBloc(mockAppStorage),
        act: (bloc) => bloc.add(const InitializeTheme()),
        expect: () => [
          const ThemeState(
            themeMode: ThemeMode.dark,
            isDark: true,
          ),
        ],
        verify: (_) {
          verify(() => mockPreferencesManager.getDarkMode()).called(1);
        },
      );
    });

    group('ToggleTheme', () {
      blocTest<ThemeBloc, ThemeState>(
        'toggles from light to dark theme',
        setUp: () {
          when(() => mockPreferencesManager.setDarkMode(any()))
              .thenAnswer((_) async {});
        },
        build: () => ThemeBloc(mockAppStorage),
        seed: () => const ThemeState(
          themeMode: ThemeMode.light,
          isDark: false,
        ),
        act: (bloc) => bloc.add(const ToggleTheme()),
        expect: () => [
          const ThemeState(
            themeMode: ThemeMode.dark,
            isDark: true,
          ),
        ],
        verify: (_) {
          verify(() => mockPreferencesManager.setDarkMode(true)).called(1);
        },
      );

      blocTest<ThemeBloc, ThemeState>(
        'toggles from dark to light theme',
        setUp: () {
          when(() => mockPreferencesManager.setDarkMode(any()))
              .thenAnswer((_) async {});
        },
        build: () => ThemeBloc(mockAppStorage),
        seed: () => const ThemeState(
          themeMode: ThemeMode.dark,
          isDark: true,
        ),
        act: (bloc) => bloc.add(const ToggleTheme()),
        expect: () => [
          const ThemeState(
            themeMode: ThemeMode.light,
            isDark: false,
          ),
        ],
        verify: (_) {
          verify(() => mockPreferencesManager.setDarkMode(false)).called(1);
        },
      );

      blocTest<ThemeBloc, ThemeState>(
        'handles storage errors gracefully',
        setUp: () {
          when(() => mockPreferencesManager.setDarkMode(any()))
              .thenThrow(Exception('Storage error'));
        },
        build: () => ThemeBloc(mockAppStorage),
        act: (bloc) => bloc.add(const ToggleTheme()),
        errors: () => [isA<Exception>()],
        verify: (_) {
          verify(() => mockPreferencesManager.setDarkMode(any())).called(1);
        },
      );
    });

    group('ThemeState', () {
      test('supports value equality', () {
        expect(
          const ThemeState(themeMode: ThemeMode.light, isDark: false),
          equals(const ThemeState(themeMode: ThemeMode.light, isDark: false)),
        );
      });

      test('different states are not equal', () {
        expect(
          const ThemeState(themeMode: ThemeMode.light, isDark: false),
          isNot(equals(const ThemeState(themeMode: ThemeMode.dark, isDark: true))),
        );
      });

      test('initial state has correct values', () {
        const state = ThemeState.initial();
        expect(state.themeMode, equals(ThemeMode.light));
        expect(state.isDark, isFalse);
      });

      test('props contain all fields', () {
        expect(
          const ThemeState(themeMode: ThemeMode.light, isDark: false).props,
          equals([ThemeMode.light, false]),
        );
      });
    });
  });
}