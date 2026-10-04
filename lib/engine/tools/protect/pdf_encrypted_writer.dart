import 'dart:typed_data';

import 'package:pdf_cos/pdf_cos.dart';

import 'pdf_security_handler.dart';

/// Rewrites a parsed document with a fresh `/Encrypt` dictionary and every
/// string and stream encrypted.
///
/// The whole file is rewritten rather than incrementally updated: encryption
/// touches nearly every object, and an existing `/XRef` stream cannot stay
/// valid once the bytes it indexes have changed. A classic cross-reference
/// table is emitted instead, which every reader understands.
class PdfEncryptedWriter {
  const PdfEncryptedWriter(this.security);

  final PdfSecurityHandler security;

  Uint8List write(CosDocument document) {
    final output = BytesBuilder(copy: false);

    _writeHeader(output, _outputVersion(document));

    final serializer = CosSerializer(output);
    final offsets = <int, int>{};

    final encryptObjectNumber = _nextObjectNumber(document);

    for (final objectNumber in _writableObjects(document)) {
      final entry = document.xrefEntry(objectNumber);

      if (entry == null || entry.type == CosXrefEntryType.free) continue;

      final object = document.getObject(objectNumber, entry.generation);

      // A cross-reference stream describes bytes this rewrite invalidates,
      // and it is never encrypted anyway.
      if (object is CosStream && _typeOf(document, object) == 'XRef') {
        continue;
      }

      offsets[objectNumber] = output.length;

      serializer.writeIndirectObject(
        CosIndirectObject(
          objectNumber,
          entry.generation,
          _encrypt(document, object),
        ),
      );
    }

    offsets[encryptObjectNumber] = output.length;

    serializer.writeIndirectObject(
      CosIndirectObject(encryptObjectNumber, 0, security.encryptDictionary),
    );

    final xref = CosXrefTableWriter(output);
    final xrefOffset = output.length;

    xref.writeTable(
      offsets,
      (number) => number == encryptObjectNumber
          ? 0
          : _generationOf(document, number),
      includeFreeHead: true,
    );

    xref.writeTrailer(
      _buildTrailer(document, encryptObjectNumber),
    );
    xref.writeEpilogue(xrefOffset);

    return output.takeBytes();
  }

  /// Every object to carry over, minus the outgoing `/Encrypt` entry, whose
  /// dictionary is replaced rather than copied.
  List<int> _writableObjects(CosDocument document) {
    final numbers = document.objectNumbers
        .where((number) => number != document.encryptObjectNumber)
        .toList()
      ..sort();

    return numbers;
  }

  CosDictionary _buildTrailer(
    CosDocument document,
    int encryptObjectNumber,
  ) {
    final root = document.trailer['Root'];

    if (root is! CosReference) {
      throw CosParseException('trailer /Root is not an indirect reference');
    }

    final info = document.trailer['Info'];

    return CosDictionary({
      'Size': CosInteger(encryptObjectNumber + 1),
      'Root': root,
      'Info': ?info,
      'Encrypt': CosReference(encryptObjectNumber, 0),
      // /ID is never encrypted, and the handler's value is the one the
      // /Perms check was computed against.
      'ID': CosArray([
        CosString(security.fileId, isHex: true),
        CosString(security.fileId, isHex: true),
      ]),
    });
  }

  /// Deep-copies an object, encrypting every string and stream payload it
  /// holds. The original graph is left alone so the source document stays
  /// usable.
  CosObject _encrypt(CosDocument document, CosObject object) {
    switch (object) {
      case CosString():
        return CosString(
          security.encryptBytes(object.bytes),
          isHex: object.isHex,
        );

      case CosArray():
        return CosArray([
          for (final item in object.items) _encrypt(document, item),
        ]);

      case CosDictionary():
        final result = CosDictionary();

        object.entries.forEach((key, value) {
          // A signature's /Contents is the one string the standard exempts:
          // it must sit in the file as plain hex so /ByteRange can be patched
          // into the gap after signing.
          if (_isSignatureContents(document, object, key)) {
            result[key] = _copy(value);
            return;
          }

          result[key] = _encrypt(document, value);
        });

        return result;

      case CosStream():
        final dictionary = _encrypt(
          document,
          object.dictionary,
        ) as CosDictionary;

        if (_streamIsExempt(document, object)) {
          dictionary['Length'] = CosInteger(object.rawBytes.length);
          return CosStream(dictionary, Uint8List.fromList(object.rawBytes));
        }

        final encrypted = security.encryptBytes(object.rawBytes);

        dictionary['Length'] = CosInteger(encrypted.length);

        return CosStream(dictionary, encrypted);

      // Numbers, names, booleans and references carry no bytes to protect.
      default:
        return object;
    }
  }

  /// An unencrypted `/Metadata` stream, or one already carrying a `/Crypt`
  /// filter, is exempt.
  bool _streamIsExempt(CosDocument document, CosStream stream) {
    final type = _typeOf(document, stream);

    // Leaving metadata readable keeps text searchable and accessible.
    if (type == 'Metadata' && !security.encryptMetadata) return true;

    final filter = document.resolve(stream.dictionary['Filter']);

    if (filter is CosArray) {
      return filter.items.any((item) {
        final name = document.resolve(item);
        return name is CosName && name.value == 'Crypt';
      });
    }

    return false;
  }

  /// A signature dictionary is recognised by `/Type /Sig` or `/DocTimeStamp`;
  /// since `/Type` is optional, a `/ByteRange` also marks one.
  bool _isSignatureContents(
    CosDocument document,
    CosDictionary dictionary,
    String key,
  ) {
    if (key != 'Contents') return false;

    final type = document.resolve(dictionary['Type']);

    if (type is CosName) {
      return type.value == 'Sig' || type.value == 'DocTimeStamp';
    }

    return dictionary.entries.containsKey('ByteRange');
  }

  CosObject _copy(CosObject object) {
    switch (object) {
      case CosString():
        return CosString(
          Uint8List.fromList(object.bytes),
          isHex: object.isHex,
        );

      case CosArray():
        return CosArray([for (final item in object.items) _copy(item)]);

      case CosDictionary():
        return CosDictionary({
          for (final entry in object.entries.entries)
            entry.key: _copy(entry.value),
        });

      case CosStream():
        return CosStream(
          _copy(object.dictionary) as CosDictionary,
          Uint8List.fromList(object.rawBytes),
        );

      default:
        return object;
    }
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

  int _nextObjectNumber(CosDocument document) {
    var highest = 0;

    for (final number in document.objectNumbers) {
      if (number > highest) highest = number;
    }

    return highest + 1;
  }

  int _generationOf(CosDocument document, int number) {
    final entry = document.xrefEntry(number);

    return entry != null && entry.type == CosXrefEntryType.inUse
        ? entry.generation
        : 0;
  }

  /// AES-256 needs a 1.5-era header; anything lower would misdescribe the
  /// revision in use.
  String _outputVersion(CosDocument document) {
    final version = document.version;
    final parsed = double.tryParse(version);

    if (parsed != null && parsed >= 1.5) return version;

    return '1.7';
  }

  void _writeHeader(BytesBuilder output, String version) {
    output.add(Uint8List.fromList('%PDF-$version\n'.codeUnits));

    // Binary marker recommended by the PDF specification.
    output.add(
      Uint8List.fromList([0x25, 0xE2, 0xE3, 0xCF, 0xD3, 0x0A]),
    );
  }
}