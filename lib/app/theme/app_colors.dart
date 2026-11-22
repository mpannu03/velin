import 'package:material_ui/material_ui.dart';

/// Velin's palette: neutral greys for every surface and text role, and a
/// single blue accent kept for primary actions, selection and focus.
///
/// Material's seeded schemes tint every surface with the seed hue; these
/// overrides keep surfaces grey so the accent stands out where it is used.
abstract final class AppColors {
  static const velinSeedColor = Color(0xFF4C6EF5);

  static ColorScheme scheme(Brightness brightness) {
    final seeded = ColorScheme.fromSeed(
      seedColor: velinSeedColor,
      brightness: brightness,
    );
    return switch (brightness) {
      Brightness.light => seeded.copyWith(
        primary: const Color(0xFF3B5BDB),
        onPrimary: const Color(0xFFFFFFFF),
        primaryContainer: const Color(0xFFE7ECFF),
        onPrimaryContainer: const Color(0xFF2A3F9E),
        secondary: const Color(0xFF52525B),
        onSecondary: const Color(0xFFFFFFFF),
        secondaryContainer: const Color(0xFFE4E4E7),
        onSecondaryContainer: const Color(0xFF18181B),
        tertiary: const Color(0xFF52525B),
        onTertiary: const Color(0xFFFFFFFF),
        tertiaryContainer: const Color(0xFFE4E4E7),
        onTertiaryContainer: const Color(0xFF18181B),
        surface: const Color(0xFFFFFFFF),
        onSurface: const Color(0xFF18181B),
        onSurfaceVariant: const Color(0xFF5F5F68),
        surfaceDim: const Color(0xFFE4E4E7),
        surfaceBright: const Color(0xFFFFFFFF),
        surfaceContainerLowest: const Color(0xFFFFFFFF),
        surfaceContainerLow: const Color(0xFFF7F7F8),
        surfaceContainer: const Color(0xFFF2F2F3),
        surfaceContainerHigh: const Color(0xFFECECEE),
        surfaceContainerHighest: const Color(0xFFE4E4E7),
        outline: const Color(0xFFA1A1AA),
        outlineVariant: const Color(0xFFE4E4E7),
        inverseSurface: const Color(0xFF27272A),
        onInverseSurface: const Color(0xFFF4F4F5),
        inversePrimary: const Color(0xFF91A7FF),
        shadow: const Color(0xFF000000),
        scrim: const Color(0xFF000000),
        surfaceTint: Colors.transparent,
      ),
      Brightness.dark => seeded.copyWith(
        primary: const Color(0xFF8099FF),
        onPrimary: const Color(0xFF0E1A4D),
        primaryContainer: const Color(0xFF26346B),
        onPrimaryContainer: const Color(0xFFDBE4FF),
        secondary: const Color(0xFFA1A1AA),
        onSecondary: const Color(0xFF18181B),
        secondaryContainer: const Color(0xFF34343A),
        onSecondaryContainer: const Color(0xFFF4F4F5),
        tertiary: const Color(0xFFA1A1AA),
        onTertiary: const Color(0xFF18181B),
        tertiaryContainer: const Color(0xFF34343A),
        onTertiaryContainer: const Color(0xFFF4F4F5),
        surface: const Color(0xFF18181B),
        onSurface: const Color(0xFFEDEDEF),
        onSurfaceVariant: const Color(0xFFA1A1AA),
        surfaceDim: const Color(0xFF131315),
        surfaceBright: const Color(0xFF34343A),
        surfaceContainerLowest: const Color(0xFF131315),
        surfaceContainerLow: const Color(0xFF1D1D20),
        surfaceContainer: const Color(0xFF222225),
        surfaceContainerHigh: const Color(0xFF28282C),
        surfaceContainerHighest: const Color(0xFF303035),
        outline: const Color(0xFF71717A),
        outlineVariant: const Color(0xFF303035),
        inverseSurface: const Color(0xFFEDEDEF),
        onInverseSurface: const Color(0xFF18181B),
        inversePrimary: const Color(0xFF3B5BDB),
        shadow: const Color(0xFF000000),
        scrim: const Color(0xFF000000),
        surfaceTint: Colors.transparent,
      ),
    };
  }
}
