import 'package:material_ui/material_ui.dart';

import 'package:velin/features/document_workspace/document_workspace_placeholder.dart';
import 'package:velin/shared/widgets/widgets.dart';
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
    return Column(
      children: [
        Row(
          children: [
            Expanded(
              child: ReaderDocumentTabs(
                documents: viewModel.documents,
                selectedDocument: viewModel.selectedDocument,
                onDocumentSelected: viewModel.onDocumentSelected,
                onDocumentClosed: viewModel.onDocumentClosed,
              ),
            ),
            VelinIconButton(
              onPressed: viewModel.onOpenDocument, 
              icon: Icons.add, 
              tooltip: 'Open Document',
            ),
          ],
        ),
        Expanded(
          child: viewModel.selectedDocument == null
              ? const Center(
                  child: Text('No document selected'),
                )
              : DocumentWorkspacePlaceholder(
                  document: viewModel.selectedDocument!,
                ),
        ),
      ],
    );
  }
}