import 'package:material_ui/material_ui.dart';
import 'package:velin/app/theme/theme.dart';
import 'package:velin/features/tools/widgets/widgets.dart';
import 'package:velin/shared/extensions/extensions.dart';

import '../bloc/bloc.dart';
import 'widgets.dart';

class ResolutionEditor extends StatelessWidget {
  const ResolutionEditor({
    super.key,
    required this.quality,
    required this.onQualityChanged,
    required this.supportsQuality,
    required this.dpi,
    required this.onDpiChanged,
  });

  final int quality;
  final ValueChanged<int> onQualityChanged;
  final bool supportsQuality;

  final int dpi;
  final ValueChanged<int> onDpiChanged;

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Text(l10n.toolsPdfToImageDpiLabel),
            const SizedBox(width: AppSpacing.md),
            DropdownButton<int>(
              key: const ValueKey('pdf-to-image-dpi'),
              value: dpi,
              onChanged: (value) {
                if (value != null) {
                  onDpiChanged(value);
                }
              },
              items: [
                for (final dpi in PdfToImageToolInput.supportedDpi)
                  DropdownMenuItem(
                    value: dpi,
                    child: Text('$dpi DPI'),
                  ),
              ],
            ),
          ],
        ),
        const SizedBox(height: AppSpacing.sm),
        HelperText(l10n.toolsPdfToImageDpiHelper),
        const SizedBox(height: AppSpacing.lg),
        ImageQualityEditor(
          quality: quality,
          onQualityChanged: onQualityChanged,
          supportsQuality: supportsQuality,
        ),
      ],
    );
  }
}