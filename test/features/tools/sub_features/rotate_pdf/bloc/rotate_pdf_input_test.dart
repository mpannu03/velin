import 'package:flutter_test/flutter_test.dart';
import 'package:velin/core/page_selection/page_selection.dart';
import 'package:velin/features/tools/tools.dart';

void main() {
  group('RotatePdfDirection', () {
    test('maps directions to clockwise degrees', () {
      expect(RotatePdfDirection.clockwise90.degrees, 90);
      expect(RotatePdfDirection.upsideDown.degrees, 180);
      expect(RotatePdfDirection.counterClockwise90.degrees, 270);
    });
  });

  group('RotatePdfPageScope', () {
    test('identifies scopes that require a selection', () {
      expect(RotatePdfPageScope.allPages.requiresSelection, isFalse);
      expect(RotatePdfPageScope.selectedPages.requiresSelection, isTrue);
    });
  });

  group('RotatePdfToolInput', () {
    test('uses expected defaults', () {
      const input = RotatePdfToolInput(
        filePath: '/documents/sample.pdf',
        direction: RotatePdfDirection.clockwise90,
      );

      expect(input.filePath, '/documents/sample.pdf');
      expect(input.direction, RotatePdfDirection.clockwise90);
      expect(input.scope, RotatePdfPageScope.allPages);
      expect(input.selection, '');
      expect(input.parsedSelection, isNull);
    });

    test('returns null parsed selection for all pages', () {
      const input = RotatePdfToolInput(
        filePath: '/documents/sample.pdf',
        direction: RotatePdfDirection.upsideDown,
        selection: '1-5',
      );

      expect(input.parsedSelection, isNull);
    });

    test('parses selected pages', () {
      const input = RotatePdfToolInput(
        filePath: '/documents/sample.pdf',
        direction: RotatePdfDirection.clockwise90,
        scope: RotatePdfPageScope.selectedPages,
        selection: '1-5, 8, last',
      );

      final selection = input.parsedSelection;

      expect(selection, isNotNull);
      expect(selection!.items, hasLength(3));
    });

    test('throws when selected pages have empty selection', () {
      const input = RotatePdfToolInput(
        filePath: '/documents/sample.pdf',
        direction: RotatePdfDirection.clockwise90,
        scope: RotatePdfPageScope.selectedPages,
      );

      expect(
        () => input.parsedSelection,
        throwsA(isA<EmptyPageSelectionError>()),
      );
    });

    test('throws when selected pages have whitespace-only selection', () {
      const input = RotatePdfToolInput(
        filePath: '/documents/sample.pdf',
        direction: RotatePdfDirection.clockwise90,
        scope: RotatePdfPageScope.selectedPages,
        selection: '   ',
      );

      expect(
        () => input.parsedSelection,
        throwsA(isA<EmptyPageSelectionError>()),
      );
    });

    test('throws when selected pages have malformed selection', () {
      const input = RotatePdfToolInput(
        filePath: '/documents/sample.pdf',
        direction: RotatePdfDirection.clockwise90,
        scope: RotatePdfPageScope.selectedPages,
        selection: 'invalid',
      );

      expect(() => input.parsedSelection, throwsA(isA<PageSelectionError>()));
    });

    test('copyWith updates direction', () {
      const input = RotatePdfToolInput(
        filePath: '/documents/sample.pdf',
        direction: RotatePdfDirection.clockwise90,
      );

      final updated = input.copyWith(direction: RotatePdfDirection.upsideDown);

      expect(
        updated,
        const RotatePdfToolInput(
          filePath: '/documents/sample.pdf',
          direction: RotatePdfDirection.upsideDown,
        ),
      );
    });

    test('copyWith updates scope and selection', () {
      const input = RotatePdfToolInput(
        filePath: '/documents/sample.pdf',
        direction: RotatePdfDirection.clockwise90,
      );

      final updated = input.copyWith(
        scope: RotatePdfPageScope.selectedPages,
        selection: '2,4,6',
      );

      expect(
        updated,
        const RotatePdfToolInput(
          filePath: '/documents/sample.pdf',
          direction: RotatePdfDirection.clockwise90,
          scope: RotatePdfPageScope.selectedPages,
          selection: '2,4,6',
        ),
      );
    });

    test('copyWith preserves unspecified values', () {
      const input = RotatePdfToolInput(
        filePath: '/documents/sample.pdf',
        direction: RotatePdfDirection.counterClockwise90,
        scope: RotatePdfPageScope.selectedPages,
        selection: '1-3',
      );

      final updated = input.copyWith();

      expect(updated, input);
    });

    test('supports equality for identical values', () {
      const first = RotatePdfToolInput(
        filePath: '/documents/sample.pdf',
        direction: RotatePdfDirection.clockwise90,
        scope: RotatePdfPageScope.selectedPages,
        selection: '1,3,5',
      );

      const second = RotatePdfToolInput(
        filePath: '/documents/sample.pdf',
        direction: RotatePdfDirection.clockwise90,
        scope: RotatePdfPageScope.selectedPages,
        selection: '1,3,5',
      );

      expect(first, second);
      expect(first.hashCode, second.hashCode);
    });

    test('distinguishes different values', () {
      const input = RotatePdfToolInput(
        filePath: '/documents/sample.pdf',
        direction: RotatePdfDirection.clockwise90,
      );

      expect(
        input,
        isNot(
          const RotatePdfToolInput(
            filePath: '/documents/sample.pdf',
            direction: RotatePdfDirection.upsideDown,
          ),
        ),
      );
    });
  });
}
