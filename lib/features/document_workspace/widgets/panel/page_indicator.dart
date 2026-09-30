import 'package:flutter/services.dart';
import 'package:material_ui/material_ui.dart';
import 'package:velin/app/theme/theme.dart';

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
      message: 'Page $currentPage of $pageCount',
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          _PageInputField(
            currentPage: currentPage!,
            pageCount: pageCount,
            onGotoPage: onGotoPage,
          ),
          Container(
            width: 16,
            height: 1,
            margin: const EdgeInsets.symmetric(vertical: AppSpacing.xs),
            color: colorScheme.outlineVariant,
          ),
          Text('$pageCount'),
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
    if (!_focusNode.hasFocus &&
        widget.currentPage != oldWidget.currentPage) {
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
    widget.onGotoPage(value);
  }

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return SizedBox(
      width: 32,
      height: 32,
      child: TextField(
        controller: _controller,
        focusNode: _focusNode,
        keyboardType: TextInputType.number,
        inputFormatters: [
          FilteringTextInputFormatter.digitsOnly,
          LengthLimitingTextInputFormatter(
            '${widget.pageCount}'.length,
          ),
        ],
        textAlign: TextAlign.center,
        textAlignVertical: TextAlignVertical.center,
        textInputAction: TextInputAction.done,
        onSubmitted: (_) {
          _submit();
          _focusNode.unfocus();
        },
        onTapOutside: (_) {
          _focusNode.unfocus();
          _submit();
        },
        style: Theme.of(context).textTheme.bodyMedium,
        decoration: InputDecoration(
          isDense: true,
          contentPadding: EdgeInsets.zero,
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(4),
            borderSide: BorderSide(color: colorScheme.outline),
          ),
          enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(4),
            borderSide: BorderSide(color: colorScheme.outlineVariant),
          ),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(4),
            borderSide: BorderSide(color: colorScheme.primary, width: 1.5),
          ),
        ),
      ),
    );
  }
}