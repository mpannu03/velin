import 'page_selection.dart';

class PageSelectionParser {
  const PageSelectionParser();

  PageSelection parse(String input) {
    final value = input.trim();

    if (value.isEmpty) {
      throw const EmptyPageSelectionError();
    }

    final items = <PageSelectionItem>[];

    for (final rawToken in value.split(',')) {
      final token = rawToken.trim();

      if (token.isEmpty) {
        throw const InvalidPageSelectionTokenError('');
      }

      final lowerToken = token.toLowerCase();

      switch (lowerToken) {
        case 'odd':
          items.add(const PageSelectionOdd());
          continue;

        case 'even':
          items.add(const PageSelectionEven());
          continue;

        case 'last':
          items.add(const PageSelectionLast());
          continue;
      }

      if (lowerToken.startsWith('last-')) {
        final number = token.substring(5);

        final amount = int.tryParse(number);

        if (amount == null || amount < 0) {
          throw InvalidPageSelectionNumberError(number);
        }

        items.add(PageSelectionLastMinus(amount));
        continue;
      }

      if (token.contains('-')) {
        items.add(_parseRange(token));
        continue;
      }

      final page = int.tryParse(token);

      if (page != null) {
        items.add(PageSelectionPage(page));
        continue;
      }

      throw InvalidPageSelectionTokenError(token);
    }

    return PageSelection(items);
  }

  PageSelectionItem _parseRange(String token) {
    final parts = token.split('-');

    if (parts.length != 2) {
      throw InvalidPageSelectionRangeError(token);
    }

    final start = parts[0].trim();
    final end = parts[1].trim();

    if (start.isEmpty) {
      final page = int.tryParse(end);

      if (page == null) {
        throw InvalidPageSelectionNumberError(end);
      }

      return PageSelectionOpenStart(page);
    }

    if (end.isEmpty) {
      final page = int.tryParse(start);

      if (page == null) {
        throw InvalidPageSelectionNumberError(start);
      }

      return PageSelectionOpenEnd(page);
    }

    final startPage = int.tryParse(start);

    if (startPage == null) {
      throw InvalidPageSelectionNumberError(start);
    }

    final endPage = int.tryParse(end);

    if (endPage == null) {
      throw InvalidPageSelectionNumberError(end);
    }

    return PageSelectionRange(startPage, endPage);
  }
}