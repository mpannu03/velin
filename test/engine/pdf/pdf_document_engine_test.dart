import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:pdfrx/pdfrx.dart';
import 'package:velin/core/document/document.dart';
import 'package:velin/core/document/engine/engine.dart';
import 'package:velin/engine/engine.dart';

class MockPdfViewerController extends Mock implements PdfViewerController {}

class MockDocumentEngineListener extends Mock
    implements DocumentEngineListener {}

class MockDocument extends Mock implements Document {}

void main() {
  late MockPdfViewerController controller;
  late MockDocument document;
  late PdfDocumentEngine engine;

  setUp(() {
    controller = MockPdfViewerController();
    document = MockDocument();

    when(() => document.path).thenReturn('test.pdf');

    engine = PdfDocumentEngine(
      document: document,
      controller: controller,
    );
  });

  group('capabilities', () {
    test('returns the supported capabilities', () {
      final capabilities = engine.capabilities;

      expect(capabilities.textSelection, isTrue);
      expect(capabilities.search, isTrue);
      expect(capabilities.bookmarks, isTrue);
      expect(capabilities.comments, isFalse);
    });
  });

  group('snapshot', () {
    test('returns the current controller state', () {
      when(() => controller.pageNumber).thenReturn(3);
      when(() => controller.pageCount).thenReturn(10);
      when(() => controller.currentZoom).thenReturn(1.5);

      final snapshot = engine.snapshot;

      expect(snapshot.currentPage, 3);
      expect(snapshot.pageCount, 10);
      expect(snapshot.zoom, 1.5);
    });

    test('returns null when there is no current page', () {
      when(() => controller.pageNumber).thenReturn(null);
      when(() => controller.pageCount).thenReturn(10);
      when(() => controller.currentZoom).thenReturn(1.0);

      final snapshot = engine.snapshot;

      expect(snapshot.currentPage, isNull);
      expect(snapshot.pageCount, 10);
      expect(snapshot.zoom, 1.0);
    });
  });

  group('listener', () {
    test('can set and read the listener', () {
      final listener = MockDocumentEngineListener();

      engine.listener = listener;

      expect(engine.listener, same(listener));
    });

    test('can clear the listener', () {
      final listener = MockDocumentEngineListener();

      engine.listener = listener;
      engine.listener = null;

      expect(engine.listener, isNull);
    });
  });

  group('actions', () {
    test('exposes document engine actions', () {
      expect(engine.actions, isA<PdfDocumentEngineActions>());
    });
  });

  group('capabilities before viewer is ready', () {
    test('text search is not initialized', () {
      expect(engine.textSearch, isNull);
    });

    test('bookmark capability is not initialized', () {
      expect(engine.bookmark, isNull);
    });

    test('annotation capability is not initialized', () {
      expect(engine.annotation, isNull);
    });
  });
}