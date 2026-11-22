import 'package:material_ui/material_ui.dart';
import 'package:velin/app/theme/theme.dart';
import 'package:velin/engine/engine.dart';
import 'package:velin/features/tools/tools.dart';
import 'package:velin/shared/extensions/extensions.dart';

class OrientationSelector extends StatelessWidget {
  const OrientationSelector({
    super.key,
    required this.orientation,
    required this.onOrientationChanged,
  });

  final ImageToPdfOrientation orientation;
  final ValueChanged<ImageToPdfOrientation> onOrientationChanged;

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        SegmentedButton<ImageToPdfOrientation>(
          key: const ValueKey('image-to-pdf-orientation'),
          showSelectedIcon: false,
          expandedInsets: EdgeInsets.zero,
          segments: [
            ButtonSegment(
              value: ImageToPdfOrientation.auto,
              label: Text(l10n.toolsImageToPdfOrientationAuto),
            ),
            ButtonSegment(
              value: ImageToPdfOrientation.portrait,
              label: Text(l10n.toolsImageToPdfOrientationPortrait),
            ),
            ButtonSegment(
              value: ImageToPdfOrientation.landscape,
              label: Text(l10n.toolsImageToPdfOrientationLandscape),
            ),
          ],
          selected: {orientation},
          onSelectionChanged: (selection) =>
              onOrientationChanged(selection.first),
        ),
        const SizedBox(height: AppSpacing.sm),
        HelperText(l10n.toolsImageToPdfOrientationHelper),
      ],
    );
  }
}
