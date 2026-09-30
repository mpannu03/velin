

import 'package:material_ui/material_ui.dart';

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
            documentViewer: viewModel.documentViewer,
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
                currentPage: viewModel.currentPage,
                pageCount: viewModel.pageCount,
                currentZoom: viewModel.currentZoom,
                zoomIn: viewModel.zoomIn,
                zoomOut: viewModel.zoomOut,
                onPanelSelected: viewModel.onPanelSelected,
                onGotoPage: viewModel.onGotoPage,
              ),
            ],
          ),
        ),
      ],
    );
  }
}