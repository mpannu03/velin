import 'package:material_ui/material_ui.dart';

class HelperText extends StatelessWidget {
  const HelperText(
    this.text, {super.key}
    );

  final String text;

  @override
  Widget build(BuildContext context) {
    return Text(
      text,
      style: Theme.of(context).textTheme.bodySmall?.copyWith(
        color: Theme.of(context).colorScheme.onSurfaceVariant,
      ),
    );
  }
}