import 'dart:io';
import 'dart:math' as math;
import 'dart:typed_data';

import 'package:pdf_cos/pdf_cos.dart';

import 'pdf_encryption_level.dart';
import 'pdf_permissions.dart';
import 'protect/protect.dart';

class EncryptPdfInput {
  const EncryptPdfInput({
    required this.inputFile,
    required this.outputFile,
    this.userPassword = '',
    this.ownerPassword,
    this.permissions = PdfPermissions.all,
    this.level = PdfEncryptionLevel.aes256,
    this.encryptMetadata = true,
  });

  final File inputFile;
  final File outputFile;

  /// Password required to open the document. Empty means no password is
  /// required, but the permissions still apply.
  final String userPassword;

  /// Password that lifts the permission restrictions. When null a random one
  /// is generated, matching what Acrobat and qpdf do: an owner password you
  /// cannot know is the only way to offer "open freely, restrict editing"
  /// without handing out the ability to edit.
  final String? ownerPassword;

  final PdfPermissions permissions;
  final PdfEncryptionLevel level;

  /// When false the document's metadata stream stays in the clear.
  final bool encryptMetadata;
}

/// Adds a user password and/or permission restrictions to an existing PDF.
class EncryptPdfEngine {
  const EncryptPdfEngine();

  Future<File> encrypt(EncryptPdfInput input) async {
    if (!input.inputFile.existsSync()) {
      throw FileSystemException('Input file not found.', input.inputFile.path);
    }

    final bytes = await input.inputFile.readAsBytes();

    final document = CosDocument.open(bytes);

    if (document.isEncrypted) {
      throw UnsupportedEncryptionException(
        'The document is already encrypted. Remove its password before '
        'applying new protection.',
      );
    }

    // A fresh /ID per output file: it is part of the /Perms binding and must
    // not be inherited from a document this one supersedes.
    final fileId = _randomBytes(16);

    final security = PdfSecurityHandler(
      userPassword: input.userPassword,
      ownerPassword: input.ownerPassword ?? _randomPassword(),
      permissions: input.permissions.toInt(),
      fileId: fileId,
      level: input.level,
      encryptMetadata: input.encryptMetadata,
    );

    final output = PdfEncryptedWriter(security).write(document);

    await input.outputFile.parent.create(recursive: true);
    await input.outputFile.writeAsBytes(output);

    return input.outputFile;
  }

  static String _randomPassword() {
    final random = math.Random.secure();

    return List.generate(
      32,
      (_) => String.fromCharCode(33 + random.nextInt(94)),
    ).join();
  }

  static Uint8List _randomBytes(int length) {
    final random = math.Random.secure();

    return Uint8List.fromList([
      for (var i = 0; i < length; i++) random.nextInt(256),
    ]);
  }
}