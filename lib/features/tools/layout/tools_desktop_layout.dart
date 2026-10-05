import 'package:material_ui/material_ui.dart';

import 'package:velin/app/theme/theme.dart';
import 'package:velin/features/tools/tools.dart';

class ToolsDesktopLayout extends StatefulWidget {
  const ToolsDesktopLayout({required this.onToolTap, super.key});

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
              Header(
                filter: _filter,
                onFilterChanged: (value) => setState(() => _filter = value),
              ),
              const SizedBox(height: AppSpacing.xxl),
              for (final category in visibleCategories)
                ToolCategorySection(
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
