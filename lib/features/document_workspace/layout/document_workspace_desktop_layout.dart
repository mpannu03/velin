import 'package:flutter/material.dart';

import '../view/view.dart';
import '../widgets/widgets.dart';

class DocumentWorkspaceDesktopLayout extends StatelessWidget {
  const DocumentWorkspaceDesktopLayout({
    required this.viewModel,
    super.key,
  });

  final DocumentWorkspaceViewModel viewModel;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        DocumentWorkspaceToolRail(
          selectedTool: viewModel.selectedTool,
          onToolSelected: viewModel.onToolSelected,
        ),
        const VerticalDivider(width: 1),
        Expanded(
          child: DocumentWorkspaceViewport(
            engine: viewModel.engine,
          ),
        ),
        if (viewModel.selectedPanel != null)
          DocumentWorkspacePanel(
            panel: viewModel.selectedPanel!,
            onClose: viewModel.onPanelClosed,
          ),
        const VerticalDivider(width: 1),
        DocumentWorkspacePanelRail(
          selectedPanel: viewModel.selectedPanel,
          onPanelSelected: viewModel.onPanelSelected,
        ),
      ],
    );
  }
}