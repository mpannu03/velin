import 'package:material_ui/material_ui.dart';

class ToolActionBar extends StatelessWidget {
  const ToolActionBar({
    super.key,
    required this.isSubmitting,
    required this.submittingText,
    required this.canAction,
    required this.icon,
    required this.label,
    required this.hintText,
    required this.onAction,
  });

  final bool isSubmitting;
  final String submittingText;
  final IconData icon;
  final String label;
  final String hintText;

  final bool canAction;
  final VoidCallback onAction;

  @override
  Widget build(BuildContext context) {
    if (isSubmitting) {
      return Align(
        alignment: Alignment.centerRight,
        child: FilledButton.icon(
          onPressed: null,
          icon: const SizedBox(
            width: 16,
            height: 16,
            child: CircularProgressIndicator(strokeWidth: 2),
          ),
          label: Text(submittingText),
        ),
      );
    }

    final button = canAction
        ? FilledButton.icon(
            onPressed: onAction,
            icon: Icon(icon, size: 18),
            label: Text(label),
          )
        : OutlinedButton.icon(
            onPressed: onAction,
            icon: Icon(icon, size: 18),
            label: Text(label),
          );

    return Align(
      alignment: Alignment.centerRight,
      child: Tooltip(message: canAction ? '' : hintText, child: button),
    );
  }
}
