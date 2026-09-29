class DocumentEngineCapabilities {
  const DocumentEngineCapabilities({
    this.textSelection = false,
    this.search = false,
    this.annotations = false,
    this.comments = false,
  });

  final bool textSelection;
  final bool search;
  final bool annotations;
  final bool comments;
}