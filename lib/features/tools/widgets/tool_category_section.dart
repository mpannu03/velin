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
      padding: const EdgeInsets.only(bottom: AppSpacing.xl),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.baseline,
            textBaseline: TextBaseline.alphabetic,
            children: [
              Text(
                category.label(context),
                style: theme.textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.w600,
                ),
              ),
              const SizedBox(width: AppSpacing.sm),
              Text(
                '${tools.length}',
                style: theme.textTheme.bodySmall?.copyWith(
                  color: colorScheme.onSurfaceVariant,
                ),
              ),
            ],
          ),
          const SizedBox(height: AppSpacing.md),
          LayoutBuilder(
            builder: (context, constraints) {
              final width = constraints.maxWidth;
              const minCardWidth = 280.0;
              final columns = (width / minCardWidth).floor().clamp(1, 4);
              const cardGap = AppSpacing.md;
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
