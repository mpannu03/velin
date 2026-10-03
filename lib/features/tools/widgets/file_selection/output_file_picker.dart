import 'package:material_ui/material_ui.dart';

import 'package:velin/app/theme/theme.dart';
import 'package:velin/shared/extensions/extensions.dart';

class OutputFilePicker extends StatefulWidget {
  const OutputFilePicker({
    required this.directoryPath,
    required this.onChooseFolder,
    this.fileName,
    this.onFileNameChanged,
    this.showFileName = true,
    super.key,
  });

  final String? fileName;
  final String? directoryPath;
  final ValueChanged<String>? onFileNameChanged;
  final VoidCallback onChooseFolder;

  /// When false the file name field and save-as preview are hidden
  /// (used by tools that write multiple files to a folder).
  final bool showFileName;

  @override
  State<OutputFilePicker> createState() => _OutputFilePickerState();
}

class _OutputFilePickerState extends State<OutputFilePicker> {
  late final TextEditingController _fileNameController;

  @override
  void initState() {
    super.initState();
    _fileNameController = TextEditingController(text: widget.fileName ?? '');
  }

  @override
  void didUpdateWidget(covariant OutputFilePicker oldWidget) {
    super.didUpdateWidget(oldWidget);

    if (widget.fileName != oldWidget.fileName &&
        widget.fileName != _fileNameController.text) {
      _fileNameController.text = widget.fileName ?? '';
    }
  }

  @override
  void dispose() {
    _fileNameController.dispose();
    super.dispose();
  }

  bool get _hasDirectory =>
      widget.directoryPath != null && widget.directoryPath!.trim().isNotEmpty;

  String get _fileName => widget.fileName ?? '';

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colors = theme.colorScheme;
    final l10n = context.l10n;

    final showFileName = widget.showFileName;
    final hasName = _fileName.trim().isNotEmpty;

    var pathDisplay = l10n.toolsOutputPathHint;

    if (_hasDirectory) {
      if (showFileName && hasName) {
        pathDisplay = l10n.toolsWillSaveAs(
          '${widget.directoryPath}/$_fileName'.replaceAll(
            RegExp(r'[/\\\\]+'),
            '/',
          ),
        );
      } else {
        pathDisplay = widget.directoryPath!;
      }
    }

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
            l10n.toolsOutputSectionTitle,
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
                    if (showFileName) ...[
                      TextField(
                        key: const ValueKey('output-file-name'),
                        controller: _fileNameController,
                        onSubmitted: (value) =>
                            widget.onFileNameChanged?.call(value),
                        onTapOutside: (_) => 
                            widget.onFileNameChanged?.call(_fileNameController.text),
                        decoration: InputDecoration(
                          labelText: l10n.toolsOutputFileNameLabel,
                          isDense: true,
                          border: const OutlineInputBorder(),
                        ),
                      ),
                      const SizedBox(height: AppSpacing.md),
                    ],
                    MouseRegion(
                      cursor: SystemMouseCursors.click,
                      child: InkWell(
                        onTap: widget.onChooseFolder,
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
                                      ? widget.directoryPath!
                                      : l10n.toolsChooseOutputFolder,
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
                    if (showFileName) ...[
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
                          pathDisplay,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: theme.textTheme.bodySmall?.copyWith(
                            color: colors.onSurfaceVariant,
                          ),
                        ),
                      ),
                    ],
                  ],
                ),
              ),
              const SizedBox(width: AppSpacing.md),
              OutlinedButton.icon(
                onPressed: widget.onChooseFolder,
                icon: const Icon(Icons.folder_open_outlined, size: 18),
                label: Text(l10n.toolsChooseFolder),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
