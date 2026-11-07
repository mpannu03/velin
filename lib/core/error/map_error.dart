import 'dart:async';
import 'dart:io';

import 'package:http/http.dart' as http;
import 'package:logging/logging.dart';
import 'package:pdf_cos/pdf_cos.dart' as cos;
import 'package:pdf_manipulator/pdf_manipulator.dart' as manipulator;
import 'package:pdfrx_engine/pdfrx_engine.dart' as pdfrx;
import 'package:velin/core/page_selection/page_selection_error.dart';

import 'app_failure.dart';

final _log = Logger('velin.error');

/// Converts any thrown object into an [AppFailure].
///
/// This is the single place that knows about library-specific exceptions.
/// Call it wherever an exception crosses into app code (repositories,
/// services, the task manager, ...); everything above that boundary works
/// with [AppFailure] only.
///
/// Unexpected errors are logged here as SEVERE, so every bug is recorded
/// exactly once regardless of who catches it. An [AppFailure] passed in is
/// returned unchanged and not logged again.
///
/// [isWindows] exists for tests; it defaults to the current platform.
AppFailure mapError(Object error, StackTrace? stackTrace, {bool? isWindows}) {
  if (error is AppFailure) return error;

  final failure = _map(error, stackTrace, isWindows ?? Platform.isWindows);

  if (failure.isUnexpected) {
    _log.severe('Unexpected error', error, stackTrace);
  }

  return failure;
}

AppFailure _map(Object error, StackTrace? stackTrace, bool isWindows) {
  return switch (error) {
    FileSystemException() => _mapFileSystem(error, stackTrace, isWindows),

    // pdfrx (pdfium). Error codes are pdfium's FPDF_ERR_* values.
    pdfrx.PdfPasswordException() => PasswordRequiredFailure(
      cause: error,
      stackTrace: stackTrace,
    ),
    pdfrx.PdfException(errorCode: 2) => FileSystemFailure(
      cause: error,
      stackTrace: stackTrace,
    ),
    pdfrx.PdfException(errorCode: 3) => CorruptDocumentFailure(
      cause: error,
      stackTrace: stackTrace,
    ),
    pdfrx.PdfException(errorCode: 4) => WrongPasswordFailure(
      cause: error,
      stackTrace: stackTrace,
    ),
    pdfrx.PdfException(errorCode: 5) => UnsupportedDocumentFeatureFailure(
      cause: error,
      stackTrace: stackTrace,
    ),

    // pdf_manipulator
    manipulator.PdfPasswordRequired() => PasswordRequiredFailure(
      cause: error,
      stackTrace: stackTrace,
    ),
    manipulator.PdfWrongPassword() => WrongPasswordFailure(
      cause: error,
      stackTrace: stackTrace,
    ),
    manipulator.PdfCorrupted() => CorruptDocumentFailure(
      cause: error,
      stackTrace: stackTrace,
    ),
    manipulator.PdfUnsupported() => UnsupportedDocumentFeatureFailure(
      cause: error,
      stackTrace: stackTrace,
    ),
    manipulator.PdfCancelled() => CancelledFailure(
      cause: error,
      stackTrace: stackTrace,
    ),
    manipulator.PdfPageRangeError(:final page, :final pageCount) =>
      InvalidPageSelectionFailure(
        PageSelectionOutOfBoundsError(page: page, totalPages: pageCount),
        cause: error,
        stackTrace: stackTrace,
      ),
    manipulator.PdfIoError(cause: final Object inner) => switch (_map(
      inner,
      stackTrace,
      isWindows,
    )) {
      UnexpectedFailure() => FileSystemFailure(
        cause: error,
        stackTrace: stackTrace,
      ),
      final mapped => mapped,
    },
    manipulator.PdfIoError() => FileSystemFailure(
      cause: error,
      stackTrace: stackTrace,
    ),

    // pdf_cos
    cos.CosParseException() => CorruptDocumentFailure(
      cause: error,
      stackTrace: stackTrace,
    ),
    cos.CosPasswordException() => PasswordRequiredFailure(
      cause: error,
      stackTrace: stackTrace,
    ),
    cos.UnsupportedEncryptionException() || cos.UnsupportedFilterException() =>
      UnsupportedDocumentFeatureFailure(cause: error, stackTrace: stackTrace),

    // App
    PageSelectionError() => InvalidPageSelectionFailure(
      error,
      cause: error,
      stackTrace: stackTrace,
    ),

    // Network. The only timeouts in the app guard network requests.
    TimeoutException() => NetworkFailure(
      isTimeout: true,
      cause: error,
      stackTrace: stackTrace,
    ),
    SocketException() || TlsException() || http.ClientException() =>
      NetworkFailure(cause: error, stackTrace: stackTrace),

    _ => UnexpectedFailure(cause: error, stackTrace: stackTrace),
  };
}

AppFailure _mapFileSystem(
  FileSystemException error,
  StackTrace? stackTrace,
  bool isWindows,
) {
  final path = error.path;

  if (error is PathNotFoundException) {
    return FileNotFoundFailure(
      path: path,
      cause: error,
      stackTrace: stackTrace,
    );
  }

  final code = error.osError?.errorCode;

  final kind = isWindows ? _windowsKind(code) : _posixKind(code);

  return switch (kind) {
    _FsKind.notFound => FileNotFoundFailure(
      path: path,
      cause: error,
      stackTrace: stackTrace,
    ),
    _FsKind.accessDenied => FileAccessDeniedFailure(
      path: path,
      cause: error,
      stackTrace: stackTrace,
    ),
    _FsKind.inUse => FileInUseFailure(
      path: path,
      cause: error,
      stackTrace: stackTrace,
    ),
    _FsKind.diskFull => DiskFullFailure(
      path: path,
      cause: error,
      stackTrace: stackTrace,
    ),
    _FsKind.other => FileSystemFailure(
      path: path,
      cause: error,
      stackTrace: stackTrace,
    ),
  };
}

enum _FsKind { notFound, accessDenied, inUse, diskFull, other }

// https://learn.microsoft.com/windows/win32/debug/system-error-codes--0-499-
_FsKind _windowsKind(int? code) => switch (code) {
  2 || 3 => _FsKind.notFound, // FILE_NOT_FOUND, PATH_NOT_FOUND
  5 || 19 => _FsKind.accessDenied, // ACCESS_DENIED, WRITE_PROTECT
  32 || 33 => _FsKind.inUse, // SHARING_VIOLATION, LOCK_VIOLATION
  39 || 112 => _FsKind.diskFull, // HANDLE_DISK_FULL, DISK_FULL
  _ => _FsKind.other,
};

// errno values shared by Linux and macOS.
_FsKind _posixKind(int? code) => switch (code) {
  2 => _FsKind.notFound, // ENOENT
  1 || 13 || 30 => _FsKind.accessDenied, // EPERM, EACCES, EROFS
  16 || 26 => _FsKind.inUse, // EBUSY, ETXTBSY
  28 => _FsKind.diskFull, // ENOSPC
  _ => _FsKind.other,
};
