import 'package:material_ui/material_ui.dart';

/// An obscured text field that commits its value on submit and on focus loss.
///
/// Shared by every tool that asks the user for a PDF password. The controller
/// is owned here rather than driven by the view model so the caret does not
/// jump to the end on every keystroke.
class PasswordField extends StatefulWidget {
  const PasswordField({
    required this.fieldKey,
    required this.value,
    required this.labelText,
    required this.helperText,
    required this.onChanged,
    super.key,
  });

  /// Current password.
  final String value;

  final String labelText;
  final String helperText;

  /// Key applied to the inner text field, used by widget tests.
  final Key fieldKey;

  /// Called when the field is submitted or unfocused.
  final ValueChanged<String> onChanged;

  @override
  State<PasswordField> createState() => _PasswordFieldState();
}

class _PasswordFieldState extends State<PasswordField> {
  late final TextEditingController _controller;

  @override
  void initState() {
    super.initState();
    _controller = TextEditingController(text: widget.value);
  }

  @override
  void didUpdateWidget(PasswordField oldWidget) {
    super.didUpdateWidget(oldWidget);

    if (widget.value != oldWidget.value &&
        widget.value != _controller.text) {
      _controller.text = widget.value;
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void _commit() => widget.onChanged(_controller.text);

  @override
  Widget build(BuildContext context) {
    return TextField(
      key: widget.fieldKey,
      controller: _controller,
      obscureText: true,
      onSubmitted: (_) => _commit(),
      onTapOutside: (_) => _commit(),
      decoration: InputDecoration(
        labelText: widget.labelText,
        helperText: widget.helperText,
        helperMaxLines: 2,
        isDense: true,
        border: const OutlineInputBorder(),
      ),
    );
  }
}