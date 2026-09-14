import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:odb_dashboard/core/theme/app_colors.dart';
import 'package:odb_dashboard/core/theme/app_spacing.dart';

class AppTheme {
  static ThemeData get dark {
    const scheme = ColorScheme.dark(
      brightness: Brightness.dark,
      surface: AppColors.surface,
      surfaceContainerHighest: AppColors.surfaceHighest,
      primary: AppColors.accent,
      onPrimary: AppColors.onPrimary,
      secondary: AppColors.rpm,
      onSecondary: AppColors.onBle,
      tertiary: AppColors.ble,
      onTertiary: AppColors.onBle,
      error: AppColors.danger,
      onError: AppColors.onDanger,
      onSurface: AppColors.onSurface,
      onSurfaceVariant: AppColors.onSurfaceMuted,
      outline: AppColors.border,
      outlineVariant: AppColors.borderBright,
    );

    const tabular = [FontFeature.tabularFigures()];

    return ThemeData(
      useMaterial3: true,
      brightness: Brightness.dark,
      colorScheme: scheme,
      scaffoldBackgroundColor: AppColors.background,
      dividerColor: AppColors.border,
      appBarTheme: const AppBarTheme(
        backgroundColor: AppColors.surface,
        foregroundColor: AppColors.onSurface,
        elevation: 0,
        centerTitle: false,
        systemOverlayStyle: SystemUiOverlayStyle.light,
        titleTextStyle: TextStyle(
          fontSize: 17,
          fontWeight: FontWeight.w600,
          letterSpacing: 0.2,
          color: AppColors.onSurface,
        ),
      ),
      switchTheme: SwitchThemeData(
        thumbColor: WidgetStateProperty.resolveWith((states) {
          if (states.contains(WidgetState.selected)) {
            return AppColors.onPrimary;
          }
          return AppColors.onSurfaceMuted;
        }),
        trackColor: WidgetStateProperty.resolveWith((states) {
          if (states.contains(WidgetState.selected)) {
            return AppColors.accent;
          }
          return AppColors.gaugeTrack;
        }),
        trackOutlineColor: WidgetStateProperty.all(AppColors.border),
      ),
      chipTheme: const ChipThemeData(
        backgroundColor: AppColors.surfaceHigh,
        side: BorderSide(color: AppColors.border),
        labelStyle: TextStyle(
          color: AppColors.onSurface,
          fontSize: 12,
          fontWeight: FontWeight.w500,
        ),
        padding: EdgeInsets.symmetric(horizontal: 8, vertical: 0),
        shape: StadiumBorder(),
      ),
      cardTheme: CardThemeData(
        color: AppColors.surface,
        elevation: 0,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(AppSpacing.radiusMd),
          side: const BorderSide(color: AppColors.border),
        ),
      ),
      navigationBarTheme: NavigationBarThemeData(
        backgroundColor: AppColors.surface,
        indicatorColor: AppColors.ledFill(AppColors.accent),
        surfaceTintColor: Colors.transparent,
        elevation: 0,
        height: 68,
        labelTextStyle: WidgetStateProperty.resolveWith((states) {
          final selected = states.contains(WidgetState.selected);
          return TextStyle(
            fontSize: 12,
            fontWeight: selected ? FontWeight.w600 : FontWeight.w500,
            letterSpacing: 0.3,
            color: selected ? AppColors.accent : AppColors.onSurfaceMuted,
          );
        }),
        iconTheme: WidgetStateProperty.resolveWith((states) {
          final selected = states.contains(WidgetState.selected);
          return IconThemeData(
            size: 24,
            color: selected ? AppColors.accent : AppColors.onSurfaceMuted,
          );
        }),
      ),
      listTileTheme: const ListTileThemeData(
        iconColor: AppColors.onSurfaceMuted,
        textColor: AppColors.onSurface,
        contentPadding: EdgeInsets.symmetric(horizontal: AppSpacing.md),
        minVerticalPadding: AppSpacing.sm,
      ),
      textTheme: const TextTheme(
        // Large instrument readout (speed / RPM center)
        displayLarge: TextStyle(
          fontSize: 52,
          fontWeight: FontWeight.w600,
          letterSpacing: -1.2,
          height: 1.05,
          color: AppColors.onSurface,
          fontFeatures: tabular,
        ),
        displayMedium: TextStyle(
          fontSize: 40,
          fontWeight: FontWeight.w600,
          letterSpacing: -0.8,
          height: 1.05,
          color: AppColors.onSurface,
          fontFeatures: tabular,
        ),
        displaySmall: TextStyle(
          fontSize: 32,
          fontWeight: FontWeight.w600,
          letterSpacing: -0.4,
          height: 1.1,
          color: AppColors.onSurface,
          fontFeatures: tabular,
        ),
        headlineMedium: TextStyle(
          fontSize: 28,
          fontWeight: FontWeight.w700,
          letterSpacing: 0.5,
          color: AppColors.onSurface,
          fontFeatures: tabular,
        ),
        headlineSmall: TextStyle(
          fontSize: 22,
          fontWeight: FontWeight.w600,
          letterSpacing: -0.2,
          color: AppColors.onSurface,
          fontFeatures: tabular,
        ),
        titleLarge: TextStyle(
          fontSize: 18,
          fontWeight: FontWeight.w600,
          color: AppColors.onSurface,
        ),
        // Section / gauge labels (uppercase-friendly)
        titleMedium: TextStyle(
          fontSize: 12,
          fontWeight: FontWeight.w600,
          letterSpacing: 1.6,
          color: AppColors.onSurfaceMuted,
        ),
        titleSmall: TextStyle(
          fontSize: 13,
          fontWeight: FontWeight.w600,
          letterSpacing: 0.2,
          color: AppColors.onSurface,
        ),
        bodyLarge: TextStyle(
          fontSize: 16,
          height: 1.35,
          color: AppColors.onSurface,
        ),
        bodyMedium: TextStyle(
          fontSize: 14,
          height: 1.4,
          color: AppColors.onSurfaceMuted,
        ),
        bodySmall: TextStyle(
          fontSize: 12,
          height: 1.35,
          color: AppColors.onSurfaceMuted,
        ),
        labelLarge: TextStyle(
          fontSize: 14,
          fontWeight: FontWeight.w600,
          letterSpacing: 0.4,
          color: AppColors.onSurface,
        ),
        labelSmall: TextStyle(
          fontSize: 11,
          fontWeight: FontWeight.w500,
          letterSpacing: 1.3,
          color: AppColors.onSurfaceMuted,
        ),
      ),
    );
  }
}
