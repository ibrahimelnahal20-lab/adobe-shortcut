import 'package:flutter/material.dart';
import 'app_colors.dart';
import 'app_typography.dart';

class AppTheme {
  static ThemeData getLightTheme(String language) {
    return ThemeData(
      useMaterial3: true,
      brightness: Brightness.light,
      scaffoldBackgroundColor: AppColors.lightBackground,
      colorScheme: const ColorScheme(
        brightness: Brightness.light,
        primary: AppColors.lightAccent,
        onPrimary: AppColors.lightSurface,
        secondary: AppColors.lightTextSecondary,
        onSecondary: AppColors.lightSurface,
        tertiary: AppColors.lightTextTertiary,
        onTertiary: AppColors.lightSurface,
        error: Colors.red,
        onError: AppColors.lightSurface,
        surface: AppColors.lightSurface,
        onSurface: AppColors.lightTextPrimary,
        outline: AppColors.lightBorder,
      ),
      textTheme: AppTypography.getTextTheme(AppColors.lightTextPrimary, language),
    );
  }

  static ThemeData getDarkTheme(String language) {
    return ThemeData(
      useMaterial3: true,
      brightness: Brightness.dark,
      scaffoldBackgroundColor: AppColors.darkBackground,
      colorScheme: const ColorScheme(
        brightness: Brightness.dark,
        primary: AppColors.darkAccent,
        onPrimary: AppColors.darkSurface,
        secondary: AppColors.darkTextSecondary,
        onSecondary: AppColors.darkSurface,
        tertiary: AppColors.darkTextTertiary,
        onTertiary: AppColors.darkSurface,
        error: Colors.red,
        onError: AppColors.darkSurface,
        surface: AppColors.darkSurface,
        onSurface: AppColors.darkTextPrimary,
        outline: AppColors.darkBorder,
      ),
      textTheme: AppTypography.getTextTheme(AppColors.darkTextPrimary, language),
    );
  }
}
