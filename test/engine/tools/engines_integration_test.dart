@Tags(['pdfium'])
library;

import 'dart:io';

import 'package:flutter_test/flutter_test.dart';
import 'package:image/image.dart' as img;
import 'package:path/path.dart' as p;
import 'package:pdf_manipulator/pdf_manipulator.dart' show Pdf;
import 'package:pdfrx_engine/pdfrx_engine.dart' show pdfrxInitialize;
import 'package:velin/core/error/error.dart';
import 'package:velin/core/page_selection/page_selection.dart';
import 'package:velin/engine/engine.dart';

/// End-to-end checks of the tool engines against the real pdfium and
/// pdf_manipulator binaries.
///
/// These cover what mocks cannot: background-isolate work interleaved with
/// pdfium, and atomic writes. Run only these with `flutter test --tags pdfium`.
void main() {
  late Directory dir;
  late File samplePdf;

  setUpAll(() async {
    await pdfrxInitialize(
      tmpPath: Directory.systemTemp.createTempSync('velin_pdfium_').path,
    );
  });

  setUp(() async {
    dir = Directory.systemTemp.createTempSync('velin_engines_');

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

  File file(String name) => File(p.join(dir.path, name));

  void expectNoTemporaryFiles() {
    expect(
      dir.listSync(recursive: true).where((e) => e.path.endsWith('.tmp')),
      isEmpty,
    );
  }

  test('image to PDF produces one page per image', () async {
    final images = await const PdfToImageEngine().convert(
      input: PdfToImageInput(file: samplePdf),
      outputDirectory: Directory(p.join(dir.path, 'images')),
    );

    expect(images, hasLength(3));
    expectNoTemporaryFiles();
  });

  test('PDF to image encodes valid images off the UI isolate', () async {
    final images = await const PdfToImageEngine().convert(
      input: PdfToImageInput(
        file: samplePdf,
        colorMode: PdfImageColorMode.grayscale,
        format: PdfImageFormat.jpeg,
      ),
      outputDirectory: Directory(p.join(dir.path, 'images')),
    );

    expect(img.decodeJpg(images.first.readAsBytesSync()), isNotNull);
  });

  test('image to PDF rejects an unreadable image', () async {
    final notAnImage = file('fake.png')..writeAsStringSync('not an image');

    await expectLater(
      const ImageToPdfEngine().convert(
        input: ImageToPdfInput(images: [notAnImage]),
        outputFile: file('out.pdf'),
      ),
      throwsA(isA<InvalidImageFailure>()),
    );
    expect(file('out.pdf').existsSync(), isFalse);
  });

  test('compress, rotate, extract and merge write their outputs', () async {
    await const CompressPdfEngine().compress(
      input: CompressPdfInput(file: samplePdf),
      outputFile: file('compressed.pdf'),
    );
    await const RotatePdfEngine().rotate(
      inputFile: samplePdf,
      outputFile: file('rotated.pdf'),
      degrees: 90,
    );
    await const MergePdfEngine().merge(
      inputs: [
        MergePdfInput(file: samplePdf),
        MergePdfInput(file: samplePdf),
      ],
      outputFile: file('merged.pdf'),
    );

    for (final name in ['compressed.pdf', 'rotated.pdf', 'merged.pdf']) {
      expect(file(name).lengthSync(), greaterThan(0), reason: name);
    }
    expectNoTemporaryFiles();
  });

  test('rotate rejects page numbers beyond the document', () async {
    await expectLater(
      const RotatePdfEngine().rotate(
        inputFile: samplePdf,
        outputFile: file('rotated.pdf'),
        degrees: 90,
        selection: PageSelectionParser().parse('9'),
      ),
      // Engines may throw the raw selection error; the task boundary maps it.
      throwsA(
        predicate(
          (Object error) =>
              mapError(error, null) is InvalidPageSelectionFailure,
        ),
      ),
    );
  });

  group('never destroys the input', () {
    late List<int> original;

    setUp(() => original = samplePdf.readAsBytesSync());

    Future<void> expectRejected(Future<Object?> operation) async {
      await expectLater(operation, throwsA(isA<OutputSameAsInputFailure>()));
      expect(samplePdf.readAsBytesSync(), original);
    }

    test('encrypt and decrypt', () async {
      final pdf = Pdf();

      await expectRejected(
        EncryptPdfEngine(pdf: pdf).encrypt(
          EncryptPdfInput(
            inputFile: samplePdf,
            outputFile: samplePdf,
            ownerPassword: 'owner',
          ),
        ),
      );
      await expectRejected(
        DecryptPdfEngine(
          pdf: pdf,
        ).decrypt(DecryptPdfInput(inputFile: samplePdf, outputFile: samplePdf)),
      );
    });

    test('compress, rotate, extract and merge', () async {
      await expectRejected(
        const CompressPdfEngine().compress(
          input: CompressPdfInput(file: samplePdf),
          outputFile: samplePdf,
        ),
      );
      await expectRejected(
        const RotatePdfEngine().rotate(
          inputFile: samplePdf,
          outputFile: samplePdf,
          degrees: 90,
        ),
      );
      await expectRejected(
        const ExtractPdfEngine().extract(
          inputFile: samplePdf,
          selection: PageSelectionParser().parse('1'),
          outputFile: samplePdf,
        ),
      );
      await expectRejected(
        const MergePdfEngine().merge(
          inputs: [MergePdfInput(file: samplePdf)],
          outputFile: samplePdf,
        ),
      );
    });
  });

  test('encrypt then decrypt round-trips', () async {
    final pdf = Pdf();

    await EncryptPdfEngine(pdf: pdf).encrypt(
      EncryptPdfInput(
        inputFile: samplePdf,
        outputFile: file('locked.pdf'),
        ownerPassword: 'owner',
        userPassword: 'user',
      ),
    );

    await expectLater(
      DecryptPdfEngine(pdf: pdf).decrypt(
        DecryptPdfInput(
          inputFile: file('locked.pdf'),
          outputFile: file('wrong.pdf'),
          password: 'nope',
        ),
      ),
      throwsA(anything),
    );
    expect(file('wrong.pdf').existsSync(), isFalse);

    await DecryptPdfEngine(pdf: pdf).decrypt(
      DecryptPdfInput(
        inputFile: file('locked.pdf'),
        outputFile: file('unlocked.pdf'),
        password: 'user',
      ),
    );

    expect(file('unlocked.pdf').lengthSync(), greaterThan(0));
    expectNoTemporaryFiles();
  });
}
