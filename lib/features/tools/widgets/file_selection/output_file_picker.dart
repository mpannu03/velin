import 'package:material_ui/material_ui.dart';

class OutputFilePicker extends StatelessWidget {
  const OutputFilePicker({
    required this.fileName,
    required this.directoryPath,
    required this.onFileNameChanged,
    required this.onChooseFolder,
    super.key,
  });

  final String fileName;
  final String? directoryPath;
  final ValueChanged<String> onFileNameChanged;
  final VoidCallback onChooseFolder;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colors = theme.colorScheme;
    final hasDirectory =
        directoryPath != null && directoryPath!.isNotEmpty;

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: colors.surface,
        border: Border.all(color: colors.outlineVariant),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Output',
            style: theme.textTheme.titleMedium,
          ),
          const SizedBox(height: 16),
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
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
                  Icons.save_outlined,
                  size: 24,
                  color: colors.onSurfaceVariant,
                ),
              ),
              const SizedBox(width: 14),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    TextField(
                      key: const ValueKey('output-file-name'),
                      controller: TextEditingController(text: fileName),
                      onChanged: onFileNameChanged,
                      decoration: const InputDecoration(
                        labelText: 'File name',
                        isDense: true,
                        border: OutlineInputBorder(),
                      ),
                    ),
                    const SizedBox(height: 8),
                    Row(
                      children: [
                        Icon(
                          Icons.folder_outlined,
                          size: 16,
                          color: colors.onSurfaceVariant,
                        ),
                        const SizedBox(width: 6),
                        Expanded(
                          child: Text(
                            hasDirectory
                                ? directoryPath!
                                : 'Choose an output folder',
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: theme.textTheme.bodySmall?.copyWith(
                              color: colors.onSurfaceVariant,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 16),
              OutlinedButton.icon(
                onPressed: onChooseFolder,
                icon: const Icon(
                  Icons.folder_open_outlined,
                  size: 18,
                ),
                label: const Text('Choose folder'),
              ),
            ],
          ),
        ],
      ),
    );
  }
}