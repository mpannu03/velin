import 'package:material_ui/material_ui.dart';

class SelectedFileItem extends StatelessWidget {
  const SelectedFileItem({
    required this.filePath,
    required this.onRemove,
    this.showPageSelection = false,
    this.pageSelection,
    this.onPageSelectionChanged,
    this.dragHandle,
    super.key,
  });

  final String filePath;
  final VoidCallback onRemove;

  final bool showPageSelection;
  final String? pageSelection;
  final ValueChanged<String>? onPageSelectionChanged;

  /// Supply ReorderableDragStartListener from the parent list.
  final Widget? dragHandle;

  String get _fileName => filePath.split(RegExp(r'[/\\]')).last;

  String get _directoryPath {
    final separator = RegExp(r'[/\\]').allMatches(filePath).lastOrNull;

    return separator == null ? '' : filePath.substring(0, separator.start);
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colors = theme.colorScheme;

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
      decoration: BoxDecoration(
        color: colors.surface,
        border: Border.all(color: colors.outlineVariant),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          if (dragHandle != null) ...[
            dragHandle!,
            const SizedBox(width: 8),
          ],
          Icon(
            Icons.picture_as_pdf_outlined,
            size: 22,
            color: colors.onSurfaceVariant,
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  _fileName,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: theme.textTheme.bodyMedium?.copyWith(
                    fontWeight: FontWeight.w600,
                  ),
                ),
                if (_directoryPath.isNotEmpty) ...[
                  const SizedBox(height: 3),
                  Text(
                    _directoryPath,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: theme.textTheme.bodySmall?.copyWith(
                      color: colors.onSurfaceVariant,
                    ),
                  ),
                ],
                if (showPageSelection) ...[
                  const SizedBox(height: 10),
                  SizedBox(
                    width: 260,
                    child: TextFormField(
                      key: ValueKey(filePath),
                      initialValue: pageSelection ?? '',
                      onChanged: onPageSelectionChanged,
                      decoration: const InputDecoration(
                        labelText: 'Pages',
                        hintText: 'e.g. 1-5, 8, last',
                        isDense: true,
                        border: OutlineInputBorder(),
                      ),
                    ),
                  ),
                ],
              ],
            ),
          ),
          const SizedBox(width: 8),
          IconButton(
            onPressed: onRemove,
            tooltip: 'Remove file',
            icon: const Icon(Icons.close),
            visualDensity: VisualDensity.compact,
          ),
        ],
      ),
    );
  }
}