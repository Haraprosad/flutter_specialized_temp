// theme_bloc.dart
import 'package:bloc/bloc.dart';
import 'package:equatable/equatable.dart';
import 'package:flutter/material.dart';
import 'package:flutter_specialized_temp/core/storage/app_storage.dart';
import 'package:injectable/injectable.dart';

part 'theme_event.dart';
part 'theme_state.dart';

@singleton
class ThemeBloc extends Bloc<ThemeEvent, ThemeState> {
  final AppStorage _storage;

  ThemeBloc(this._storage) : super(const ThemeState.initial()) {
    on<InitializeTheme>(_onInitializeTheme);
    on<ToggleTheme>(_onToggleTheme);
  }

  Future<void> _onInitializeTheme(
    InitializeTheme event,
    Emitter<ThemeState> emit,
  ) async {
    final isDarkMode = _storage.preferences.getDarkMode();
    emit(ThemeState(
      themeMode: isDarkMode ? ThemeMode.dark : ThemeMode.light,
      isDark: isDarkMode,
    ));
  }

  Future<void> _onToggleTheme(
    ToggleTheme event,
    Emitter<ThemeState> emit,
  ) async {
    final newIsDark = !state.isDark;
    await _storage.preferences.setDarkMode(newIsDark);
    emit(ThemeState(
      themeMode: newIsDark ? ThemeMode.dark : ThemeMode.light,
      isDark: newIsDark,
    ));
  }
}
