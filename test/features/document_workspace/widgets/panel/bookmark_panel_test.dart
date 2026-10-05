import 'package:flutter_test/flutter_test.dart';
import 'package:material_ui/material_ui.dart';
import 'package:velin/core/document/engine/engine.dart';
import 'package:velin/features/document_workspace/document_workspace.dart';

import '../../../../helpers/helpers.dart';

void main() {
  group('BookmarkPanel', () {
    testWidgets('shows empty state when there are no bookmarks', (
      tester,
    ) async {
      await pumpApp(
        tester,
        BookmarkPanel(bookmarks: const [], onBookmarkSelected: (_) {}),
      );

      expect(find.text('No bookmarks'), findsOneWidget);
    });

    testWidgets('displays bookmark titles', (tester) async {
      final bookmarks = [
        Bookmark(id: "1", title: 'Introduction', children: const [], page: 1),
        Bookmark(id: "2", title: 'Chapter 1', children: const [], page: 2),
      ];

      await pumpApp(
        tester,
        BookmarkPanel(bookmarks: bookmarks, onBookmarkSelected: (_) {}),
      );

      expect(find.text('Introduction'), findsOneWidget);
      expect(find.text('Chapter 1'), findsOneWidget);
    });

    testWidgets('calls callback when a bookmark is selected', (tester) async {
      final bookmark = Bookmark(
        id: "3",
        title: 'Introduction',
        children: const [],
        page: 3,
      );

      Bookmark? selectedBookmark;

      await pumpApp(
        tester,
        BookmarkPanel(
          bookmarks: [bookmark],
          onBookmarkSelected: (value) => selectedBookmark = value,
        ),
      );

      await tester.tap(find.text('Introduction'));

      expect(selectedBookmark, same(bookmark));
    });

    testWidgets('expands and collapses child bookmarks', (tester) async {
      final bookmarks = [
        Bookmark(
          id: '1',
          title: 'Chapter 1',
          page: 2,
          children: [
            Bookmark(
              id: '1.1',
              title: 'Section 1.1',
              page: 2,
              children: const [],
            ),
          ],
        ),
      ];

      await pumpApp(
        tester,
        BookmarkPanel(bookmarks: bookmarks, onBookmarkSelected: (_) {}),
      );

      expect(find.text('Section 1.1').hitTestable(), findsNothing);

      await tester.tap(find.byIcon(Icons.expand_more));
      await tester.pumpAndSettle();

      expect(find.text('Section 1.1'), findsOneWidget);

      await tester.tap(find.byIcon(Icons.expand_less));
      await tester.pumpAndSettle();

      expect(find.text('Section 1.1').hitTestable(), findsNothing);
    });

    testWidgets('selects a nested bookmark', (tester) async {
      final child = Bookmark(
        id: '1.1',
        title: 'Section 1.1',
        page: 2,
        children: const [],
      );

      final bookmarks = [
        Bookmark(id: '1', title: 'Chapter 1', page: 2, children: [child]),
      ];

      Bookmark? selectedBookmark;

      await pumpApp(
        tester,
        BookmarkPanel(
          bookmarks: bookmarks,
          onBookmarkSelected: (value) => selectedBookmark = value,
        ),
      );

      await tester.tap(find.byIcon(Icons.expand_more));
      await tester.pumpAndSettle();

      await tester.tap(find.text('Section 1.1'));

      expect(selectedBookmark, same(child));
    });
  });
}
