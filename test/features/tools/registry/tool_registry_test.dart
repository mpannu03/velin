import 'package:flutter_test/flutter_test.dart';
import 'package:velin/features/tools/tools.dart';

void main() {
  group('ToolRegistry', () {
    test('registers every tool', () {
      expect(ToolRegistry.all.length, ToolId.values.length);

      expect(
        ToolRegistry.all.map((tool) => tool.id).toSet(),
        hasLength(ToolId.values.length),
      );
    });

    test('does not contain duplicate tool ids', () {
      final ids = ToolRegistry.all.map((tool) => tool.id).toList();

      expect(ids.toSet(), hasLength(ids.length));
    });

    test('does not contain duplicate routes', () {
      final routes = ToolRegistry.all.map((tool) => tool.route).toList();

      expect(routes.toSet(), hasLength(routes.length));
    });

    test('all routes are tool routes', () {
      for (final tool in ToolRegistry.all) {
        expect(tool.route, startsWith('/tools/'));
      }
    });

    test('all routes are non-empty', () {
      for (final tool in ToolRegistry.all) {
        expect(tool.route, isNotEmpty);
      }
    });

    test('all tools have an icon', () {
      for (final tool in ToolRegistry.all) {
        expect(tool.icon, isNotNull);
      }
    });

    test('registers expected categories', () {
      expect(ToolRegistry.mergePdf.category, ToolCategory.edit);
      expect(ToolRegistry.splitPdf.category, ToolCategory.edit);
      expect(ToolRegistry.extractPdf.category, ToolCategory.edit);
      expect(ToolRegistry.compressPdf.category, ToolCategory.optimize);
      expect(ToolRegistry.pdfToImage.category, ToolCategory.convert);
      expect(ToolRegistry.imageToPdf.category, ToolCategory.convert);
      expect(ToolRegistry.rotatePdf.category, ToolCategory.edit);
      expect(ToolRegistry.protectPdf.category, ToolCategory.security);
      expect(ToolRegistry.unlockPdf.category, ToolCategory.security);
      expect(ToolRegistry.watermark.category, ToolCategory.edit);
    });

    test('registers expected routes', () {
      expect(ToolRegistry.mergePdf.route, '/tools/merge-pdf');
      expect(ToolRegistry.splitPdf.route, '/tools/split-pdf');
      expect(ToolRegistry.extractPdf.route, '/tools/extract-pdf');
      expect(ToolRegistry.compressPdf.route, '/tools/compress-pdf');
      expect(ToolRegistry.pdfToImage.route, '/tools/pdf-to-image');
      expect(ToolRegistry.imageToPdf.route, '/tools/image-to-pdf');
      expect(ToolRegistry.rotatePdf.route, '/tools/rotate-pdf');
      expect(ToolRegistry.protectPdf.route, '/tools/protect-pdf');
      expect(ToolRegistry.unlockPdf.route, '/tools/unlock-pdf');
      expect(ToolRegistry.watermark.route, '/tools/watermark');
    });
  });
}
