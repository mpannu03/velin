import 'package:material_ui/material_ui.dart';

import 'package:velin/app/theme/theme.dart';
import 'package:velin/shared/extensions/extensions.dart';

class SelectedFileItem extends StatelessWidget {
  const SelectedFileItem({
    required this.filePath,
    required this.onRemove,
    this.showPageSelection = false,
    this.pageSelection,
    this.onPageSelectionChanged,
    this.dragHandle,
    this.index,
    super.key,
  });

  final String filePath;
  final VoidCallback onRemove;

  final bool showPageSelection;
  final String? pageSelection;
  final ValueChanged<String>? onPageSelectionChanged;

  /// Supply ReorderableDragStartListener from the parent list.
  final Widget? dragHandle;

  /// Optional 1-based position shown as an order badge.
  final int? index;

  String get _fileName => filePath.split(RegExp(r'[/\\\\]')).last;

  String get _directoryPath {
    final separator = RegExp(r'[/\\\\]').allMatches(filePath).lastOrNull;

    return separator == null ? '' : filePath.substring(0, separator.start);
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colors = theme.colorScheme;
    final l10n = context.l10n;

    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: AppSpacing.md,
        vertical: AppSpacing.sm,
      ),
      decoration: BoxDecoration(
        color: colors.surfaceContainerLow,
        border: Border.all(color: colors.outlineVariant),
        borderRadius: BorderRadius.circular(AppRadius.md),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          if (index != null) ...[
            Container(
              alignment: Alignment.center,
              width: 24,
              height: 24,
              decoration: BoxDecoration(
                color: colors.secondaryContainer,
                shape: BoxShape.circle,
              ),
              child: Text(
                '$index',
                style: theme.textTheme.labelSmall?.copyWith(
                  color: colors.onSecondaryContainer,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
            const SizedBox(width: AppSpacing.sm),
          ],
          if (dragHandle != null) ...[
            dragHandle!,
            const SizedBox(width: AppSpacing.xs),
          ],
          Container(
            width: 36,
            height: 36,
            alignment: Alignment.center,
            decoration: BoxDecoration(
              color: colors.primaryContainer,
              borderRadius: BorderRadius.circular(AppRadius.sm),
            ),
            child: Icon(
              Icons.picture_as_pdf_outlined,
              size: 20,
              color: colors.onPrimaryContainer,
            ),
          ),
          const SizedBox(width: AppSpacing.md),
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
                  const SizedBox(height: AppSpacing.sm),
                  TextFormField(
                    key: ValueKey('pages-$filePath'),
                    initialValue: pageSelection ?? '',
                    onFieldSubmitted: onPageSelectionChanged,
                    onTapOutside: (_) => onPageSelectionChanged?.call(pageSelection ?? ''),
                    decoration: InputDecoration(
                      labelText: l10n.toolsPagesLabel,
                      hintText: l10n.toolsPagesHint,
                      isDense: true,
                      border: const OutlineInputBorder(),
                    ),
                  ),
                ],
              ],
            ),
          ),
          const SizedBox(width: AppSpacing.xs),
          IconButton(
            onPressed: onRemove,
            tooltip: l10n.toolsRemoveFile,
            icon: const Icon(Icons.close),
            visualDensity: VisualDensity.compact,
          ),
        ],
      ),
    );
  }
}
