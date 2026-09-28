enum DocumentType {
  pdf;

  List<String> get fileExtensions => switch (this) {
        DocumentType.pdf => ['pdf'],
      };
  
  static DocumentType? fromPath(String path) {
    final extension = path.split('.').last.toLowerCase();

    return switch (extension) {
      'pdf' => DocumentType.pdf,
      _ => null,
    };
  }
}