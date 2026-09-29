import 'package:material_ui/material_ui.dart';
import 'package:velin/app/theme/theme.dart';

class VelinIconButton extends StatelessWidget {
  const VelinIconButton({
    required this.icon,
    required this.tooltip,
    required this.onPressed,
    this.isSelected,
    super.key,
  });

  final IconData icon;
  final String tooltip;
  final VoidCallback? onPressed;
  final bool? isSelected;

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return Tooltip(
      message: tooltip,
      child: IconButton(
        onPressed: onPressed,
        icon: Icon(icon,
          size: AppDimensions.iconButtonSize,
          color: isSelected ?? false 
              ? colorScheme.onPrimary : colorScheme.primary,
        ),
        padding: EdgeInsets.all(AppSpacing.sm),
        style: IconButton.styleFrom(
          minimumSize: Size.zero,
          backgroundColor: isSelected ?? false 
              ? colorScheme.primary : colorScheme.primaryContainer,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(AppRadius.md),
          ),
        ),
      ),
    );
  }
}