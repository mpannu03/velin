import 'package:material_ui/material_ui.dart';

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
        icon: Icon(icon),
        padding: EdgeInsets.zero,
      ),
    );
  }
}