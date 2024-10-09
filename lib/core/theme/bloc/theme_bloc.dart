import 'package:bloc/bloc.dart';
import 'package:equatable/equatable.dart';
import 'package:flutter/material.dart';
import 'package:flutter_specialized_temp/core/theme/app_theme.dart';

part 'theme_event.dart';
part 'theme_state.dart';

class ThemeBloc extends Bloc<ThemeEvent, ThemeState> {
  ThemeBloc() : super(LightThemeState()) {
    on<ToggleLightTheme>((event, emit) {
      print("Toggling Light Theme");
      emit(LightThemeState());
    });
    on<ToggleDarkTheme>((event, emit) {
      print("Toggling Dark Theme");
      emit(DarkThemeState());
    });
    on<ToggleCustomTheme>((event, emit) {
      print("Toggling Custom Theme");
      emit(CustomThemeState());
    });
  }
}
