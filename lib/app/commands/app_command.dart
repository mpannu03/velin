import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';
import 'package:material_ui/material_ui.dart';
import 'package:velin/l10n/app_localizations.dart';

/// Every app-wide action that can be triggered from a menu or a shortcut.
///
/// This is the single list the menus (`AppMenuButton`, the macOS menu bar)
/// and the keyboard shortcuts (`AppCommandScope`) are built from, so a
/// command shows the same label and shortcut everywhere.
enum AppCommand {
  openDocument,
  toggleFullScreen,
  openLogsFolder,
  about,
  quit;

  String label(AppLocalizations l10n) => switch (this) {
    openDocument => l10n.commandOpenDocument,
    toggleFullScreen => l10n.commandToggleFullScreen,
    openLogsFolder => l10n.commandOpenLogsFolder,
    about => l10n.commandAbout,
    quit => l10n.commandQuit,
  };

  IconData get icon => switch (this) {
    openDocument => Icons.file_open_outlined,
    toggleFullScreen => Icons.fullscreen,
    openLogsFolder => Icons.folder_open_outlined,
    about => Icons.info_outline,
    quit => Icons.logout,
  };

  /// The keyboard shortcut on the current platform, if any.
  SingleActivator? get shortcut {
    final isMac = defaultTargetPlatform == TargetPlatform.macOS;

    return switch (this) {
      openDocument => SingleActivator(
        LogicalKeyboardKey.keyO,
        control: !isMac,
        meta: isMac,
      ),
      toggleFullScreen =>
        isMac
            ? const SingleActivator(
                LogicalKeyboardKey.keyF,
                control: true,
                meta: true,
              )
            : const SingleActivator(LogicalKeyboardKey.f11),
      quit => SingleActivator(
        LogicalKeyboardKey.keyQ,
        control: !isMac,
        meta: isMac,
      ),
      openLogsFolder || about => null,
    };
  }
}

/// How the commands are grouped in menus; groups are separated by dividers.
const appMenuGroups = <List<AppCommand>>[
  [AppCommand.openDocument],
  [AppCommand.toggleFullScreen],
  [AppCommand.openLogsFolder, AppCommand.about],
  [AppCommand.quit],
];

class AppCommandIntent extends Intent {
  const AppCommandIntent(this.command);

  final AppCommand command;
}

/// Opens files from outside the app, e.g. dropped on the window.
class OpenFilesIntent extends Intent {
  const OpenFilesIntent(this.paths);

  final List<String> paths;
}
