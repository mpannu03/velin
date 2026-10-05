import 'package:material_ui/material_ui.dart';

import 'package:velin/shared/extensions/extensions.dart';

/// Generic page-range input shared by every PDF tool that lets the user pick
/// which pages take part in an operation.
///
/// The widget keeps its own [TextEditingController] so that rebuilds (which
/// happen on every keystroke in the split tool) do not reset the cursor.
/// [value] is only pushed back into the controller when it actually differs
/// from what the user typed.
class PageSelectionField extends StatefulWidget {
  const PageSelectionField({
    required this.value,
    this.onChanged,
    this.onSubmitted,
    this.labelText,
    this.hintText,
    this.fieldKey,
    this.width,
    this.keyboardType,
    this.autofocus = false,
    this.commitOnTapOutside = false,
    super.key,
  });

  /// Current page selection, e.g. `1-5, 8, last`.
  final String value;

  /// Called on every keystroke. Omit when the tool commits on submit only.
  final ValueChanged<String>? onChanged;

  /// Called when the field is submitted or unfocused with
  /// [commitOnTapOutside] enabled.
  final ValueChanged<String>? onSubmitted;

  /// Defaults to `toolsPagesLabel`.
  final String? labelText;

  /// Defaults to `toolsPagesHint`.
  final String? hintText;

  /// Key applied to the inner text field, used by widget tests.
  final Key? fieldKey;

  /// Optional fixed width for the field.
  final double? width;

  final TextInputType? keyboardType;
  final bool autofocus;

  /// Submits the current value when the user taps outside the field.
  final bool commitOnTapOutside;

  @override
  State<PageSelectionField> createState() => _PageSelectionFieldState();
}

class _PageSelectionFieldState extends State<PageSelectionField> {
  late final TextEditingController _controller;

  @override
  void initState() {
    super.initState();
    _controller = TextEditingController(text: widget.value);
  }

  @override
  void didUpdateWidget(PageSelectionField oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.value != _controller.text) {
      _controller.value = TextEditingValue(
        text: widget.value,
        selection: TextSelection.collapsed(offset: widget.value.length),
      );
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void _handleTapOutside(PointerDownEvent event) {
    if (widget.commitOnTapOutside) {
      widget.onSubmitted?.call(_controller.text);
    }
  }

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;

    final field = TextField(
      key: widget.fieldKey,
      controller: _controller,
      autofocus: widget.autofocus,
      keyboardType: widget.keyboardType,
      onChanged: widget.onChanged,
      onSubmitted: widget.onSubmitted,
      onTapOutside: _handleTapOutside,
      decoration: InputDecoration(
        labelText: widget.labelText ?? l10n.toolsPagesLabel,
        hintText: widget.hintText ?? l10n.toolsPagesHint,
        isDense: true,
        border: const OutlineInputBorder(),
      ),
    );

    return widget.width == null
        ? field
        : SizedBox(width: widget.width, child: field);
  }
}
