part of 'document_workspace_bloc.dart';

sealed class DocumentWorkspaceEvent {
  const DocumentWorkspaceEvent();
}

final class DocumentWorkspaceStarted extends DocumentWorkspaceEvent {
  const DocumentWorkspaceStarted();
}

final class DocumentWorkspaceReady extends DocumentWorkspaceEvent {
  const DocumentWorkspaceReady();
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

final class DocumentWorkspaceSearch extends DocumentWorkspaceEvent {
  const DocumentWorkspaceSearch(this.text, this.caseInsensitive);

  final String text;
  final bool caseInsensitive;
}

final class DocumentWorkspaceClearSearch extends DocumentWorkspaceEvent {
  const DocumentWorkspaceClearSearch();
}

final class DocumentWorkspaceSelectSearch extends DocumentWorkspaceEvent {
  const DocumentWorkspaceSelectSearch(this.textSearchResult);

  final TextSearchResult textSearchResult;
}

final class DocumentWorkspaceSelectBookmark extends DocumentWorkspaceEvent {
  const DocumentWorkspaceSelectBookmark(this.bookmark);

  final Bookmark bookmark;
}

final class DocumentWorkspaceSelectAnnotation extends DocumentWorkspaceEvent {
  const DocumentWorkspaceSelectAnnotation(this.annotation);

  final Annotation annotation;
}
