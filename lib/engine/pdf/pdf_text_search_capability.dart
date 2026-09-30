import 'dart:async';

import 'package:pdfrx/pdfrx.dart';
import 'package:velin/core/document/engine/engine.dart';

class PdfTextSearchCapability implements TextSearchCapability {
  PdfTextSearchCapability(PdfViewerController controller)
    : _textSearcher = PdfTextSearcher(controller);

  final PdfTextSearcher _textSearcher;

  @override
  Future<void> clear() async {
    _textSearcher.resetTextSearch();
  }

  @override
  Stream<List<TextSearchResult>> search(String text) {
    final controller = StreamController<List<TextSearchResult>>();

    List<TextSearchResult> getCurrentResults() {
      return _textSearcher.matches.asMap().entries.map((entry) {
        final idx = entry.key;
        final match = entry.value;
        return TextSearchResult(
          index: idx,
          pageNumber: match.pageNumber,
          text: match.text,
        );
      }).toList();
    }

    void listener() {
      if (controller.isClosed) return;

      controller.add(getCurrentResults());

      if (!_textSearcher.isSearching) {
        _textSearcher.removeListener(listener);
        controller.close();
      }
    }

    _textSearcher.addListener(listener);
    _textSearcher.startTextSearch(text, caseInsensitive: true);

    controller.onCancel = () {
      _textSearcher.removeListener(listener);
      if (_textSearcher.isSearching) {
        _textSearcher.resetTextSearch();
      }
    };

    return controller.stream;
  }

  @override
  Future<void> selectResult(TextSearchResult result) async {
    final v = await _textSearcher.goToMatchOfIndex(result.index);;
  }
}