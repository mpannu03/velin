import 'package:material_ui/material_ui.dart';
import 'package:velin/shared/extensions/extensions.dart';

class ReaderEmptyState extends StatelessWidget {
  const ReaderEmptyState({
    required this.onOpenDocument,
    super.key,
  });

  final VoidCallback onOpenDocument;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colors = theme.colorScheme;
    final text = theme.textTheme;

    return Center(
      child: ConstrainedBox(
        constraints: const BoxConstraints(maxWidth: 360),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Container(
              width: 72,
              height: 72,
              decoration: BoxDecoration(
                color: colors.surfaceContainerHighest,
                shape: BoxShape.circle,
              ),
              child: Icon(
                Icons.description_outlined,
                size: 32,
                color: colors.onSurfaceVariant,
              ),
            ),
            const SizedBox(height: 20),

            Text(
              context.l10n.readerNoDocumentOpen,
              style: text.titleMedium?.copyWith(
                color: colors.onSurface,
                fontWeight: FontWeight.w600,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 6),

            Text(
              context.l10n.readerNoDocumentOpenDescription,
              style: text.bodyMedium?.copyWith(
                color: colors.onSurfaceVariant,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 20),

            FilledButton.icon(
              onPressed: onOpenDocument,
              icon: const Icon(Icons.folder_open_outlined, size: 18),
              label: Text(context.l10n.commonOpenDocument),
            ),
          ],
        ),
      ),
    );
  }
}