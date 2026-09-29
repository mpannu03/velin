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
    return Stack(
      children: [
        Positioned.fill(
          child: DocumentWorkspaceViewport(
            engine: viewModel.engine,
          ),
        ),

        Positioned(
          top: 0,
          left: 0,
          child: DocumentWorkspaceToolRail(
            selectedTool: viewModel.selectedTool,
            onToolSelected: viewModel.onToolSelected,
          ),
        ),

        // Panel + panel rail grouped and pinned to the right edge.
        // The panel (when open) sits to the LEFT of the rail.
        Positioned(
          top: 0,
          right: 0,
          bottom: 0,
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              if (viewModel.selectedPanel != null)
                DocumentWorkspacePanel(
                  panel: viewModel.selectedPanel!,
                  onClose: viewModel.onPanelClosed,
                ),
              DocumentWorkspacePanelRail(
                selectedPanel: viewModel.selectedPanel,
                onPanelSelected: viewModel.onPanelSelected,
              ),
            ],
          ),
        ),
      ],
    );
  }
}