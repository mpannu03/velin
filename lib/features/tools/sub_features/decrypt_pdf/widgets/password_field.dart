import 'package:material_ui/material_ui.dart';
import 'package:velin/shared/extensions/extensions.dart';

/// An obscured text field that commits its value on submit and on focus loss.
///
/// The controller is owned here rather than driven by the view model so the
/// caret does not jump to the end on every keystroke.
class PasswordField extends StatefulWidget {
  const PasswordField({
    super.key,
    required this.password,
    required this.onPasswordChanged,
  });

  final String password;
  final ValueChanged<String> onPasswordChanged;

  @override
  State<PasswordField> createState() => _PasswordFieldState();
}

class _PasswordFieldState extends State<PasswordField> {
  late final TextEditingController _controller;

  @override
  void initState() {
    super.initState();
    _controller = TextEditingController(text: widget.password);
  }

  @override
  void didUpdateWidget(covariant PasswordField oldWidget) {
    super.didUpdateWidget(oldWidget);

    final password = widget.password;

    if (password != oldWidget.password &&
        password != _controller.text) {
      _controller.text = password;
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void _commit() => widget.onPasswordChanged(_controller.text);

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;

    return TextField(
      key: const ValueKey('decrypt-password'),
      controller: _controller,
      obscureText: true,
      onSubmitted: (_) => _commit(),
      onTapOutside: (_) => _commit(),
      decoration: InputDecoration(
        labelText: l10n.toolsUnlockPasswordLabel,
        helperText: l10n.toolsUnlockPasswordHelper,
        helperMaxLines: 2,
        isDense: true,
        border: const OutlineInputBorder(),
      ),
    );
  }
}