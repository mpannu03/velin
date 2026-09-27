import 'package:material_ui/material_ui.dart';

class VelinWindowControls extends StatelessWidget {
  const VelinWindowControls({
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        _WindowButton(
          icon: Icons.remove,
          onPressed: () {},
        ),
        _WindowButton(
          icon: Icons.crop_square,
          onPressed: () {},
        ),
        _WindowButton(
          icon: Icons.close,
          close: true,
          onPressed: () {},
        ),
      ],
    );
  }
}

class _WindowButton extends StatefulWidget {
  const _WindowButton({
    required this.icon,
    required this.onPressed,
    this.close = false,
  });

  final IconData icon;
  final VoidCallback onPressed;
  final bool close;

  @override
  State<_WindowButton> createState() => _WindowButtonState();
}

class _WindowButtonState extends State<_WindowButton> {
  bool _hovered = false;

  @override
  Widget build(BuildContext context) {
    final foreground = Theme.of(context).colorScheme.onSurface;

    return MouseRegion(
      cursor: SystemMouseCursors.click,
      onEnter: (_) => setState(() => _hovered = true),
      onExit: (_) => setState(() => _hovered = false),
      child: GestureDetector(
        onTap: widget.onPressed,
        child: SizedBox(
          width: 46,
          height: 40,
          child: ColoredBox(
            color: _hovered
                ? widget.close
                    ? Colors.red
                    : Theme.of(context).colorScheme.surfaceContainerHighest
                : Colors.transparent,
            child: Center(
              child: Icon(
                widget.icon,
                size: 16,
                color: widget.close && _hovered
                    ? Colors.white
                    : foreground,
              ),
            ),
          ),
        ),
      ),
    );
  }
}