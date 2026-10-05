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
          showSelectedIcon: true,
          segments: [
            ButtonSegment(
              value: ImageToPdfPageSize.auto,
              icon: const Icon(
                Icons.photo_size_select_actual_outlined,
                size: 18,
              ),
              label: Text(l10n.toolsImageToPdfPageSizeAuto),
            ),
            ButtonSegment(
              value: ImageToPdfPageSize.a4,
              icon: const Icon(Icons.description_outlined, size: 18),
              label: Text(l10n.toolsImageToPdfPageSizeA4),
            ),
            ButtonSegment(
              value: ImageToPdfPageSize.letter,
              icon: const Icon(Icons.description_outlined, size: 18),
              label: Text(l10n.toolsImageToPdfPageSizeLetter),
            ),
          ],
          selected: {pageSize},
          onSelectionChanged: (selection) =>
              onPageSizeChanged(selection.first),
        ),
        const SizedBox(height: AppSpacing.sm),
        HelperText(l10n.toolsImageToPdfPageSizeHelper),
      ],
    );
  }
}