import 'package:flutter/foundation.dart';
import 'package:material_ui/material_ui.dart';
import 'package:velin/app/theme/theme.dart';
import 'package:window_manager/window_manager.dart';

import 'widgets/widgets.dart';

/// Desktop window chrome: a single title bar holding the app menu, the
/// section [navigation] and the window controls, above the page content.
/// Files dropped anywhere on the window are opened.
class DesktopShell extends StatelessWidget {
  const DesktopShell({
    required this.navigation,
    required this.child,
    super.key,
  });

  final Widget navigation;
  final Widget child;

  @override
  Widget build(BuildContext context) {
    return FileDropTarget(
      child: Column(
        children: [
          _TitleBar(navigation: navigation),
          Expanded(child: child),
        ],
      ),
    );
  }
}

class _TitleBar extends StatelessWidget {
  const _TitleBar({required this.navigation});

  final Widget navigation;

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    // macOS shows the commands in the native menu bar instead.
    final showAppMenu = defaultTargetPlatform != TargetPlatform.macOS;

    return ColoredBox(
      color: colorScheme.primaryContainer,
      child: SizedBox(
        height: AppDimensions.desktopRibbonHeight,
        child: Row(
          children: [
            if (showAppMenu)
              const AppMenuButton()
            else
              const SizedBox(width: AppSpacing.sm),
            const SizedBox(width: AppSpacing.xs),
            navigation,
            const Expanded(child: DragToMoveArea(child: SizedBox.expand())),
            const VelinWindowControls(),
          ],
        ),
      ),
    );
  }
}
