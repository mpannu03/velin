import 'package:material_ui/material_ui.dart';

import 'package:velin/app/theme/theme.dart';
import 'package:velin/shared/extensions/extensions.dart';

import '../tool_section_card.dart';
import 'selected_file_item.dart';

class MultiFilePicker extends StatelessWidget {
  const MultiFilePicker({
    required this.filePaths,
    required this.onAddFiles,
    required this.onRemoveFile,
    required this.onReorderItem,
    required this.emptyStateDescription,
    this.pageSelections,
    this.showPageSelection = false,
    this.onPageSelectionChanged,
    super.key,
  });

  final List<String> filePaths;
  final VoidCallback onAddFiles;
  final ValueChanged<int> onRemoveFile;
  final void Function(int oldIndex, int newIndex) onReorderItem;

  /// Tool-specific copy shown in the empty state.
  final String emptyStateDescription;

  final List<String?>? pageSelections;
  final bool showPageSelection;
  final void Function(int index, String value)? onPageSelectionChanged;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colors = theme.colorScheme;
    final l10n = context.l10n;

    final isEmpty = filePaths.isEmpty;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        ToolSectionHeader(
          title: l10n.toolsInputSectionTitle,
          badge: isEmpty ? null : l10n.toolsFileCount(filePaths.length),
          // The empty state has its own button; one is enough.
          trailing: isEmpty
              ? null
              : OutlinedButton.icon(
                  onPressed: onAddFiles,
                  icon: const Icon(Icons.add, size: 18),
                  label: Text(l10n.toolsAddFiles),
                ),
        ),
        if (isEmpty) ...[
          const SizedBox(height: AppSpacing.md),
          Container(
            width: double.infinity,
            padding: const EdgeInsets.symmetric(
              horizontal: AppSpacing.xl,
              vertical: AppSpacing.xxl,
            ),
            decoration: BoxDecoration(
              color: colors.surfaceContainer,
              borderRadius: BorderRadius.circular(AppRadius.md),
            ),
            child: Column(
              children: [
                Icon(
                  Icons.picture_as_pdf_outlined,
                  size: 32,
                  color: colors.onSurfaceVariant,
                ),
                const SizedBox(height: AppSpacing.md),
                Text(
                  l10n.toolsNoFilesTitle,
                  style: theme.textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const SizedBox(height: AppSpacing.xs),
                Text(
                  emptyStateDescription,
                  textAlign: TextAlign.center,
                  style: theme.textTheme.bodySmall?.copyWith(
                    color: colors.onSurfaceVariant,
                  ),
                ),
                const SizedBox(height: AppSpacing.lg),
                FilledButton.icon(
                  onPressed: onAddFiles,
                  icon: const Icon(Icons.add, size: 18),
                  label: Text(l10n.toolsAddFiles),
                ),
              ],
            ),
          ),
        ] else ...[
          const SizedBox(height: AppSpacing.md),
          ReorderableListView.builder(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            buildDefaultDragHandles: false,
            itemCount: filePaths.length,
            onReorderItem: onReorderItem,
            itemBuilder: (context, index) {
              return Padding(
                key: ValueKey('$filePaths[$index]'),
                padding: const EdgeInsets.only(bottom: AppSpacing.sm),
                child: SelectedFileItem(
                  index: index + 1,
                  filePath: filePaths[index],
                  onRemove: () => onRemoveFile(index),
                  showPageSelection: showPageSelection,
                  pageSelection:
                      pageSelections != null && index < pageSelections!.length
                      ? pageSelections![index]
                      : null,
                  onPageSelectionChanged: onPageSelectionChanged == null
                      ? null
                      : (value) => onPageSelectionChanged!(index, value),
                  dragHandle: ReorderableDragStartListener(
                    index: index,
                    child: Icon(
                      Icons.drag_indicator,
                      color: colors.onSurfaceVariant,
                    ),
                  ),
                ),
              );
            },
          ),
        ],
      ],
    );
  }
}
