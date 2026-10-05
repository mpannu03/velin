import 'package:flutter_test/flutter_test.dart';
import 'package:velin/core/page_selection/page_selection.dart';

void main() {
  group('resolve', () {
    group('Page', () {
      test('resolves a valid page', () {
        const selection = PageSelection([PageSelectionPage(5)]);

        expect(selection.resolve(10), [5]);
      });

      test('resolves the first page', () {
        const selection = PageSelection([PageSelectionPage(1)]);

        expect(selection.resolve(10), [1]);
      });

      test('resolves the last page', () {
        const selection = PageSelection([PageSelectionPage(10)]);

        expect(selection.resolve(10), [10]);
      });

      test('throws when page is zero', () {
        const selection = PageSelection([PageSelectionPage(0)]);

        expect(
          () => selection.resolve(10),
          throwsA(
            isA<PageSelectionOutOfBoundsError>()
                .having((e) => e.page, 'page', 0)
                .having((e) => e.totalPages, 'totalPages', 10),
          ),
        );
      });

      test('throws when page exceeds document length', () {
        const selection = PageSelection([PageSelectionPage(11)]);

        expect(
          () => selection.resolve(10),
          throwsA(
            isA<PageSelectionOutOfBoundsError>()
                .having((e) => e.page, 'page', 11)
                .having((e) => e.totalPages, 'totalPages', 10),
          ),
        );
      });
    });

    group('Range', () {
      test('resolves an ascending range', () {
        const selection = PageSelection([PageSelectionRange(3, 7)]);

        expect(selection.resolve(10), [3, 4, 5, 6, 7]);
      });

      test('resolves a descending range', () {
        const selection = PageSelection([PageSelectionRange(7, 3)]);

        expect(selection.resolve(10), [7, 6, 5, 4, 3]);
      });

      test('resolves a single-page range', () {
        const selection = PageSelection([PageSelectionRange(5, 5)]);

        expect(selection.resolve(10), [5]);
      });

      test('resolves a range starting at the first page', () {
        const selection = PageSelection([PageSelectionRange(1, 5)]);

        expect(selection.resolve(10), [1, 2, 3, 4, 5]);
      });

      test('resolves a range ending at the last page', () {
        const selection = PageSelection([PageSelectionRange(6, 10)]);

        expect(selection.resolve(10), [6, 7, 8, 9, 10]);
      });

      test('throws when ascending range exceeds document length', () {
        const selection = PageSelection([PageSelectionRange(8, 12)]);

        expect(
          () => selection.resolve(10),
          throwsA(
            isA<PageSelectionOutOfBoundsError>()
                .having((e) => e.page, 'page', 11)
                .having((e) => e.totalPages, 'totalPages', 10),
          ),
        );
      });

      test('throws when descending range exceeds document length', () {
        const selection = PageSelection([PageSelectionRange(12, 8)]);

        expect(
          () => selection.resolve(10),
          throwsA(
            isA<PageSelectionOutOfBoundsError>()
                .having((e) => e.page, 'page', 12)
                .having((e) => e.totalPages, 'totalPages', 10),
          ),
        );
      });

      test('throws when range contains page zero', () {
        const selection = PageSelection([PageSelectionRange(0, 5)]);

        expect(
          () => selection.resolve(10),
          throwsA(
            isA<PageSelectionOutOfBoundsError>()
                .having((e) => e.page, 'page', 0)
                .having((e) => e.totalPages, 'totalPages', 10),
          ),
        );
      });

      test('throws when descending range contains page zero', () {
        const selection = PageSelection([PageSelectionRange(5, 0)]);

        expect(
          () => selection.resolve(10),
          throwsA(
            isA<PageSelectionOutOfBoundsError>()
                .having((e) => e.page, 'page', 0)
                .having((e) => e.totalPages, 'totalPages', 10),
          ),
        );
      });
    });

    group('OpenStart', () {
      test('resolves pages from the beginning', () {
        const selection = PageSelection([PageSelectionOpenStart(5)]);

        expect(selection.resolve(10), [1, 2, 3, 4, 5]);
      });

      test('resolves a single-page open-start selection', () {
        const selection = PageSelection([PageSelectionOpenStart(1)]);

        expect(selection.resolve(10), [1]);
      });

      test('resolves through the last page', () {
        const selection = PageSelection([PageSelectionOpenStart(10)]);

        expect(selection.resolve(10), [1, 2, 3, 4, 5, 6, 7, 8, 9, 10]);
      });

      test('throws when end exceeds document length', () {
        const selection = PageSelection([PageSelectionOpenStart(11)]);

        expect(
          () => selection.resolve(10),
          throwsA(
            isA<PageSelectionOutOfBoundsError>()
                .having((e) => e.page, 'page', 11)
                .having((e) => e.totalPages, 'totalPages', 10),
          ),
        );
      });

      test('throws when end is zero', () {
        const selection = PageSelection([PageSelectionOpenStart(0)]);

        expect(
          () => selection.resolve(10),
          throwsA(
            isA<PageSelectionOutOfBoundsError>()
                .having((e) => e.page, 'page', 0)
                .having((e) => e.totalPages, 'totalPages', 10),
          ),
        );
      });
    });

    group('OpenEnd', () {
      test('resolves pages through the end', () {
        const selection = PageSelection([PageSelectionOpenEnd(6)]);

        expect(selection.resolve(10), [6, 7, 8, 9, 10]);
      });

      test(
        'resolves a single-page selection when starting at the last page',
        () {
          const selection = PageSelection([PageSelectionOpenEnd(10)]);

          expect(selection.resolve(10), [10]);
        },
      );

      test('resolves the entire document when starting at page one', () {
        const selection = PageSelection([PageSelectionOpenEnd(1)]);

        expect(selection.resolve(10), [1, 2, 3, 4, 5, 6, 7, 8, 9, 10]);
      });

      test('throws when start page exceeds document length', () {
        const selection = PageSelection([PageSelectionOpenEnd(11)]);

        expect(
          () => selection.resolve(10),
          throwsA(
            isA<PageSelectionOutOfBoundsError>()
                .having((e) => e.page, 'page', 11)
                .having((e) => e.totalPages, 'totalPages', 10),
          ),
        );
      });

      test('throws when start page is zero', () {
        const selection = PageSelection([PageSelectionOpenEnd(0)]);

        expect(
          () => selection.resolve(10),
          throwsA(
            isA<PageSelectionOutOfBoundsError>()
                .having((e) => e.page, 'page', 0)
                .having((e) => e.totalPages, 'totalPages', 10),
          ),
        );
      });
    });

    group('Last', () {
      test('resolves to the last page', () {
        const selection = PageSelection([PageSelectionLast()]);

        expect(selection.resolve(10), [10]);
      });

      test('resolves correctly for a one-page document', () {
        const selection = PageSelection([PageSelectionLast()]);

        expect(selection.resolve(1), [1]);
      });
    });

    group('LastMinus', () {
      test('resolves the requested page from the end', () {
        const selection = PageSelection([PageSelectionLastMinus(2)]);

        expect(selection.resolve(10), [8]);
      });

      test('last-0 resolves to the last page', () {
        const selection = PageSelection([PageSelectionLastMinus(0)]);

        expect(selection.resolve(10), [10]);
      });

      test('last-1 resolves to the page before the last', () {
        const selection = PageSelection([PageSelectionLastMinus(1)]);

        expect(selection.resolve(10), [9]);
      });

      test('last-(totalPages - 1) resolves to the first page', () {
        const selection = PageSelection([PageSelectionLastMinus(9)]);

        expect(selection.resolve(10), [1]);
      });

      test('last-0 resolves correctly for a one-page document', () {
        const selection = PageSelection([PageSelectionLastMinus(0)]);

        expect(selection.resolve(1), [1]);
      });

      test('last-1 is invalid for a one-page document', () {
        const selection = PageSelection([PageSelectionLastMinus(1)]);

        expect(
          () => selection.resolve(1),
          throwsA(
            isA<PageSelectionOutOfBoundsError>()
                .having((e) => e.page, 'page', 0)
                .having((e) => e.totalPages, 'totalPages', 1),
          ),
        );
      });

      test('throws when amount goes before the first page', () {
        const selection = PageSelection([PageSelectionLastMinus(10)]);

        expect(
          () => selection.resolve(10),
          throwsA(
            isA<PageSelectionOutOfBoundsError>()
                .having((e) => e.page, 'page', 0)
                .having((e) => e.totalPages, 'totalPages', 10),
          ),
        );
      });

      test('throws when amount goes beyond the first page', () {
        const selection = PageSelection([PageSelectionLastMinus(11)]);

        expect(
          () => selection.resolve(10),
          throwsA(
            isA<PageSelectionOutOfBoundsError>()
                .having((e) => e.page, 'page', -1)
                .having((e) => e.totalPages, 'totalPages', 10),
          ),
        );
      });
    });

    group('PageSelectionOdd', () {
      test('resolves odd pages', () {
        const selection = PageSelection([PageSelectionOdd()]);

        expect(selection.resolve(10), [1, 3, 5, 7, 9]);
      });

      test('includes the last page when total pages is odd', () {
        const selection = PageSelection([PageSelectionOdd()]);

        expect(selection.resolve(9), [1, 3, 5, 7, 9]);
      });

      test('does not include the last page when total pages is even', () {
        const selection = PageSelection([PageSelectionOdd()]);

        expect(selection.resolve(10), isNot(contains(10)));
      });

      test('resolves to one page for a one-page document', () {
        const selection = PageSelection([PageSelectionOdd()]);

        expect(selection.resolve(1), [1]);
      });

      test('resolves to empty for a zero-page document', () {
        const selection = PageSelection([PageSelectionOdd()]);

        expect(selection.resolve(0), isEmpty);
      });
    });

    group('PageSelectionEven', () {
      test('resolves even pages', () {
        const selection = PageSelection([PageSelectionEven()]);

        expect(selection.resolve(10), [2, 4, 6, 8, 10]);
      });

      test('includes the last page when total pages is even', () {
        const selection = PageSelection([PageSelectionEven()]);

        expect(selection.resolve(10), [2, 4, 6, 8, 10]);
      });

      test('does not include the last page when total pages is odd', () {
        const selection = PageSelection([PageSelectionEven()]);

        expect(selection.resolve(9), isNot(contains(9)));
      });

      test('resolves to empty for a one-page document', () {
        const selection = PageSelection([PageSelectionEven()]);

        expect(selection.resolve(1), isEmpty);
      });

      test('resolves to empty for a zero-page document', () {
        const selection = PageSelection([PageSelectionEven()]);

        expect(selection.resolve(0), isEmpty);
      });
    });
  });

  group('resolveGroups', () {
    test('keeps a single page as one group', () {
      const selection = PageSelection([PageSelectionPage(3)]);

      expect(selection.resolveGroups(10), [
        [3],
      ]);
    });

    test('keeps ranges as separate groups', () {
      const selection = PageSelection([
        PageSelectionRange(2, 4),
        PageSelectionRange(7, 9),
      ]);

      expect(selection.resolveGroups(10), [
        [2, 3, 4],
        [7, 8, 9],
      ]);
    });

    test('preserves selection order', () {
      const selection = PageSelection([
        PageSelectionPage(5),
        PageSelectionRange(2, 3),
        PageSelectionLast(),
      ]);

      expect(selection.resolveGroups(10), [
        [5],
        [2, 3],
        [10],
      ]);
    });

    test('preserves descending ranges as groups', () {
      const selection = PageSelection([
        PageSelectionRange(5, 2),
        PageSelectionRange(9, 7),
      ]);

      expect(selection.resolveGroups(10), [
        [5, 4, 3, 2],
        [9, 8, 7],
      ]);
    });

    test('supports different selection types in separate groups', () {
      const selection = PageSelection([
        PageSelectionOdd(),
        PageSelectionEven(),
        PageSelectionLast(),
        PageSelectionPage(4),
      ]);

      expect(selection.resolveGroups(6), [
        [1, 3, 5],
        [2, 4, 6],
        [6],
        [4],
      ]);
    });

    test('returns empty list for empty selection', () {
      const selection = PageSelection([]);

      expect(selection.resolveGroups(10), isEmpty);
    });
  });
}
