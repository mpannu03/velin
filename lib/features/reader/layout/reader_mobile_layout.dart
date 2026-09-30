import 'package:material_ui/material_ui.dart';

import 'package:velin/features/reader/view/view.dart';
import 'package:velin/shared/widgets/widgets.dart';

import '../widgets/mobile_document_switcher.dart';

class ReaderMobileLayout extends StatelessWidget {
  const ReaderMobileLayout({
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
              child: MobileDocumentSwitcher(
                documents: viewModel.documents,
                selectedDocument: viewModel.selectedDocument,
                onDocumentSelected: viewModel.onDocumentSelected,
                onDocumentClosed: viewModel.onDocumentClosed,
              ),
            ),
            VelinIconButton(
              onPressed: viewModel.onOpenDocument,
              icon: Icons.add,
              tooltip: 'Open document',
            ),
          ],
        ),
        Expanded(
          child: viewModel.selectedDocument == null
              ? const Center(
                  child: Text('No document selected'),
                )
              : Text(
                  'Selected document: ${viewModel.selectedDocument!.path}',
                ),
        ),
      ],
    );
  }
}