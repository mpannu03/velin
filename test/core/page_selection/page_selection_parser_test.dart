import 'package:flutter_test/flutter_test.dart';
import 'package:velin/core/page_selection/page_selection.dart';

void main() {
  const parser = PageSelectionParser();

  group('single page', () {
    test('parses a page number', () {
      final selection = parser.parse('5');

      expect(selection.items, hasLength(1));
      expect(selection.items.first, isA<PageSelectionPage>());
      expect(
        (selection.items.first as PageSelectionPage).page,
        5,
      );
    });

    test('parses the first page', () {
      final selection = parser.parse('1');

      expect(selection.items, hasLength(1));
      expect(
        (selection.items.first as PageSelectionPage).page,
        1,
      );
    });

    test('parses zero as a page', () {
      final selection = parser.parse('0');

      expect(selection.items, hasLength(1));
      expect(
        (selection.items.first as PageSelectionPage).page,
        0,
      );
    });

    test('parses surrounding whitespace', () {
      final selection = parser.parse('  5  ');

      expect(selection.items, hasLength(1));
      expect(
        (selection.items.first as PageSelectionPage).page,
        5,
      );
    });
  });

  group('range', () {
    test('parses an ascending range', () {
      final selection = parser.parse('2-5');

      expect(selection.items, hasLength(1));
      expect(selection.items.first, isA<PageSelectionRange>());

      final range = selection.items.first as PageSelectionRange;

      expect(range.start, 2);
      expect(range.end, 5);
    });

    test('parses a descending range', () {
      final selection = parser.parse('5-2');

      expect(selection.items, hasLength(1));

      final range = selection.items.first as PageSelectionRange;

      expect(range.start, 5);
      expect(range.end, 2);
    });

    test('parses a single-page range', () {
      final selection = parser.parse('5-5');

      expect(selection.items, hasLength(1));

      final range = selection.items.first as PageSelectionRange;

      expect(range.start, 5);
      expect(range.end, 5);
    });

    test('parses a range starting at zero', () {
      final selection = parser.parse('0-5');

      expect(selection.items, hasLength(1));

      final range = selection.items.first as PageSelectionRange;

      expect(range.start, 0);
      expect(range.end, 5);
    });

    test('parses a range ending at zero', () {
      final selection = parser.parse('5-0');

      expect(selection.items, hasLength(1));

      final range = selection.items.first as PageSelectionRange;

      expect(range.start, 5);
      expect(range.end, 0);
    });

    test('trims whitespace around range', () {
      final selection = parser.parse('  2 - 5  ');

      expect(selection.items, hasLength(1));

      final range = selection.items.first as PageSelectionRange;

      expect(range.start, 2);
      expect(range.end, 5);
    });
  });

  group('open ranges', () {
    group('open start', () {
      test('parses an open-start range', () {
        final selection = parser.parse('-5');

        expect(selection.items, hasLength(1));
        expect(selection.items.first, isA<PageSelectionOpenStart>());

        final range = selection.items.first as PageSelectionOpenStart;

        expect(range.end, 5);
      });

      test('parses an open-start range with whitespace', () {
        final selection = parser.parse(' - 5 ');

        expect(selection.items, hasLength(1));
        expect(selection.items.first, isA<PageSelectionOpenStart>());

        final range = selection.items.first as PageSelectionOpenStart;

        expect(range.end, 5);
      });

      test('parses zero as the end page', () {
        final selection = parser.parse('-0');

        expect(selection.items, hasLength(1));
        expect(selection.items.first, isA<PageSelectionOpenStart>());

        final range = selection.items.first as PageSelectionOpenStart;

        expect(range.end, 0);
      });

      test('throws for a non-numeric end', () {
        expect(
          () => parser.parse('-abc'),
          throwsA(
            isA<InvalidPageSelectionNumberError>(),
          ),
        );
      });
    });

    group('open end', () {
      test('parses an open-end range', () {
        final selection = parser.parse('5-');

        expect(selection.items, hasLength(1));
        expect(selection.items.first, isA<PageSelectionOpenEnd>());

        final range = selection.items.first as PageSelectionOpenEnd;

        expect(range.start, 5);
      });

      test('parses an open-end range with whitespace', () {
        final selection = parser.parse('5 - ');

        expect(selection.items, hasLength(1));
        expect(selection.items.first, isA<PageSelectionOpenEnd>());

        final range = selection.items.first as PageSelectionOpenEnd;

        expect(range.start, 5);
      });

      test('parses zero as the start page', () {
        final selection = parser.parse('0-');

        expect(selection.items, hasLength(1));
        expect(selection.items.first, isA<PageSelectionOpenEnd>());

        final range = selection.items.first as PageSelectionOpenEnd;

        expect(range.start, 0);
      });

      test('throws for a non-numeric start', () {
        expect(
          () => parser.parse('abc-'),
          throwsA(
            isA<InvalidPageSelectionNumberError>(),
          ),
        );
      });
    });
  });

  group('last', () {
    test('parses last', () {
      final selection = parser.parse('last');

      expect(selection.items, hasLength(1));
      expect(selection.items.first, isA<PageSelectionLast>());
    });

    test('parses last case-insensitively', () {
      final selection = parser.parse('LAST');

      expect(selection.items, hasLength(1));
      expect(selection.items.first, isA<PageSelectionLast>());
    });

    test('parses last with surrounding whitespace', () {
      final selection = parser.parse('  last  ');

      expect(selection.items, hasLength(1));
      expect(selection.items.first, isA<PageSelectionLast>());
    });
  });

  group('last-N', () {
    test('parses last-N', () {
      final selection = parser.parse('last-3');

      expect(selection.items, hasLength(1));
      expect(selection.items.first, isA<PageSelectionLastMinus>());

      final lastMinus = selection.items.first as PageSelectionLastMinus;

      expect(lastMinus.amount, 3);
    });

    test('parses last-0', () {
      final selection = parser.parse('last-0');

      expect(selection.items, hasLength(1));

      final lastMinus = selection.items.first as PageSelectionLastMinus;

      expect(lastMinus.amount, 0);
    });

    test('parses last-N case-insensitively', () {
      final selection = parser.parse('LAST-3');

      expect(selection.items, hasLength(1));

      final lastMinus = selection.items.first as PageSelectionLastMinus;

      expect(lastMinus.amount, 3);
    });

    test('parses last-N with surrounding whitespace', () {
      final selection = parser.parse('  last-3  ');

      expect(selection.items, hasLength(1));

      final lastMinus = selection.items.first as PageSelectionLastMinus;

      expect(lastMinus.amount, 3);
    });

    test('throws for a non-numeric amount', () {
      expect(
        () => parser.parse('last-abc'),
        throwsA(
          isA<InvalidPageSelectionNumberError>(),
        ),
      );
    });

    test('throws for a negative amount', () {
      expect(
        () => parser.parse('last--1'),
        throwsA(
          isA<InvalidPageSelectionNumberError>(),
        ),
      );
    });

    test('throws for an empty amount', () {
      expect(
        () => parser.parse('last-'),
        throwsA(
          isA<InvalidPageSelectionNumberError>(),
        ),
      );
    });
  });

  group('odd', () {
    test('parses odd', () {
      final selection = parser.parse('odd');

      expect(selection.items, hasLength(1));
      expect(selection.items.first, isA<PageSelectionOdd>());
    });

    test('parses odd case-insensitively', () {
      final selection = parser.parse('ODD');

      expect(selection.items, hasLength(1));
      expect(selection.items.first, isA<PageSelectionOdd>());
    });

    test('parses odd with surrounding whitespace', () {
      final selection = parser.parse('  odd  ');

      expect(selection.items, hasLength(1));
      expect(selection.items.first, isA<PageSelectionOdd>());
    });
  });

  group('even', () {
    test('parses even', () {
      final selection = parser.parse('even');

      expect(selection.items, hasLength(1));
      expect(selection.items.first, isA<PageSelectionEven>());
    });

    test('parses even case-insensitively', () {
      final selection = parser.parse('EVEN');

      expect(selection.items, hasLength(1));
      expect(selection.items.first, isA<PageSelectionEven>());
    });

    test('parses even with surrounding whitespace', () {
      final selection = parser.parse('  even  ');

      expect(selection.items, hasLength(1));
      expect(selection.items.first, isA<PageSelectionEven>());
    });
  });

  group('multiple selections', () {
    test('parses multiple single pages', () {
      final selection = parser.parse('1,3,5');

      expect(selection.items, hasLength(3));

      expect(
        selection.items[0],
        isA<PageSelectionPage>(),
      );
      expect(
        (selection.items[0] as PageSelectionPage).page,
        1,
      );

      expect(
        (selection.items[1] as PageSelectionPage).page,
        3,
      );

      expect(
        (selection.items[2] as PageSelectionPage).page,
        5,
      );
    });

    test('parses multiple ranges', () {
      final selection = parser.parse('2-4,7-9');

      expect(selection.items, hasLength(2));

      final first = selection.items[0] as PageSelectionRange;
      final second = selection.items[1] as PageSelectionRange;

      expect(first.start, 2);
      expect(first.end, 4);

      expect(second.start, 7);
      expect(second.end, 9);
    });

    test('parses mixed selection types', () {
      final selection = parser.parse(
        '1,3-5,-8,10-,last,last-2,odd,even',
      );

      expect(selection.items, hasLength(8));

      expect(selection.items[0], isA<PageSelectionPage>());
      expect(selection.items[1], isA<PageSelectionRange>());
      expect(selection.items[2], isA<PageSelectionOpenStart>());
      expect(selection.items[3], isA<PageSelectionOpenEnd>());
      expect(selection.items[4], isA<PageSelectionLast>());
      expect(selection.items[5], isA<PageSelectionLastMinus>());
      expect(selection.items[6], isA<PageSelectionOdd>());
      expect(selection.items[7], isA<PageSelectionEven>());
    });

    test('preserves selection order', () {
      final selection = parser.parse('last,2-4,1,odd');

      expect(selection.items, hasLength(4));

      expect(selection.items[0], isA<PageSelectionLast>());
      expect(selection.items[1], isA<PageSelectionRange>());
      expect(selection.items[2], isA<PageSelectionPage>());
      expect(selection.items[3], isA<PageSelectionOdd>());
    });

    test('trims whitespace around tokens', () {
      final selection = parser.parse(
        ' 1 , 3-5 , last , odd ',
      );

      expect(selection.items, hasLength(4));

      expect(
        (selection.items[0] as PageSelectionPage).page,
        1,
      );

      final range = selection.items[1] as PageSelectionRange;
      expect(range.start, 3);
      expect(range.end, 5);

      expect(selection.items[2], isA<PageSelectionLast>());
      expect(selection.items[3], isA<PageSelectionOdd>());
    });

    test('allows repeated selection types', () {
      final selection = parser.parse('1,1,2-3,2-3');

      expect(selection.items, hasLength(4));
    });
  });

  group('invalid input', () {
    group('empty input', () {
      test('throws for an empty string', () {
        expect(
          () => parser.parse(''),
          throwsA(isA<EmptyPageSelectionError>()),
        );
      });

      test('throws for whitespace-only input', () {
        expect(
          () => parser.parse('   '),
          throwsA(isA<EmptyPageSelectionError>()),
        );
      });
    });

    group('empty tokens', () {
      test('throws for a trailing comma', () {
        expect(
          () => parser.parse('1,'),
          throwsA(
            isA<InvalidPageSelectionTokenError>(),
          ),
        );
      });

      test('throws for a leading comma', () {
        expect(
          () => parser.parse(',1'),
          throwsA(
            isA<InvalidPageSelectionTokenError>(),
          ),
        );
      });

      test('throws for an empty token between selections', () {
        expect(
          () => parser.parse('1,,3'),
          throwsA(
            isA<InvalidPageSelectionTokenError>(),
          ),
        );
      });

      test('throws when input contains only a comma', () {
        expect(
          () => parser.parse(','),
          throwsA(
            isA<InvalidPageSelectionTokenError>(),
          ),
        );
      });
    });

    group('invalid tokens', () {
      test('throws for an unknown token', () {
        expect(
          () => parser.parse('foo'),
          throwsA(
            isA<InvalidPageSelectionTokenError>(),
          ),
        );
      });

      test('includes the invalid token', () {
        expect(
          () => parser.parse('foo'),
          throwsA(
            isA<InvalidPageSelectionTokenError>().having(
              (error) => error.token,
              'token',
              'foo',
            ),
          ),
        );
      });

      test('throws for decimal numbers', () {
        expect(
          () => parser.parse('1.5'),
          throwsA(
            isA<InvalidPageSelectionTokenError>(),
          ),
        );
      });

      test('throws for unsupported keywords', () {
        expect(
          () => parser.parse('first'),
          throwsA(
            isA<InvalidPageSelectionTokenError>(),
          ),
        );
      });
    });

    group('invalid ranges', () {
      test('throws for too many separators', () {
        expect(
          () => parser.parse('1-2-3'),
          throwsA(
            isA<InvalidPageSelectionRangeError>(),
          ),
        );
      });

      test('throws for multiple separators with empty parts', () {
        expect(
          () => parser.parse('1--2'),
          throwsA(
            isA<InvalidPageSelectionRangeError>(),
          ),
        );
      });

      test('throws for only separators', () {
        expect(
          () => parser.parse('--'),
          throwsA(
            isA<InvalidPageSelectionRangeError>(),
          ),
        );
      });

      test('throws for a non-numeric range start', () {
        expect(
          () => parser.parse('abc-5'),
          throwsA(
            isA<InvalidPageSelectionNumberError>(),
          ),
        );
      });

      test('throws for a non-numeric range end', () {
        expect(
          () => parser.parse('5-abc'),
          throwsA(
            isA<InvalidPageSelectionNumberError>(),
          ),
        );
      });
    });

    group('invalid last-N', () {
      test('throws for a missing amount', () {
        expect(
          () => parser.parse('last-'),
          throwsA(
            isA<InvalidPageSelectionNumberError>(),
          ),
        );
      });

      test('throws for a non-numeric amount', () {
        expect(
          () => parser.parse('last-foo'),
          throwsA(
            isA<InvalidPageSelectionNumberError>(),
          ),
        );
      });

      test('throws for a negative amount', () {
        expect(
          () => parser.parse('last--1'),
          throwsA(
            isA<InvalidPageSelectionNumberError>(),
          ),
        );
      });
    });
  });
}