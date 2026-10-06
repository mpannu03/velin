import 'package:flutter_test/flutter_test.dart';
import 'package:velin/engine/engine.dart';
import 'package:velin/features/tools/tools.dart';

void main() {
  group('ImageToPdfToolInput', () {
    test('stores the file path', () {
      const input = ImageToPdfToolInput(filePath: '/images/photo.png');

      expect(input.filePath, '/images/photo.png');
    });

    test('supports equality by file path', () {
      const first = ImageToPdfToolInput(filePath: '/images/photo.png');
      const second = ImageToPdfToolInput(filePath: '/images/photo.png');
      const different = ImageToPdfToolInput(filePath: '/images/other.png');

      expect(first, second);
      expect(first.hashCode, second.hashCode);
      expect(first, isNot(different));
    });

    test('copyWith preserves the existing file path by default', () {
      const input = ImageToPdfToolInput(filePath: '/images/photo.png');

      final result = input.copyWith();

      expect(result, input);
    });

    test('copyWith updates the file path', () {
      const input = ImageToPdfToolInput(filePath: '/images/photo.png');

      final result = input.copyWith(filePath: '/images/updated.png');

      expect(result.filePath, '/images/updated.png');
    });

    test('maps file path to File', () {
      const input = ImageToPdfToolInput(filePath: '/images/photo.png');

      expect(input.file.path, '/images/photo.png');
    });
  });

  group('ImageToPdfToolInputMapper', () {
    test('maps inputs to engine input in the same order', () {
      final inputs = [
        const ImageToPdfToolInput(filePath: '/images/first.png'),
        const ImageToPdfToolInput(filePath: '/images/second.jpg'),
        const ImageToPdfToolInput(filePath: '/images/third.webp'),
      ];

      final result = inputs.toImageToPdfInput(
        pageSize: ImageToPdfPageSize.a4,
        orientation: ImageToPdfOrientation.landscape,
        fit: ImageToPdfFit.contain,
      );

      expect(result.images[0].path, '/images/first.png');
      expect(result.images[1].path, '/images/second.jpg');
      expect(result.images[2].path, '/images/third.webp');

      expect(result.pageSize, ImageToPdfPageSize.a4);
      expect(result.orientation, ImageToPdfOrientation.landscape);
      expect(result.fit, ImageToPdfFit.contain);
    });

    test('uses default margin and dpi', () {
      final inputs = [const ImageToPdfToolInput(filePath: '/images/photo.png')];

      final result = inputs.toImageToPdfInput(
        pageSize: ImageToPdfPageSize.auto,
        orientation: ImageToPdfOrientation.auto,
        fit: ImageToPdfFit.cover,
      );

      expect(result.margin, 10);
      expect(result.dpi, 150);
    });

    test('forwards custom margin and dpi', () {
      final inputs = [const ImageToPdfToolInput(filePath: '/images/photo.png')];

      final result = inputs.toImageToPdfInput(
        pageSize: ImageToPdfPageSize.letter,
        orientation: ImageToPdfOrientation.portrait,
        fit: ImageToPdfFit.stretch,
        margin: 24,
        dpi: 300,
      );

      expect(result.margin, 24);
      expect(result.dpi, 300);
    });

    test('maps an empty list to an engine input with no images', () {
      final result = <ImageToPdfToolInput>[].toImageToPdfInput(
        pageSize: ImageToPdfPageSize.auto,
        orientation: ImageToPdfOrientation.auto,
        fit: ImageToPdfFit.contain,
      );

      expect(result.images, isEmpty);
    });
  });
}
