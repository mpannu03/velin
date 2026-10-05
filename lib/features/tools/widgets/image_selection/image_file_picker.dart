import 'package:material_ui/material_ui.dart';

import 'package:velin/app/theme/theme.dart';
import 'package:velin/shared/extensions/extensions.dart';

import 'image_file_picker_grid.dart';
import 'image_file_picker_item.dart';
import 'image_picker_view_mode.dart';

/// Picker for image based tools.
///
/// Supports both a list and a grid presentation and, in either case,
/// lets the user drag the images to change the resulting page order.
class ImageFilePicker extends StatelessWidget {
  const ImageFilePicker({
    required this.filePaths,
    required this.viewMode,
    required this.emptyStateDescription,
    required this.onAddFiles,
    required this.onRemoveFile,
    required this.onReorderItem,
    required this.onViewModeChanged,
    super.key,
  });

  final List<String> filePaths;
  final ImagePickerViewMode viewMode;

  /// Tool-specific copy shown in the empty state.
  final String emptyStateDescription;

  final VoidCallback onAddFiles;
  final ValueChanged<int> onRemoveFile;

  /// Called with the old and new index. [newIndex] is an insertion point,
  /// matching `ReorderableListView.onReorder` semantics.
  final void Function(int oldIndex, int newIndex) onReorderItem;

  final ValueChanged<ImagePickerViewMode> onViewModeChanged;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colors = theme.colorScheme;
    final l10n = context.l10n;

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
          Row(
            children: [
              Text(
                l10n.toolsImageToPdfSourceSectionTitle,
                style: theme.textTheme.titleLarge?.copyWith(
                  fontWeight: FontWeight.w600,
                ),
              ),
              const SizedBox(width: AppSpacing.sm),
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: AppSpacing.sm,
                  vertical: AppSpacing.xxs,
                ),
                decoration: BoxDecoration(
                  color: colors.surfaceContainerHighest,
                  borderRadius: BorderRadius.circular(999),
                ),
                child: Text(
                  l10n.toolsFileCount(filePaths.length),
                  style: theme.textTheme.labelSmall?.copyWith(
                    color: colors.onSurfaceVariant,
                  ),
                ),
              ),
              const Spacer(),
              _ViewModeToggle(
                viewMode: viewMode,
                onViewModeChanged: onViewModeChanged,
              ),
              const SizedBox(width: AppSpacing.sm),
              OutlinedButton.icon(
                onPressed: onAddFiles,
                icon: const Icon(Icons.add, size: 18),
                label: Text(l10n.toolsAddFiles),
              ),
            ],
          ),
          const SizedBox(height: AppSpacing.lg),
          if (filePaths.isEmpty)
            _EmptyState(
              description: emptyStateDescription,
              onAddFiles: onAddFiles,
            )
          else
            switch (viewMode) {
              ImagePickerViewMode.list => _ImageList(
                filePaths: filePaths,
                onRemoveFile: onRemoveFile,
                onReorderItem: onReorderItem,
              ),
              ImagePickerViewMode.grid => ImageFilePickerGrid(
                filePaths: filePaths,
                onRemoveFile: onRemoveFile,
                onReorderItem: onReorderItem,
              ),
            },
        ],
      ),
    );
  }
}

class _ViewModeToggle extends StatelessWidget {
  const _ViewModeToggle({
    required this.viewMode,
    required this.onViewModeChanged,
  });

  final ImagePickerViewMode viewMode;
  final ValueChanged<ImagePickerViewMode> onViewModeChanged;

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;

    return SegmentedButton<ImagePickerViewMode>(
      key: const ValueKey('image-file-picker-view-mode'),
      showSelectedIcon: false,
      segments: [
        ButtonSegment(
          value: ImagePickerViewMode.list,
          icon: Tooltip(
            message: l10n.toolsImageToPdfViewModeList,
            child: const Icon(Icons.view_list_outlined, size: 18),
          ),
        ),
        ButtonSegment(
          value: ImagePickerViewMode.grid,
          icon: Tooltip(
            message: l10n.toolsImageToPdfViewModeGrid,
            child: const Icon(Icons.grid_view_outlined, size: 18),
          ),
        ),
      ],
      selected: {viewMode},
      onSelectionChanged: (selection) => onViewModeChanged(selection.first),
    );
  }
}

class _EmptyState extends StatelessWidget {
  const _EmptyState({required this.description, required this.onAddFiles});

  final String description;
  final VoidCallback onAddFiles;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colors = theme.colorScheme;
    final l10n = context.l10n;

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(
        horizontal: AppSpacing.xl,
        vertical: AppSpacing.xxl,
      ),
      decoration: BoxDecoration(
        color: colors.surfaceContainer,
        borderRadius: BorderRadius.circular(AppRadius.md),
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
              Icons.image_outlined,
              size: 26,
              color: colors.onPrimaryContainer,
            ),
          ),
          const SizedBox(height: AppSpacing.md),
          Text(
            l10n.toolsNoFilesTitle,
            style: theme.textTheme.titleMedium?.copyWith(
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(height: AppSpacing.xs),
          Text(
            description,
            textAlign: TextAlign.center,
            style: theme.textTheme.bodySmall?.copyWith(
              color: colors.onSurfaceVariant,
            ),
          ),
          const SizedBox(height: AppSpacing.lg),
          FilledButton.icon(
            onPressed: onAddFiles,
            icon: const Icon(Icons.add, size: 18),
            label: Text(l10n.toolsAddFiles),
          ),
        ],
      ),
    );
  }
}

/// List presentation. Reordering is delegated to [ReorderableListView].
class _ImageList extends StatelessWidget {
  const _ImageList({
    required this.filePaths,
    required this.onRemoveFile,
    required this.onReorderItem,
  });

  final List<String> filePaths;
  final ValueChanged<int> onRemoveFile;
  final void Function(int oldIndex, int newIndex) onReorderItem;

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;

    return ReorderableListView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      buildDefaultDragHandles: false,
      itemCount: filePaths.length,
      onReorderItem: onReorderItem,
      itemBuilder: (context, index) {
        return Padding(
          key: ValueKey(filePaths[index]),
          padding: const EdgeInsets.only(bottom: AppSpacing.sm),
          child: ImageFilePickerItem(
            filePath: filePaths[index],
            index: index + 1,
            onRemove: () => onRemoveFile(index),
            dragHandle: ReorderableDragStartListener(
              index: index,
              child: Icon(Icons.drag_indicator, color: colors.onSurfaceVariant),
            ),
          ),
        );
      },
    );
  }
}
