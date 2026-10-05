import 'package:flutter_test/flutter_test.dart';
import 'package:material_ui/material_ui.dart';
import 'package:mocktail/mocktail.dart';
import 'package:pdfrx/pdfrx.dart';
import 'package:velin/engine/engine.dart';

class MockPdfViewerController extends Mock implements PdfViewerController {}

void main() {
  late MockPdfViewerController controller;
  late PdfDocumentEngineActions actions;

  setUp(() {
    controller = MockPdfViewerController();
    actions = PdfDocumentEngineActions(controller);
  });

  group('goToPage', () {
    test('does nothing when page is below 1', () async {
      when(() => controller.pageCount).thenReturn(10);

      await actions.goToPage(0);

      verifyNever(
        () =>
            controller.calcMatrixForPage(pageNumber: any(named: 'pageNumber')),
      );
      verifyNever(() => controller.goTo(any()));
    });

    test('does nothing when page is greater than page count', () async {
      when(() => controller.pageCount).thenReturn(10);

      await actions.goToPage(11);

      verifyNever(
        () =>
            controller.calcMatrixForPage(pageNumber: any(named: 'pageNumber')),
      );
      verifyNever(() => controller.goTo(any()));
    });

    test('calculates matrix and navigates to valid page', () async {
      final matrix = Matrix4.identity();

      when(() => controller.pageCount).thenReturn(10);
      when(() => controller.calcMatrixForPage(pageNumber: 5))
          .thenReturn(matrix);
      when(() => controller.goTo(matrix)).thenAnswer((_) async {});

      await actions.goToPage(5);

      verify(() => controller.calcMatrixForPage(pageNumber: 5)).called(1);
      verify(() => controller.goTo(matrix)).called(1);
    });
  });

  group('zoom', () {
    test('zooms in by 0.2', () async {
      final visibleRect = Rect.fromLTWH(0, 0, 100, 100);

      when(() => controller.currentZoom).thenReturn(1.0);
      when(() => controller.minScale).thenReturn(0.5);
      when(() => controller.maxScale).thenReturn(3.0);
      when(() => controller.visibleRect).thenReturn(visibleRect);

      when(() => controller.setZoom(visibleRect.center, 1.2))
          .thenAnswer((_) async {});

      await actions.zoomIn();

      verify(() => controller.setZoom(visibleRect.center, 1.2)).called(1);
    });

    test('zooms out by 0.2', () async {
      final visibleRect = Rect.fromLTWH(0, 0, 100, 100);

      when(() => controller.currentZoom).thenReturn(1.0);
      when(() => controller.minScale).thenReturn(0.5);
      when(() => controller.maxScale).thenReturn(3.0);
      when(() => controller.visibleRect).thenReturn(visibleRect);

      when(() => controller.setZoom(visibleRect.center, 0.8))
          .thenAnswer((_) async {});

      await actions.zoomOut();

      verify(() => controller.setZoom(visibleRect.center, 0.8)).called(1);
    });

    test('clamps zoom in to maximum scale', () async {
      final visibleRect = Rect.fromLTWH(0, 0, 100, 100);

      when(() => controller.currentZoom).thenReturn(2.9);
      when(() => controller.minScale).thenReturn(0.5);
      when(() => controller.maxScale).thenReturn(3.0);
      when(() => controller.visibleRect).thenReturn(visibleRect);

      when(() => controller.setZoom(visibleRect.center, 3.0))
          .thenAnswer((_) async {});

      await actions.zoomIn();

      verify(() => controller.setZoom(visibleRect.center, 3.0)).called(1);
    });

    test('clamps zoom out to minimum scale', () async {
      final visibleRect = Rect.fromLTWH(0, 0, 100, 100);

      when(() => controller.currentZoom).thenReturn(0.6);
      when(() => controller.minScale).thenReturn(0.5);
      when(() => controller.maxScale).thenReturn(3.0);
      when(() => controller.visibleRect).thenReturn(visibleRect);

      when(() => controller.setZoom(visibleRect.center, 0.5))
          .thenAnswer((_) async {});

      await actions.zoomOut();

      verify(() => controller.setZoom(visibleRect.center, 0.5)).called(1);
    });
  });

  group('fitWidth', () {
    test('fits the current page to width', () async {
      when(() => controller.pageNumber).thenReturn(3);

      when(() => controller.calcMatrixFitWidthForPage(pageNumber: 3))
          .thenReturn(null);

      await actions.fitWidth();

      verify(() => controller.calcMatrixFitWidthForPage(pageNumber: 3))
          .called(1);
    });

    test('uses page 1 when there is no current page', () async {
      when(() => controller.pageNumber).thenReturn(null);

      when(() => controller.calcMatrixFitWidthForPage(pageNumber: 1))
          .thenReturn(null);

      await actions.fitWidth();

      verify(() => controller.calcMatrixFitWidthForPage(pageNumber: 1))
          .called(1);
    });

    test('does not navigate when matrix is null', () async {
      when(() => controller.pageNumber).thenReturn(3);

      when(() => controller.calcMatrixFitWidthForPage(pageNumber: 3))
          .thenReturn(null);

      await actions.fitWidth();

      verifyNever(() => controller.goTo(any()));
    });
  });

  group('fitPage', () {
    test('fits the current page', () async {
      when(() => controller.pageNumber).thenReturn(3);

      when(() => controller.calcMatrixForFit(pageNumber: 3)).thenReturn(null);

      await actions.fitPage();

      verify(() => controller.calcMatrixForFit(pageNumber: 3)).called(1);
    });

    test('uses page 1 when there is no current page', () async {
      when(() => controller.pageNumber).thenReturn(null);

      when(() => controller.calcMatrixForFit(pageNumber: 1)).thenReturn(null);

      await actions.fitPage();

      verify(() => controller.calcMatrixForFit(pageNumber: 1)).called(1);
    });

    test('does not navigate when matrix is null', () async {
      when(() => controller.pageNumber).thenReturn(3);

      when(() => controller.calcMatrixForFit(pageNumber: 3)).thenReturn(null);

      await actions.fitPage();

      verifyNever(() => controller.goTo(any()));
    });
  });

  group('nextPage', () {
    test('goes to the next page', () async {
      when(() => controller.pageNumber).thenReturn(3);
      when(() => controller.pageCount).thenReturn(10);

      when(() => controller.calcMatrixForPage(pageNumber: 4))
          .thenReturn(Matrix4.identity());

      when(() => controller.goTo(any())).thenAnswer((_) => Future.value());

      await actions.nextPage();

      verify(() => controller.calcMatrixForPage(pageNumber: 4)).called(1);
    });

    test('does nothing when there is no current page', () async {
      when(() => controller.pageNumber).thenReturn(null);
      when(() => controller.pageCount).thenReturn(10);

      await actions.nextPage();

      verifyNever(
        () =>
            controller.calcMatrixForPage(pageNumber: any(named: 'pageNumber')),
      );
    });

    test('does nothing when already on the last page', () async {
      when(() => controller.pageNumber).thenReturn(10);
      when(() => controller.pageCount).thenReturn(10);

      await actions.nextPage();

      verifyNever(
        () =>
            controller.calcMatrixForPage(pageNumber: any(named: 'pageNumber')),
      );
    });
  });

  group('previousPage', () {
    test('goes to the previous page', () async {
      when(() => controller.pageNumber).thenReturn(3);
      when(() => controller.pageCount).thenReturn(10);

      when(() => controller.calcMatrixForPage(pageNumber: 2))
          .thenReturn(Matrix4.identity());

      when(() => controller.goTo(any())).thenAnswer((_) => Future.value());

      await actions.previousPage();

      verify(() => controller.calcMatrixForPage(pageNumber: 2)).called(1);
    });

    test('does nothing when there is no current page', () async {
      when(() => controller.pageNumber).thenReturn(null);
      when(() => controller.pageCount).thenReturn(10);

      await actions.previousPage();

      verifyNever(
        () =>
            controller.calcMatrixForPage(pageNumber: any(named: 'pageNumber')),
      );
    });

    test('does nothing when already on the first page', () async {
      when(() => controller.pageNumber).thenReturn(1);
      when(() => controller.pageCount).thenReturn(10);

      await actions.previousPage();

      verifyNever(
        () =>
            controller.calcMatrixForPage(pageNumber: any(named: 'pageNumber')),
      );
    });
  });
}
