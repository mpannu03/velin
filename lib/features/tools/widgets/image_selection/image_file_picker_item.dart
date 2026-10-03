import 'dart:io';

import 'package:material_ui/material_ui.dart';

import 'package:velin/app/theme/theme.dart';
import 'package:velin/shared/extensions/extensions.dart';

/// Rounded thumbnail of a single image file, with a graceful fallback
/// when the file cannot be decoded.
class ImageFileThumbnail extends StatelessWidget {
  const ImageFileThumbnail({
    required this.filePath,
    this.borderRadius = AppRadius.md,
    super.key,
  });

  final String filePath;

  /// Corner radius of the clipped thumbnail.
  final double borderRadius;

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;

    return ClipRRect(
      borderRadius: BorderRadius.circular(borderRadius),
      child: Image.file(
        File(filePath),
        fit: BoxFit.cover,
        errorBuilder: (context, error, stackTrace) => ColoredBox(
          color: colors.surfaceContainerHighest,
          child: Icon(
            Icons.broken_image_outlined,
            size: 24,
            color: colors.onSurfaceVariant,
          ),
        ),
      ),
    );
  }
}

/// Circular badge showing the 1-based page position of an image.
class ImageOrderBadge extends StatelessWidget {
  const ImageOrderBadge({
    required this.index,
    super.key,
  });

  final int index;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colors = theme.colorScheme;

    return Container(
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
    );
  }
}

/// Row presentation of a selected image, used by the list view.
class ImageFilePickerItem extends StatelessWidget {
  const ImageFilePickerItem({
    required this.filePath,
    required this.onRemove,
    this.index,
    this.dragHandle,
    super.key,
  });

  final String filePath;
  final VoidCallback onRemove;

  /// Optional 1-based position shown as an order badge.
  final int? index;

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
    final l10n = context.l10n;

    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: AppSpacing.md,
        vertical: AppSpacing.sm,
      ),
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surfaceContainerLow,
        border: Border.all(
          color: Theme.of(context).colorScheme.outlineVariant,
        ),
        borderRadius: BorderRadius.circular(AppRadius.md),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          if (index != null) ...[
            ImageOrderBadge(index: index!),
            const SizedBox(width: AppSpacing.sm),
          ],
          if (dragHandle != null) ...[
            dragHandle!,
            const SizedBox(width: AppSpacing.xs),
          ],
          SizedBox(
            width: 40,
            height: 40,
            child: ImageFileThumbnail(
              filePath: filePath,
              borderRadius: AppRadius.sm,
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
                      color: theme.colorScheme.onSurfaceVariant,
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
