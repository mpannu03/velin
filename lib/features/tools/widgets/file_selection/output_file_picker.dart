import 'package:material_ui/material_ui.dart';

import 'package:velin/app/theme/theme.dart';
import 'package:velin/features/tools/widgets/widgets.dart';
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

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colors = theme.colorScheme;
    final l10n = context.l10n;

    return ToolSectionCard(
      title: l10n.toolsOutputSectionTitle,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          if (widget.showFileName) ...[
            TextField(
              key: const ValueKey('output-file-name'),
              controller: _fileNameController,
              onSubmitted: (value) => widget.onFileNameChanged?.call(value),
              onTapOutside: (_) =>
                  widget.onFileNameChanged?.call(_fileNameController.text),
              decoration: InputDecoration(
                labelText: l10n.toolsOutputFileNameLabel,
              ),
            ),
            const SizedBox(height: AppSpacing.sm),
          ],
          // The folder, with a button to change it; the whole row opens
          // the folder picker.
          Material(
            color: colors.surfaceContainer,
            borderRadius: BorderRadius.circular(AppRadius.md),
            clipBehavior: Clip.antiAlias,
            child: InkWell(
              key: const ValueKey('output-directory-row'),
              onTap: widget.onChooseFolder,
              child: Padding(
                padding: const EdgeInsets.only(
                  left: AppSpacing.md,
                  right: AppSpacing.xs,
                ),
                child: Row(
                  children: [
                    Icon(
                      Icons.folder_outlined,
                      size: 16,
                      color: colors.onSurfaceVariant,
                    ),
                    const SizedBox(width: AppSpacing.sm),
                    Expanded(
                      child: Tooltip(
                        message: _hasDirectory ? widget.directoryPath! : '',
                        child: Text(
                          _hasDirectory
                              ? widget.directoryPath!
                              : l10n.toolsChooseOutputFolder,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: theme.textTheme.bodySmall?.copyWith(
                            color: _hasDirectory
                                ? colors.onSurface
                                : colors.onSurfaceVariant,
                          ),
                        ),
                      ),
                    ),
                    TextButton(
                      onPressed: widget.onChooseFolder,
                      child: Text(l10n.toolsChooseFolder),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
