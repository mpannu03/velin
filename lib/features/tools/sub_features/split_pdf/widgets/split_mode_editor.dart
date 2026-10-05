import 'package:material_ui/material_ui.dart';
import 'package:velin/app/theme/theme.dart';
import 'package:velin/engine/engine.dart';
import 'package:velin/shared/extensions/extensions.dart';

import 'widgets.dart';

class SplitModeEditor extends StatelessWidget {
  const SplitModeEditor({
    super.key,
    required this.mode,
    required this.onModeChanged,
    required this.pageCount,
    required this.onPageCountChanged,
    required this.selections,
    required this.onSelectionChanged,
    required this.onAddSelection,
    required this.onRemoveSelection,
  });
  
  final SplitPdfMode mode;
  final ValueChanged<SplitPdfMode> onModeChanged;

  final String pageCount;
  final ValueChanged<String> onPageCountChanged;

  final List<String> selections;
  final void Function(int index, String value) onSelectionChanged;
  final VoidCallback onAddSelection;
  final ValueChanged<int> onRemoveSelection;

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final theme = Theme.of(context);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        SegmentedButton<SplitPdfMode>(
          showSelectedIcon: true,
          segments: [
            ButtonSegment(
              value: SplitPdfMode.byPageCount,
              icon: const Icon(Icons.numbers_outlined, size: 18),
              label: Text(l10n.toolsSplitModeByPageCount),
            ),
            ButtonSegment(
              value: SplitPdfMode.bySelection,
              icon: const Icon(Icons.tune_outlined, size: 18),
              label: Text(l10n.toolsSplitModeBySelection),
            ),
            ButtonSegment(
              value: SplitPdfMode.extractAllPages,
              icon: const Icon(Icons.content_copy_outlined, size: 18),
              label: Text(l10n.toolsSplitModeExtractAll),
            ),
          ],
          selected: {mode},
          onSelectionChanged: (selection) =>
              onModeChanged(selection.first),
        ),
        const SizedBox(height: AppSpacing.lg),
        switch (mode) {
          SplitPdfMode.byPageCount => ByPageCountEditor(
            pageCount: pageCount,
            onPageCountChanged: onPageCountChanged
          ),
          SplitPdfMode.bySelection => BySelectionEditor(
              selections: selections,
              onSelectionChanged: onSelectionChanged,
              onAddSelection: onAddSelection,
              onRemoveSelection: onRemoveSelection,
            ),
          SplitPdfMode.extractAllPages => Text(
              l10n.toolsSplitExtractAllInfo,
              style: theme.textTheme.bodyMedium?.copyWith(
                color: theme.colorScheme.onSurfaceVariant,
              ),
            ),
        },
      ],
    );
  }
}