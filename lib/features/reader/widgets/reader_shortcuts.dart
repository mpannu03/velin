import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';
import 'package:material_ui/material_ui.dart';
import 'package:velin/core/document/document.dart';

/// Keyboard shortcuts for the reader's document tabs:
///
/// * Ctrl+W (⌘W on macOS) closes the current document.
/// * Ctrl+Tab / Ctrl+PageDown selects the next tab, Ctrl+Shift+Tab /
///   Ctrl+PageUp the previous one (both wrap around).
///
/// Takes keyboard focus whenever the reader becomes visible or another
/// document is selected, unless something inside it is already focused
/// (e.g. the search field), so the shortcuts work without clicking first.
class ReaderShortcuts extends StatefulWidget {
  const ReaderShortcuts({
    required this.documents,
    required this.selectedDocument,
    required this.onDocumentSelected,
    required this.onDocumentClosed,
    required this.child,
    super.key,
  });

  final List<Document> documents;
  final Document? selectedDocument;
  final ValueChanged<Document> onDocumentSelected;
  final ValueChanged<Document> onDocumentClosed;
  final Widget child;

  @override
  State<ReaderShortcuts> createState() => _ReaderShortcutsState();
}

class _ReaderShortcutsState extends State<ReaderShortcuts> {
  final _focusNode = FocusNode(debugLabel: 'ReaderShortcuts');

  bool _wasVisible = false;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();

    // Inactive navigation branches are kept alive with tickers disabled.
    final isVisible = TickerMode.valuesOf(context).enabled;
    if (isVisible && !_wasVisible) _takeFocus();
    _wasVisible = isVisible;
  }

  @override
  void didUpdateWidget(ReaderShortcuts oldWidget) {
    super.didUpdateWidget(oldWidget);

    if (widget.selectedDocument != oldWidget.selectedDocument) _takeFocus();
  }

  @override
  void dispose() {
    _focusNode.dispose();
    super.dispose();
  }

  void _takeFocus() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted || _focusNode.hasFocus) return;
      if (!TickerMode.valuesOf(context).enabled) return;
      _focusNode.requestFocus();
    });
  }

  void _closeSelected() {
    final selected = widget.selectedDocument;
    if (selected != null) widget.onDocumentClosed(selected);
  }

  void _selectRelative(int offset) {
    final documents = widget.documents;
    final selected = widget.selectedDocument;
    if (documents.length < 2 || selected == null) return;

    final index = documents.indexOf(selected);
    if (index < 0) return;

    widget.onDocumentSelected(documents[(index + offset) % documents.length]);
  }

  @override
  Widget build(BuildContext context) {
    final isMac = defaultTargetPlatform == TargetPlatform.macOS;

    return CallbackShortcuts(
      bindings: {
        SingleActivator(LogicalKeyboardKey.keyW, control: !isMac, meta: isMac):
            _closeSelected,
        const SingleActivator(LogicalKeyboardKey.tab, control: true): () =>
            _selectRelative(1),
        const SingleActivator(
          LogicalKeyboardKey.tab,
          control: true,
          shift: true,
        ): () =>
            _selectRelative(-1),
        const SingleActivator(LogicalKeyboardKey.pageDown, control: true): () =>
            _selectRelative(1),
        const SingleActivator(LogicalKeyboardKey.pageUp, control: true): () =>
            _selectRelative(-1),
      },
      child: Focus(focusNode: _focusNode, child: widget.child),
    );
  }
}
