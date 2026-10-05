import 'package:material_ui/material_ui.dart';
import 'package:velin/l10n/app_localizations.dart';

import 'package:velin/shared/extensions/extensions.dart';

class SingleFilePicker extends StatelessWidget {
  const SingleFilePicker({
    required this.onPickFile,
    this.filePath,
    this.emptyStateDescription,
    super.key,
  });

  final String? filePath;
  final VoidCallback onPickFile;

  /// Tool-specific copy shown in the empty state.
  /// Falls back to [l10n.toolsChooseFileHint] when null.
  final String? emptyStateDescription;

  bool get hasFile => filePath != null && filePath!.isNotEmpty;

  String get fileName {
    final path = filePath!;
    return path.split(RegExp(r'[/\\]')).last;
  }

  String get directoryPath {
    final path = filePath!;
    final separator = RegExp(r'[/\\]').allMatches(path).lastOrNull;

    return separator == null ? '' : path.substring(0, separator.start);
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colors = theme.colorScheme;
    final l10n = context.l10n;

    if (!hasFile) {
      return _buildEmptyState(theme, colors, l10n);
    }

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: colors.surface,
        border: Border.all(color: colors.outlineVariant),
        borderRadius: BorderRadius.circular(12),
      ),
      child: _buildFileRow(theme, colors, l10n),
    );
  }

  Widget _buildFileRow(
    ThemeData theme,
    ColorScheme colors,
    AppLocalizations l10n,
  ) {
    return Row(
      children: [
        Container(
          width: 44,
          height: 44,
          alignment: Alignment.center,
          decoration: BoxDecoration(
            color: colors.surfaceContainerHighest,
            borderRadius: BorderRadius.circular(8),
          ),
          child: Icon(
            Icons.insert_drive_file_outlined,
            size: 24,
            color: colors.onSurfaceVariant,
          ),
        ),
        const SizedBox(width: 14),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                fileName,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: theme.textTheme.bodyMedium?.copyWith(
                  fontWeight: FontWeight.w600,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                directoryPath,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: theme.textTheme.bodySmall?.copyWith(
                  color: colors.onSurfaceVariant,
                ),
              ),
            ],
          ),
        ),
        const SizedBox(width: 16),
        OutlinedButton.icon(
          onPressed: onPickFile,
          icon: const Icon(Icons.swap_horiz, size: 18),
          label: Text(l10n.toolsReplaceFile),
        ),
      ],
    );
  }

  Widget _buildEmptyState(
    ThemeData theme,
    ColorScheme colors,
    AppLocalizations l10n,
  ) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 32),
      decoration: BoxDecoration(
        color: colors.surfaceContainer,
        borderRadius: BorderRadius.circular(12),
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
          const SizedBox(height: 16),
          Text(
            l10n.toolsNoFileSelected,
            style: theme.textTheme.titleMedium?.copyWith(
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            emptyStateDescription ?? l10n.toolsChooseFileHint,
            textAlign: TextAlign.center,
            style: theme.textTheme.bodySmall?.copyWith(
              color: colors.onSurfaceVariant,
            ),
          ),
          const SizedBox(height: 20),
          FilledButton.icon(
            onPressed: onPickFile,
            icon: const Icon(Icons.add, size: 18),
            label: Text(l10n.toolsChooseFile),
          ),
        ],
      ),
    );
  }
}
