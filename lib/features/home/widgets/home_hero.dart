import 'package:material_ui/material_ui.dart';
import 'package:velin/app/theme/theme.dart';

class HomeHero extends StatelessWidget {
  const HomeHero({
    required this.docCount,
    required this.isOpening,
    required this.onOpenDocument,
    required this.onBrowseTools,
    super.key,
  });

  final int docCount;
  final bool isOpening;
  final VoidCallback onOpenDocument;
  final VoidCallback onBrowseTools;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colors = theme.colorScheme;
    final headline = docCount == 0
        ? 'Open your first document'
        : 'Pick up where you left off';

    return Container(
      padding: const EdgeInsets.all(AppSpacing.xl),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [colors.primaryContainer, colors.surfaceContainerLow],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        border: Border.all(color: colors.outlineVariant),
        borderRadius: BorderRadius.circular(AppRadius.lg),
      ),
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  headline,
                  style: theme.textTheme.headlineSmall?.copyWith(
                    fontWeight: FontWeight.w700,
                  ),
                ),
                const SizedBox(height: AppSpacing.sm),
                Text(
                  docCount == 0
                      ? 'Velin keeps your place, covers and history on this device.'
                      : '$docCount recent ${docCount == 1 ? 'document' : 'documents'} — resume in one click.',
                  style: theme.textTheme.bodyMedium?.copyWith(
                    color: colors.onSurfaceVariant,
                  ),
                ),
                const SizedBox(height: AppSpacing.lg),
                Wrap(
                  spacing: AppSpacing.md,
                  runSpacing: AppSpacing.sm,
                  children: [
                    FilledButton.icon(
                      onPressed: isOpening ? null : onOpenDocument,
                      icon: isOpening
                          ? const SizedBox(
                              width: 16,
                              height: 16,
                              child: CircularProgressIndicator(strokeWidth: 2),
                            )
                          : const Icon(Icons.folder_open_outlined, size: 18),
                      label: Text(isOpening ? 'Opening…' : 'Open document'),
                    ),
                    OutlinedButton.icon(
                      onPressed: onBrowseTools,
                      icon: const Icon(Icons.construction_outlined, size: 18),
                      label: const Text('Browse tools'),
                    ),
                  ],
                ),
              ],
            ),
          ),
          const SizedBox(width: AppSpacing.xl),
          Container(
            width: 96,
            height: 96,
            decoration: BoxDecoration(
              color: colors.primary.withValues(alpha: 0.12),
              borderRadius: BorderRadius.circular(AppRadius.lg),
            ),
            child: Icon(
              Icons.menu_book_rounded,
              size: 48,
              color: colors.primary,
            ),
          ),
        ],
      ),
    );
  }
}
