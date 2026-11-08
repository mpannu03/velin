import 'dart:io';

import 'package:logging/logging.dart';

final _log = Logger('velin.file_manager');

/// Shows [path] (a folder) in the system file manager.
///
/// Returns `false` when the file manager could not be started.
Future<bool> openInFileManager(String path) async {
  final String executable;

  if (Platform.isWindows) {
    executable = 'explorer.exe';
  } else if (Platform.isMacOS) {
    executable = 'open';
  } else {
    executable = 'xdg-open';
  }

  try {
    // Detached: the file manager outlives this call, and explorer.exe's exit
    // code does not say whether it worked anyway.
    await Process.start(executable, [path], mode: ProcessStartMode.detached);
    return true;
  } on ProcessException catch (error, stackTrace) {
    _log.warning('Could not open $path with $executable', error, stackTrace);
    return false;
  }
}
