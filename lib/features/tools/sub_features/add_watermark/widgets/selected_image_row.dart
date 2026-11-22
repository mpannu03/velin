import 'package:material_ui/material_ui.dart';
import 'package:velin/app/theme/theme.dart';
import 'package:velin/features/tools/tools.dart';
import 'package:velin/shared/extensions/extensions.dart';

class SelectedImageRow extends StatelessWidget {
  const SelectedImageRow({
    super.key,
    required this.filePath,
    required this.onReplace,
    required this.onRemove,
  });

  final String filePath;
  final VoidCallback onReplace;
  final VoidCallback onRemove;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final l10n = context.l10n;

    final fileName = filePath.split(RegExp(r'[/\\]')).last;

    return Container(
      padding: const EdgeInsets.all(AppSpacing.md),
      decoration: BoxDecoration(
        color: theme.colorScheme.surfaceContainerLow,
        borderRadius: BorderRadius.circular(AppRadius.md),
      ),
      child: Row(
        children: [
          SizedBox(
            width: 56,
            height: 56,
            child: ImageFileThumbnail(filePath: filePath),
          ),
          const SizedBox(width: AppSpacing.md),
          Expanded(
            child: Text(
              fileName,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: theme.textTheme.bodyMedium?.copyWith(
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
          const SizedBox(width: AppSpacing.xs),
          // Icon buttons: labelled ones leave the file name no room in the
          // settings pane.
          IconButton(
            key: const ValueKey('selected-image-replace'),
            onPressed: onReplace,
            tooltip: l10n.toolsWatermarkImageReplace,
            icon: const Icon(Icons.swap_horiz, size: 20),
          ),
          IconButton(
            key: const ValueKey('selected-image-remove'),
            onPressed: onRemove,
            tooltip: l10n.toolsWatermarkImageRemove,
            icon: const Icon(Icons.close, size: 20),
          ),
        ],
      ),
    );
  }
}
