part of 'theme_bloc.dart';

class ThemeState extends Equatable {
  const ThemeState({required this.themeMode, required this.isDark});

  const ThemeState.initial() : themeMode = ThemeMode.light, isDark = false;
  final ThemeMode themeMode;
  final bool isDark;

  @override
  List<Object> get props => [themeMode, isDark];
}
