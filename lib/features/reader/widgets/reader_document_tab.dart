import 'package:material_ui/material_ui.dart';
import 'package:velin/app/theme/theme.dart';
import 'package:velin/core/document/document.dart';

class ReaderDocumentTab extends StatelessWidget {
  const ReaderDocumentTab({
    super.key,
    required this.document,
    required this.isSelected,
    required this.onSelected,
    required this.onClosed,
  });

  final Document document;
  final bool isSelected;
  final ValueChanged<Document> onSelected;
  final ValueChanged<Document> onClosed;

  static const _maxWidth = 200.0;

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;

    final fileName = document.path.split(RegExp(r'[/\\]')).last;

    return ConstrainedBox(
      constraints: const BoxConstraints(maxWidth: _maxWidth),
      child: Material(
        color: isSelected
            ? colorScheme.surfaceContainerHighest
            : colorScheme.surface,
        borderRadius: const BorderRadius.only(
          topLeft: Radius.circular(AppRadius.md),
          topRight: Radius.circular(AppRadius.md),
        ),
        clipBehavior: Clip.antiAlias,
        child: InkWell(
          onTap: () => onSelected(document),
          child: Padding(
            padding: const EdgeInsets.symmetric(
              horizontal: AppSpacing.sm,
              vertical: AppSpacing.sm,
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Flexible(
                  child: Text(
                    fileName,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: textTheme.labelSmall,
                  ),
                ),
                const SizedBox(width: AppSpacing.xs),
                IconButton(
                  onPressed: () => onClosed(document),
                  icon: const Icon(Icons.close, size: 16),
                  padding: EdgeInsets.zero,
                  style: IconButton.styleFrom(
                    minimumSize: Size.zero,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(AppRadius.md),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
