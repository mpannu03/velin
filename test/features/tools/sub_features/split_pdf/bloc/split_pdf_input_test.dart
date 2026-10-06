import 'package:flutter_test/flutter_test.dart';
import 'package:velin/core/page_selection/page_selection.dart';
import 'package:velin/engine/engine.dart';
import 'package:velin/features/tools/tools.dart';

void main() {
  group('SplitPdfToolInput', () {
    test('uses the expected defaults', () {
      const input = SplitPdfToolInput(filePath: '/documents/input.pdf');

      expect(input.filePath, '/documents/input.pdf');
      expect(input.selections, isEmpty);
      expect(input.pageCount, isNull);
    });

    test('copyWith replaces selections', () {
      const input = SplitPdfToolInput(
        filePath: '/documents/input.pdf',
        selections: ['1-5'],
        pageCount: 10,
      );

      final copied = input.copyWith(selections: ['1', 'odd']);

      expect(
        copied,
        const SplitPdfToolInput(
          filePath: '/documents/input.pdf',
          selections: ['1', 'odd'],
          pageCount: 10,
        ),
      );
    });

    test('copyWith replaces page count', () {
      const input = SplitPdfToolInput(
        filePath: '/documents/input.pdf',
        selections: ['1-5'],
        pageCount: 10,
      );

      final copied = input.copyWith(pageCount: 20);

      expect(
        copied,
        const SplitPdfToolInput(
          filePath: '/documents/input.pdf',
          selections: ['1-5'],
          pageCount: 20,
        ),
      );
    });

    test('copyWith preserves unspecified values', () {
      const input = SplitPdfToolInput(
        filePath: '/documents/input.pdf',
        selections: ['1-5'],
        pageCount: 10,
      );

      final copied = input.copyWith();

      expect(copied, input);
    });

    test('supports value equality', () {
      const first = SplitPdfToolInput(
        filePath: '/documents/input.pdf',
        selections: ['1-5', '10'],
        pageCount: 5,
      );
      const second = SplitPdfToolInput(
        filePath: '/documents/input.pdf',
        selections: ['1-5', '10'],
        pageCount: 5,
      );

      expect(first, second);
      expect(first.hashCode, second.hashCode);
    });

    test('different values are not equal', () {
      const first = SplitPdfToolInput(
        filePath: '/documents/input.pdf',
        selections: ['1-5'],
        pageCount: 5,
      );
      const second = SplitPdfToolInput(
        filePath: '/documents/other.pdf',
        selections: ['1-5'],
        pageCount: 5,
      );

      expect(first, isNot(second));
    });

    group('toSplitInput', () {
      test('maps by selection mode', () {
        const input = SplitPdfToolInput(
          filePath: '/documents/input.pdf',
          selections: ['1-5', '10', 'odd'],
        );

        final result = input.toSplitInput(SplitPdfMode.bySelection);

        expect(result.file.path, '/documents/input.pdf');
        expect(result.mode, SplitPdfMode.bySelection);
        expect(result.pageCount, isNull);
        expect(result.selections, hasLength(3));
      });

      test('maps by page count mode', () {
        const input = SplitPdfToolInput(
          filePath: '/documents/input.pdf',
          pageCount: 10,
        );

        final result = input.toSplitInput(SplitPdfMode.byPageCount);

        expect(result.file.path, '/documents/input.pdf');
        expect(result.mode, SplitPdfMode.byPageCount);
        expect(result.pageCount, 10);
        expect(result.selections, isEmpty);
      });

      test('maps extract all pages mode', () {
        const input = SplitPdfToolInput(filePath: '/documents/input.pdf');

        final result = input.toSplitInput(SplitPdfMode.extractAllPages);

        expect(result.file.path, '/documents/input.pdf');
        expect(result.mode, SplitPdfMode.extractAllPages);
        expect(result.pageCount, isNull);
        expect(result.selections, isEmpty);
      });

      test('rejects selection mode without selections', () {
        const input = SplitPdfToolInput(filePath: '/documents/input.pdf');

        expect(
          () => input.toSplitInput(SplitPdfMode.bySelection),
          throwsA(isA<EmptyPageSelectionError>()),
        );
      });

      test('rejects page count mode without page count', () {
        const input = SplitPdfToolInput(filePath: '/documents/input.pdf');

        expect(
          () => input.toSplitInput(SplitPdfMode.byPageCount),
          throwsA(isA<ArgumentError>()),
        );
      });

      test('rejects zero page count', () {
        const input = SplitPdfToolInput(
          filePath: '/documents/input.pdf',
          pageCount: 0,
        );

        expect(
          () => input.toSplitInput(SplitPdfMode.byPageCount),
          throwsA(isA<ArgumentError>()),
        );
      });

      test('rejects negative page count', () {
        const input = SplitPdfToolInput(
          filePath: '/documents/input.pdf',
          pageCount: -1,
        );

        expect(
          () => input.toSplitInput(SplitPdfMode.byPageCount),
          throwsA(isA<ArgumentError>()),
        );
      });

      test('parses every selection group', () {
        const input = SplitPdfToolInput(
          filePath: '/documents/input.pdf',
          selections: ['1-5', '10', 'odd'],
        );

        final result = input.toSplitInput(SplitPdfMode.bySelection);

        expect(result.selections, hasLength(3));

        expect(result.selections[0].resolve(20), [1, 2, 3, 4, 5]);
        expect(result.selections[1].resolve(20), [10]);
        expect(result.selections[2].resolve(20), [
          1,
          3,
          5,
          7,
          9,
          11,
          13,
          15,
          17,
          19,
        ]);
      });

      test('propagates invalid page selection errors', () {
        const input = SplitPdfToolInput(
          filePath: '/documents/input.pdf',
          selections: ['invalid'],
        );

        expect(
          () => input.toSplitInput(SplitPdfMode.bySelection),
          throwsA(isA<PageSelectionError>()),
        );
      });
    });
  });
}
