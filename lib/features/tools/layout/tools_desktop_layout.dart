import 'package:material_ui/material_ui.dart';

import 'package:velin/app/theme/theme.dart';
import 'package:velin/features/tools/tools.dart';
import 'package:velin/shared/extensions/extensions.dart';

/// Every tool, grouped by category; the search box narrows the list by
/// name or description.
class ToolsDesktopLayout extends StatefulWidget {
  const ToolsDesktopLayout({required this.onToolTap, super.key});

  final ValueChanged<ToolDefinition> onToolTap;

  @override
  State<ToolsDesktopLayout> createState() => _ToolsDesktopLayoutState();
}

class _ToolsDesktopLayoutState extends State<ToolsDesktopLayout> {
  String _query = '';

  bool _matches(ToolDefinition tool, String query) {
    if (query.isEmpty) return true;
    return tool.title(context).toLowerCase().contains(query) ||
        tool.description(context).toLowerCase().contains(query);
  }

  @override
  Widget build(BuildContext context) {
    final query = _query.trim().toLowerCase();
    final tools = ToolRegistry.all.where((t) => _matches(t, query)).toList();

    return SingleChildScrollView(
      padding: const EdgeInsets.symmetric(
        horizontal: AppSpacing.xxl,
        vertical: AppSpacing.xl,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          ToolsHeader(
            onQueryChanged: (value) => setState(() => _query = value),
          ),
          const SizedBox(height: AppSpacing.xxl),
          if (tools.isEmpty)
            Padding(
              padding: const EdgeInsets.symmetric(vertical: AppSpacing.xxl),
              child: Text(
                context.l10n.toolsNoMatches(_query.trim()),
                textAlign: TextAlign.center,
                style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                  color: Theme.of(context).colorScheme.onSurfaceVariant,
                ),
              ),
            )
          else
            _CategoryColumns(tools: tools, onToolTap: widget.onToolTap),
        ],
      ),
    );
  }
}

/// The categories side by side; on a narrow window they wrap into two
/// columns (or one).
class _CategoryColumns extends StatelessWidget {
  const _CategoryColumns({required this.tools, required this.onToolTap});

  final List<ToolDefinition> tools;
  final ValueChanged<ToolDefinition> onToolTap;

  static const _minColumnWidth = 240.0;
  static const _gap = AppSpacing.xl;

  @override
  Widget build(BuildContext context) {
    final categories = [
      for (final category in ToolCategory.values)
        if (tools.any((t) => t.category == category)) category,
    ];

    return LayoutBuilder(
      builder: (context, constraints) {
        final width = constraints.maxWidth;
        final fit = ((width + _gap) / (_minColumnWidth + _gap)).floor();
        final columns = fit.clamp(1, ToolCategory.values.length);
        final columnWidth = (width - _gap * (columns - 1)) / columns;

        return Wrap(
          spacing: _gap,
          runSpacing: AppSpacing.xxl,
          children: [
            for (final category in categories)
              SizedBox(
                width: columnWidth,
                child: ToolCategorySection(
                  category: category,
                  tools: tools.where((t) => t.category == category).toList(),
                  onToolTap: onToolTap,
                ),
              ),
          ],
        );
      },
    );
  }
}
