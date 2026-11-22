import 'package:flutter_test/flutter_test.dart';
import 'package:material_ui/material_ui.dart';
import 'package:velin/core/document/document.dart';
import 'package:velin/core/recent/recent.dart';
import 'package:velin/features/home/home.dart';
import 'package:velin/features/tools/tools.dart';

import '../../../helpers/helpers.dart';

void main() {
  final recents = [
    RecentDocument(
      path: '/docs/older.pdf',
      pageCount: 10,
      currentPage: 10,
      lastOpenedAt: DateTime(2026, 1, 1),
      documentType: DocumentType.pdf,
    ),
    RecentDocument(
      path: '/docs/latest.pdf',
      pageCount: 40,
      currentPage: 10,
      lastOpenedAt: DateTime(2026, 2, 1),
      documentType: DocumentType.pdf,
    ),
  ];

  late int openRequests;
  late List<RecentDocument> resumed;
  late List<ToolDefinition> toolsSelected;

  setUp(() {
    openRequests = 0;
    resumed = [];
    toolsSelected = [];
  });

  Future<void> pumpLayout(
    WidgetTester tester, {
    required List<RecentDocument> documents,
    Size size = const Size(1400, 1000),
  }) async {
    await setViewSize(tester, size);
    addTearDown(() => resetViewSize(tester));

    await pumpApp(
      tester,
      HomeDesktopLayout(
        viewModel: HomeViewModel(
          recentDocuments: documents,
          onRecentDocumentSelected: resumed.add,
          onOpenDocument: () => openRequests++,
          onBrowseTools: () {},
          onToolSelected: toolsSelected.add,
          thumbnailLoader: (_) async => null,
        ),
      ),
    );
    await tester.pump();
  }

  testWidgets('without recents: an invitation with one Open button', (
    tester,
  ) async {
    await pumpLayout(tester, documents: const []);

    expect(find.text('Open your first document'), findsOneWidget);
    expect(find.text('Open…'), findsOneWidget);
    expect(find.text('Jump back in'), findsNothing);
    expect(find.text('All documents'), findsNothing);

    await tester.tap(find.text('Open…'));
    expect(openRequests, 1);
  });

  testWidgets('with recents: covers, one Open button and the table', (
    tester,
  ) async {
    await pumpLayout(tester, documents: recents);

    expect(find.text('Jump back in'), findsOneWidget);
    expect(find.text('Open…'), findsOneWidget);
    expect(find.text('All documents'), findsOneWidget);
    // Each document appears on a cover and in the table.
    expect(find.text('latest'), findsNWidgets(2));
    expect(find.text('older'), findsNWidgets(2));
  });

  testWidgets('covers start with the most recently opened document', (
    tester,
  ) async {
    await pumpLayout(tester, documents: recents);

    await tester.tap(find.text('latest').first);

    expect(resumed, [recents.last]);
  });

  testWidgets('clicking a table row opens that document', (tester) async {
    await pumpLayout(tester, documents: recents);

    await tester.tap(find.text('older').last);

    expect(resumed, [recents.first]);
  });

  testWidgets('the Progress heading sorts the table by progress', (
    tester,
  ) async {
    await pumpLayout(tester, documents: recents);

    await tester.tap(find.text('Progress'));
    await tester.pump();

    // older is finished, latest a quarter read.
    final latestY = tester.getTopLeft(find.text('latest').last).dy;
    final olderY = tester.getTopLeft(find.text('older').last).dy;
    expect(olderY, lessThan(latestY));
  });

  testWidgets('search without matches says so', (tester) async {
    await pumpLayout(tester, documents: recents);

    await tester.enterText(find.byType(TextField), 'nothing-like-this');
    await tester.pump();

    expect(find.text('No matches for "nothing-like-this".'), findsOneWidget);
  });

  testWidgets('wide windows show the quick tools in a side pane', (
    tester,
  ) async {
    await pumpLayout(tester, documents: recents);

    expect(find.byType(HomeToolsPane), findsOneWidget);
    expect(find.byType(HomeQuickTools), findsNothing);

    await tester.tap(find.text('Merge PDF'));
    expect(toolsSelected, [ToolRegistry.mergePdf]);
  });

  testWidgets('the tools pane is there before anything was opened', (
    tester,
  ) async {
    await pumpLayout(tester, documents: const []);

    expect(find.text('Open your first document'), findsOneWidget);
    expect(find.byType(HomeToolsPane), findsOneWidget);
  });

  testWidgets('narrow windows show the quick tools under the covers', (
    tester,
  ) async {
    await pumpLayout(tester, documents: recents, size: const Size(900, 1000));

    expect(find.byType(HomeToolsPane), findsNothing);
    expect(find.byType(HomeQuickTools), findsOneWidget);

    await tester.tap(find.text('Compress PDF'));
    expect(toolsSelected, [ToolRegistry.compressPdf]);
  });
}
