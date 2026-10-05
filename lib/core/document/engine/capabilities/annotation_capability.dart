abstract interface class AnnotationCapability {
  Future<List<Annotation>> get annotations;

  void goto(Annotation annotation);
}

class Annotation {
  const Annotation({
    required this.id,
    this.title,
    this.subject,
    this.content,
    this.creationDate,
    required this.pageNumber,
  });

  final String id;
  final String? title;
  final String? subject;
  final String? content;
  final String? creationDate;
  final int pageNumber;
}
