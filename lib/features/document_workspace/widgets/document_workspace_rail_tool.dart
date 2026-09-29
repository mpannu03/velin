import 'package:material_ui/material_ui.dart';
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
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        VelinIconButton(
          icon: Icons.ads_click,
          tooltip: 'Select',
          onPressed: () => onToolSelected(WorkspaceTool.select),
        ),
        VelinIconButton(
          icon: Icons.pan_tool,
          tooltip: 'Pan',
          onPressed: () => onToolSelected(WorkspaceTool.pan),
        ),
      ],
    );
  }
}