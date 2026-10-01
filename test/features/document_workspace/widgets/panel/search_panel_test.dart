import 'package:flutter_test/flutter_test.dart';
import 'package:material_ui/material_ui.dart';
import 'package:velin/core/document/engine/engine.dart';
import 'package:velin/features/document_workspace/document_workspace.dart';

import '../../../../helpers/helpers.dart';

void main() {
  group('SearchPanel', () {
    testWidgets('shows empty search state initially', (tester) async {
      await pumpApp(
        tester,
        SearchPanel(
          onTextSearch: (_, _) {},
          onClearSearch: () {},
          onTextSearchResultSelected: (_) {},
          results: const [],
          currentIndex: null,
          isLoading: false,
        ),
      );

      expect(find.byType(TextField), findsOneWidget);
      expect(find.text('Enter text to search'), findsOneWidget);
    });

    testWidgets('searches submitted text case insensitively by default', (
      tester,
    ) async {
      String? query;
      bool? caseInsensitive;

      await pumpApp(
        tester,
        SearchPanel(
          onTextSearch: (text, insensitive) {
            query = text;
            caseInsensitive = insensitive;
          },
          onClearSearch: () {},
          onTextSearchResultSelected: (_) {},
          results: const [],
          currentIndex: null,
          isLoading: false,
        ),
      );

      await tester.enterText(find.byType(TextField), 'flutter');
      await tester.testTextInput.receiveAction(TextInputAction.search);

      expect(query, 'flutter');
      expect(caseInsensitive, isTrue);
    });

    testWidgets('searches case sensitively after toggling case sensitivity', (
      tester,
    ) async {
      String? query;
      bool? caseInsensitive;

      await pumpApp(
        tester,
        SearchPanel(
          onTextSearch: (text, insensitive) {
            query = text;
            caseInsensitive = insensitive;
          },
          onClearSearch: () {},
          onTextSearchResultSelected: (_) {},
          results: const [],
          currentIndex: null,
          isLoading: false,
        ),
      );

      await tester.tap(
        find.byTooltip('Toggle Case Sensitivity'),
      );

      await tester.enterText(find.byType(TextField), 'Flutter');
      await tester.testTextInput.receiveAction(TextInputAction.search);

      expect(query, 'Flutter');
      expect(caseInsensitive, isFalse);
    });

    testWidgets('clears search when submitted text is empty', (
      tester,
    ) async {
      var clearCalled = false;
      var searchCalled = false;

      await pumpApp(
        tester,
        SearchPanel(
          onTextSearch: (_, _) => searchCalled = true,
          onClearSearch: () => clearCalled = true,
          onTextSearchResultSelected: (_) {},
          results: const [],
          currentIndex: null,
          isLoading: false,
        ),
      );

      await tester.testTextInput.receiveAction(TextInputAction.search);

      expect(clearCalled, isTrue);
      expect(searchCalled, isFalse);
    });

    testWidgets('clears search when clear button is tapped', (
      tester,
    ) async {
      var clearCalled = false;

      await pumpApp(
        tester,
        SearchPanel(
          onTextSearch: (_, _) {},
          onClearSearch: () => clearCalled = true,
          onTextSearchResultSelected: (_) {},
          results: const [],
          currentIndex: null,
          isLoading: false,
        ),
      );

      await tester.enterText(find.byType(TextField), 'flutter');

      await tester.tap(find.byTooltip('Clear Search'));

      expect(clearCalled, isTrue);
      expect(find.text('flutter'), findsNothing);
    });

    testWidgets('displays search results', (tester) async {
      const results = [
        TextSearchResult(
          index: 0,
          pageNumber: 2,
          text: 'Flutter is a UI toolkit.',
        ),
        TextSearchResult(
          index: 1,
          pageNumber: 5,
          text: 'Flutter supports multiple platforms.',
        ),
      ];

      await pumpApp(
        tester,
        SearchPanel(
          onTextSearch: (_, _) {},
          onClearSearch: () {},
          onTextSearchResultSelected: (_) {},
          results: results,
          currentIndex: null,
          isLoading: false,
        ),
      );

      expect(find.byType(SearchResultItem), findsNWidgets(2));
      expect(find.text('Flutter is a UI toolkit.'), findsOneWidget);
      expect(
        find.text('Flutter supports multiple platforms.'),
        findsOneWidget,
      );
      expect(find.text('Page 2'), findsOneWidget);
      expect(find.text('Page 5'), findsOneWidget);
    });

    testWidgets('displays result count', (tester) async {
      const results = [
        TextSearchResult(
          index: 0,
          pageNumber: 2,
          text: 'First result',
        ),
        TextSearchResult(
          index: 1,
          pageNumber: 5,
          text: 'Second result',
        ),
      ];

      await pumpApp(
        tester,
        SearchPanel(
          onTextSearch: (_, _) {},
          onClearSearch: () {},
          onTextSearchResultSelected: (_) {},
          results: results,
          currentIndex: null,
          isLoading: false,
        ),
      );

      expect(find.text('2 results found'), findsOneWidget);
    });

    testWidgets('selects search result when tapped', (tester) async {
      const result = TextSearchResult(
        index: 0,
        pageNumber: 3,
        text: 'Flutter result',
      );

      TextSearchResult? selectedResult;

      await pumpApp(
        tester,
        SearchPanel(
          onTextSearch: (_, _) {},
          onClearSearch: () {},
          onTextSearchResultSelected: (value) {
            selectedResult = value;
          },
          results: const [result],
          currentIndex: null,
          isLoading: false,
        ),
      );

      await tester.tap(find.text('Flutter result'));

      expect(selectedResult, same(result));
    });

    testWidgets('shows loading state', (tester) async {
      await pumpApp(
        tester,
        SearchPanel(
          onTextSearch: (_, _) {},
          onClearSearch: () {},
          onTextSearchResultSelected: (_) {},
          results: const [],
          currentIndex: null,
          isLoading: true,
        ),
      );

      expect(find.byType(LinearProgressIndicator), findsOneWidget);
      expect(find.byType(CircularProgressIndicator), findsOneWidget);
    });

    testWidgets('shows no match state after a submitted search with no results', (
      tester,
    ) async {
      await pumpApp(
        tester,
        SearchPanel(
          onTextSearch: (_, _) {},
          onClearSearch: () {},
          onTextSearchResultSelected: (_) {},
          results: const [],
          currentIndex: null,
          isLoading: false,
        ),
      );

      await tester.enterText(find.byType(TextField), 'flutter');
      await tester.testTextInput.receiveAction(TextInputAction.search);
      await tester.pumpAndSettle();

      expect(find.text('No match found'), findsOneWidget);
    });
  });
}