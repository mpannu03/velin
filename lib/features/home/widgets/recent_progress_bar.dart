import 'package:material_ui/material_ui.dart';

/// A thin reading-progress bar.
class RecentProgressBar extends StatelessWidget {
  const RecentProgressBar({required this.value, super.key, this.height = 3});

  final double value;
  final double height;

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;
    return ClipRRect(
      borderRadius: BorderRadius.circular(height),
      child: LinearProgressIndicator(
        value: value.clamp(0.0, 1.0),
        minHeight: height,
        backgroundColor: colors.surfaceContainerHighest,
        valueColor: AlwaysStoppedAnimation<Color>(colors.primary),
      ),
    );
  }
}
