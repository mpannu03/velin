import 'package:material_ui/material_ui.dart';

class VelinHoverable extends StatefulWidget {
  const VelinHoverable({
    required this.child,
    this.onTap,
    this.hoverColor,
    super.key,
  });

  final Widget child;
  final VoidCallback? onTap;
  final Color? hoverColor;

  @override
  State<VelinHoverable> createState() => _VelinHoverableState();
}

class _VelinHoverableState extends State<VelinHoverable> {
  bool _hovered = false;

  @override
  Widget build(BuildContext context) {
    final color = _hovered
        ? widget.hoverColor ?? Theme.of(context).colorScheme.surfaceContainer
        : null;

    return MouseRegion(
      cursor: widget.onTap == null
          ? SystemMouseCursors.basic
          : SystemMouseCursors.click,
      onEnter: (_) => setState(() => _hovered = true),
      onExit: (_) => setState(() => _hovered = false),
      child: GestureDetector(
        onTap: widget.onTap,
        child: ColoredBox(
          color: color ?? Colors.transparent,
          child: widget.child,
        ),
      ),
    );
  }
}