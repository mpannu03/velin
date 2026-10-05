import 'package:pdfrx/pdfrx.dart';
import 'package:velin/core/document/engine/engine.dart';

class PdfBookmarkCapability implements BookmarkCapability {
  PdfBookmarkCapability(this._controller);

  final PdfViewerController _controller;

  final Map<String, PdfDest> _destById = {};
  List<Bookmark>? _cache;

  @override
  Future<List<Bookmark>> get bookmarks async {
    if (_cache != null) return _cache!;

    final nodes = await _controller.document.loadOutline();
    _destById.clear();

    _cache = _convert(nodes, '');
    return _cache!;
  }

  /// goToDest was not preserving zoom so we use goToPage instead.
  @override
  void goto(Bookmark bookmark) {
    // final dest = _destById[bookmark.id];
    _controller.goToPage(pageNumber: bookmark.page);
    // if (dest != null) {
    //   _controller.goToDest(dest);
    // } else {
    //   _controller.goToPage(pageNumber: bookmark.page);
    // }
  }

  List<Bookmark> _convert(List<PdfOutlineNode> list, String parentPath) {
    final out = <Bookmark>[];
    for (var i = 0; i < list.length; i++) {
      final node = list[i];
      final id = parentPath.isEmpty ? '$i' : '$parentPath.$i';

      final dest = node.dest;
      if (dest != null) _destById[id] = dest;

      out.add(
        Bookmark(
          id: id,
          title: node.title,
          page: dest == null ? 1 : dest.pageNumber,
          children: _convert(node.children, id),
        ),
      );
    }
    return out;
  }
}
