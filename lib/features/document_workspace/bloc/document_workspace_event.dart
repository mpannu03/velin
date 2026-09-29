part of 'document_workspace_bloc.dart';

sealed class DocumentWorkspaceEvent {
  const DocumentWorkspaceEvent();
}

final class DocumentWorkspaceStarted extends DocumentWorkspaceEvent {
  const DocumentWorkspaceStarted();
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