import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'app_colors.dart';

class AppTheme {
  AppTheme._();

  static final TextTheme _baseTextTheme = TextTheme(
    displayLarge: TextStyle(fontSize: 57.sp, height: 1.12, letterSpacing: -0.25),
    displayMedium: TextStyle(fontSize: 45.sp, height: 1.16, letterSpacing: 0),
    displaySmall: TextStyle(fontSize: 36.sp, height: 1.22, letterSpacing: 0),
    headlineLarge: TextStyle(fontSize: 32.sp, height: 1.25, letterSpacing: 0),
    headlineMedium: TextStyle(fontSize: 28.sp, height: 1.29, letterSpacing: 0),
    headlineSmall: TextStyle(fontSize: 24.sp, height: 1.33, letterSpacing: 0),
    titleLarge: TextStyle(fontSize: 22.sp, height: 1.27, letterSpacing: 0),
    titleMedium: TextStyle(fontSize: 16.sp, height: 1.5, letterSpacing: 0.15),
    titleSmall: TextStyle(fontSize: 14.sp, height: 1.43, letterSpacing: 0.1),
    bodyLarge: TextStyle(fontSize: 16.sp, height: 1.5, letterSpacing: 0.15),
    bodyMedium: TextStyle(fontSize: 14.sp, height: 1.43, letterSpacing: 0.25),
    bodySmall: TextStyle(fontSize: 12.sp, height: 1.33, letterSpacing: 0.4),
    labelLarge: TextStyle(fontSize: 14.sp, height: 1.43, letterSpacing: 0.1),
    labelMedium: TextStyle(fontSize: 12.sp, height: 1.33, letterSpacing: 0.5),
    labelSmall: TextStyle(fontSize: 11.sp, height: 1.45, letterSpacing: 0.5),
  );

  static ThemeData lightTheme = _createTheme(
    brightness: Brightness.light,
    seedColor: AppColors.lightThemeSeed,
    textTheme: _baseTextTheme,
    backgroundColor: AppColors.backgroundLight,
    surfaceColor: AppColors.surfaceLight,
  );

  static ThemeData darkTheme = _createTheme(
    brightness: Brightness.dark,
    seedColor: AppColors.darkThemeSeed,
    textTheme: _baseTextTheme,
    backgroundColor: AppColors.backgroundDark,
    surfaceColor: AppColors.surfaceDark,
  );

  static ThemeData _createTheme({
    required Brightness brightness,
    required Color seedColor,
    required TextTheme textTheme,
    required Color backgroundColor,
    required Color surfaceColor,
  }) {
    final colorScheme = ColorScheme.fromSeed(
      seedColor: seedColor,
      brightness: brightness,
    );

    return ThemeData(
      useMaterial3: true,
      brightness: brightness,
      colorScheme: colorScheme,
      textTheme: textTheme,
      scaffoldBackgroundColor: backgroundColor,
      
      // Component themes
      cardTheme: _buildCardTheme(colorScheme),
      elevatedButtonTheme: _buildElevatedButtonTheme(colorScheme),
      outlinedButtonTheme: _buildOutlinedButtonTheme(colorScheme),
      textButtonTheme: _buildTextButtonTheme(colorScheme),
      inputDecorationTheme: _buildInputDecorationTheme(colorScheme),
      
      // Add more component themes as needed
    );
  }

  static CardTheme _buildCardTheme(ColorScheme colorScheme) {
    return CardTheme(
      elevation: 2,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
      color: colorScheme.surface,
    );
  }

  static ElevatedButtonThemeData _buildElevatedButtonTheme(ColorScheme colorScheme) {
    return ElevatedButtonThemeData(
      style: ElevatedButton.styleFrom(
        padding: EdgeInsets.symmetric(horizontal: 24.w, vertical: 12.h),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(8),
        ),
      ),
    );
  }

  static OutlinedButtonThemeData _buildOutlinedButtonTheme(ColorScheme colorScheme) {
    return OutlinedButtonThemeData(
      style: OutlinedButton.styleFrom(
        padding: EdgeInsets.symmetric(horizontal: 24.w, vertical: 12.h),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(8),
        ),
      ),
    );
  }

  static TextButtonThemeData _buildTextButtonTheme(ColorScheme colorScheme) {
    return TextButtonThemeData(
      style: TextButton.styleFrom(
        padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 8.h),
      ),
    );
  }

  static InputDecorationTheme _buildInputDecorationTheme(ColorScheme colorScheme) {
    return InputDecorationTheme(
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(8),
      ),
      contentPadding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 12.h),
      filled: true,
      fillColor: colorScheme.surface,
    );
  }
}