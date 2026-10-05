import 'package:material_ui/material_ui.dart';

import 'bloc/add_watermark_input.dart';

/// Parses `#RRGGBB`, falling back to the theme surface when the value is not
/// a color the engine would accept.
Color colorFromHex(String hex) {
  if (!AddWatermarkToolInput.colorHexPattern.hasMatch(hex.trim())) {
    return Colors.transparent;
  }

  final rgb = int.tryParse(hex.trim().replaceFirst('#', ''), radix: 16);

  if (rgb == null) {
    return Colors.transparent;
  }

  return Color(0xff000000 | rgb);
}

/// Picks black or white so the checkmark and eyedropper stay readable.
Color contrastColorFromHex(String hex) {
  return colorFromHex(hex).computeLuminance() > 0.5
      ? Colors.black
      : Colors.white;
}
