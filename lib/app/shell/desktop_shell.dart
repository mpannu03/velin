import 'package:material_ui/material_ui.dart';
import 'package:velin/app/theme/theme.dart';
import 'package:velin/shared/extensions/extensions.dart';

import 'package:velin/shared/widgets/widgets.dart';
import 'package:window_manager/window_manager.dart';

import 'widgets/widgets.dart';

class DesktopShell extends StatelessWidget {
  const DesktopShell({
    required this.child,
    super.key,
  });

  final Widget child;

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        _WindowRibbon(),
        // const Divider(height: 1),
        Expanded(child: child),
      ],
    );
  }
}

class _WindowRibbon extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return ColoredBox(
      color: Theme.of(context).colorScheme.primaryContainer,
      child: Row(
        children: [
          Padding(
            padding: EdgeInsets.symmetric(horizontal: AppSpacing.md),
            child: Text(
              context.l10n.appName,
              style: TextStyle(
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
          VelinMenuButton(
            label: context.l10n.menuFile,
            onPressed: () {},
          ),
          VelinMenuButton(
            label: context.l10n.menuEdit,
            onPressed: () {},
          ),
          VelinMenuButton(
            label: context.l10n.menuView,
            onPressed: () {},
          ),
          const Expanded(
            child: DragToMoveArea(
              child: SizedBox(height: AppDimensions.desktopRibbonHeight),
            ),
          ),
          const VelinWindowControls(),
        ],
      ),
    );
  }
}
