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
    required this.pageCount,
    this.currentPage,
    this.selectedTool = WorkspaceTool.select,
    this.selectedPanel,
    required this.currentZoom,
  });

  final DocumentEngine engine;
  final int? currentPage;
  final int pageCount;
  final double currentZoom;
  final WorkspaceTool selectedTool;
  final WorkspacePanel? selectedPanel;

  DocumentWorkspaceLoaded copyWith({
    DocumentEngine? engine,
    Object? currentPage = _unset,
    int? pageCount,
    double? currentZoom,
    WorkspaceTool? selectedTool,
    Object? selectedPanel = _unset,
  }) {
    return DocumentWorkspaceLoaded(
      engine: engine ?? this.engine,
      currentPage: identical(currentPage, _unset)
          ? this.currentPage
          : currentPage as int?,
      pageCount: pageCount ?? this.pageCount,
      currentZoom: currentZoom ?? this.currentZoom,
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