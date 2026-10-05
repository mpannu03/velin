import 'package:flutter_test/flutter_test.dart';
import 'package:material_ui/material_ui.dart';
import 'package:velin/core/document/document.dart';
import 'package:velin/features/reader/widgets/widgets.dart';

import '../../../helpers/helpers.dart';

void main() {
  group('ReaderDocumentTabs', () {
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

    testWidgets('shows all document tabs', (tester) async {
      await pumpApp(
        tester,
        ReaderDocumentTabs(
          documents: [firstDocument, secondDocument],
          selectedDocument: firstDocument,
          onDocumentSelected: (_) {},
          onDocumentClosed: (_) {},
          onOpenDocument: () {},
        ),
      );

      expect(find.text('first.pdf'), findsOneWidget);
      expect(find.text('second.pdf'), findsOneWidget);
      expect(find.byType(ReaderDocumentTab), findsNWidgets(2));
    });

    testWidgets('forwards document selection', (tester) async {
      Document? selectedDocument;

      await pumpApp(
        tester,
        ReaderDocumentTabs(
          documents: [firstDocument, secondDocument],
          selectedDocument: firstDocument,
          onDocumentSelected: (document) {
            selectedDocument = document;
          },
          onDocumentClosed: (_) {},
          onOpenDocument: () {},
        ),
      );

      await tester.tap(find.text('second.pdf'));

      expect(selectedDocument, same(secondDocument));
    });

    testWidgets('forwards document close', (tester) async {
      Document? closedDocument;

      await pumpApp(
        tester,
        ReaderDocumentTabs(
          documents: [firstDocument, secondDocument],
          selectedDocument: firstDocument,
          onDocumentSelected: (_) {},
          onDocumentClosed: (document) {
            closedDocument = document;
          },
          onOpenDocument: () {},
        ),
      );

      final closeButtons = find.byIcon(Icons.close);

      expect(closeButtons, findsNWidgets(2));

      await tester.tap(closeButtons.at(1));

      expect(closedDocument, same(secondDocument));
    });

    testWidgets('shows add button when documents exist', (tester) async {
      await pumpApp(
        tester,
        ReaderDocumentTabs(
          documents: [firstDocument],
          selectedDocument: firstDocument,
          onDocumentSelected: (_) {},
          onDocumentClosed: (_) {},
          onOpenDocument: () {},
        ),
      );

      expect(find.byIcon(Icons.add), findsOneWidget);
    });

    testWidgets('does not show add button when there are no documents', (
      tester,
    ) async {
      await pumpApp(
        tester,
        ReaderDocumentTabs(
          documents: const [],
          selectedDocument: null,
          onDocumentSelected: (_) {},
          onDocumentClosed: (_) {},
          onOpenDocument: () {},
        ),
      );

      expect(find.byIcon(Icons.add), findsNothing);
    });

    testWidgets('calls onOpenDocument when add button is tapped', (
      tester,
    ) async {
      var opened = false;

      await pumpApp(
        tester,
        ReaderDocumentTabs(
          documents: [firstDocument],
          selectedDocument: firstDocument,
          onDocumentSelected: (_) {},
          onDocumentClosed: (_) {},
          onOpenDocument: () {
            opened = true;
          },
        ),
      );

      await tester.tap(find.byIcon(Icons.add));

      expect(opened, isTrue);
    });
  });
}
