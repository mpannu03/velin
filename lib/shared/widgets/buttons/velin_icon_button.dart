import 'package:material_ui/material_ui.dart';
import 'package:velin/app/theme/theme.dart';

class VelinIconButton extends StatelessWidget {
  const VelinIconButton({
    required this.icon,
    required this.tooltip,
    required this.onPressed,
    super.key,
  });

  final IconData icon;
  final String tooltip;
  final VoidCallback? onPressed;

  @override
  Widget build(BuildContext context) {
    return Tooltip(
      message: tooltip,
      child: IconButton(
        onPressed: onPressed,
        icon: Icon(icon,
          size: AppDimensions.iconButtonSize,
          color: Theme.of(context).colorScheme.primary,
        ),
        padding: EdgeInsets.all(AppSpacing.xs),
        style: IconButton.styleFrom(
          minimumSize: Size.zero,
          backgroundColor: Theme.of(context).colorScheme.primaryContainer,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(AppRadius.md),
          ),
        ),
      ),
    );
  }
}