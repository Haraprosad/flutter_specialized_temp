part of 'theme_bloc.dart';

abstract class ThemeEvent extends Equatable {
  const ThemeEvent();

  @override
  List<Object?> get props => [];
}

class InitializeTheme extends ThemeEvent {
  const InitializeTheme();
}

class ToggleTheme extends ThemeEvent {
  const ToggleTheme();
}