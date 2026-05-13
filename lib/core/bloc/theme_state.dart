part of 'theme_bloc.dart';

class ThemeState extends Equatable {
  final ThemeMode themeMode;
  final bool isDark;

  const ThemeState({
    required this.themeMode,
    required this.isDark,
  });

  const ThemeState.initial()
      : themeMode = ThemeMode.light,
        isDark = false;

  @override
  List<Object> get props => [themeMode, isDark];
}
