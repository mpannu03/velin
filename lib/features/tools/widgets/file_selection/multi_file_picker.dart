import 'package:material_ui/material_ui.dart';

import 'selected_file_item.dart';

class MultiFilePicker extends StatelessWidget {
  const MultiFilePicker({
    required this.filePaths,
    required this.onAddFiles,
    required this.onRemoveFile,
    required this.onReorderItem,
    this.pageSelections,
    this.showPageSelection = false,
    this.onPageSelectionChanged,
    super.key,
  });

  final List<String> filePaths;
  final VoidCallback onAddFiles;
  final ValueChanged<int> onRemoveFile;
  final void Function(int oldIndex, int newIndex) onReorderItem;

  final List<String?>? pageSelections;
  final bool showPageSelection;
  final void Function(int index, String value)? onPageSelectionChanged;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colors = theme.colorScheme;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Text(
              'Input files',
              style: theme.textTheme.titleMedium,
            ),
            const SizedBox(width: 8),
            Text(
              '${filePaths.length}',
              style: theme.textTheme.bodySmall?.copyWith(
                color: colors.onSurfaceVariant,
              ),
            ),
            const Spacer(),
            OutlinedButton.icon(
              onPressed: onAddFiles,
              icon: const Icon(Icons.add, size: 18),
              label: const Text('Add files'),
            ),
          ],
        ),
        const SizedBox(height: 12),
        if (filePaths.isEmpty)
          Container(
            width: double.infinity,
            padding: const EdgeInsets.symmetric(
              horizontal: 24,
              vertical: 32,
            ),
            decoration: BoxDecoration(
              border: Border.all(color: colors.outlineVariant),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Column(
              children: [
                Icon(
                  Icons.picture_as_pdf_outlined,
                  size: 32,
                  color: colors.onSurfaceVariant,
                ),
                const SizedBox(height: 8),
                Text(
                  'No files added',
                  style: theme.textTheme.bodyMedium,
                ),
                const SizedBox(height: 4),
                Text(
                  'Add PDF files to get started.',
                  style: theme.textTheme.bodySmall?.copyWith(
                    color: colors.onSurfaceVariant,
                  ),
                ),
              ],
            ),
          )
        else
          ReorderableListView.builder(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            buildDefaultDragHandles: false,
            itemCount: filePaths.length,
            onReorderItem: onReorderItem,
            itemBuilder: (context, index) {
              return Padding(
                key: ValueKey(filePaths[index]),
                padding: const EdgeInsets.only(bottom: 8),
                child: SelectedFileItem(
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
    );
  }
}