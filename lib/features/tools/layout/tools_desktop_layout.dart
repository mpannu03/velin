import 'package:material_ui/material_ui.dart';

import 'package:velin/app/theme/theme.dart';
import 'package:velin/features/tools/registry/tool_definition.dart';
import 'package:velin/features/tools/registry/tool_registry.dart';
import 'package:velin/features/tools/widgets/tool_card.dart';
import 'package:velin/features/tools/widgets/tool_category_filter.dart';
import 'package:velin/shared/extensions/extensions.dart';

class ToolsDesktopLayout extends StatefulWidget {
  const ToolsDesktopLayout({
    required this.onToolTap,
    super.key,
  });

  final ValueChanged<ToolDefinition> onToolTap;

  @override
  State<ToolsDesktopLayout> createState() => _ToolsDesktopLayoutState();
}

class _ToolsDesktopLayoutState extends State<ToolsDesktopLayout> {
  static const _maxContentWidth = 1160.0;

  /// The active category filter; `null` means "All".
  ToolCategory? _filter;

  @override
  Widget build(BuildContext context) {
    final tools = ToolRegistry.all;

    final visibleCategories = _filter == null
        ? ToolCategory.values
            .where((category) => tools.any((t) => t.category == category))
            .toList()
        : [_filter!];

    return SingleChildScrollView(
      padding: const EdgeInsets.all(AppSpacing.xxl),
      child: Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: _maxContentWidth),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _Header(
                filter: _filter,
                onFilterChanged: (value) =>
                    setState(() => _filter = value),
              ),
              const SizedBox(height: AppSpacing.xxl),
              for (final category in visibleCategories)
                _ToolCategorySection(
                  category: category,
                  tools: tools
                      .where((tool) => tool.category == category)
                      .toList(),
                  onToolTap: widget.onToolTap,
                ),
            ],
          ),
        ),
      ),
    );
  }
}

class _Header extends StatelessWidget {
  const _Header({
    required this.filter,
    required this.onFilterChanged,
  });

  final ToolCategory? filter;
  final ValueChanged<ToolCategory?> onFilterChanged;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          context.l10n.navigationTools,
          style: theme.textTheme.headlineMedium?.copyWith(
            fontWeight: FontWeight.w700,
          ),
        ),
        const SizedBox(height: AppSpacing.sm),
        Text(
          context.l10n.toolsIntro,
          style: theme.textTheme.bodyMedium?.copyWith(
            color: colorScheme.onSurfaceVariant,
          ),
        ),
        const SizedBox(height: AppSpacing.xl),
        ToolCategoryFilter(
          selected: filter,
          onChanged: onFilterChanged,
        ),
      ],
    );
  }
}

class _ToolCategorySection extends StatelessWidget {
  const _ToolCategorySection({
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
              final columns = (width / minCardWidth)
                  .floor()
                  .clamp(1, 5);
              final cardGap = AppSpacing.lg;
              final itemWidth =
                  (width - (cardGap * (columns - 1))) / columns;

              return Wrap(
                spacing: cardGap,
                runSpacing: cardGap,
                children: [
                  for (final tool in tools)
                    SizedBox(
                      width: itemWidth,
                      child: ToolCard(
                        tool: tool,
                        onTap: () => onToolTap(tool),
                      ),
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