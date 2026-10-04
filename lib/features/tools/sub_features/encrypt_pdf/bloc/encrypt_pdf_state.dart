import 'dart:io';

import 'encrypt_pdf_input.dart';

class EncryptPdfState {
  const EncryptPdfState({
    this.inputFilePath,
    this.outputDirectory,
    this.outputFileName,
    this.userPassword = '',
    this.ownerPassword = '',
    this.level = EncryptPdfEncryptionLevel.aes256,
    this.permissions = EncryptPdfPermissionPreset.all,
    this.isSubmitting = false,
  });

  final String? inputFilePath;
  final String? outputDirectory;
  final String? outputFileName;

  /// Password required to open the document. Empty is valid: it restricts
  /// permissions without requiring a password to view.
  final String userPassword;

  /// Password that lifts the permission restrictions. Empty means the engine
  /// generates a random one.
  final String ownerPassword;

  final EncryptPdfEncryptionLevel level;
  final EncryptPdfPermissionPreset permissions;

  final bool isSubmitting;

  bool get hasInputFile =>
      inputFilePath != null && inputFilePath!.trim().isNotEmpty;

  bool get hasValidOutputDirectory =>
      outputDirectory != null && outputDirectory!.trim().isNotEmpty;

  bool get hasValidOutputFileName =>
      outputFileName != null && outputFileName!.trim().isNotEmpty;

  /// True when an owner password was typed that collides with the open
  /// password, which would make the owner door pointless.
  bool get hasDuplicatePasswords =>
      ownerPassword.isNotEmpty && ownerPassword == userPassword;

  /// Protection has to change something: an open password, an owner password,
  /// or a restriction on what viewers may do.
  bool get hasProtection =>
      userPassword.isNotEmpty ||
      ownerPassword.isNotEmpty ||
      permissions != EncryptPdfPermissionPreset.all;

  bool get canProtect =>
      hasInputFile &&
      hasProtection &&
      !hasDuplicatePasswords &&
      hasValidOutputDirectory &&
      hasValidOutputFileName &&
      !isSubmitting;

  /// The tool input for the current state.
  ///
  /// [outputDirectory] and [outputFileName] are joined here so the cubit and
  /// the view agree on the final path.
  EncryptPdfToolInput get toolInput {
    final directory = outputDirectory!.trim().replaceFirst(
      RegExp(r'[/\\]+$'),
      '',
    );

    return EncryptPdfToolInput(
      filePath: inputFilePath!.trim(),
      outputFilePath:
          '$directory${Platform.pathSeparator}'
          '${outputFileName!.trim()}',
      userPassword: userPassword,
      ownerPassword: ownerPassword,
      level: level,
      permissions: permissions,
    );
  }

  EncryptPdfState copyWith({
    Object? inputFilePath = _unset,
    Object? outputDirectory = _unset,
    Object? outputFileName = _unset,
    String? userPassword,
    String? ownerPassword,
    EncryptPdfEncryptionLevel? level,
    EncryptPdfPermissionPreset? permissions,
    bool? isSubmitting,
  }) {
    return EncryptPdfState(
      inputFilePath: identical(inputFilePath, _unset)
          ? this.inputFilePath
          : inputFilePath as String?,
      outputDirectory: identical(outputDirectory, _unset)
          ? this.outputDirectory
          : outputDirectory as String?,
      outputFileName: identical(outputFileName, _unset)
          ? this.outputFileName
          : outputFileName as String?,
      userPassword: userPassword ?? this.userPassword,
      ownerPassword: ownerPassword ?? this.ownerPassword,
      level: level ?? this.level,
      permissions: permissions ?? this.permissions,
      isSubmitting: isSubmitting ?? this.isSubmitting,
    );
  }
}

const _unset = Object();
