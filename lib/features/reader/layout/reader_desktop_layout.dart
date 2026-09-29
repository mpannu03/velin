import 'package:material_ui/material_ui.dart';
import 'package:velin/features/document_workspace/document_workspace.dart';

import '../view/reader_view_model.dart';
import '../widgets/widgets.dart';

class ReaderDesktopLayout extends StatelessWidget {
  const ReaderDesktopLayout({
    super.key,
    required this.viewModel,
  });

  final ReaderViewModel viewModel;

  @override
  Widget build(BuildContext context) {
    final selectedDocument = viewModel.selectedDocument;

    return Column(
      children: [
        ReaderDocumentTabs(
          documents: viewModel.documents,
          selectedDocument: selectedDocument,
          onDocumentSelected: viewModel.onDocumentSelected,
          onDocumentClosed: viewModel.onDocumentClosed,
          onOpenDocument: viewModel.onOpenDocument,
        ),
        Expanded(
          child: selectedDocument == null
              ? ReaderEmptyState(
                  onOpenDocument: viewModel.onOpenDocument,
                )
              : IndexedStack(
                  index: viewModel.documents.indexOf(selectedDocument),
                  children: [
                    for (final document in viewModel.documents)
                      DocumentWorkspacePage(
                        key: ValueKey(document.path),
                        document: document,
                      ),
                  ],
                ),
        ),
      ],
    );
  }
}