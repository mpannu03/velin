import 'package:material_ui/material_ui.dart';

import 'app_colors.dart';

abstract final class AppTheme {
  static ThemeData light() {
    final colorScheme = ColorScheme.fromSeed(
      seedColor: AppColors.velinSeedColor,
      primary: AppColors.velinSeedColor,
    );
    return ThemeData(
      brightness: Brightness.light,
      colorScheme: colorScheme,
    );
  }

  static ThemeData dark() {
    final colorScheme = ColorScheme.fromSeed(
      seedColor: AppColors.velinSeedColor,
      primary: AppColors.velinSeedColor,
      brightness: Brightness.dark
    );
    return ThemeData(
      brightness: Brightness.dark,
      colorScheme: colorScheme
    );
  }
}