@Tags(['pdfium'])
library;

import 'dart:io';

import 'package:flutter_test/flutter_test.dart';
import 'package:image/image.dart' as img;
import 'package:path/path.dart' as p;
import 'package:pdfrx_engine/pdfrx_engine.dart' show pdfrxInitialize;
import 'package:velin/core/result/result.dart';
import 'package:velin/engine/engine.dart';

/// Page previews against the real pdfium binary. Run with
/// `flutter test --tags pdfium`.
void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  late Directory dir;
  late File samplePdf;

  setUpAll(() async {
    await pdfrxInitialize(
      tmpPath: Directory.systemTemp.createTempSync('velin_pdfium_').path,
    );
  });

  setUp(() async {
    dir = Directory.systemTemp.createTempSync('velin_preview_');

    final png = File(p.join(dir.path, 'page.png'))
      ..writeAsBytesSync(
        img.encodePng(img.Image(width: 300, height: 200, numChannels: 4)),
      );

    samplePdf = File(p.join(dir.path, 'sample.pdf'));

    await const ImageToPdfEngine().convert(
      input: ImageToPdfInput(images: [png, png, png]),
      outputFile: samplePdf,
    );
  });

  tearDown(() => dir.deleteSync(recursive: true));

  Future<PdfPreviewDocument> open() async {
    final result = await PdfPageRenderer().openPreview(samplePdf.path);
    return (result as Success<PdfPreviewDocument>).data;
  }

  test('reports the page count and page shape', () async {
    final preview = await open();
    addTearDown(preview.dispose);

    expect(preview.pageCount, 3);
    expect(preview.aspectRatio(1), greaterThan(0));
  });

  test('renders a page at the asked width, keeping its shape', () async {
    final preview = await open();
    addTearDown(preview.dispose);

    final image = await preview.renderPage(2, width: 120);
    addTearDown(() => image?.dispose());

    expect(image, isNotNull);
    expect(image!.width, 120);
    expect(image.width / image.height, closeTo(preview.aspectRatio(2), 0.05));
  });

  test('renders asked-for pages one after another', () async {
    final preview = await open();
    addTearDown(preview.dispose);

    final images = await Future.wait([
      for (var page = 1; page <= 3; page++) preview.renderPage(page, width: 60),
    ]);
    addTearDown(() {
      for (final image in images) {
        image?.dispose();
      }
    });

    expect(images, everyElement(isNotNull));
  });

  test('renders nothing once disposed', () async {
    final preview = await open();
    await preview.dispose();

    expect(await preview.renderPage(1, width: 60), isNull);
  });

  test('fails to open a file that is not a PDF', () async {
    final notPdf = File(p.join(dir.path, 'note.pdf'))
      ..writeAsStringSync('not a pdf');

    final result = await PdfPageRenderer().openPreview(notPdf.path);

    expect(result, isA<Failure<PdfPreviewDocument>>());
  });
}
