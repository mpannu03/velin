import 'package:desktop_drop/desktop_drop.dart';
import 'package:material_ui/material_ui.dart';
import 'package:velin/app/commands/commands.dart';
import 'package:velin/app/theme/theme.dart';
import 'package:velin/shared/extensions/extensions.dart';

/// Opens files dropped anywhere on [child], showing a hint while files are
/// dragged over it.
///
/// The files go to [OpenFilesIntent], so unsupported ones are reported the
/// same way as any other file that cannot be opened.
class FileDropTarget extends StatefulWidget {
  const FileDropTarget({required this.child, super.key});

  final Widget child;

  @override
  State<FileDropTarget> createState() => _FileDropTargetState();
}

class _FileDropTargetState extends State<FileDropTarget> {
  bool _isDragging = false;

  void _setDragging(bool value) {
    if (_isDragging != value) setState(() => _isDragging = value);
  }

  void _onDragDone(DropDoneDetails details) {
    _setDragging(false);

    final paths = [
      for (final file in details.files)
        if (file.path.isNotEmpty) file.path,
    ];

    if (paths.isNotEmpty) {
      Actions.maybeInvoke(context, OpenFilesIntent(paths));
    }
  }

  @override
  Widget build(BuildContext context) {
    return DropTarget(
      onDragEntered: (_) => _setDragging(true),
      onDragExited: (_) => _setDragging(false),
      onDragDone: _onDragDone,
      child: Stack(
        children: [
          widget.child,
          if (_isDragging) const Positioned.fill(child: _DropHint()),
        ],
      ),
    );
  }
}

class _DropHint extends StatelessWidget {
  const _DropHint();

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return IgnorePointer(
      child: ColoredBox(
        color: colorScheme.surface.withValues(alpha: 0.85),
        child: Padding(
          padding: const EdgeInsets.all(AppSpacing.lg),
          child: DecoratedBox(
            decoration: BoxDecoration(
              border: Border.all(color: colorScheme.primary, width: 2),
              borderRadius: BorderRadius.circular(AppRadius.lg),
            ),
            child: Center(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(
                    Icons.file_download_outlined,
                    size: 48,
                    color: colorScheme.primary,
                  ),
                  const SizedBox(height: AppSpacing.sm),
                  Text(
                    context.l10n.dropFilesToOpen,
                    style: Theme.of(context).textTheme.titleMedium
                        ?.copyWith(color: colorScheme.primary),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
