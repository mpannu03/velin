import 'page_selection_error.dart';
import 'page_selection_item.dart';

export 'page_selection_error.dart';
export 'page_selection_item.dart';
export 'page_selection_parser.dart';

class PageSelection {
  const PageSelection(this.items);

  final List<PageSelectionItem> items;

  List<int> resolve(int totalPages) {
    final result = <int>[];

    for (final item in items) {
      result.addAll(_resolveItem(item, totalPages));
    }

    return result;
  }

  List<List<int>> resolveGroups(int totalPages) {
    return [
      for (final item in items) _resolveItem(item, totalPages),
    ];
  }

  List<int> _resolveItem(
    PageSelectionItem item,
    int totalPages,
  ) {
    return switch (item) {
      PageSelectionPage(:final page) => [
          _validatePage(page, totalPages),
        ],

      PageSelectionRange(:final start, :final end) => _resolveRange(
          start,
          end,
          totalPages,
        ),

      PageSelectionOpenStart(:final end) => _resolveRange(
          1,
          end,
          totalPages,
        ),

      PageSelectionOpenEnd(:final start) => _resolveRange(
          start,
          totalPages,
          totalPages,
        ),

      PageSelectionLast() => [
          _validatePage(totalPages, totalPages),
        ],

      PageSelectionLastMinus(:final amount) => [
          _resolveLastMinus(amount, totalPages),
        ],

      PageSelectionOdd() => [
          for (var page = 1; page <= totalPages; page += 2) page,
        ],

      PageSelectionEven() => [
          for (var page = 2; page <= totalPages; page += 2) page,
        ],
    };
  }

  List<int> _resolveRange(
    int start,
    int end,
    int totalPages,
  ) {
    final result = <int>[];

    if (start <= end) {
      for (var page = start; page <= end; page++) {
        result.add(_validatePage(page, totalPages));
      }
    } else {
      for (var page = start; page >= end; page--) {
        result.add(_validatePage(page, totalPages));
      }
    }

    return result;
  }

  int _resolveLastMinus(int amount, int totalPages) {
    final page = totalPages - amount;

    if (page < 1) {
      throw PageSelectionOutOfBoundsError(
        page: page,
        totalPages: totalPages,
      );
    }

    return page;
  }

  int _validatePage(int page, int totalPages) {
    if (page < 1 || page > totalPages) {
      throw PageSelectionOutOfBoundsError(
        page: page,
        totalPages: totalPages,
      );
    }

    return page;
  }
}