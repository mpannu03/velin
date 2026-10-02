import 'package:material_ui/material_ui.dart';

import 'package:velin/features/tools/registry/tool_definition.dart';
import 'package:velin/features/tools/registry/tool_registry.dart';
import 'package:velin/features/tools/widgets/tool_card.dart';

class ToolsDesktopLayout extends StatelessWidget {
  const ToolsDesktopLayout({
    required this.onToolTap,
    super.key,
  });

  final ValueChanged<ToolDefinition> onToolTap;

  @override
  Widget build(BuildContext context) {
    final tools = ToolRegistry.all;

    return SingleChildScrollView(
      padding: const EdgeInsets.all(24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          for (final category in ToolCategory.values)
            _ToolCategorySection(
              category: category,
              tools: tools
                  .where((tool) => tool.category == category)
                  .toList(),
              onToolTap: onToolTap,
            ),
        ],
      ),
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

    return Padding(
      padding: const EdgeInsets.only(bottom: 32),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            ToolDefinition(
              id: tools.first.id,
              category: category,
              icon: tools.first.icon,
              route: tools.first.route,
            ).categoryLabel(context),
            style: Theme.of(context).textTheme.titleLarge,
          ),
          const SizedBox(height: 16),
          Wrap(
            spacing: 16,
            runSpacing: 16,
            children: [
              for (final tool in tools)
                SizedBox(
                  width: 180,
                  height: 140,
                  child: ToolCard(
                    tool: tool,
                    onTap: () => onToolTap(tool),
                  ),
                ),
            ],
          ),
        ],
      ),
    );
  }
}