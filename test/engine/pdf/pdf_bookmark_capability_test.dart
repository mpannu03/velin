import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:pdfrx/pdfrx.dart';
import 'package:velin/core/document/engine/engine.dart';
import 'package:velin/engine/engine.dart';

class MockPdfViewerController extends Mock
    implements PdfViewerController {}

class MockPdfDocument extends Mock implements PdfDocument {}

void main() {
  late MockPdfViewerController controller;
  late MockPdfDocument document;
  late PdfBookmarkCapability capability;

  setUp(() {
    controller = MockPdfViewerController();
    document = MockPdfDocument();

    when(() => controller.document).thenReturn(document);
    when(() => controller.goToPage(pageNumber: any(named: 'pageNumber'))).thenAnswer(
      (invocation) => Future.value(),
    );

    capability = PdfBookmarkCapability(controller);
  });

  test('loads bookmarks from the PDF outline', () async {
    when(() => document.loadOutline()).thenAnswer(
      (_) async => [
        PdfOutlineNode(
          title: 'Chapter 1',
          dest: null,
          children: const [],
        ),
      ],
    );

    final bookmarks = await capability.bookmarks;

    expect(bookmarks, hasLength(1));
    expect(bookmarks.first.title, 'Chapter 1');
    expect(bookmarks.first.page, 1);
    expect(bookmarks.first.id, '0');
  });

  test('converts nested bookmarks with hierarchical ids', () async {
    when(() => document.loadOutline()).thenAnswer(
      (_) async => [
        PdfOutlineNode(
          title: 'Chapter 1',
          dest: null,
          children: [
            PdfOutlineNode(
              title: 'Section 1',
              dest: null,
              children: const [],
            ),
            PdfOutlineNode(
              title: 'Section 2',
              dest: null,
              children: const [],
            ),
          ],
        ),
      ],
    );

    final bookmarks = await capability.bookmarks;

    expect(bookmarks, hasLength(1));
    expect(bookmarks.first.id, '0');
    expect(bookmarks.first.children, hasLength(2));
    expect(bookmarks.first.children[0].id, '0.0');
    expect(bookmarks.first.children[0].title, 'Section 1');
    expect(bookmarks.first.children[1].id, '0.1');
    expect(bookmarks.first.children[1].title, 'Section 2');
  });

  test('caches bookmarks after the first load', () async {
    when(() => document.loadOutline()).thenAnswer(
      (_) async => [
        PdfOutlineNode(
          title: 'Chapter 1',
          dest: null,
          children: const [],
        ),
      ],
    );

    final first = await capability.bookmarks;
    final second = await capability.bookmarks;

    expect(second, same(first));

    verify(
      () => document.loadOutline(),
    ).called(1);
  });

  test('goes to the bookmark page', () {
    final bookmark = Bookmark(
      id: '0',
      title: 'Chapter 1',
      page: 5,
      children: const [],
    );

    capability.goto(bookmark);

    verify(
      () => controller.goToPage(pageNumber: 5),
    ).called(1);
  });
}