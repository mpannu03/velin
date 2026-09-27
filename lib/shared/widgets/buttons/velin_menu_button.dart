import 'package:material_ui/material_ui.dart';
import 'package:velin/app/presentation/presentation.dart';
import 'package:velin/app/theme/app_radius.dart';

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
        minimumSize: Size(
          0,
          context.presentation.controlHeight,
        ),
        padding: const EdgeInsets.symmetric(horizontal: 10),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(AppRadius.sm),
        ),
        foregroundColor: Theme.of(context).colorScheme.onSurface,
      ),
      child: Text(label),
    );
  }
}