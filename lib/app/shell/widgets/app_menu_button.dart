import 'package:flutter_svg/flutter_svg.dart';
import 'package:material_ui/material_ui.dart';
import 'package:velin/app/commands/commands.dart';
import 'package:velin/app/theme/theme.dart';
import 'package:velin/shared/extensions/extensions.dart';

/// The app logo in the title bar; opens the application menu on Windows and
/// Linux. (macOS uses the native menu bar instead.)
class AppMenuButton extends StatelessWidget {
  const AppMenuButton({super.key});

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final l10n = context.l10n;

    return MenuAnchor(
      alignmentOffset: const Offset(AppSpacing.xs, 0),
      menuChildren: [
        for (final (index, group) in appMenuGroups.indexed) ...[
          if (index > 0) const Divider(height: AppSpacing.sm),
          for (final command in group)
            MenuItemButton(
              leadingIcon: Icon(command.icon, size: 18),
              shortcut: command.shortcut,
              onPressed: () =>
                  Actions.maybeInvoke(context, AppCommandIntent(command)),
              child: Text(command.label(l10n)),
            ),
        ],
      ],
      builder: (context, controller, _) => Tooltip(
        message: l10n.menuApp,
        child: InkWell(
          onTap: () =>
              controller.isOpen ? controller.close() : controller.open(),
          child: SizedBox(
            width: AppDimensions.desktopRibbonHeight + AppSpacing.sm,
            height: AppDimensions.desktopRibbonHeight,
            child: Padding(
              padding: const EdgeInsets.all(AppSpacing.sm),
              child: SvgPicture.asset(
                'assets/icons/icon_mono.svg',
                colorFilter: ColorFilter.mode(
                  colorScheme.primary,
                  BlendMode.modulate,
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
