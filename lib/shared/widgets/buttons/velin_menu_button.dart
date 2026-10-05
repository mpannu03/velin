import 'package:material_ui/material_ui.dart';
import 'package:velin/app/theme/theme.dart';

class VelinMenuButton extends StatelessWidget {
  const VelinMenuButton({
    required this.label,
    required this.onPressed,
    super.key,
  });

  final String label;
  final VoidCallback onPressed;

  @override
  Widget build(BuildContext context) {
    return TextButton(
      onPressed: onPressed,
      style: TextButton.styleFrom(
        padding: const EdgeInsets.all(AppSpacing.md),
        minimumSize: Size.zero,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(AppRadius.sm),
        ),
        foregroundColor: Theme.of(context).colorScheme.onSurface,
      ),
      child: Text(label),
    );
  }
}
