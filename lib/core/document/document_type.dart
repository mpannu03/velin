enum DocumentType {
  pdf;

  List<String> get fileExtensions => switch (this) {
        DocumentType.pdf => ['pdf'],
      };
}