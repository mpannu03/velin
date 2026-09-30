part of 'document_workspace_bloc.dart';

sealed class DocumentWorkspaceEvent {
  const DocumentWorkspaceEvent();
}

final class DocumentWorkspaceStarted extends DocumentWorkspaceEvent {
  const DocumentWorkspaceStarted({
    required this.currentPage,
    required this.pageCount,
    required this.currentZoom,
  });

  final int? currentPage;
  final int pageCount;
  final double currentZoom;
}

final class DocumentWorkspacePageChanged extends DocumentWorkspaceEvent {
  const DocumentWorkspacePageChanged(this.page);

  final int? page;
}

final class DocumentWorkspaceZoomChanged extends DocumentWorkspaceEvent {
  const DocumentWorkspaceZoomChanged(this.zoom);

  final double zoom;
}

final class DocumentWorkspaceToolSelected extends DocumentWorkspaceEvent {
  const DocumentWorkspaceToolSelected(this.tool);

  final WorkspaceTool tool;
}

final class DocumentWorkspacePanelSelected extends DocumentWorkspaceEvent {
  const DocumentWorkspacePanelSelected(this.panel);

  final WorkspacePanel panel;
}

final class DocumentWorkspacePanelClosed extends DocumentWorkspaceEvent {
  const DocumentWorkspacePanelClosed();
}