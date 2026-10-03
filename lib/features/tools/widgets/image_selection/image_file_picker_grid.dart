import 'package:material_ui/material_ui.dart';

import 'package:velin/app/theme/theme.dart';
import 'package:velin/shared/extensions/extensions.dart';

import 'image_file_picker_item.dart';

/// Grid presentation of the selected images.
///
/// Flutter has no reorderable grid view, so every tile acts as a drop
/// target for the item the user is dragging.
class ImageFilePickerGrid extends StatelessWidget {
  const ImageFilePickerGrid({
    required this.filePaths,
    required this.onRemoveFile,
    required this.onReorderItem,
    this.maxCrossAxisExtent = 180.0,
    super.key,
  });

  final List<String> filePaths;
  final ValueChanged<int> onRemoveFile;
  final void Function(int oldIndex, int newIndex) onReorderItem;

  final double maxCrossAxisExtent;

  static const _spacing = AppSpacing.sm;
  static const _maxColumns = 6;

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final columnCount = _columnCount(constraints.maxWidth);

        return Wrap(
          spacing: _spacing,
          runSpacing: _spacing,
          children: [
            for (var index = 0; index < filePaths.length; index++)
              SizedBox(
                width: _tileWidth(constraints.maxWidth, columnCount),
                child: _ImageGridTile(
                  index: index,
                  filePath: filePaths[index],
                  tileWidth: _tileWidth(constraints.maxWidth, columnCount),
                  onRemove: () => onRemoveFile(index),
                  onReorder: (sourceIndex) => _reorder(sourceIndex, index),
                ),
              ),
          ],
        );
      },
    );
  }

  int _columnCount(double maxWidth) {
    final usable = maxWidth - _spacing * (_maxColumns - 1);

    return (usable / (maxCrossAxisExtent + _spacing)).floor().clamp(
      1,
      _maxColumns,
    );
  }

  double _tileWidth(double maxWidth, int columnCount) {
    final usable = maxWidth - _spacing * (columnCount - 1);

    return usable / columnCount;
  }

  /// Moves the item at [sourceIndex] so that it lands on [targetIndex].
  void _reorder(int sourceIndex, int targetIndex) {
    if (sourceIndex == targetIndex) {
      return;
    }

    // `onReorderItem` receives an insertion index, so an item dragged
    // downwards has to be inserted one slot further ahead.
    onReorderItem(
      sourceIndex,
      sourceIndex < targetIndex ? targetIndex + 1 : targetIndex,
    );
  }
}

class _ImageGridTile extends StatelessWidget {
  const _ImageGridTile({
    required this.index,
    required this.filePath,
    required this.tileWidth,
    required this.onRemove,
    required this.onReorder,
  });

  final int index;
  final String filePath;
  final double tileWidth;
  final VoidCallback onRemove;

  /// Called while another item is dragged over this tile.
  final ValueChanged<int> onReorder;

  @override
  Widget build(BuildContext context) {
    return DragTarget<int>(
      key: ValueKey('image-grid-$filePath'),
      onWillAcceptWithDetails: (details) => details.data != index,
      onAcceptWithDetails: (details) => onReorder(details.data),
      onMove: (details) => onReorder(details.data),
      builder: (context, candidates, _) {
        final isHovered = candidates.isNotEmpty;
        final colors = Theme.of(context).colorScheme;

        return AnimatedContainer(
          duration: const Duration(milliseconds: 120),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(AppRadius.md),
            border: Border.all(
              color: isHovered ? colors.primary : colors.outlineVariant,
              width: isHovered ? 2 : 1,
            ),
          ),
          child: LongPressDraggable<int>(
            data: index,
            feedback: Material(
              color: Colors.transparent,
              child: SizedBox(
                width: tileWidth,
                child: Opacity(
                  opacity: 0.85,
                  child: _ImageGridTileBody(filePath: filePath),
                ),
              ),
            ),
            childWhenDragging: Opacity(
              opacity: 0.4,
              child: _ImageGridTileBody(filePath: filePath),
            ),
            child: _ImageGridTileBody(
              filePath: filePath,
              index: index + 1,
              onRemove: onRemove,
            ),
          ),
        );
      },
    );
  }
}

class _ImageGridTileBody extends StatelessWidget {
  const _ImageGridTileBody({
    required this.filePath,
    this.index,
    this.onRemove,
  });

  final String filePath;
  final int? index;
  final VoidCallback? onRemove;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final l10n = context.l10n;

    return Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Stack(
          children: [
            AspectRatio(
              aspectRatio: 1,
              child: ImageFileThumbnail(filePath: filePath),
            ),
            if (index != null)
              Positioned(
                left: AppSpacing.xs,
                top: AppSpacing.xs,
                child: ImageOrderBadge(index: index!),
              ),
            if (onRemove != null)
              Positioned(
                right: 0,
                top: 0,
                child: IconButton(
                  onPressed: onRemove,
                  tooltip: l10n.toolsRemoveFile,
                  icon: const Icon(Icons.close, size: 18),
                  visualDensity: VisualDensity.compact,
                  style: IconButton.styleFrom(
                    backgroundColor: theme.colorScheme.surfaceContainerHighest,
                  ),
                ),
              ),
          ],
        ),
        Padding(
          padding: const EdgeInsets.fromLTRB(
            AppSpacing.sm,
            AppSpacing.sm,
            AppSpacing.sm,
            AppSpacing.xs,
          ),
          child: Text(
            filePath.split(RegExp(r'[/\\]')).last,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            textAlign: TextAlign.center,
            style: theme.textTheme.bodySmall?.copyWith(
              fontWeight: FontWeight.w600,
            ),
          ),
        ),
      ],
    );
  }
}
