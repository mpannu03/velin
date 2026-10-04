import 'dart:io';

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

/// How much a viewer is allowed to do with the protected document.
///
/// These are the three presets that cover real use. The engine's finer grained
/// [PdfPermissions] stays available for callers that need a custom combination.
enum EncryptPdfPermissionPreset {
  all(PdfPermissions.all),
  readOnly(PdfPermissions.readOnly),
  none(PdfPermissions.none);

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
    this.encryptMetadata = true,
  });

  final String filePath;
  final String outputFilePath;

  /// Password required to open the document. Empty means no password is
  /// required, but the permissions still apply.
  final String userPassword;

  /// Password that lifts the permission restrictions. Empty means the engine
  /// generates a random one, matching what Acrobat and qpdf do.
  final String ownerPassword;

  final EncryptPdfEncryptionLevel level;
  final EncryptPdfPermissionPreset permissions;

  /// When false the document's metadata stream stays in the clear.
  final bool encryptMetadata;

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
    bool? encryptMetadata,
  }) {
    return EncryptPdfToolInput(
      filePath: filePath,
      outputFilePath: outputFilePath,
      userPassword: userPassword ?? this.userPassword,
      ownerPassword: ownerPassword ?? this.ownerPassword,
      level: level ?? this.level,
      permissions: permissions ?? this.permissions,
      encryptMetadata: encryptMetadata ?? this.encryptMetadata,
    );
  }
}

extension EncryptPdfMapper on EncryptPdfToolInput {
  EncryptPdfInput toEncryptPdfInput() {
    return EncryptPdfInput(
      inputFile: File(filePath),
      outputFile: File(outputFilePath),
      userPassword: userPassword,
      // A blank owner password is left null so the engine generates one rather
      // than writing an empty owner door anyone could walk through.
      ownerPassword: ownerPassword.isEmpty ? null : ownerPassword,
      permissions: permissions.permissions,
      level: level.level,
      encryptMetadata: encryptMetadata,
    );
  }
}
