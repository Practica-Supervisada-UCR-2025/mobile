import 'package:flutter/material.dart';
import 'package:mobile/core/theme/app_colors.dart';

class AppTheme {
  static ThemeData lightTheme = ThemeData(
    useMaterial3: true,
    fontFamily: 'Poppins',
    primaryColor: AppColors.primary,
    scaffoldBackgroundColor: AppColors.background,
    textTheme: const TextTheme(
      displayLarge: TextStyle(fontWeight: FontWeight.w700),
      displayMedium: TextStyle(fontWeight: FontWeight.w600),
      displaySmall: TextStyle(fontWeight: FontWeight.w500),
      headlineLarge: TextStyle(fontWeight: FontWeight.w700),
      headlineMedium: TextStyle(fontWeight: FontWeight.w600),
      headlineSmall: TextStyle(fontWeight: FontWeight.w500),
      titleLarge: TextStyle(fontWeight: FontWeight.w700),
      titleMedium: TextStyle(fontWeight: FontWeight.w600),
      titleSmall: TextStyle(fontWeight: FontWeight.w500),
      bodyLarge: TextStyle(fontWeight: FontWeight.w400),
      bodyMedium: TextStyle(fontWeight: FontWeight.w400),
      bodySmall: TextStyle(fontWeight: FontWeight.w400),
      labelLarge: TextStyle(fontWeight: FontWeight.w500),
      labelMedium: TextStyle(fontWeight: FontWeight.w500),
      labelSmall: TextStyle(fontWeight: FontWeight.w500),
    ).apply(
      bodyColor: AppColors.textPrimary,
      displayColor: AppColors.textPrimary,
    ),
    colorScheme: ColorScheme.light(
      primary: AppColors.primary,
      secondary: AppColors.secondary,
      error: AppColors.error,
      surface: AppColors.background,
      outline: AppColors.textSecondary,
      onPrimary: AppColors.buttonBackground,
    ),
    floatingActionButtonTheme: FloatingActionButtonThemeData(
      backgroundColor: AppColors.primary,      
      foregroundColor: Colors.white,    
      elevation: 4,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
      ),
    ),
  );

  static ThemeData darkTheme = ThemeData(
    useMaterial3: true,
    fontFamily: 'Poppins',
    primaryColor: AppColors.primary,
    scaffoldBackgroundColor: Colors.black,
    textTheme: const TextTheme(
      displayLarge: TextStyle(fontWeight: FontWeight.w700),
      displayMedium: TextStyle(fontWeight: FontWeight.w600),
      displaySmall: TextStyle(fontWeight: FontWeight.w500),
      headlineLarge: TextStyle(fontWeight: FontWeight.w700),
      headlineMedium: TextStyle(fontWeight: FontWeight.w600),
      headlineSmall: TextStyle(fontWeight: FontWeight.w500),
      titleLarge: TextStyle(fontWeight: FontWeight.w700),
      titleMedium: TextStyle(fontWeight: FontWeight.w600),
      titleSmall: TextStyle(fontWeight: FontWeight.w500),
      bodyLarge: TextStyle(fontWeight: FontWeight.w400),
      bodyMedium: TextStyle(fontWeight: FontWeight.w400),
      bodySmall: TextStyle(fontWeight: FontWeight.w400),
      labelLarge: TextStyle(fontWeight: FontWeight.w500),
      labelMedium: TextStyle(fontWeight: FontWeight.w500),
      labelSmall: TextStyle(fontWeight: FontWeight.w500),
    ).apply(bodyColor: Colors.white, displayColor: Colors.white),
    colorScheme: ColorScheme.dark(
      primary: AppColors.primary,
      secondary: AppColors.secondary,
      error: AppColors.error,
      surface: AppColors.backgroundDark,
      outline: AppColors.textSecondary,
      onPrimary: AppColors.buttonBackgroundDark,
    ),
    floatingActionButtonTheme: FloatingActionButtonThemeData(
      backgroundColor: AppColors.primary,       // mismo color o uno más claro
      foregroundColor: AppColors.buttonBackground,            // para contraste en modo oscuro
      elevation: 4,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
      ),
    ),

  );
}