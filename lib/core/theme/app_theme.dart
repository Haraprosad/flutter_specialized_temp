import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'app_colors.dart';

class AppTheme {
  //************** -: Light Theme Start:- ********************** */
  // Define light text theme
  static final TextTheme lightTextTheme = TextTheme(
    displayLarge: TextStyle(
        fontSize: 57.sp, fontWeight: FontWeight.bold, color: Colors.black),
    displayMedium: TextStyle(
        fontSize: 45.sp, fontWeight: FontWeight.bold, color: Colors.black),
    displaySmall: TextStyle(fontSize: 36.sp, fontWeight: FontWeight.bold),
    headlineLarge: TextStyle(fontSize: 32.sp, fontWeight: FontWeight.bold),
    headlineMedium: TextStyle(fontSize: 28.sp, fontWeight: FontWeight.w600),
    headlineSmall: TextStyle(fontSize: 24.sp, fontWeight: FontWeight.w500),
    titleLarge: TextStyle(fontSize: 22.sp, fontWeight: FontWeight.w600),
    titleMedium: TextStyle(fontSize: 20.sp, fontWeight: FontWeight.w500),
    titleSmall: TextStyle(fontSize: 18.sp, fontWeight: FontWeight.w400),
    bodyLarge: TextStyle(fontSize: 16.sp, fontWeight: FontWeight.normal),
    bodyMedium: TextStyle(fontSize: 14.sp, fontWeight: FontWeight.normal),
    bodySmall: TextStyle(fontSize: 12.sp, fontWeight: FontWeight.normal),
    labelLarge: TextStyle(fontSize: 14.sp, fontWeight: FontWeight.bold),
    labelMedium: TextStyle(fontSize: 12.sp, fontWeight: FontWeight.bold),
    labelSmall: TextStyle(fontSize: 10.sp, fontWeight: FontWeight.bold),
  );

  // Define light theme
  static final ThemeData lightTheme = ThemeData(
    useMaterial3: true,
    textTheme: lightTextTheme,
    colorScheme: ColorScheme.fromSeed(seedColor: AppColors.lightThemeSeed),
    primaryColor: AppColors.primaryLight, //override primary color explicitly
    buttonTheme: ButtonThemeData(buttonColor: Colors.blue),
  );

  //************** -: Light Theme End:- ********************** */

  // Define dark text theme
  static final TextTheme darkTextTheme = lightTextTheme.copyWith(
    displayLarge: TextStyle(
        fontSize: 57.sp, fontWeight: FontWeight.bold, color: Colors.white),
    displayMedium: TextStyle(
        fontSize: 45.sp, fontWeight: FontWeight.bold, color: Colors.white),
  );

  //Define another text theme
  //todo: add more text themes as needed

  static final ThemeData darkTheme = ThemeData(
    useMaterial3: true,
    textTheme: darkTextTheme,
    colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurple),
    primaryColor: Colors.deepPurple,
    scaffoldBackgroundColor: Colors.black,
    buttonTheme: const ButtonThemeData(buttonColor: Colors.deepPurple),
  );

  static final ThemeData customTheme = ThemeData(
    textTheme: lightTextTheme.copyWith(
      headlineLarge: TextStyle(
          fontSize: 32.sp, fontWeight: FontWeight.bold, color: Colors.orange),
    ),
    colorScheme: ColorScheme.fromSeed(seedColor: Colors.orange),
    primaryColor: Colors.orange,
    scaffoldBackgroundColor: Colors.orange.shade50,
    buttonTheme: ButtonThemeData(buttonColor: Colors.orange),
  );

  // Define button theme
  static ButtonThemeData _buttonTheme() {
    return ButtonThemeData(
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(8.0),
      ),
      buttonColor: AppColors.primaryLight, // Use primary color for buttons
      textTheme: ButtonTextTheme.primary,
    );
  }

  // Define card theme
  static CardTheme _cardTheme() {
    return CardTheme(
      elevation: 5,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
    );
  }

  // Define input decoration theme (for TextFields)
  static InputDecorationTheme _inputDecorationTheme() {
    return InputDecorationTheme(
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(10),
      ),
      contentPadding: const EdgeInsets.symmetric(vertical: 12, horizontal: 16),
    );
  }
}
