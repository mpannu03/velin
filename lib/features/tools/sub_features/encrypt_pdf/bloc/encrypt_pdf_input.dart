import 'dart:io';
import 'dart:math' as math;

import 'package:velin/engine/engine.dart';

/// The cipher the output document is written with.
///
/// Mirrors [PdfEncryptionLevel] one-for-one so the UI can drive a segmented
/// control over the engine's levels without an extra mapping layer.
enum EncryptPdfEncryptionLevel {
  aes256(PdfEncryptionLevel.aes256),
  aes128(PdfEncryptionLevel.aes128),
  rc4(PdfEncryptionLevel.rc4);

  const EncryptPdfEncryptionLevel(this.level);

  /// The engine level this option writes.
  final PdfEncryptionLevel level;
}

enum EncryptPdfPermissionPreset {
  all(PdfPermissions.all()),
  readOnly(PdfPermissions.readOnly()),
  none(PdfPermissions.none());

  const EncryptPdfPermissionPreset(this.permissions);

  /// The engine permissions this preset grants.
  final PdfPermissions permissions;
}

/// User-facing model for the Protect PDF tool.
class EncryptPdfToolInput {
  const EncryptPdfToolInput({
    required this.filePath,
    required this.outputFilePath,
    this.userPassword = '',
    this.ownerPassword = '',
    this.level = EncryptPdfEncryptionLevel.aes256,
    this.permissions = EncryptPdfPermissionPreset.all,
  });

  final String filePath;
  final String outputFilePath;

  /// Password required to open the document. Empty means no password is
  /// required, but the permissions still apply.
  final String userPassword;

  /// Password that lifts the permission restrictions. Empty means a random one
  /// is generated when the request is mapped to the engine, matching what
  /// Acrobat and qpdf do.
  final String ownerPassword;

  final EncryptPdfEncryptionLevel level;
  final EncryptPdfPermissionPreset permissions;

  /// Whether protection would do anything at all.
  ///
  /// A document with neither a password nor restricted permissions is already
  /// as open as it can be, so there is no point writing it out.
  bool get hasEffect =>
      userPassword.isNotEmpty ||
      ownerPassword.isNotEmpty ||
      permissions != EncryptPdfPermissionPreset.all;

  /// True when an owner password was typed that collides with the open
  /// password. Writing them the same would make the owner door pointless.
  bool get hasDuplicatePasswords =>
      ownerPassword.isNotEmpty && ownerPassword == userPassword;

  EncryptPdfToolInput copyWith({
    String? userPassword,
    String? ownerPassword,
    EncryptPdfEncryptionLevel? level,
    EncryptPdfPermissionPreset? permissions,
  }) {
    return EncryptPdfToolInput(
      filePath: filePath,
      outputFilePath: outputFilePath,
      userPassword: userPassword ?? this.userPassword,
      ownerPassword: ownerPassword ?? this.ownerPassword,
      level: level ?? this.level,
      permissions: permissions ?? this.permissions,
    );
  }
}

extension EncryptPdfMapper on EncryptPdfToolInput {
  EncryptPdfInput toEncryptPdfInput() {
    return EncryptPdfInput(
      inputFile: File(filePath),
      outputFile: File(outputFilePath),
      userPassword: userPassword,
      // The engine always writes an owner password, so a blank field gets a
      // random one. An owner password nobody knows is what makes "open freely,
      // restrict editing" safe to offer without handing out full access.
      ownerPassword: ownerPassword.isEmpty
          ? _randomOwnerPassword()
          : ownerPassword,
      permissions: permissions.permissions,
      level: level.level,
    );
  }
}

/// 32 printable ASCII characters, which keeps the value out of the way of PDF
/// string escaping rules while staying long enough to be unguessable.
String _randomOwnerPassword() {
  final random = math.Random.secure();

  return List.generate(
    32,
    (_) => String.fromCharCode(33 + random.nextInt(94)),
  ).join();
}
