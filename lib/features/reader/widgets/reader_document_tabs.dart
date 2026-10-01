import 'package:material_ui/material_ui.dart';
import 'package:velin/app/theme/theme.dart';

import 'package:velin/core/document/document.dart';
import 'package:velin/shared/widgets/widgets.dart';
import 'reader_document_tab.dart';

class ReaderDocumentTabs extends StatelessWidget {
  const ReaderDocumentTabs({
    required this.documents,
    required this.selectedDocument,
    required this.onDocumentSelected,
    required this.onDocumentClosed,
    required this.onOpenDocument,
    super.key,
  });

  final List<Document> documents;
  final Document? selectedDocument;
  final ValueChanged<Document> onDocumentSelected;
  final ValueChanged<Document> onDocumentClosed;
  final VoidCallback onOpenDocument;

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return Padding(
      padding: const EdgeInsets.only(top: AppSpacing.xs),
      child: Column(
        children: [
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: AppSpacing.sm),
            child: Row(
              children: [
                for (final document in documents) ...[
                  ReaderDocumentTab(
                    document: document,
                    isSelected: document == selectedDocument,
                    onSelected: onDocumentSelected,
                    onClosed: onDocumentClosed,
                  ),
                  Container(
                    color: colorScheme.outline,
                    width: 1,
                    height: 16,
                  ),
                ],
                SizedBox(width: AppSpacing.xs),
                if (documents.isNotEmpty)
                  VelinToolButton(
                    icon: Icons.add, 
                    toolTip: 'Open Document', 
                    onPressed: onOpenDocument
                  ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
