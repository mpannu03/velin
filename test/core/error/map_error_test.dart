import 'dart:async';
import 'dart:io';

import 'package:flutter_test/flutter_test.dart';
import 'package:http/http.dart' as http;
import 'package:logging/logging.dart';
import 'package:pdf_cos/pdf_cos.dart' as cos;
import 'package:pdf_manipulator/pdf_manipulator.dart' as manipulator;
import 'package:pdfrx_engine/pdfrx_engine.dart' as pdfrx;
import 'package:velin/core/error/error.dart';
import 'package:velin/core/page_selection/page_selection_error.dart';

FileSystemException _fsError(int code, {String path = '/f.pdf'}) =>
    FileSystemException('failed', path, OSError('os', code));

void main() {
  group('file system errors on Windows', () {
    AppFailure map(int code) => mapError(_fsError(code), null, isWindows: true);

    test('maps not found codes', () {
      expect(map(2), isA<FileNotFoundFailure>());
      expect(map(3), isA<FileNotFoundFailure>());
    });

    test('maps access denied', () {
      expect(map(5), isA<FileAccessDeniedFailure>());
    });

    test('maps sharing and lock violations to file in use', () {
      expect(map(32), isA<FileInUseFailure>());
      expect(map(33), isA<FileInUseFailure>());
    });

    test('maps disk full', () {
      expect(map(112), isA<DiskFullFailure>());
    });

    test('keeps the path', () {
      expect(
        map(5),
        isA<FileAccessDeniedFailure>().having((f) => f.path, 'path', '/f.pdf'),
      );
    });

    test('maps unknown codes to a generic file system failure', () {
      expect(map(9999), isA<FileSystemFailure>());
    });
  });

  group('file system errors on POSIX', () {
    AppFailure map(int code) =>
        mapError(_fsError(code), null, isWindows: false);

    test('maps errno values', () {
      expect(map(2), isA<FileNotFoundFailure>());
      expect(map(13), isA<FileAccessDeniedFailure>());
      expect(map(30), isA<FileAccessDeniedFailure>());
      expect(map(16), isA<FileInUseFailure>());
      expect(map(28), isA<DiskFullFailure>());
    });

    test('does not confuse Windows codes', () {
      // 5 is EIO on POSIX, not "access denied".
      expect(map(5), isA<FileSystemFailure>());
    });
  });

  test('PathNotFoundException is always file not found', () {
    expect(
      mapError(
        const PathNotFoundException('/x', OSError('missing', 999)),
        null,
      ),
      isA<FileNotFoundFailure>(),
    );
  });

  group('pdfrx', () {
    test('maps password and pdfium error codes', () {
      expect(
        mapError(const pdfrx.PdfPasswordException('no password'), null),
        isA<PasswordRequiredFailure>(),
      );
      expect(
        mapError(const pdfrx.PdfException('format', 3), null),
        isA<CorruptDocumentFailure>(),
      );
      expect(
        mapError(const pdfrx.PdfException('password', 4), null),
        isA<WrongPasswordFailure>(),
      );
      expect(
        mapError(const pdfrx.PdfException('security', 5), null),
        isA<UnsupportedDocumentFeatureFailure>(),
      );
    });
  });

  group('pdf_manipulator', () {
    test('maps typed errors', () {
      expect(
        mapError(const manipulator.PdfPasswordRequired(), null),
        isA<PasswordRequiredFailure>(),
      );
      expect(
        mapError(const manipulator.PdfWrongPassword(), null),
        isA<WrongPasswordFailure>(),
      );
      expect(
        mapError(const manipulator.PdfCorrupted('bad xref'), null),
        isA<CorruptDocumentFailure>(),
      );
      expect(
        mapError(const manipulator.PdfCancelled(), null),
        isA<CancelledFailure>(),
      );
    });

    test('maps page range errors to an out-of-bounds page selection', () {
      final failure = mapError(
        const manipulator.PdfPageRangeError(page: 9, pageCount: 3),
        null,
      );

      expect(
        failure,
        isA<InvalidPageSelectionFailure>().having(
          (f) => f.error,
          'error',
          isA<PageSelectionOutOfBoundsError>()
              .having((e) => e.page, 'page', 9)
              .having((e) => e.totalPages, 'totalPages', 3),
        ),
      );
    });

    test('unwraps the cause of an I/O error', () {
      expect(
        mapError(
          manipulator.PdfIoError('write failed', cause: _fsError(112)),
          null,
          isWindows: true,
        ),
        isA<DiskFullFailure>(),
      );
    });
  });

  test('maps pdf_cos errors', () {
    expect(
      mapError(cos.CosParseException('bad'), null),
      isA<CorruptDocumentFailure>(),
    );
    expect(
      mapError(cos.CosPasswordException(), null),
      isA<PasswordRequiredFailure>(),
    );
  });

  test('maps page selection errors', () {
    const error = InvalidPageSelectionTokenError('x');

    expect(
      mapError(error, null),
      isA<InvalidPageSelectionFailure>().having(
        (f) => f.error,
        'error',
        same(error),
      ),
    );
  });

  test('maps network errors', () {
    expect(
      mapError(const SocketException('offline'), null),
      isA<NetworkFailure>(),
    );
    expect(
      mapError(http.ClientException('reset'), null),
      isA<NetworkFailure>(),
    );
    expect(
      mapError(TimeoutException('slow'), null),
      isA<NetworkFailure>().having((f) => f.isTimeout, 'isTimeout', isTrue),
    );
  });

  test('returns an AppFailure unchanged', () {
    const failure = DiskFullFailure();

    expect(mapError(failure, null), same(failure));
  });

  group('unexpected errors', () {
    late List<LogRecord> records;
    late StreamSubscription<LogRecord> subscription;

    setUp(() {
      Logger.root.level = Level.ALL;
      records = [];
      subscription = Logger.root.onRecord.listen(records.add);
    });

    tearDown(() => subscription.cancel());

    test('are wrapped, keep their cause and are logged as severe', () {
      final error = StateError('bug');
      final stackTrace = StackTrace.current;

      final failure = mapError(error, stackTrace);

      expect(failure, isA<UnexpectedFailure>());
      expect(failure.isUnexpected, isTrue);
      expect(failure.cause, same(error));
      expect(failure.stackTrace, same(stackTrace));

      expect(records.single.level, Level.SEVERE);
      expect(records.single.error, same(error));
    });

    test('expected failures are not logged by the mapper', () {
      mapError(_fsError(2), null, isWindows: true);

      expect(records, isEmpty);
    });
  });
}
