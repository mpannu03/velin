import 'package:material_ui/material_ui.dart';
import 'package:velin/app/theme/theme.dart';
import 'package:velin/engine/engine.dart';
import 'package:velin/features/tools/widgets/widgets.dart';
import 'package:velin/shared/extensions/extensions.dart';

class PageSizeSelector extends StatelessWidget {
  const PageSizeSelector({
    super.key,
    required this.pageSize,
    required this.onPageSizeChanged,
  });

  final ImageToPdfPageSize pageSize;
  final ValueChanged<ImageToPdfPageSize> onPageSizeChanged;

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        SegmentedButton<ImageToPdfPageSize>(
          key: const ValueKey('image-to-pdf-page-size'),
          showSelectedIcon: false,
          expandedInsets: EdgeInsets.zero,
          segments: [
            ButtonSegment(
              value: ImageToPdfPageSize.auto,
              label: Text(l10n.toolsImageToPdfPageSizeAuto),
            ),
            ButtonSegment(
              value: ImageToPdfPageSize.a4,
              label: Text(l10n.toolsImageToPdfPageSizeA4),
            ),
            ButtonSegment(
              value: ImageToPdfPageSize.letter,
              label: Text(l10n.toolsImageToPdfPageSizeLetter),
            ),
          ],
          selected: {pageSize},
          onSelectionChanged: (selection) => onPageSizeChanged(selection.first),
        ),
        const SizedBox(height: AppSpacing.sm),
        HelperText(l10n.toolsImageToPdfPageSizeHelper),
      ],
    );
  }
}
