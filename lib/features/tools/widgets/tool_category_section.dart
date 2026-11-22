import 'package:material_ui/material_ui.dart';
import 'package:velin/app/theme/theme.dart';
import 'package:velin/features/tools/tools.dart';

/// One category of the Tools page as a column: a small heading over a
/// hairline, then its tools as rows.
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

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: AppSpacing.sm),
          child: Text(
            category.label(context).toUpperCase(),
            style: theme.textTheme.labelSmall?.copyWith(
              color: colorScheme.onSurfaceVariant,
              fontWeight: FontWeight.w600,
              letterSpacing: 0.8,
            ),
          ),
        ),
        const SizedBox(height: AppSpacing.sm),
        const Divider(),
        const SizedBox(height: AppSpacing.sm),
        for (final tool in tools) ...[
          ToolCard(tool: tool, onTap: () => onToolTap(tool)),
          const SizedBox(height: AppSpacing.xxs),
        ],
      ],
    );
  }
}
