import 'package:flutter/foundation.dart';
import 'package:material_ui/material_ui.dart';

import 'app_colors.dart';
import 'app_radius.dart';
import 'app_spacing.dart';

/// Velin's Material theme.
///
/// On desktop it is tuned for mouse and keyboard: compact density, tighter
/// corners and smaller controls than Material's touch-first defaults.
/// Component styling lives here so widgets do not restyle buttons, fields
/// and dialogs one by one.
abstract final class AppTheme {
  static ThemeData light() => _build(Brightness.light);

  static ThemeData dark() => _build(Brightness.dark);

  static bool get _isDesktop => switch (defaultTargetPlatform) {
    TargetPlatform.windows ||
    TargetPlatform.linux ||
    TargetPlatform.macOS => true,
    _ => false,
  };

  static ThemeData _build(Brightness brightness) {
    final colorScheme = AppColors.scheme(brightness);

    if (!_isDesktop) {
      return ThemeData(brightness: brightness, colorScheme: colorScheme);
    }

    const controlShape = RoundedRectangleBorder(
      borderRadius: BorderRadius.all(Radius.circular(AppRadius.md)),
    );
    const surfaceShape = RoundedRectangleBorder(
      borderRadius: BorderRadius.all(Radius.circular(AppRadius.lg)),
    );
    const buttonPadding = EdgeInsets.symmetric(
      horizontal: AppSpacing.lg,
      vertical: AppSpacing.sm,
    );
    const buttonSize = Size(64, 36);

    // Floating surfaces (menus, dialogs) sit above the page: white with a
    // shadow in light mode, one step lighter than the page in dark mode.
    final floatingColor = brightness == Brightness.light
        ? colorScheme.surface
        : colorScheme.surfaceContainerHigh;

    return ThemeData(
      brightness: brightness,
      colorScheme: colorScheme,
      visualDensity: VisualDensity.compact,
      materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
      filledButtonTheme: FilledButtonThemeData(
        style: FilledButton.styleFrom(
          shape: controlShape,
          padding: buttonPadding,
          minimumSize: buttonSize,
        ),
      ),
      outlinedButtonTheme: OutlinedButtonThemeData(
        style: OutlinedButton.styleFrom(
          shape: controlShape,
          padding: buttonPadding,
          minimumSize: buttonSize,
        ),
      ),
      textButtonTheme: TextButtonThemeData(
        style: TextButton.styleFrom(
          shape: controlShape,
          padding: const EdgeInsets.symmetric(
            horizontal: AppSpacing.md,
            vertical: AppSpacing.sm,
          ),
          minimumSize: const Size(48, 36),
        ),
      ),
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          shape: controlShape,
          padding: buttonPadding,
          minimumSize: buttonSize,
        ),
      ),
      iconButtonTheme: IconButtonThemeData(
        style: IconButton.styleFrom(shape: controlShape),
      ),
      segmentedButtonTheme: SegmentedButtonThemeData(
        style: SegmentedButton.styleFrom(shape: controlShape),
      ),
      inputDecorationTheme: InputDecorationTheme(
        isDense: true,
        contentPadding: const EdgeInsets.symmetric(
          horizontal: AppSpacing.md,
          vertical: AppSpacing.sm + AppSpacing.xxs,
        ),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(AppRadius.md),
        ),
      ),
      cardTheme: const CardThemeData(
        shape: surfaceShape,
        margin: EdgeInsets.zero,
      ),
      dialogTheme: DialogThemeData(
        shape: surfaceShape,
        backgroundColor: floatingColor,
      ),
      popupMenuTheme: PopupMenuThemeData(
        shape: surfaceShape,
        color: floatingColor,
      ),
      menuTheme: MenuThemeData(
        style: MenuStyle(
          shape: const WidgetStatePropertyAll(surfaceShape),
          backgroundColor: WidgetStatePropertyAll(floatingColor),
          padding: const WidgetStatePropertyAll(
            EdgeInsets.symmetric(vertical: AppSpacing.xs),
          ),
        ),
      ),
      snackBarTheme: const SnackBarThemeData(
        behavior: SnackBarBehavior.floating,
        shape: surfaceShape,
        width: 480,
      ),
      tooltipTheme: TooltipThemeData(
        waitDuration: const Duration(milliseconds: 500),
        decoration: BoxDecoration(
          color: colorScheme.inverseSurface,
          borderRadius: BorderRadius.circular(AppRadius.sm),
        ),
        textStyle: TextStyle(color: colorScheme.onInverseSurface, fontSize: 12),
      ),
      chipTheme: const ChipThemeData(shape: controlShape),
      dividerTheme: DividerThemeData(
        color: colorScheme.outlineVariant,
        space: 1,
        thickness: 1,
      ),
      scrollbarTheme: const ScrollbarThemeData(
        thickness: WidgetStatePropertyAll(8),
        radius: Radius.circular(AppRadius.sm),
      ),
    );
  }
}
