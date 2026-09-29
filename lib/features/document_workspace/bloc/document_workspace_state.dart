part of 'document_workspace_bloc.dart';

sealed class DocumentWorkspaceState {
  const DocumentWorkspaceState();
}

final class DocumentWorkspaceInitial extends DocumentWorkspaceState {
  const DocumentWorkspaceInitial();
}

final class DocumentWorkspaceLoading extends DocumentWorkspaceState {
  const DocumentWorkspaceLoading();
}

final class DocumentWorkspaceLoaded extends DocumentWorkspaceState {
  const DocumentWorkspaceLoaded({
    required this.engine,
    this.selectedTool = WorkspaceTool.select,
    this.selectedPanel,
  });

  final DocumentEngine engine;
  final WorkspaceTool selectedTool;
  final WorkspacePanel? selectedPanel;

  DocumentWorkspaceLoaded copyWith({
    DocumentEngine? engine,
    WorkspaceTool? selectedTool,
    Object? selectedPanel = _unset,
  }) {
    return DocumentWorkspaceLoaded(
      engine: engine ?? this.engine,
      selectedTool: selectedTool ?? this.selectedTool,
      selectedPanel: identical(selectedPanel, _unset)
          ? this.selectedPanel
          : selectedPanel as WorkspacePanel?,
    );
  }
}

final class DocumentWorkspaceError extends DocumentWorkspaceState {
  const DocumentWorkspaceError(this.message);

  final String message;
}

const _unset = Object();