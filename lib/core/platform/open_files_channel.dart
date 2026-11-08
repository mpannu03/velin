import 'package:flutter/services.dart';
import 'package:logging/logging.dart';
import 'package:path/path.dart' as p;

final _log = Logger('velin.open_files');

/// Receives files the operating system asks Velin to open while it is
/// running, e.g. "Open with Velin" on a PDF when Velin is already open.
///
/// The native runners (`windows/runner/flutter_window.cpp`,
/// `linux/runner/my_application.cc`) keep a single instance running and
/// forward the files of every later launch here. They hold the files until
/// [listen] reports that Dart is ready, so none are lost during startup.
///
/// Files given to the *first* launch arrive as `main()` arguments instead;
/// see [filePathsFromArguments].
class OpenFilesChannel {
  OpenFilesChannel({MethodChannel? channel})
    : _channel = channel ?? const MethodChannel(channelName);

  static const channelName = 'velin/open_files';

  final MethodChannel _channel;

  /// Calls [onFiles] with the paths of each later "open" request.
  Future<void> listen(void Function(List<String> paths) onFiles) async {
    _channel.setMethodCallHandler((call) async {
      if (call.method != 'openFiles') {
        throw MissingPluginException('Unknown method ${call.method}');
      }

      final paths = (call.arguments as List<Object?>).whereType<String>();
      onFiles(paths.toList());
    });

    try {
      await _channel.invokeMethod<void>('ready');
    } on MissingPluginException {
      // Platforms without the native side (macOS, mobile, tests).
      _log.fine('No native open-files handler on this platform');
    }
  }
}

/// The document paths among the app's command-line [arguments].
///
/// Flags (`--foo`) are skipped; everything else is treated as a path and
/// made absolute.
List<String> filePathsFromArguments(List<String> arguments) {
  return [
    for (final argument in arguments)
      if (argument.trim().isNotEmpty && !argument.startsWith('-'))
        p.absolute(argument),
  ];
}
