import 'package:pdfrx/pdfrx.dart';
import 'package:velin/core/document/engine/engine.dart';

class PdfAnnotationCapability implements AnnotationCapability {
  PdfAnnotationCapability(this._controller);

  final PdfViewerController _controller;

  final Map<String, PdfDest> _destById = {};
  List<Annotation>? _cache;

  @override
  Future<List<Annotation>> get annotations async {
    if (_cache != null) return _cache!;

    final cache = <Annotation>[];
    _destById.clear();

    for (final page in _controller.document.pages) {
      final links = await page.loadLinks();

      cache.addAll(_convert(links, page.pageNumber));
    }
    _cache = cache;
    return _cache!;
  }

  @override
  void goto(Annotation annotation) {
    final dest = _destById[annotation.id];
    if (dest != null) {
      _controller.goToDest(dest);
    }
  }

  List<Annotation> _convert(List<PdfLink> list, int pageNumber) {
    final annotations = <Annotation>[];

    for (int i = 0; i < list.length; i++) {
      final link = list[i];
      if (link.annotation != null) {
        final id = '$pageNumber-$i';
        if (link.dest != null) {
          _destById[id] = link.dest!;
        }
        final annotation = Annotation(
          id: id,
          pageNumber: pageNumber,
          title: link.annotation!.title,
          subject: link.annotation!.subject,
          content: link.annotation!.content,
          creationDate: link.annotation!.creationDate?.pdfDateString,
        );

        annotations.add(annotation);
      }
    }
    
    return annotations;
  }
}