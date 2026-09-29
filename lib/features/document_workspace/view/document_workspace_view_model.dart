import 'package:material_ui/material_ui.dart';
import 'package:velin/core/document/engine/engine.dart';

import '../models/models.dart';

class DocumentWorkspaceViewModel {
  const DocumentWorkspaceViewModel({
    required this.engine,
    required this.selectedTool,
    required this.selectedPanel,
    required this.onToolSelected,
    required this.onPanelSelected,
    required this.onPanelClosed,
  });

  final DocumentEngine engine;
  final WorkspaceTool selectedTool;
  final WorkspacePanel? selectedPanel;

  final ValueChanged<WorkspaceTool> onToolSelected;
  final ValueChanged<WorkspacePanel> onPanelSelected;
  final VoidCallback onPanelClosed;
}