import 'package:material_ui/material_ui.dart';
import 'package:velin/app/theme/theme.dart';

import 'package:velin/core/document/document.dart';
import 'package:velin/shared/extensions/extensions.dart';
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

  static const height = 36.0;

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    // A neutral strip; the selected tab takes the toolbar's colour so it
    // reads as attached to the document below.
    return Container(
      height: height,
      color: colorScheme.surfaceContainer,
      padding: const EdgeInsets.only(
        left: AppSpacing.sm,
        right: AppSpacing.sm,
        top: AppSpacing.xs,
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          for (final document in documents)
            Flexible(
              child: ReaderDocumentTab(
                document: document,
                isSelected: document == selectedDocument,
                onSelected: onDocumentSelected,
                onClosed: onDocumentClosed,
              ),
            ),
          if (documents.isNotEmpty)
            Padding(
              padding: const EdgeInsets.only(
                left: AppSpacing.xs,
                bottom: AppSpacing.xs,
              ),
              child: Center(
                child: ToolbarIconButton(
                  icon: Icons.add,
                  tooltip: context.l10n.commonOpenDocument,
                  onPressed: onOpenDocument,
                ),
              ),
            ),
        ],
      ),
    );
  }
}
