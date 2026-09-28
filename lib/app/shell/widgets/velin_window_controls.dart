import 'package:material_ui/material_ui.dart';
import 'package:window_manager/window_manager.dart';

class VelinWindowControls extends StatelessWidget {
  const VelinWindowControls({
    super.key,
    this.windowManager
  });

  final WindowManager? windowManager;

  WindowManager get _windowManager => windowManager ?? WindowManager.instance;

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        _MinimiseButton(
          windowManager: _windowManager,
        ),
        _ResizeButton(
          windowManager: _windowManager,
        ),
        _CloseButton(
          windowManager: _windowManager,
        ),
      ],
    );
  }
}

class _MinimiseButton extends StatelessWidget {
  const _MinimiseButton({
    required this.windowManager
  });

  final WindowManager windowManager;

  @override
  Widget build(BuildContext context) {
    return _WindowButtonShell(
      icon: Icons.remove,
      onPressed: () => windowManager.minimize(),
    );
  }
}

class _ResizeButton extends StatefulWidget {
  const _ResizeButton({required this.windowManager});

  final WindowManager windowManager;

  @override
  State<_ResizeButton> createState() => _ResizeButtonState();
}

class _ResizeButtonState extends State<_ResizeButton> {
  bool? _isMaximized;

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    final maximized = await widget.windowManager.isMaximized();
    if (!mounted) return;
    setState(() => _isMaximized = maximized);
  }

  Future<void> _toggle() async {
    if (_isMaximized == null) return;

    if (_isMaximized == true) {
      await widget.windowManager.restore();
    } else {
      await widget.windowManager.maximize();
    }

    await _load();
  }

  @override
  Widget build(BuildContext context) {
    final icon = (_isMaximized ?? false) ? Icons.filter_none : Icons.crop_square;

    return _WindowButtonShell(
      icon: icon,
      onPressed: _toggle,
      iconSize: (_isMaximized ?? false) ? 12 : 16,
    );
  }
}

class _CloseButton extends StatelessWidget {
  const _CloseButton({
    required this.windowManager,
  });

  final WindowManager windowManager;

  @override
  Widget build(BuildContext context) {
    return _WindowButtonShell(
      icon: Icons.close,
      onPressed: () => windowManager.close(),
      hoverColor: Colors.red,
    );
  }
  
}

class _WindowButtonShell extends StatefulWidget {
  const _WindowButtonShell({
    required this.icon,
    required this.onPressed,
    this.hoverColor,
    this.iconSize,
  });

  final IconData icon;
  final VoidCallback onPressed;
  final Color? hoverColor;
  final double? iconSize;

  @override
  State<_WindowButtonShell> createState() => _WindowButtonShellState();
}

class _WindowButtonShellState extends State<_WindowButtonShell> {
  bool _hovered = false;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    return MouseRegion(
      cursor: SystemMouseCursors.click,
      onEnter: (_) => setState(() => _hovered = true),
      onExit: (_) => setState(() => _hovered = false),
      child: GestureDetector(
        onTap: widget.onPressed,
        child: Container(
          width: 46,
          height: 32,
          color: _hovered
              ? widget.hoverColor ?? scheme.surfaceContainerHighest
              : Colors.transparent,
          alignment: Alignment.center,
          child: Icon(
            widget.icon,
            size: widget.iconSize ?? 16,
            color: scheme.onSurface,
          ),
        ),
      ),
    );
  }
}
