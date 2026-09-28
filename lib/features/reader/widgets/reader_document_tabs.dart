import 'package:material_ui/material_ui.dart';

import 'package:velin/core/document/document.dart';
import 'package:velin/shared/widgets/widgets.dart';

class ReaderDocumentTabs extends StatelessWidget {
  const ReaderDocumentTabs({
    required this.documents,
    required this.selectedDocument,
    required this.onDocumentSelected,
    required this.onDocumentClosed,
    super.key,
  });

  final List<Document> documents;
  final Document? selectedDocument;
  final ValueChanged<Document> onDocumentSelected;
  final ValueChanged<Document> onDocumentClosed;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        for (final document in documents)
          _DocumentTab(
            document: document,
            selected: document == selectedDocument,
            onSelected: onDocumentSelected,
            onClosed: onDocumentClosed,
          ),
      ],
    );
  }
}

class _DocumentTab extends StatelessWidget {
  const _DocumentTab({
    required this.document,
    required this.selected,
    required this.onSelected,
    required this.onClosed,
  });

  final Document document;
  final bool selected;
  final ValueChanged<Document> onSelected;
  final ValueChanged<Document> onClosed;

  @override
  Widget build(BuildContext context) {
    final fileName = document.path.split('/').last;

    return VelinHoverable(
      onTap: () => onSelected(document),
      child: Container(
        padding: const EdgeInsets.only(left: 12),
        decoration: BoxDecoration(
          color: selected
              ? Theme.of(context).colorScheme.surface
              : null,
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(fileName),
            IconButton(
              icon: const Icon(Icons.close),
              onPressed: () => onClosed(document),
            ),
          ],
        ),
      ),
    );
  }
}