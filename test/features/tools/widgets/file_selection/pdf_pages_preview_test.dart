import 'dart:ui' as ui;

import 'package:flutter_test/flutter_test.dart';
import 'package:material_ui/material_ui.dart';
import 'package:velin/core/di/injection.dart';
import 'package:velin/core/result/result.dart';
import 'package:velin/engine/rendering/rendering.dart';
import 'package:velin/features/tools/widgets/widgets.dart';

import '../../../../helpers/helpers.dart';

/// Rendering real pages is covered by the pdfium tests of
/// `PdfPreviewDocument`; here a fake document stands in for pdfium.
void main() {
  group('PdfPagesPreview', () {
    testWidgets('says so when the file cannot be previewed', (tester) async {
      // The test-wide renderer from flutter_test_config.dart never opens.
      await pumpApp(tester, const PdfPagesPreview(filePath: '/docs/a.pdf'));
      await tester.pump();

      expect(
        find.text('No preview for this file. It may be password protected.'),
        findsOneWidget,
      );
    });

    group('with a document', () {
      late _FakePreviewRenderer renderer;

      setUp(() {
        renderer = _FakePreviewRenderer();
        getIt.unregister<PdfPageRenderer>();
        getIt.registerSingleton<PdfPageRenderer>(renderer);
      });

      // flutter_test_config.dart registers its renderer again before the
      // next test.
      tearDown(() => getIt.unregister<PdfPageRenderer>());

      Future<void> pumpPreview(
        WidgetTester tester, {
        required int pages,
      }) async {
        renderer.pageCount = pages;
        await setViewSize(tester, const Size(1200, 2400));
        addTearDown(() => resetViewSize(tester));
        await pumpApp(
          tester,
          const SingleChildScrollView(
            child: PdfPagesPreview(filePath: '/docs/a.pdf'),
          ),
        );
        // Open the document, then let the queued page renders finish.
        await tester.runAsync(() => Future<void>.delayed(Duration.zero));
        await tester.pump();
        await tester.runAsync(() => renderer.document!.idle);
        await tester.pump();
      }

      testWidgets('shows the page count and every page of a short file', (
        tester,
      ) async {
        await pumpPreview(tester, pages: 3);

        expect(find.text('3 pages'), findsOneWidget);
        for (var page = 1; page <= 3; page++) {
          expect(find.bySemanticsLabel('Page $page'), findsOneWidget);
        }
        expect(find.textContaining('more page'), findsNothing);
      });

      testWidgets('draws the rendered pages', (tester) async {
        await pumpPreview(tester, pages: 2);

        expect(find.byType(RawImage), findsNWidgets(2));
        expect(renderer.document!.rendered, [1, 2]);
      });

      testWidgets('previews only the first pages of a long file', (
        tester,
      ) async {
        await pumpPreview(tester, pages: PdfPagesPreview.maxPages + 6);

        expect(
          find.text('${PdfPagesPreview.maxPages + 6} pages'),
          findsOneWidget,
        );
        expect(
          renderer.document!.rendered,
          hasLength(PdfPagesPreview.maxPages),
        );
        expect(find.text('+6 more pages'), findsOneWidget);
      });

      testWidgets('closes the document when it goes away', (tester) async {
        await pumpPreview(tester, pages: 1);

        await pumpApp(tester, const SizedBox());

        expect(renderer.document!.disposed, isTrue);
      });
    });
  });

  group('SingleFilePicker', () {
    testWidgets('previews the selected file by default', (tester) async {
      await pumpApp(
        tester,
        SingleFilePicker(filePath: '/docs/a.pdf', onPickFile: () {}),
      );

      expect(find.byType(PdfPagesPreview), findsOneWidget);
    });

    testWidgets('leaves the preview out when asked to', (tester) async {
      await pumpApp(
        tester,
        SingleFilePicker(
          filePath: '/docs/a.pdf',
          showPreview: false,
          onPickFile: () {},
        ),
      );

      expect(find.byType(PdfPagesPreview), findsNothing);
    });

    testWidgets('has no preview before a file is chosen', (tester) async {
      await pumpApp(tester, SingleFilePicker(onPickFile: () {}));

      expect(find.byType(PdfPagesPreview), findsNothing);
    });
  });
}

class _FakePreviewRenderer extends PdfPageRenderer {
  int pageCount = 1;
  _FakePreviewDocument? document;

  @override
  Future<Result<PdfPreviewDocument>> openPreview(String path) async {
    return Success(document = _FakePreviewDocument(pageCount));
  }
}

class _FakePreviewDocument implements PdfPreviewDocument {
  _FakePreviewDocument(this.pageCount);

  @override
  final int pageCount;

  final rendered = <int>[];
  final _pending = <Future<void>>[];
  bool disposed = false;

  /// Completes once every page asked for so far has been rendered.
  Future<void> get idle => Future.wait(_pending);

  @override
  double aspectRatio(int page) => 0.75;

  @override
  Future<ui.Image?> renderPage(int page, {required int width}) {
    final image = _image(page, width);
    _pending.add(image);
    return image;
  }

  Future<ui.Image?> _image(int page, int width) async {
    final recorder = ui.PictureRecorder();
    ui.Canvas(recorder).drawRect(
      ui.Rect.fromLTWH(0, 0, width.toDouble(), width / 0.75),
      ui.Paint()..color = const ui.Color(0xFFFFFFFF),
    );
    final image = await recorder.endRecording().toImage(
      width,
      (width / 0.75).round(),
    );
    rendered.add(page);
    return image;
  }

  @override
  Future<void> dispose() async => disposed = true;
}
