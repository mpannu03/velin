import 'package:flutter/services.dart';
import 'package:material_ui/material_ui.dart';
import 'package:velin/app/theme/theme.dart';
import 'package:velin/shared/extensions/extensions.dart';

class PageIndicator extends StatelessWidget {
  const PageIndicator({
    super.key,
    required this.currentPage,
    required this.pageCount,
    required this.onGotoPage,
  });

  final int? currentPage;
  final int pageCount;
  final ValueChanged<int> onGotoPage;

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    // Nothing meaningful to show before a page is known.
    if (currentPage == null || pageCount == 0) {
      return const SizedBox.shrink();
    }

    return Tooltip(
      message: context.l10n.toolPageOf(currentPage!, pageCount),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          _PageInputField(
            currentPage: currentPage!,
            pageCount: pageCount,
            onGotoPage: onGotoPage,
          ),
          const SizedBox(width: AppSpacing.xs),
          Text(
            '/ $pageCount',
            style: Theme.of(context).textTheme.bodyMedium
                ?.copyWith(color: colorScheme.onSurfaceVariant),
          ),
        ],
      ),
    );
  }
}

class _PageInputField extends StatefulWidget {
  const _PageInputField({
    required this.currentPage,
    required this.pageCount,
    required this.onGotoPage,
  });

  final int currentPage;
  final int pageCount;
  final ValueChanged<int> onGotoPage;

  @override
  State<_PageInputField> createState() => _PageInputFieldState();
}

class _PageInputFieldState extends State<_PageInputField> {
  late TextEditingController _controller;
  late FocusNode _focusNode;

  @override
  void initState() {
    super.initState();
    _controller = TextEditingController(text: '${widget.currentPage}');
    _focusNode = FocusNode();
  }

  @override
  void didUpdateWidget(covariant _PageInputField oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (!_focusNode.hasFocus && widget.currentPage != oldWidget.currentPage) {
      _controller.text = '${widget.currentPage}';
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    _focusNode.dispose();
    super.dispose();
  }

  void _submit() {
    final value = int.tryParse(_controller.text);
    if (value == null || value < 1 || value > widget.pageCount) {
      _controller.text = '${widget.currentPage}';
      return;
    }

    // Re-submitting the current page would only jump to its top.
    if (value != widget.currentPage) widget.onGotoPage(value);
  }

  void _submitAndUnfocus() {
    _submit();
    _focusNode.unfocus();
  }

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;

    return ListenableBuilder(
      listenable: Listenable.merge([_focusNode, _controller]),
      builder: (context, _) {
        final isFocused = _focusNode.hasFocus;

        // Wide enough for the largest page number.
        final digits = '${widget.pageCount}'.length;

        return Container(
          width: 20.0 + digits * 9,
          height: 28,
          decoration: BoxDecoration(
            color: colorScheme.surfaceContainerHighest,
            border: Border.all(
              color: isFocused ? colorScheme.primary : Colors.transparent,
              width: 1.5,
            ),
            borderRadius: BorderRadius.circular(AppRadius.md),
          ),
          alignment: Alignment.center,
          child: EditableText(
            controller: _controller,
            focusNode: _focusNode,
            // Clicking elsewhere commits the typed page, like pressing Enter.
            onTapOutside: (_) => _submitAndUnfocus(),
            style: (textTheme.bodyMedium ?? const TextStyle()).copyWith(
              color: colorScheme.onSurface,
              fontSize: 14,
              height: 1.0,
            ),
            cursorColor: colorScheme.primary,
            backgroundCursorColor: colorScheme.surface,
            keyboardType: TextInputType.number,
            textAlign: TextAlign.center,
            textInputAction: TextInputAction.done,
            onSubmitted: (_) => _submitAndUnfocus(),
            inputFormatters: [
              FilteringTextInputFormatter.digitsOnly,
              LengthLimitingTextInputFormatter('${widget.pageCount}'.length),
            ],
          ),
        );
      },
    );
  }
}
