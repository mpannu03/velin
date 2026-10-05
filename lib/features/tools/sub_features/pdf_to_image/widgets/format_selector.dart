import 'package:material_ui/material_ui.dart';
import 'package:velin/app/theme/theme.dart';
import 'package:velin/engine/engine.dart';
import 'package:velin/features/tools/tools.dart';
import 'package:velin/shared/extensions/extensions.dart';

class FormatSelector extends StatelessWidget {
  const FormatSelector({
    super.key,
    required this.format,
    required this.onFormatChanged,
  });

  final PdfImageFormat format;
  final ValueChanged<PdfImageFormat> onFormatChanged;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        SegmentedButton<PdfImageFormat>(
          showSelectedIcon: true,
          segments: [
            for (final format in PdfImageFormat.values)
              ButtonSegment(
                value: format,
                icon: Icon(_iconFor(format), size: 18),
                label: Text(_labelFor(context, format)),
              ),
          ],
          selected: {format},
          onSelectionChanged: (selection) {
            onFormatChanged(selection.first);
          },
        ),
        const SizedBox(height: AppSpacing.sm),
        HelperText(context.l10n.toolsPdfToImageFormatHelper),
      ],
    );
  }

  String _labelFor(BuildContext context, PdfImageFormat format) {
    final l10n = context.l10n;

    return switch (format) {
      PdfImageFormat.png => l10n.toolsPdfToImageFormatPng,
      PdfImageFormat.jpeg => l10n.toolsPdfToImageFormatJpeg,
      PdfImageFormat.webp => l10n.toolsPdfToImageFormatWebp,
    };
  }

  IconData _iconFor(PdfImageFormat format) {
    return switch (format) {
      PdfImageFormat.png => Icons.image_outlined,
      PdfImageFormat.jpeg => Icons.photo_outlined,
      PdfImageFormat.webp => Icons.data_object,
    };
  }
}
