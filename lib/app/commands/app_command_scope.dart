import 'package:flutter/foundation.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:material_ui/material_ui.dart';
import 'package:velin/core/app_info/app_info.dart';
import 'package:velin/shared/extensions/extensions.dart';

import 'app_command.dart';
import 'app_command_handler.dart';

/// Binds every [AppCommand] to its keyboard shortcut and handler for the
/// whole app. Menus trigger commands with
/// `Actions.invoke(context, AppCommandIntent(command))`.
///
/// On macOS the commands also go into the native menu bar, which handles
/// their shortcuts itself.
class AppCommandScope extends StatelessWidget {
  const AppCommandScope({
    required this.handler,
    required this.appInfo,
    required this.navigatorKey,
    required this.child,
    super.key,
  });

  final AppCommandHandler handler;
  final AppInfo appInfo;

  /// Used to show dialogs from above the router.
  final GlobalKey<NavigatorState> navigatorKey;

  final Widget child;

  static bool get _usesPlatformMenuBar =>
      defaultTargetPlatform == TargetPlatform.macOS;

  @override
  Widget build(BuildContext context) {
    Widget result = Actions(
      actions: {
        AppCommandIntent: CallbackAction<AppCommandIntent>(
          onInvoke: (intent) {
            _run(intent.command);
            return null;
          },
        ),
      },
      child: child,
    );

    if (_usesPlatformMenuBar) {
      return PlatformMenuBar(menus: _platformMenus(context), child: result);
    }

    return Shortcuts(
      shortcuts: {
        for (final command in AppCommand.values)
          ?command.shortcut: AppCommandIntent(command),
      },
      child: result,
    );
  }

  void _run(AppCommand command) {
    switch (command) {
      case AppCommand.openDocument:
        handler.openDocument();
      case AppCommand.toggleFullScreen:
        handler.toggleFullScreen();
      case AppCommand.openLogsFolder:
        handler.openLogsFolder();
      case AppCommand.about:
        _showAbout();
      case AppCommand.quit:
        handler.quit();
    }
  }

  void _showAbout() {
    final context = navigatorKey.currentContext;
    if (context == null) return;

    final l10n = context.l10n;

    showAboutDialog(
      context: context,
      applicationName: l10n.appName,
      applicationVersion: appInfo.displayVersion,
      applicationIcon: SvgPicture.asset(
        'assets/icons/icon_mono.svg',
        width: 48,
        height: 48,
        colorFilter: ColorFilter.mode(
          Theme.of(context).colorScheme.primary,
          BlendMode.srcIn,
        ),
      ),
      applicationLegalese: l10n.aboutLicense,
      children: [const SizedBox(height: 16), Text(l10n.aboutDescription)],
    );
  }

  List<PlatformMenuItem> _platformMenus(BuildContext context) {
    final l10n = context.l10n;

    PlatformMenuItem item(AppCommand command) => PlatformMenuItem(
      label: command.label(l10n),
      shortcut: command.shortcut,
      onSelected: () => _run(command),
    );

    // macOS convention: About and Quit live in the application menu.
    return [
      PlatformMenu(
        label: l10n.appName,
        menus: [
          PlatformMenuItemGroup(members: [item(AppCommand.about)]),
          PlatformMenuItemGroup(members: [item(AppCommand.quit)]),
        ],
      ),
      PlatformMenu(
        label: l10n.menuFile,
        menus: [item(AppCommand.openDocument)],
      ),
      PlatformMenu(
        label: l10n.menuView,
        menus: [item(AppCommand.toggleFullScreen)],
      ),
      PlatformMenu(
        label: l10n.menuHelp,
        menus: [item(AppCommand.openLogsFolder)],
      ),
    ];
  }
}
