abstract interface class TextSearchCapability {
  Stream<List<TextSearchResult>> search(String text);

  Future<void> clear();

  Future<void> selectResult(TextSearchResult result);
}

class TextSearchResult {
  const TextSearchResult({
    required this.index,
    required this.pageNumber,
    required this.text,
  });

  final int index;
  final int pageNumber;
  final String text;
}