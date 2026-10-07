import 'package:flutter_test/flutter_test.dart';
import 'package:velin/features/document_workspace/document_workspace.dart';

import '../../../../helpers/helpers.dart';

void main() {
  group('DocumentWorkspacePanel', () {
    testWidgets('renders comments panel', (tester) async {
      await pumpApp(
        tester,
        DocumentWorkspacePanel(
          panel: WorkspacePanel.comments,
          searchState: SearchState(),
          onTextSearch: (_, _) {},
          onClearSearch: () {},
          onTextSearchResultSelected: (_) {},
          bookmarks: const [],
          onBookmarkSelected: (_) {},
          annotations: const [],
          onAnnotationSelected: (_) {},
          dictionaryState: DictionaryState(),
          onDictionaryLookup: (_) {},
          onClearDictionary: () {},
        ),
      );

      expect(find.byType(CommentPanel), findsOneWidget);
    });

    testWidgets('renders bookmarks panel', (tester) async {
      await pumpApp(
        tester,
        DocumentWorkspacePanel(
          panel: WorkspacePanel.bookmarks,
          searchState: SearchState(),
          onTextSearch: (_, _) {},
          onClearSearch: () {},
          onTextSearchResultSelected: (_) {},
          bookmarks: const [],
          onBookmarkSelected: (_) {},
          annotations: const [],
          onAnnotationSelected: (_) {},
          dictionaryState: DictionaryState(),
          onDictionaryLookup: (_) {},
          onClearDictionary: () {},
        ),
      );

      expect(find.byType(BookmarkPanel), findsOneWidget);
    });

    testWidgets('renders search panel', (tester) async {
      await pumpApp(
        tester,
        DocumentWorkspacePanel(
          panel: WorkspacePanel.search,
          searchState: SearchState(),
          onTextSearch: (_, _) {},
          onClearSearch: () {},
          onTextSearchResultSelected: (_) {},
          bookmarks: const [],
          onBookmarkSelected: (_) {},
          annotations: const [],
          onAnnotationSelected: (_) {},
          dictionaryState: DictionaryState(),
          onDictionaryLookup: (_) {},
          onClearDictionary: () {},
        ),
      );

      expect(find.byType(SearchPanel), findsOneWidget);
    });

    testWidgets('renders dictionary panel', (tester) async {
      await pumpApp(
        tester,
        DocumentWorkspacePanel(
          panel: WorkspacePanel.dictionary,
          searchState: SearchState(),
          onTextSearch: (_, _) {},
          onClearSearch: () {},
          onTextSearchResultSelected: (_) {},
          bookmarks: const [],
          onBookmarkSelected: (_) {},
          annotations: const [],
          onAnnotationSelected: (_) {},
          dictionaryState: DictionaryState(),
          onDictionaryLookup: (_) {},
          onClearDictionary: () {},
        ),
      );

      expect(find.byType(DictionaryPanel), findsOneWidget);
    });
  });
}
