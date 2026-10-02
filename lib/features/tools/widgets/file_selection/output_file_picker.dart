import 'package:material_ui/material_ui.dart';

import 'package:velin/app/theme/theme.dart';
import 'package:velin/shared/extensions/extensions.dart';

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

  bool get _hasDirectory =>
      directoryPath != null && directoryPath!.trim().isNotEmpty;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colors = theme.colorScheme;
    final l10n = context.l10n;

    final hasName = fileName.trim().isNotEmpty;

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
          Text(
            l10n.toolsMergeOutputSectionTitle,
            style: theme.textTheme.titleLarge?.copyWith(
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(height: AppSpacing.lg),
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                width: 44,
                height: 44,
                alignment: Alignment.center,
                decoration: BoxDecoration(
                  color: colors.primaryContainer,
                  borderRadius: BorderRadius.circular(AppRadius.md),
                ),
                child: Icon(
                  Icons.save_outlined,
                  size: 22,
                  color: colors.onPrimaryContainer,
                ),
              ),
              const SizedBox(width: AppSpacing.md),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    TextField(
                      key: const ValueKey('output-file-name'),
                      controller: TextEditingController(text: fileName),
                      onSubmitted: onFileNameChanged,
                      decoration: InputDecoration(
                        labelText: l10n.toolsMergeOutputFileNameLabel,
                        isDense: true,
                        border: const OutlineInputBorder(),
                      ),
                    ),
                    const SizedBox(height: AppSpacing.md),
                    MouseRegion(
                      cursor: SystemMouseCursors.click,
                      child: InkWell(
                        onTap: onChooseFolder,
                        borderRadius: BorderRadius.circular(AppRadius.sm),
                        child: Padding(
                          padding: const EdgeInsets.symmetric(
                            vertical: AppSpacing.xs,
                          ),
                          child: Row(
                            children: [
                              Icon(
                                _hasDirectory
                                    ? Icons.folder_outlined
                                    : Icons.folder_open_outlined,
                                size: 16,
                                color: colors.onSurfaceVariant,
                              ),
                              const SizedBox(width: AppSpacing.xs),
                              Flexible(
                                child: Text(
                                  _hasDirectory
                                      ? directoryPath!
                                      : l10n.toolsMergeChooseOutputFolder,
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                  style: theme.textTheme.bodySmall?.copyWith(
                                    color: colors.onSurfaceVariant,
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(height: AppSpacing.sm),
                    Container(
                      width: double.infinity,
                      padding: const EdgeInsets.symmetric(
                        horizontal: AppSpacing.md,
                        vertical: AppSpacing.sm,
                      ),
                      decoration: BoxDecoration(
                        color: colors.surfaceContainerHighest,
                        borderRadius: BorderRadius.circular(AppRadius.sm),
                      ),
                      child: Text(
                        _hasDirectory && hasName
                            ? l10n.toolsMergeWillSaveAs(
                                '$directoryPath/$fileName'.replaceAll(
                                  RegExp(r'[/\\\\]+'),
                                  '/',
                                ),
                              )
                            : l10n.toolsMergeOutputPathHint,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: theme.textTheme.bodySmall?.copyWith(
                          color: colors.onSurfaceVariant,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(width: AppSpacing.md),
              OutlinedButton.icon(
                onPressed: onChooseFolder,
                icon: const Icon(Icons.folder_open_outlined, size: 18),
                label: Text(l10n.toolsMergeChooseFolder),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
