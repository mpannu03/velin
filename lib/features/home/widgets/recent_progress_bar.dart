import 'package:material_ui/material_ui.dart';

class RecentProgressBar extends StatelessWidget {
  const RecentProgressBar({required this.value, super.key, this.height = 4});

  final double value;
  final double height;

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;
    return ClipRRect(
      borderRadius: BorderRadius.circular(999),
      child: LinearProgressIndicator(
        value: value.clamp(0.0, 1.0),
        minHeight: height,
        backgroundColor: colors.surfaceContainerHighest,
        valueColor: AlwaysStoppedAnimation<Color>(colors.primary),
      ),
    );
  }
}
