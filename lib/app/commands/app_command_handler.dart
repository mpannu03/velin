import 'dart:io';

import 'package:logging/logging.dart';
import 'package:velin/app/effects/effects.dart';
import 'package:velin/core/document/document.dart';
import 'package:velin/core/platform/file_manager.dart';
import 'package:velin/core/result/result.dart';
import 'package:window_manager/window_manager.dart';

final _log = Logger('velin.commands');

/// Carries out the [AppCommand]s that need no widget context.
///
/// UI-only commands (the About dialog) are handled by `AppCommandScope`.
class AppCommandHandler {
  AppCommandHandler({
    required this._documentService,
    required this._appEffectController,
    required this._navigate,
    required this._windowManager,
    required this._logDirectory,
    this._openFolder = openInFileManager,
  });

  final DocumentService _documentService;
  final AppEffectController _appEffectController;

  /// Goes to a route location, e.g. `/reader`.
  final void Function(String location) _navigate;
  final WindowManager _windowManager;
  final Directory? _logDirectory;
  final Future<bool> Function(String path) _openFolder;

  bool _isOpening = false;

  /// Lets the user pick a document, then shows it in the reader.
  Future<void> openDocument() async {
    // Ignore repeated shortcuts while the picker is up.
    if (_isOpening) return;
    _isOpening = true;

    try {
      final result = await _documentService.open();

      switch (result) {
        case Success(data: null):
          // The user cancelled the picker.
          break;
        case Success():
          _navigate('/reader');
        case Failure(:final failure):
          _appEffectController.notifyFailure(failure);
      }
    } finally {
      _isOpening = false;
    }
  }

  Future<void> toggleFullScreen() async {
    final isFullScreen = await _windowManager.isFullScreen();
    await _windowManager.setFullScreen(!isFullScreen);
  }

  Future<void> openLogsFolder() async {
    final directory = _logDirectory;

    if (directory == null) {
      _appEffectController.notifyUser(
        message: (l10n) => l10n.commandLogsUnavailable,
        type: NotificationType.warning,
      );
      return;
    }

    final opened = await _openFolder(directory.path);

    if (!opened) {
      _appEffectController.notifyUser(
        message: (l10n) => l10n.commandOpenLogsFolderFailed,
        type: NotificationType.error,
      );
    }
  }

  Future<void> quit() async {
    _log.info('Quit requested');
    await _windowManager.close();
  }
}
