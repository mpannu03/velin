class DocumentEngineCapabilities {
  const DocumentEngineCapabilities({
    this.textSelection = false,
    this.search = false,
    this.comments = false,
    this.bookmarks = false,
  });

  final bool textSelection;
  final bool search;
  final bool comments;
  final bool bookmarks;
}
