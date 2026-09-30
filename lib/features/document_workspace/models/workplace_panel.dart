enum WorkspacePanel {
  comments,
  bookmarks,
  search
}

extension WorkplacePanelLabel on WorkspacePanel {
  String get label {
    return switch (this) {
      WorkspacePanel.comments => 'Comments',
      WorkspacePanel.bookmarks => 'Bookmarks',
      WorkspacePanel.search => 'Search',
    };
  }
}