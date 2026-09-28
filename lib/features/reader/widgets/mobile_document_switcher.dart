import 'package:material_ui/material_ui.dart';

import 'package:velin/core/document/document.dart';

class MobileDocumentSwitcher extends StatelessWidget {
  const MobileDocumentSwitcher({
    required this.documents,
    required this.selectedDocument,
    required this.onDocumentSelected,
    super.key,
  });

  final List<Document> documents;
  final Document? selectedDocument;
  final ValueChanged<Document> onDocumentSelected;

  @override
  Widget build(BuildContext context) {
    final fileName = selectedDocument == null
        ? 'No document'
        : selectedDocument!.path.split('/').last;

    return DropdownButton<Document>(
      value: selectedDocument,
      isExpanded: true,
      items: [
        for (final document in documents)
          DropdownMenuItem(
            value: document,
            child: Text(
              document.path.split('/').last,
              overflow: TextOverflow.ellipsis,
            ),
          ),
      ],
      onChanged: (document) {
        if (document != null) {
          onDocumentSelected(document);
        }
      },
      hint: Text(fileName),
    );
  }
}