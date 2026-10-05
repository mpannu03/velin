import 'package:material_ui/material_ui.dart';
import 'package:velin/app/theme/theme.dart';
import 'package:velin/engine/engine.dart';
import 'package:velin/features/tools/tools.dart';
import 'package:velin/shared/extensions/extensions.dart';

class FitSelector extends StatelessWidget {
  const FitSelector({super.key, required this.fit, required this.onFitChanged});

  final ImageToPdfFit fit;
  final ValueChanged<ImageToPdfFit> onFitChanged;

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        SegmentedButton<ImageToPdfFit>(
          key: const ValueKey('image-to-pdf-fit'),
          showSelectedIcon: true,
          segments: [
            ButtonSegment(
              value: ImageToPdfFit.contain,
              icon: const Icon(Icons.fit_screen_outlined, size: 18),
              label: Text(l10n.toolsImageToPdfFitContain),
            ),
            ButtonSegment(
              value: ImageToPdfFit.cover,
              icon: const Icon(Icons.crop_free_outlined, size: 18),
              label: Text(l10n.toolsImageToPdfFitCover),
            ),
            ButtonSegment(
              value: ImageToPdfFit.stretch,
              icon: const Icon(Icons.open_in_full_outlined, size: 18),
              label: Text(l10n.toolsImageToPdfFitStretch),
            ),
          ],
          selected: {fit},
          onSelectionChanged: (selection) => onFitChanged(selection.first),
        ),
        const SizedBox(height: AppSpacing.sm),
        HelperText(l10n.toolsImageToPdfFitHelper),
      ],
    );
  }
}
