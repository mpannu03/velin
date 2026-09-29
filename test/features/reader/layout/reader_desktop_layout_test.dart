import 'package:flutter_test/flutter_test.dart';
import 'package:velin/core/document/document.dart';
import 'package:velin/features/document_workspace/document_workspace_placeholder.dart';
import 'package:velin/features/reader/layout/reader_desktop_layout.dart';
import 'package:velin/features/reader/view/reader_view_model.dart';
import 'package:velin/features/reader/widgets/widgets.dart';

import '../../../helpers/helpers.dart';
void main() {
  group('ReaderDesktopLayout', () {
    late Document firstDocument;
    late Document secondDocument;

    setUp(() {
      firstDocument = Document(
        path: r'C:\Documents\first.pdf',
        type: DocumentType.pdf,
      );

      secondDocument = Document(
        path: r'C:\Documents\second.pdf',
        type: DocumentType.pdf,
      );
    });

    testWidgets('shows document tabs and selected document workspace', (
      tester,
    ) async {
      final viewModel = ReaderViewModel(
        documents: [
          firstDocument,
          secondDocument,
        ],
        selectedDocument: firstDocument,
        onDocumentSelected: (_) {},
        onDocumentClosed: (_) {},
        onOpenDocument: () {},
      );

      await pumpApp(
        tester,
        ReaderDesktopLayout(viewModel: viewModel),
      );

      expect(find.byType(ReaderDocumentTabs), findsOneWidget);
      expect(
        find.byType(DocumentWorkspacePlaceholder),
        findsOneWidget,
      );
    });

    testWidgets('shows empty state when no document is selected', (
      tester,
    ) async {
      final viewModel = ReaderViewModel(
        documents: [firstDocument],
        selectedDocument: null,
        onDocumentSelected: (_) {},
        onDocumentClosed: (_) {},
        onOpenDocument: () {},
      );

      await pumpApp(
        tester,
        ReaderDesktopLayout(viewModel: viewModel),
      );

      expect(find.byType(ReaderEmptyState), findsOneWidget);
      expect(
        find.byType(DocumentWorkspacePlaceholder),
        findsNothing,
      );
    });

    testWidgets('passes documents and selected document to tabs', (
      tester,
    ) async {
      final viewModel = ReaderViewModel(
        documents: [
          firstDocument,
          secondDocument,
        ],
        selectedDocument: secondDocument,
        onDocumentSelected: (_) {},
        onDocumentClosed: (_) {},
        onOpenDocument: () {},
      );

      await pumpApp(
        tester,
        ReaderDesktopLayout(viewModel: viewModel),
      );

      final tabs = tester.widget<ReaderDocumentTabs>(
        find.byType(ReaderDocumentTabs),
      );

      expect(tabs.documents, same(viewModel.documents));
      expect(tabs.selectedDocument, same(secondDocument));
    });
  });
}