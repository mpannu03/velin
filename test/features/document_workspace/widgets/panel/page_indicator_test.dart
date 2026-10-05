import 'package:flutter_test/flutter_test.dart';
import 'package:material_ui/material_ui.dart';
import 'package:velin/features/document_workspace/document_workspace.dart';

import '../../../../helpers/helpers.dart';

void main() {
  group('PageIndicator', () {
    testWidgets('renders nothing when current page is unknown', (tester) async {
      await pumpApp(
        tester,
        PageIndicator(currentPage: null, pageCount: 10, onGotoPage: (_) {}),
      );

      expect(find.byType(EditableText), findsNothing);
    });

    testWidgets('renders nothing when page count is zero', (tester) async {
      await pumpApp(
        tester,
        PageIndicator(currentPage: 1, pageCount: 0, onGotoPage: (_) {}),
      );

      expect(find.byType(EditableText), findsNothing);
    });

    testWidgets('shows current page and page count', (tester) async {
      await pumpApp(
        tester,
        PageIndicator(currentPage: 3, pageCount: 10, onGotoPage: (_) {}),
      );

      expect(find.text('3'), findsOneWidget);
      expect(find.text('10'), findsOneWidget);
    });

    testWidgets('calls onGotoPage when valid page is submitted', (
      tester,
    ) async {
      int? selectedPage;

      await pumpApp(
        tester,
        PageIndicator(
          currentPage: 3,
          pageCount: 10,
          onGotoPage: (page) => selectedPage = page,
        ),
      );

      final input = find.byType(EditableText);

      await tester.tap(input);
      await tester.enterText(input, '7');
      await tester.testTextInput.receiveAction(TextInputAction.done);

      expect(selectedPage, 7);
    });

    testWidgets('rejects page greater than page count', (tester) async {
      int? selectedPage;

      await pumpApp(
        tester,
        PageIndicator(
          currentPage: 3,
          pageCount: 10,
          onGotoPage: (page) => selectedPage = page,
        ),
      );

      final input = find.byType(EditableText);

      await tester.tap(input);
      await tester.enterText(input, '11');
      await tester.testTextInput.receiveAction(TextInputAction.done);

      expect(selectedPage, isNull);
      expect(tester.widget<EditableText>(input).controller.text, '3');
    });

    testWidgets('rejects page below one', (tester) async {
      int? selectedPage;

      await pumpApp(
        tester,
        PageIndicator(
          currentPage: 3,
          pageCount: 10,
          onGotoPage: (page) => selectedPage = page,
        ),
      );

      final input = find.byType(EditableText);

      await tester.tap(input);
      await tester.enterText(input, '0');
      await tester.testTextInput.receiveAction(TextInputAction.done);

      expect(selectedPage, isNull);
      expect(tester.widget<EditableText>(input).controller.text, '3');
    });
  });
}
