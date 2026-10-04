import 'dart:io';
import 'dart:typed_data';

import 'package:pdf_cos/pdf_cos.dart';

class DecryptPdfInput {
  const DecryptPdfInput({
    required this.inputFile,
    required this.outputFile,
    this.password = '',
  });

  final File inputFile;
  final File outputFile;

  /// The current user or owner password. Empty when the document is
  /// unencrypted, or protected by permissions only.
  final String password;
}

/// Removes the password and permission restrictions from a PDF.
class DecryptPdfEngine {
  const DecryptPdfEngine();

  Future<File> decrypt(DecryptPdfInput input) async {
    if (!input.inputFile.existsSync()) {
      throw FileSystemException(
        'Input file not found.',
        input.inputFile.path,
      );
    }

    final bytes = await input.inputFile.readAsBytes();

    // Opening installs the security handler, which authenticates the password
    // and throws CosPasswordException when it opens neither door.
    final document = CosDocument.open(bytes, password: input.password);

    if (!document.isEncrypted) {
      throw StateError('The document is not encrypted.');
    }

    final output = _writeUnencrypted(document);

    await input.outputFile.parent.create(recursive: true);
    await input.outputFile.writeAsBytes(output);

    return input.outputFile;
  }

  /// Rewrites the document with the `/Encrypt` entry dropped and nothing
  /// encrypted.
  ///
  /// The parsed object graph is already plaintext - reading decrypted it - so
  /// every string and stream carries across untouched. Only the trailer
  /// changes.
  Uint8List _writeUnencrypted(CosDocument document) {
    final output = BytesBuilder(copy: false);

    _writeHeader(output, document.version);

    final serializer = CosSerializer(output);
    final offsets = <int, int>{};

    for (final objectNumber in document.objectNumbers) {
      // The outgoing /Encrypt dictionary is not carried over.
      if (objectNumber == document.encryptObjectNumber) continue;

      final entry = document.xrefEntry(objectNumber);

      if (entry == null || entry.type == CosXrefEntryType.free) continue;

      final object = document.getObject(objectNumber, entry.generation);

      // A cross-reference stream describes bytes this rewrite invalidates.
      if (object is CosStream && _typeOf(document, object) == 'XRef') {
        continue;
      }

      offsets[objectNumber] = output.length;

      serializer.writeIndirectObject(
        CosIndirectObject(objectNumber, entry.generation, object),
      );
    }

    final xref = CosXrefTableWriter(output);
    final xrefOffset = output.length;

    xref.writeTable(
      offsets,
      (number) => _generationOf(document, number),
      includeFreeHead: true,
    );

    xref.writeTrailer(_buildTrailer(document));
    xref.writeEpilogue(xrefOffset);

    return output.takeBytes();
  }

  CosDictionary _buildTrailer(CosDocument document) {
    final root = document.trailer['Root'];

    if (root is! CosReference) {
      throw CosParseException('trailer /Root is not an indirect reference');
    }

    final info = document.trailer['Info'];
    final id = document.resolve(document.trailer['ID']);

    return CosDictionary({
      'Size': CosInteger(_nextObjectNumber(document)),
      'Root': root,
      'Info': ?info,
      // Preserved rather than regenerated, so the output stays recognisably
      // the same document.
      if (id is CosArray) 'ID': id,
    });
  }

  String? _typeOf(CosDocument document, CosObject object) {
    final dictionary = switch (object) {
      CosStream(:final dictionary) => dictionary,
      CosDictionary() => object,
      _ => null,
    };

    if (dictionary == null) return null;

    final type = document.resolve(dictionary['Type']);

    return type is CosName ? type.value : null;
  }

  int _generationOf(CosDocument document, int number) {
    final entry = document.xrefEntry(number);

    return entry != null && entry.type == CosXrefEntryType.inUse
        ? entry.generation
        : 0;
  }

  int _nextObjectNumber(CosDocument document) {
    var highest = 0;

    for (final number in document.objectNumbers) {
      if (number > highest) highest = number;
    }

    return highest + 1;
  }

  void _writeHeader(BytesBuilder output, String version) {
    output.add(Uint8List.fromList('%PDF-$version\n'.codeUnits));

    // Binary marker recommended by the PDF specification.
    output.add(
      Uint8List.fromList([0x25, 0xE2, 0xE3, 0xCF, 0xD3, 0x0A]),
    );
  }
}