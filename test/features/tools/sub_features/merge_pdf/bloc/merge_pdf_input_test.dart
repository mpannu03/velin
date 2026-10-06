import 'package:flutter_test/flutter_test.dart';
import 'package:velin/core/page_selection/page_selection.dart';
import 'package:velin/features/tools/sub_features/merge_pdf/merge_pdf.dart';

void main() {
  group('MergePdfToolInput', () {
    test('has expected default values', () {
      const input = MergePdfToolInput(filePath: '/documents/one.pdf');

      expect(input.filePath, '/documents/one.pdf');
      expect(input.pageSelection, isNull);
    });

    test('supports page selection', () {
      const input = MergePdfToolInput(
        filePath: '/documents/one.pdf',
        pageSelection: '1-5',
      );

      expect(input.filePath, '/documents/one.pdf');
      expect(input.pageSelection, '1-5');
    });

    test('copyWith updates page selection', () {
      const input = MergePdfToolInput(
        filePath: '/documents/one.pdf',
        pageSelection: '1-5',
      );

      final result = input.copyWith(pageSelection: '2,4,6');

      expect(
        result,
        const MergePdfToolInput(
          filePath: '/documents/one.pdf',
          pageSelection: '2,4,6',
        ),
      );
    });

    test('copyWith preserves page selection when omitted', () {
      const input = MergePdfToolInput(
        filePath: '/documents/one.pdf',
        pageSelection: '1-5',
      );

      final result = input.copyWith();

      expect(result, input);
    });

    test('copyWith preserves file path', () {
      const input = MergePdfToolInput(
        filePath: '/documents/one.pdf',
        pageSelection: '1-5',
      );

      final result = input.copyWith(pageSelection: '2');

      expect(result.filePath, input.filePath);
    });

    test('is equal when values are equal', () {
      const first = MergePdfToolInput(
        filePath: '/documents/one.pdf',
        pageSelection: '1-5',
      );
      const second = MergePdfToolInput(
        filePath: '/documents/one.pdf',
        pageSelection: '1-5',
      );

      expect(first, second);
      expect(first.hashCode, second.hashCode);
    });

    test('is not equal when file path differs', () {
      const first = MergePdfToolInput(
        filePath: '/documents/one.pdf',
        pageSelection: '1-5',
      );
      const second = MergePdfToolInput(
        filePath: '/documents/two.pdf',
        pageSelection: '1-5',
      );

      expect(first, isNot(second));
    });

    test('is not equal when page selection differs', () {
      const first = MergePdfToolInput(
        filePath: '/documents/one.pdf',
        pageSelection: '1-5',
      );
      const second = MergePdfToolInput(
        filePath: '/documents/one.pdf',
        pageSelection: '2-6',
      );

      expect(first, isNot(second));
    });

    test('is not equal when one page selection is null', () {
      const first = MergePdfToolInput(filePath: '/documents/one.pdf');
      const second = MergePdfToolInput(
        filePath: '/documents/one.pdf',
        pageSelection: '1-5',
      );

      expect(first, isNot(second));
    });
  });

  group('MergePdfMapper', () {
    test('maps file path to File when no selection is provided', () {
      const input = MergePdfToolInput(filePath: '/documents/one.pdf');

      final result = input.toPdfInput();

      expect(result.file.path, '/documents/one.pdf');
      expect(result.selection, isNull);
    });

    test('maps file path to File when selection is empty', () {
      const input = MergePdfToolInput(
        filePath: '/documents/one.pdf',
        pageSelection: '',
      );

      final result = input.toPdfInput();

      expect(result.file.path, '/documents/one.pdf');
      expect(result.selection, isNull);
    });

    test('maps file path to File when selection is whitespace', () {
      const input = MergePdfToolInput(
        filePath: '/documents/one.pdf',
        pageSelection: '   ',
      );

      final result = input.toPdfInput();

      expect(result.file.path, '/documents/one.pdf');
      expect(result.selection, isNull);
    });

    test('parses a valid page selection', () {
      const input = MergePdfToolInput(
        filePath: '/documents/one.pdf',
        pageSelection: '1-5',
      );

      final result = input.toPdfInput();

      expect(result.file.path, '/documents/one.pdf');
      expect(result.selection, isNotNull);
    });

    test('trims page selection before parsing', () {
      const input = MergePdfToolInput(
        filePath: '/documents/one.pdf',
        pageSelection: ' 1-5 ',
      );

      final result = input.toPdfInput();

      expect(result.file.path, '/documents/one.pdf');
      expect(result.selection, isNotNull);
    });

    test('supports complex page selection syntax', () {
      const input = MergePdfToolInput(
        filePath: '/documents/one.pdf',
        pageSelection: '1-5, 8, odd, last-2',
      );

      final result = input.toPdfInput();

      expect(result.file.path, '/documents/one.pdf');
      expect(result.selection, isNotNull);
    });

    test('throws PageSelectionError for invalid selection', () {
      const input = MergePdfToolInput(
        filePath: '/documents/one.pdf',
        pageSelection: 'invalid',
      );

      expect(input.toPdfInput, throwsA(isA<PageSelectionError>()));
    });
  });
}
