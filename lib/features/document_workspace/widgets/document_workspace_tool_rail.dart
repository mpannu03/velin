import 'package:material_symbols_icons/symbols.dart';
import 'package:material_ui/material_ui.dart';
import 'package:velin/app/theme/theme.dart';
import 'package:velin/shared/widgets/widgets.dart';

import '../models/models.dart';

class DocumentWorkspaceToolRail extends StatelessWidget {
  const DocumentWorkspaceToolRail({
    required this.selectedTool,
    required this.onToolSelected,
    super.key,
  });

  final WorkspaceTool selectedTool;
  final ValueChanged<WorkspaceTool> onToolSelected;

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return Padding(
      padding: const EdgeInsets.all(AppSpacing.sm),
      child: Card(
        color: colorScheme.surface,
        child: Padding(
          padding: const EdgeInsets.all(AppSpacing.sm),
          child: Column(
            spacing: AppSpacing.sm,
            mainAxisSize: MainAxisSize.min,
            children: [
              VelinIconButton(
                icon: Symbols.arrow_selector_tool,
                tooltip: 'Select',
                onPressed: () => onToolSelected(WorkspaceTool.select),
                isSelected: selectedTool == WorkspaceTool.select,
              ),
              VelinIconButton(
                icon: Symbols.drag_pan_rounded,
                tooltip: 'Pan',
                onPressed: () => onToolSelected(WorkspaceTool.pan),
                isSelected: selectedTool == WorkspaceTool.pan,
              ),
            ],
          ),
        ),
      ),
    );
  }
}