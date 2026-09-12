import 'package:flutter/material.dart';
import 'package:odb_dashboard/core/theme/app_colors.dart';

class AppTheme {
  static ThemeData get dark {
    const scheme = ColorScheme.dark(
      surface: AppColors.surface,
      primary: AppColors.accent,
      onPrimary: AppColors.background,
      secondary: AppColors.rpm,
      error: AppColors.danger,
      onSurface: AppColors.speed,
    );

    return ThemeData(
      useMaterial3: true,
      brightness: Brightness.dark,
      colorScheme: scheme,
      scaffoldBackgroundColor: AppColors.background,
      appBarTheme: const AppBarTheme(
        backgroundColor: AppColors.surface,
        foregroundColor: AppColors.speed,
        elevation: 0,
        centerTitle: false,
      ),
      chipTheme: const ChipThemeData(
        backgroundColor: AppColors.surfaceHigh,
        side: BorderSide(color: AppColors.border),
        labelStyle: TextStyle(color: AppColors.speed, fontSize: 12),
        padding: EdgeInsets.symmetric(horizontal: 8, vertical: 0),
      ),
      cardTheme: CardThemeData(
        color: AppColors.surface,
        elevation: 0,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
          side: const BorderSide(color: AppColors.border),
        ),
      ),
      textTheme: const TextTheme(
        displayLarge: TextStyle(
          fontSize: 48,
          fontWeight: FontWeight.w600,
          letterSpacing: -1,
          color: AppColors.speed,
        ),
        displayMedium: TextStyle(
          fontSize: 36,
          fontWeight: FontWeight.w600,
          letterSpacing: -0.5,
          color: AppColors.speed,
        ),
        titleMedium: TextStyle(
          fontSize: 13,
          fontWeight: FontWeight.w500,
          letterSpacing: 1.4,
          color: AppColors.muted,
        ),
        bodyLarge: TextStyle(fontSize: 16, color: AppColors.speed),
        bodyMedium: TextStyle(fontSize: 14, color: AppColors.muted),
        labelSmall: TextStyle(
          fontSize: 11,
          letterSpacing: 1.2,
          color: AppColors.muted,
        ),
      ),
    );
  }
}
