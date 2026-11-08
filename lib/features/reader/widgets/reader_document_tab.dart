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

  static const _maxWidth = 220.0;

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;

    final fileName = document.path.split(RegExp(r'[/\\]')).last;

    return ConstrainedBox(
      constraints: const BoxConstraints(maxWidth: _maxWidth),
      child: Tooltip(
        message: document.path,
        waitDuration: const Duration(seconds: 1),
        child: Material(
          color: isSelected ? colorScheme.surface : Colors.transparent,
          borderRadius: const BorderRadius.vertical(
            top: Radius.circular(AppRadius.md),
          ),
          clipBehavior: Clip.antiAlias,
          child: InkWell(
            onTap: () => onSelected(document),
            hoverColor: colorScheme.onSurface.withValues(alpha: 0.05),
            child: Padding(
              padding: const EdgeInsets.only(
                left: AppSpacing.md,
                right: AppSpacing.xs,
              ),
              child: Row(
                children: [
                  Expanded(
                    child: Text(
                      fileName,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: textTheme.bodySmall?.copyWith(
                        color: isSelected
                            ? colorScheme.onSurface
                            : colorScheme.onSurfaceVariant,
                        fontWeight: isSelected ? FontWeight.w600 : null,
                      ),
                    ),
                  ),
                  const SizedBox(width: AppSpacing.xs),
                  IconButton(
                    onPressed: () => onClosed(document),
                    icon: const Icon(Icons.close, size: 14),
                    padding: EdgeInsets.zero,
                    style: IconButton.styleFrom(
                      fixedSize: const Size.square(22),
                      minimumSize: const Size.square(22),
                      foregroundColor: colorScheme.onSurfaceVariant,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(AppRadius.sm),
                      ),
                    ),
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
