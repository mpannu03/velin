import 'package:material_ui/material_ui.dart';
import 'package:velin/core/document/document.dart';

class ReaderViewModel {
  const ReaderViewModel({
    required this.documents,
    required this.selectedDocument,
    required this.onOpenDocument,
    required this.onDocumentSelected,
    required this.onDocumentClosed,
  });

  final List<Document> documents;
  final Document? selectedDocument;

  final VoidCallback onOpenDocument;
  final ValueChanged<Document> onDocumentSelected;
  final ValueChanged<Document> onDocumentClosed;
}