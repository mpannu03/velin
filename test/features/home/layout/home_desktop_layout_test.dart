import 'package:flutter_test/flutter_test.dart';
import 'package:material_ui/material_ui.dart';
import 'package:velin/core/document/document.dart';
import 'package:velin/core/recent/recent.dart';
import 'package:velin/features/home/home.dart';

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

  setUp(() {
    openRequests = 0;
    resumed = [];
  });

  Future<void> pumpLayout(
    WidgetTester tester, {
    required List<RecentDocument> documents,
  }) async {
    await setViewSize(tester, const Size(1400, 1000));
    addTearDown(() => resetViewSize(tester));

    await pumpApp(
      tester,
      HomeDesktopLayout(
        viewModel: HomeViewModel(
          recentDocuments: documents,
          onRecentDocumentSelected: resumed.add,
          onOpenDocument: () => openRequests++,
          onBrowseTools: () {},
          thumbnailLoader: (_) async => null,
        ),
      ),
    );
    await tester.pump();
  }

  testWidgets('without recents: one Open button and an empty state', (
    tester,
  ) async {
    await pumpLayout(tester, documents: const []);

    expect(find.text('Open your first document'), findsOneWidget);
    expect(find.text('Open…'), findsOneWidget);
    expect(find.text('No recent documents yet'), findsOneWidget);
    expect(find.text('Continue reading'.toUpperCase()), findsNothing);
    expect(find.text('Recent'), findsNothing);

    await tester.tap(find.text('Open…'));
    expect(openRequests, 1);
  });

  testWidgets('with recents: one Open button and one Continue reading', (
    tester,
  ) async {
    await pumpLayout(tester, documents: recents);

    expect(find.text('Pick up where you left off'), findsOneWidget);
    expect(find.text('2 recent documents'), findsOneWidget);
    expect(find.text('Open…'), findsOneWidget);
    expect(find.text('CONTINUE READING'), findsOneWidget);
    expect(find.text('Resume'), findsOneWidget);
    expect(find.text('Recent'), findsOneWidget);
  });

  testWidgets('Resume opens the most recently read document', (tester) async {
    await pumpLayout(tester, documents: recents);

    await tester.tap(find.text('Resume'));

    expect(resumed, [recents.last]);
  });

  testWidgets('search without matches says so', (tester) async {
    await pumpLayout(tester, documents: recents);

    await tester.enterText(find.byType(TextField), 'nothing-like-this');
    await tester.pump();

    expect(find.text('No matches for "nothing-like-this".'), findsOneWidget);
  });
}
