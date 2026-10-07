import 'package:material_ui/material_ui.dart';
import 'package:velin/app/theme/theme.dart';

class RecentEmptyState extends StatelessWidget {
  const RecentEmptyState({
    required this.isOpening,
    required this.onOpenDocument,
    super.key,
  });

  final bool isOpening;
  final VoidCallback onOpenDocument;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colors = theme.colorScheme;
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(AppSpacing.xxl),
      decoration: BoxDecoration(
        color: colors.surfaceContainerLow,
        border: Border.all(
          color: colors.outlineVariant,
          strokeAlign: BorderSide.strokeAlignInside,
        ),
        borderRadius: BorderRadius.circular(AppRadius.lg),
      ),
      child: Column(
        children: [
          Container(
            width: 64,
            height: 64,
            decoration: BoxDecoration(
              color: colors.primaryContainer,
              shape: BoxShape.circle,
            ),
            child: Icon(
              Icons.folder_open_outlined,
              size: 30,
              color: colors.onPrimaryContainer,
            ),
          ),
          const SizedBox(height: AppSpacing.lg),
          Text(
            'No recent documents yet',
            style: theme.textTheme.titleMedium?.copyWith(
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(height: AppSpacing.xs),
          Text(
            'Open a PDF to start building your library.',
            style: theme.textTheme.bodyMedium?.copyWith(
              color: colors.onSurfaceVariant,
            ),
          ),
          const SizedBox(height: AppSpacing.lg),
          FilledButton.icon(
            onPressed: isOpening ? null : onOpenDocument,
            icon: const Icon(Icons.folder_open_outlined, size: 18),
            label: Text(isOpening ? 'Opening…' : 'Open document'),
          ),
        ],
      ),
    );
  }
}
