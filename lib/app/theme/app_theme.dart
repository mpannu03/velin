import 'package:material_ui/material_ui.dart';

import 'app_colors.dart';
import 'app_typography.dart';

abstract final class AppTheme {
  static ThemeData light() {
    return ThemeData(
      brightness: Brightness.light,
      scaffoldBackgroundColor: AppColors.lightBackground,
      colorScheme: const ColorScheme.light(
        primary: AppColors.velinAccent,
        surface: AppColors.lightSurface,
        surfaceContainerHighest: AppColors.lightSurfaceAlt,
        onSurface: AppColors.lightText,
        onSurfaceVariant: AppColors.lightTextSecondary,
      ),
      dividerColor: AppColors.lightBorder,
      textTheme: _textTheme(AppColors.lightText),
    );
  }

  static ThemeData dark() {
    return ThemeData(
      brightness: Brightness.dark,
      scaffoldBackgroundColor: AppColors.darkBackground,
      colorScheme: const ColorScheme.dark(
        primary: AppColors.velinAccent,
        surface: AppColors.darkSurface,
        surfaceContainerHighest: AppColors.darkSurfaceAlt,
        onSurface: AppColors.darkText,
        onSurfaceVariant: AppColors.darkTextSecondary,
      ),
      dividerColor: AppColors.darkBorder,
      textTheme: _textTheme(AppColors.darkText),
    );
  }

  static TextTheme _textTheme(Color color) {
    return TextTheme(
      displaySmall: AppTypography.display.copyWith(color: color),
      titleLarge: AppTypography.title.copyWith(color: color),
      bodyLarge: AppTypography.body.copyWith(color: color),
      bodyMedium: AppTypography.bodyMedium.copyWith(color: color),
      labelLarge: AppTypography.label.copyWith(color: color),
      bodySmall: AppTypography.caption.copyWith(color: color),
    );
  }
}