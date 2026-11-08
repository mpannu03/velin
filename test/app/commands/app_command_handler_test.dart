import 'dart:async';
import 'dart:io';

import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:velin/app/commands/commands.dart';
import 'package:velin/app/effects/effects.dart';
import 'package:velin/core/document/document.dart';
import 'package:velin/core/error/error.dart';
import 'package:velin/core/result/result.dart';
import 'package:window_manager/window_manager.dart';

import '../../helpers/helpers.dart';

class MockDocumentService extends Mock implements DocumentService {}

class MockAppEffectController extends Mock implements AppEffectController {}

class MockWindowManager extends Mock implements WindowManager {}

void main() {
  setUpAll(() {
    registerFallbackValue(const UnexpectedFailure());
    registerFallbackValue(NotificationType.error);
    registerLocalizedMessageFallback();
  });

  late MockDocumentService documentService;
  late MockAppEffectController effects;
  late MockWindowManager windowManager;
  late List<String> locations;
  late List<String> openedFolders;
  late bool folderOpens;

  setUp(() {
    documentService = MockDocumentService();
    effects = MockAppEffectController();
    windowManager = MockWindowManager();
    locations = [];
    openedFolders = [];
    folderOpens = true;
  });

  AppCommandHandler buildHandler({Directory? logDirectory}) {
    return AppCommandHandler(
      documentService: documentService,
      appEffectController: effects,
      navigate: locations.add,
      windowManager: windowManager,
      logDirectory: logDirectory,
      openFolder: (path) async {
        openedFolders.add(path);
        return folderOpens;
      },
    );
  }

  group('openDocument', () {
    test('shows the reader after a document was opened', () async {
      when(() => documentService.open()).thenAnswer(
        (_) async => Success<Document?>(
          Document(path: '/docs/a.pdf', type: DocumentType.pdf),
        ),
      );

      await buildHandler().openDocument();

      expect(locations, ['/reader']);
      verifyNever(() => effects.notifyFailure(any()));
    });

    test('stays put when the picker is cancelled', () async {
      when(() => documentService.open())
          .thenAnswer((_) async => const Success<Document?>(null));

      await buildHandler().openDocument();

      expect(locations, isEmpty);
      verifyNever(() => effects.notifyFailure(any()));
    });

    test('reports a failure', () async {
      const failure = FileAccessDeniedFailure();
      when(() => documentService.open())
          .thenAnswer((_) async => const Failure<Document?>(failure));

      await buildHandler().openDocument();

      expect(locations, isEmpty);
      verify(() => effects.notifyFailure(failure)).called(1);
    });

    test('ignores repeated requests while the picker is open', () async {
      final picker = Completer<Result<Document?>>();
      when(() => documentService.open()).thenAnswer((_) => picker.future);

      final handler = buildHandler();
      final first = handler.openDocument();
      await handler.openDocument();

      picker.complete(const Success<Document?>(null));
      await first;

      verify(() => documentService.open()).called(1);

      // Usable again afterwards.
      when(() => documentService.open())
          .thenAnswer((_) async => const Success<Document?>(null));
      await handler.openDocument();
      verify(() => documentService.open()).called(1);
    });
  });

  group('openPaths', () {
    test('opens every file and shows the reader', () async {
      when(() => documentService.openPath(any())).thenAnswer(
        (invocation) async => Success(
          Document(
            path: invocation.positionalArguments.single as String,
            type: DocumentType.pdf,
          ),
        ),
      );

      await buildHandler().openPaths(['/docs/a.pdf', '/docs/b.pdf']);

      verify(() => documentService.openPath('/docs/a.pdf')).called(1);
      verify(() => documentService.openPath('/docs/b.pdf')).called(1);
      expect(locations, ['/reader']);
    });

    test('reports files that cannot be opened and opens the rest', () async {
      const failure = UnsupportedFileTypeFailure(path: '/docs/notes.txt');
      when(() => documentService.openPath('/docs/notes.txt'))
          .thenAnswer((_) async => const Failure(failure));
      when(() => documentService.openPath('/docs/a.pdf')).thenAnswer(
        (_) async =>
            Success(Document(path: '/docs/a.pdf', type: DocumentType.pdf)),
      );

      await buildHandler().openPaths(['/docs/notes.txt', '/docs/a.pdf']);

      verify(() => effects.notifyFailure(failure)).called(1);
      expect(locations, ['/reader']);
    });

    test('stays put when nothing could be opened', () async {
      const failure = FileNotFoundFailure(path: '/docs/gone.pdf');
      when(() => documentService.openPath(any()))
          .thenAnswer((_) async => const Failure(failure));

      await buildHandler().openPaths(['/docs/gone.pdf']);

      expect(locations, isEmpty);
    });

    test('does nothing for an empty list', () async {
      await buildHandler().openPaths(const []);

      verifyNever(() => documentService.openPath(any()));
      expect(locations, isEmpty);
    });
  });

  group('toggleFullScreen', () {
    test('enters full screen when windowed', () async {
      when(() => windowManager.isFullScreen()).thenAnswer((_) async => false);
      when(() => windowManager.setFullScreen(any())).thenAnswer((_) async {});

      await buildHandler().toggleFullScreen();

      verify(() => windowManager.setFullScreen(true)).called(1);
    });

    test('leaves full screen when full screen', () async {
      when(() => windowManager.isFullScreen()).thenAnswer((_) async => true);
      when(() => windowManager.setFullScreen(any())).thenAnswer((_) async {});

      await buildHandler().toggleFullScreen();

      verify(() => windowManager.setFullScreen(false)).called(1);
    });
  });

  group('openLogsFolder', () {
    test('opens the log directory', () async {
      await buildHandler(logDirectory: Directory('/logs')).openLogsFolder();

      expect(openedFolders, ['/logs']);
      verifyNever(
        () => effects.notifyUser(
          message: any(named: 'message'),
          type: any(named: 'type'),
        ),
      );
    });

    test('explains when file logging is off', () async {
      await buildHandler().openLogsFolder();

      expect(openedFolders, isEmpty);
      verify(
        () => effects.notifyUser(
          message: any(
            named: 'message',
            that: localizes(testL10n.commandLogsUnavailable),
          ),
          type: NotificationType.warning,
        ),
      ).called(1);
    });

    test('reports when the file manager could not be started', () async {
      folderOpens = false;

      await buildHandler(logDirectory: Directory('/logs')).openLogsFolder();

      verify(
        () => effects.notifyUser(
          message: any(
            named: 'message',
            that: localizes(testL10n.commandOpenLogsFolderFailed),
          ),
          type: NotificationType.error,
        ),
      ).called(1);
    });
  });

  test('quit closes the window', () async {
    when(() => windowManager.close()).thenAnswer((_) async {});

    await buildHandler().quit();

    verify(() => windowManager.close()).called(1);
  });
}
