import 'package:material_ui/material_ui.dart';

import 'package:velin/app/theme/theme.dart';
import 'package:velin/shared/extensions/extensions.dart';

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

    return Container(
      padding: const EdgeInsets.all(AppSpacing.lg),
      decoration: BoxDecoration(
        color: colors.surfaceContainerLow,
        border: Border.all(color: colors.outlineVariant),
        borderRadius: BorderRadius.circular(AppRadius.lg),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Text(
                l10n.toolsInputSectionTitle,
                style: theme.textTheme.titleLarge?.copyWith(
                  fontWeight: FontWeight.w600,
                ),
              ),
              const SizedBox(width: AppSpacing.sm),
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: AppSpacing.sm,
                  vertical: AppSpacing.xxs,
                ),
                decoration: BoxDecoration(
                  color: colors.surfaceContainerHighest,
                  borderRadius: BorderRadius.circular(999),
                ),
                child: Text(
                  l10n.toolsFileCount(filePaths.length),
                  style: theme.textTheme.labelSmall?.copyWith(
                    color: colors.onSurfaceVariant,
                  ),
                ),
              ),
              const Spacer(),
              OutlinedButton.icon(
                onPressed: onAddFiles,
                icon: const Icon(Icons.add, size: 18),
                label: Text(l10n.toolsAddFiles),
              ),
            ],
          ),
          if (isEmpty) ...[
            const SizedBox(height: AppSpacing.xl),
            Container(
              width: double.infinity,
              padding: const EdgeInsets.symmetric(
                horizontal: AppSpacing.xl,
                vertical: AppSpacing.xxl,
              ),
              decoration: BoxDecoration(
                color: colors.surfaceContainer,
                borderRadius: BorderRadius.circular(AppRadius.md),
                border: Border.all(color: colors.outlineVariant),
              ),
              child: Column(
                children: [
                  Container(
                    width: 56,
                    height: 56,
                    alignment: Alignment.center,
                    decoration: BoxDecoration(
                      color: colors.primaryContainer,
                      shape: BoxShape.circle,
                    ),
                    child: Icon(
                      Icons.picture_as_pdf_outlined,
                      size: 26,
                      color: colors.onPrimaryContainer,
                    ),
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
            const SizedBox(height: AppSpacing.lg),
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
                    pageSelection: pageSelections != null &&
                            index < pageSelections!.length
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
      ),
    );
  }
}
