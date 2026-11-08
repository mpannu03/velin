import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:material_ui/material_ui.dart';
import 'package:velin/core/document/document.dart';
import 'package:velin/features/reader/widgets/widgets.dart';

void main() {
  final first = Document(path: '/docs/first.pdf', type: DocumentType.pdf);
  final second = Document(path: '/docs/second.pdf', type: DocumentType.pdf);
  final third = Document(path: '/docs/third.pdf', type: DocumentType.pdf);

  late List<Document> selected;
  late List<Document> closed;

  setUp(() {
    selected = [];
    closed = [];
  });

  Future<void> pumpShortcuts(
    WidgetTester tester, {
    required Document? current,
    List<Document>? documents,
  }) async {
    await tester.pumpWidget(
      MaterialApp(
        home: ReaderShortcuts(
          documents: documents ?? [first, second, third],
          selectedDocument: current,
          onDocumentSelected: selected.add,
          onDocumentClosed: closed.add,
          child: const SizedBox.expand(),
        ),
      ),
    );
    // Focus is taken after the first frame.
    await tester.pump();
  }

  Future<void> pressWithControl(
    WidgetTester tester,
    LogicalKeyboardKey key, {
    bool shift = false,
  }) async {
    await tester.sendKeyDownEvent(LogicalKeyboardKey.controlLeft);
    if (shift) await tester.sendKeyDownEvent(LogicalKeyboardKey.shiftLeft);
    await tester.sendKeyEvent(key);
    if (shift) await tester.sendKeyUpEvent(LogicalKeyboardKey.shiftLeft);
    await tester.sendKeyUpEvent(LogicalKeyboardKey.controlLeft);
  }

  testWidgets('Ctrl+W closes the selected document', (tester) async {
    await pumpShortcuts(tester, current: second);

    await pressWithControl(tester, LogicalKeyboardKey.keyW);

    expect(closed, [second]);
  });

  testWidgets('Ctrl+W does nothing without a document', (tester) async {
    await pumpShortcuts(tester, current: null, documents: const []);

    await pressWithControl(tester, LogicalKeyboardKey.keyW);

    expect(closed, isEmpty);
  });

  testWidgets('Ctrl+Tab and Ctrl+PageDown select the next tab, wrapping', (
    tester,
  ) async {
    await pumpShortcuts(tester, current: third);

    await pressWithControl(tester, LogicalKeyboardKey.tab);
    await pressWithControl(tester, LogicalKeyboardKey.pageDown);

    expect(selected, [first, first]);
  });

  testWidgets('Ctrl+Shift+Tab and Ctrl+PageUp select the previous tab', (
    tester,
  ) async {
    await pumpShortcuts(tester, current: first);

    await pressWithControl(tester, LogicalKeyboardKey.tab, shift: true);
    await pressWithControl(tester, LogicalKeyboardKey.pageUp);

    expect(selected, [third, third]);
  });
}
