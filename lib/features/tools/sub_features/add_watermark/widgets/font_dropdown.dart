import 'package:material_ui/material_ui.dart';
import 'package:velin/features/tools/sub_features/sub_features.dart';
import 'package:velin/shared/extensions/extensions.dart';

class FontDropdown extends StatelessWidget {
  const FontDropdown({
    super.key,
    required this.fontName,
    required this.onFontNameChanged,
  });

  /// Null lets the engine use its default font.
  final String? fontName;
  final ValueChanged<String?> onFontNameChanged;

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;

    return DropdownButtonFormField<String?>(
      key: const ValueKey('add-watermark-font'),
      initialValue: fontName,
      isDense: true,
      decoration: InputDecoration(
        labelText: l10n.toolsWatermarkFontLabel,
        border: const OutlineInputBorder(),
      ),
      items: [
        for (final font in AddWatermarkToolInput.supportedFonts)
          DropdownMenuItem<String?>(
            value: font,
            child: Text(font ?? l10n.toolsWatermarkFontDefault),
          ),
      ],
      onChanged: onFontNameChanged,
    );
  }
}
