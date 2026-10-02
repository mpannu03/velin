import 'package:material_ui/material_ui.dart';

class SingleFilePicker extends StatelessWidget {
  const SingleFilePicker({
    required this.onPickFile,
    this.filePath,
    super.key,
  });

  final String? filePath;
  final VoidCallback onPickFile;

  bool get hasFile => filePath != null && filePath!.isNotEmpty;

  String get fileName {
    final path = filePath!;
    return path.split(RegExp(r'[/\\]')).last;
  }

  String get directoryPath {
    final path = filePath!;
    final separator = RegExp(r'[/\\]').allMatches(path).lastOrNull;

    return separator == null
        ? ''
        : path.substring(0, separator.start);
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colors = theme.colorScheme;

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: colors.surface,
        border: Border.all(color: colors.outlineVariant),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
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
                  hasFile ? fileName : 'No file selected',
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: theme.textTheme.bodyMedium?.copyWith(
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  hasFile
                      ? directoryPath
                      : 'Choose a file to get started',
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
            icon: Icon(
              hasFile
                  ? Icons.swap_horiz
                  : Icons.folder_open_outlined,
              size: 18,
            ),
            label: Text(hasFile ? 'Replace file' : 'Choose file'),
          ),
        ],
      ),
    );
  }
}