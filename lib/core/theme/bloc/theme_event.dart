part of 'theme_bloc.dart';

abstract class ThemeEvent extends Equatable {
  const ThemeEvent();

  @override
  List<Object> get props => [];
}

class ToggleLightTheme extends ThemeEvent {}

class ToggleDarkTheme extends ThemeEvent {}

class ToggleCustomTheme extends ThemeEvent {}
