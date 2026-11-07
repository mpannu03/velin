import 'package:velin/core/page_selection/page_selection_error.dart';

/// Every way an operation in Velin can fail, as seen by the rest of the app.
///
/// Low-level exceptions (`FileSystemException`, pdfium errors, HTTP errors,
/// ...) are converted into one of these by `mapError` at the boundary where
/// they are caught. Blocs and widgets only ever deal with [AppFailure], and
/// because the class is sealed, a `switch` over it must handle every case: a
/// new failure type does not compile until it has a user-facing message.
///
/// Failures carry facts, not text. The message is chosen in the UI layer
/// (see `AppFailureMessage`) so it can be localized.
///
/// [AppFailure] implements [Exception] so engines may throw one directly when
/// they detect a condition themselves (e.g. an encrypted input).
sealed class AppFailure implements Exception {
  const AppFailure({this.cause, this.stackTrace});

  /// The original error, kept for logs. Never shown to the user.
  final Object? cause;

  final StackTrace? stackTrace;

  /// `true` when this failure indicates a bug rather than a condition the
  /// user can understand or fix. Unexpected failures are logged as SEVERE.
  bool get isUnexpected => false;

  /// `true` when the user cancelled the operation; callers stay quiet.
  bool get isCancellation => false;

  @override
  String toString() => cause == null ? '$runtimeType' : '$runtimeType($cause)';
}

// ---------------------------------------------------------------------------
// File system
// ---------------------------------------------------------------------------

final class FileNotFoundFailure extends AppFailure {
  const FileNotFoundFailure({this.path, super.cause, super.stackTrace});

  final String? path;
}

final class FileAccessDeniedFailure extends AppFailure {
  const FileAccessDeniedFailure({this.path, super.cause, super.stackTrace});

  final String? path;
}

/// Another program holds the file open (common on Windows when the PDF is
/// open in another viewer).
final class FileInUseFailure extends AppFailure {
  const FileInUseFailure({this.path, super.cause, super.stackTrace});

  final String? path;
}

final class DiskFullFailure extends AppFailure {
  const DiskFullFailure({this.path, super.cause, super.stackTrace});

  final String? path;
}

/// Any other read or write error.
final class FileSystemFailure extends AppFailure {
  const FileSystemFailure({this.path, super.cause, super.stackTrace});

  final String? path;
}

/// The output would overwrite the input, which would destroy the source.
final class OutputSameAsInputFailure extends AppFailure {
  const OutputSameAsInputFailure({super.cause, super.stackTrace});
}

// ---------------------------------------------------------------------------
// Documents
// ---------------------------------------------------------------------------

final class UnsupportedFileTypeFailure extends AppFailure {
  const UnsupportedFileTypeFailure({this.path, super.cause, super.stackTrace});

  final String? path;
}

/// The document is encrypted and needs a password for this operation.
final class PasswordRequiredFailure extends AppFailure {
  const PasswordRequiredFailure({super.cause, super.stackTrace});
}

final class WrongPasswordFailure extends AppFailure {
  const WrongPasswordFailure({super.cause, super.stackTrace});
}

/// The file is damaged or is not a valid document.
final class CorruptDocumentFailure extends AppFailure {
  const CorruptDocumentFailure({this.path, super.cause, super.stackTrace});

  final String? path;
}

/// The document uses a feature Velin cannot process yet (an unusual security
/// handler, an unknown stream filter, ...).
final class UnsupportedDocumentFeatureFailure extends AppFailure {
  const UnsupportedDocumentFeatureFailure({super.cause, super.stackTrace});
}

/// An operation that needs an encrypted document (e.g. unlocking) was given
/// one that is not encrypted.
final class DocumentNotEncryptedFailure extends AppFailure {
  const DocumentNotEncryptedFailure({super.cause, super.stackTrace});
}

/// An image could not be decoded.
final class InvalidImageFailure extends AppFailure {
  const InvalidImageFailure({this.path, super.cause, super.stackTrace});

  final String? path;
}

final class InvalidPageSelectionFailure extends AppFailure {
  const InvalidPageSelectionFailure(
    this.error, {
    super.cause,
    super.stackTrace,
  });

  final PageSelectionError error;
}

// ---------------------------------------------------------------------------
// Network
// ---------------------------------------------------------------------------

/// No connection, DNS failure, TLS failure or timeout.
final class NetworkFailure extends AppFailure {
  const NetworkFailure({this.isTimeout = false, super.cause, super.stackTrace});

  final bool isTimeout;
}

/// The server answered with an error status or an unreadable response.
final class ServerFailure extends AppFailure {
  const ServerFailure({this.statusCode, super.cause, super.stackTrace});

  final int? statusCode;
}

// ---------------------------------------------------------------------------
// Feature specific
//
// These live here (rather than in their feature) so the hierarchy stays
// sealed and every switch remains exhaustive.
// ---------------------------------------------------------------------------

final class DictionaryEntryNotFoundFailure extends AppFailure {
  const DictionaryEntryNotFoundFailure(
    this.word, {
    super.cause,
    super.stackTrace,
  });

  final String word;
}

// ---------------------------------------------------------------------------
// General
// ---------------------------------------------------------------------------

final class CancelledFailure extends AppFailure {
  const CancelledFailure({super.cause, super.stackTrace});

  @override
  bool get isCancellation => true;
}

/// Anything we did not anticipate. This is a bug: it is logged as SEVERE and
/// the user sees a generic message.
final class UnexpectedFailure extends AppFailure {
  const UnexpectedFailure({super.cause, super.stackTrace});

  @override
  bool get isUnexpected => true;
}
