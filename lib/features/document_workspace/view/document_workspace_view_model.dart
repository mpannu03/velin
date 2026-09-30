import 'package:material_ui/material_ui.dart';
import 'package:velin/core/document/engine/engine.dart';

import '../models/models.dart';

class DocumentWorkspaceViewModel {
  const DocumentWorkspaceViewModel({
    required this.engine,
    required this.currentPage,
    required this.pageCount,
    required this.selectedTool,
    required this.selectedPanel,
    required this.onToolSelected,
    required this.onPanelSelected,
    required this.onGotoPage,
    required this.onPanelClosed,
  });

  final DocumentEngine engine;

  final int? currentPage;
  final int pageCount;

  final WorkspaceTool selectedTool;
  final WorkspacePanel? selectedPanel;

  final ValueChanged<WorkspaceTool> onToolSelected;
  final ValueChanged<WorkspacePanel> onPanelSelected;
  final ValueChanged<int> onGotoPage;
  final VoidCallback onPanelClosed;
}