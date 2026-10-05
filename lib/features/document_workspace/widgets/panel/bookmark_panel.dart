import 'package:material_symbols_icons/symbols.dart';
import 'package:material_ui/material_ui.dart';
import 'package:velin/app/theme/theme.dart';
import 'package:velin/core/document/engine/engine.dart';
import 'package:velin/shared/extensions/extensions.dart';

import 'empty_state_shell.dart';

class BookmarkPanel extends StatelessWidget {
  const BookmarkPanel({
    super.key,
    required this.bookmarks,
    required this.onBookmarkSelected,
  });

  final List<Bookmark> bookmarks;
  final ValueChanged<Bookmark> onBookmarkSelected;

  @override
  Widget build(BuildContext context) {
    if (bookmarks.isEmpty) {
      return EmptyStateShell(
        icon: Symbols.bookmark,
        message: context.l10n.panelBookmarkEmpty,
      );
    }

    return SingleChildScrollView(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: bookmarks.map((bookmark) {
          return _BookmarkNode(
            bookmark: bookmark,
            depth: 0,
            onSelected: onBookmarkSelected,
          );
        }).toList(),
      ),
    );
  }
}

class _BookmarkNode extends StatefulWidget {
  const _BookmarkNode({
    required this.bookmark,
    required this.depth,
    required this.onSelected,
  });

  final Bookmark bookmark;
  final int depth;
  final ValueChanged<Bookmark> onSelected;

  @override
  State<_BookmarkNode> createState() => _BookmarkNodeState();
}

class _BookmarkNodeState extends State<_BookmarkNode> {
  bool _expanded = false;

  @override
  Widget build(BuildContext context) {
    final bookmark = widget.bookmark;
    final depth = widget.depth;
    final hasChildren = bookmark.children.isNotEmpty;

    final padding = EdgeInsets.only(
      left: (depth + 1) * AppSpacing.md,
      right: AppSpacing.md,
    );

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        ListTile(
          contentPadding: padding,
          title: Text(bookmark.title),
          onTap: () => widget.onSelected(bookmark),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(AppRadius.md),
          ),
          trailing: hasChildren
              ? IconButton(
                  icon: Icon(_expanded ? Icons.expand_less : Icons.expand_more),
                  onPressed: () => setState(() => _expanded = !_expanded),
                )
              : null,
        ),
        if (hasChildren)
          ClipRect(
            child: AnimatedAlign(
              alignment: Alignment.topCenter,
              heightFactor: _expanded ? 1.0 : 0.0,
              duration: const Duration(milliseconds: 200),
              curve: Curves.easeInOut,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: bookmark.children.map((child) {
                  return _BookmarkNode(
                    bookmark: child,
                    depth: depth + 1,
                    onSelected: widget.onSelected,
                  );
                }).toList(),
              ),
            ),
          ),
      ],
    );
  }
}
