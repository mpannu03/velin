import 'package:material_ui/material_ui.dart';
import 'package:velin/app/theme/theme.dart';
import 'package:velin/features/tools/tools.dart';

class ToolCategorySection extends StatelessWidget {
  const ToolCategorySection({
    super.key,
    required this.category,
    required this.tools,
    required this.onToolTap,
  });

  final ToolCategory category;
  final List<ToolDefinition> tools;
  final ValueChanged<ToolDefinition> onToolTap;

  @override
  Widget build(BuildContext context) {
    if (tools.isEmpty) {
      return const SizedBox.shrink();
    }

    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return Padding(
      padding: const EdgeInsets.only(bottom: AppSpacing.xxl),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Text(
                category.label(context),
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
                  color: colorScheme.surfaceContainerHighest,
                  borderRadius: BorderRadius.circular(999),
                ),
                child: Text(
                  '${tools.length}',
                  style: theme.textTheme.labelSmall?.copyWith(
                    color: colorScheme.onSurfaceVariant,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: AppSpacing.md),
          LayoutBuilder(
            builder: (context, constraints) {
              final width = constraints.maxWidth;
              const minCardWidth = 220.0;
              final columns = (width / minCardWidth).floor().clamp(1, 5);
              final cardGap = AppSpacing.lg;
              final itemWidth = (width - (cardGap * (columns - 1))) / columns;

              return Wrap(
                spacing: cardGap,
                runSpacing: cardGap,
                children: [
                  for (final tool in tools)
                    SizedBox(
                      width: itemWidth,
                      child: ToolCard(tool: tool, onTap: () => onToolTap(tool)),
                    ),
                ],
              );
            },
          ),
        ],
      ),
    );
  }
}
