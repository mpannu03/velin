import 'package:flutter_test/flutter_test.dart';
import 'package:material_ui/material_ui.dart';
import 'package:velin/core/document/document.dart';
import 'package:velin/features/reader/widgets/reader_document_tab.dart';

import '../../../helpers/helpers.dart';

void main() {
  group('ReaderDocumentTab', () {
    late Document document;

    setUp(() {
      document = Document(
        path: r'C:\Documents\example.pdf',
        type: DocumentType.pdf,
      );
    });

    testWidgets('shows document file name', (tester) async {
      await pumpApp(
        tester,
        ReaderDocumentTab(
          document: document,
          isSelected: false,
          onSelected: (_) {},
          onClosed: (_) {},
        ),
      );

      expect(find.text('example.pdf'), findsOneWidget);
      expect(find.text(r'C:\Documents\example.pdf'), findsNothing);
    });

    testWidgets('calls onSelected when tab is tapped', (tester) async {
      Document? selectedDocument;

      await pumpApp(
        tester,
        ReaderDocumentTab(
          document: document,
          isSelected: false,
          onSelected: (value) {
            selectedDocument = value;
          },
          onClosed: (_) {},
        ),
      );

      await tester.tap(find.text('example.pdf'));

      expect(selectedDocument, same(document));
    });

    testWidgets('calls onClosed when close button is tapped', (tester) async {
      Document? closedDocument;

      await pumpApp(
        tester,
        ReaderDocumentTab(
          document: document,
          isSelected: false,
          onSelected: (_) {},
          onClosed: (value) {
            closedDocument = value;
          },
        ),
      );

      await tester.tap(find.byIcon(Icons.close));

      expect(closedDocument, same(document));
    });
  });
}
