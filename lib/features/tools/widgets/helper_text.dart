import 'package:material_ui/material_ui.dart';

/// Small muted explanatory line shown beneath a control.
class HelperText extends StatelessWidget {
  const HelperText(this.text, {super.key});

  final String text;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Text(
      text,
      style: theme.textTheme.bodySmall?.copyWith(
        color: theme.colorScheme.onSurfaceVariant,
      ),
    );
  }
}
