import 'package:material_ui/material_ui.dart';
import 'package:velin/app/theme/theme.dart';
import 'package:velin/features/home/widgets/recent_helpers.dart';

class RecentSectionHeader extends StatelessWidget {
  const RecentSectionHeader({
    required this.totalCount,
    required this.mode,
    required this.sort,
    required this.query,
    required this.onModeChanged,
    required this.onSortChanged,
    required this.onQueryChanged,
    super.key,
  });

  final int totalCount;
  final RecentViewMode mode;
  final RecentSortMode sort;
  final String query;
  final ValueChanged<RecentViewMode> onModeChanged;
  final ValueChanged<RecentSortMode> onSortChanged;
  final ValueChanged<String> onQueryChanged;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colors = theme.colorScheme;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Text(
              'Recent',
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
                '$totalCount',
                style: theme.textTheme.labelSmall?.copyWith(
                  color: colors.onSurfaceVariant,
                ),
              ),
            ),
            const Spacer(),
            SegmentedButton<RecentViewMode>(
              segments: const [
                ButtonSegment(
                  value: RecentViewMode.list,
                  icon: Icon(Icons.view_list_outlined, size: 18),
                  tooltip: 'List view',
                ),
                ButtonSegment(
                  value: RecentViewMode.grid,
                  icon: Icon(Icons.grid_view_outlined, size: 18),
                  tooltip: 'Grid view',
                ),
              ],
              selected: {mode},
              showSelectedIcon: false,
              onSelectionChanged: (s) => onModeChanged(s.first),
              style: SegmentedButton.styleFrom(
                visualDensity: VisualDensity.compact,
              ),
            ),
          ],
        ),
        const SizedBox(height: AppSpacing.md),
        Row(
          children: [
            Expanded(
              child: SizedBox(
                height: 40,
                child: TextField(
                  onChanged: onQueryChanged,
                  decoration: InputDecoration(
                    hintText: 'Search by name or folder…',
                    prefixIcon: const Icon(Icons.search, size: 18),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(AppRadius.md),
                    ),
                    contentPadding: const EdgeInsets.symmetric(
                      horizontal: AppSpacing.md,
                    ),
                  ),
                ),
              ),
            ),
            const SizedBox(width: AppSpacing.sm),
            MenuAnchor(
              builder: (context, controller, _) => OutlinedButton.icon(
                onPressed: () =>
                    controller.isOpen ? controller.close() : controller.open(),
                icon: const Icon(Icons.sort_outlined, size: 18),
                label: Text(switch (sort) {
                  RecentSortMode.lastOpened => 'Last opened',
                  RecentSortMode.progress => 'Progress',
                  RecentSortMode.name => 'Name',
                }),
              ),
              menuChildren: [
                for (final m in RecentSortMode.values)
                  MenuItemButton(
                    onPressed: () => onSortChanged(m),
                    leadingIcon: m == sort
                        ? const Icon(Icons.check, size: 18)
                        : const SizedBox(width: 18),
                    child: Text(switch (m) {
                      RecentSortMode.lastOpened => 'Last opened',
                      RecentSortMode.progress => 'Progress',
                      RecentSortMode.name => 'Name',
                    }),
                  ),
              ],
            ),
          ],
        ),
      ],
    );
  }
}
