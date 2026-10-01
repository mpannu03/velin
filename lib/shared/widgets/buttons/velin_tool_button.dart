import 'package:material_ui/material_ui.dart';
import 'package:velin/app/theme/theme.dart';

class VelinToolButton extends StatelessWidget {
  const VelinToolButton({
    super.key,
    required this.icon,
    required this.toolTip,
    required this.onPressed,
    this.isSelected,
  });

  final IconData icon;
  final String toolTip;
  final VoidCallback onPressed;
  final bool? isSelected;

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    
    return Tooltip(
      message: toolTip,
      child: IconButton(
        onPressed: onPressed,
        icon: Icon(icon, size: 16),
        padding: EdgeInsets.all(AppSpacing.xs),
        style: IconButton.styleFrom(
          minimumSize: Size.zero,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(AppRadius.md),
          ),
          backgroundColor: isSelected ?? false
              ? colorScheme.surfaceDim : Colors.transparent,
        ),
      ),
    );
  }
}