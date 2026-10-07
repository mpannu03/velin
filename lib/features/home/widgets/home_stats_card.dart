import 'package:material_ui/material_ui.dart';
import 'package:velin/app/theme/theme.dart';
import 'package:velin/core/recent/recent.dart';
import 'package:velin/features/home/widgets/recent_helpers.dart';

class HomeStatsCard extends StatelessWidget {
  const HomeStatsCard({required this.documents, super.key});

  final List<RecentDocument> documents;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colors = theme.colorScheme;

    final totalPages = documents.fold<int>(0, (s, d) => s + d.pageCount);
    final remaining = documents.fold<int>(0, (s, d) => s + pagesLeft(d));
    final finished = documents
        .where((d) => d.pageCount > 0 && d.currentPage >= d.pageCount)
        .length;

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
          Text(
            'Library',
            style: theme.textTheme.titleMedium?.copyWith(
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(height: AppSpacing.md),
          _StatRow(
            icon: Icons.folder_outlined,
            label: 'Documents',
            value: '${documents.length}',
          ),
          const SizedBox(height: AppSpacing.sm),
          _StatRow(
            icon: Icons.auto_stories_outlined,
            label: 'Pages left',
            value: '$remaining of $totalPages',
          ),
          const SizedBox(height: AppSpacing.sm),
          _StatRow(
            icon: Icons.check_circle_outline,
            label: 'Finished',
            value: '$finished',
          ),
        ],
      ),
    );
  }
}

class _StatRow extends StatelessWidget {
  const _StatRow({
    required this.icon,
    required this.label,
    required this.value,
  });

  final IconData icon;
  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colors = theme.colorScheme;
    return Row(
      children: [
        Container(
          width: 32,
          height: 32,
          decoration: BoxDecoration(
            color: colors.primaryContainer,
            borderRadius: BorderRadius.circular(AppRadius.md),
          ),
          child: Icon(icon, size: 18, color: colors.onPrimaryContainer),
        ),
        const SizedBox(width: AppSpacing.md),
        Expanded(
          child: Text(
            label,
            style: theme.textTheme.bodyMedium?.copyWith(
              color: colors.onSurfaceVariant,
            ),
          ),
        ),
        Text(
          value,
          style: theme.textTheme.bodyMedium?.copyWith(
            fontWeight: FontWeight.w600,
          ),
        ),
      ],
    );
  }
}
