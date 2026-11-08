import 'package:material_ui/material_ui.dart';
import 'package:velin/app/theme/theme.dart';

/// A flat 32px icon button for toolbars: no fill until hovered, a soft
/// tonal fill when [isSelected] (for toggles such as panels and tools).
class ToolbarIconButton extends StatelessWidget {
  const ToolbarIconButton({
    required this.icon,
    required this.tooltip,
    required this.onPressed,
    this.isSelected = false,
    super.key,
  });

  final IconData icon;
  final String tooltip;
  final VoidCallback? onPressed;
  final bool isSelected;

  static const size = 32.0;

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return IconButton(
      tooltip: tooltip,
      onPressed: onPressed,
      isSelected: isSelected,
      icon: Icon(icon, size: 18),
      style:
          IconButton.styleFrom(
            fixedSize: const Size.square(size),
            minimumSize: const Size.square(size),
            padding: EdgeInsets.zero,
            foregroundColor: colorScheme.onSurfaceVariant,
            backgroundColor: isSelected ? colorScheme.secondaryContainer : null,
            disabledForegroundColor: colorScheme.onSurface.withValues(
              alpha: 0.3,
            ),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(AppRadius.md),
            ),
          ).copyWith(
            foregroundColor: WidgetStateProperty.resolveWith((states) {
              if (states.contains(WidgetState.disabled)) {
                return colorScheme.onSurface.withValues(alpha: 0.3);
              }
              return isSelected
                  ? colorScheme.onSecondaryContainer
                  : colorScheme.onSurfaceVariant;
            }),
          ),
    );
  }
}
