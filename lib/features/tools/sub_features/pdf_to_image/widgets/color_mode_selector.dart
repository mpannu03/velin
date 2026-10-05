import 'package:material_ui/material_ui.dart';
import 'package:velin/engine/engine.dart';
import 'package:velin/shared/extensions/extensions.dart';

class ColorModeSelector extends StatelessWidget {
  const ColorModeSelector({
    super.key,
    required this.colorMode,
    required this.onColorModeChanged,
  });

  final PdfImageColorMode colorMode;
  final ValueChanged<PdfImageColorMode> onColorModeChanged;

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;

    return SegmentedButton<PdfImageColorMode>(
      showSelectedIcon: true,
      segments: [
        ButtonSegment(
          value: PdfImageColorMode.color,
          icon: const Icon(Icons.palette_outlined, size: 18),
          label: Text(l10n.toolsPdfToImageColorModeColor),
        ),
        ButtonSegment(
          value: PdfImageColorMode.grayscale,
          icon: const Icon(Icons.gradient_outlined, size: 18),
          label: Text(l10n.toolsPdfToImageColorModeGreyscale),
        ),
      ],
      selected: {colorMode},
      onSelectionChanged: (selection) {
        onColorModeChanged(selection.first);
      },
    );
  }
}