import 'package:material_symbols_icons/symbols.dart';
import 'tool_definition.dart';

abstract final class ToolRegistry {
  static const mergePdf = ToolDefinition(
    id: ToolId.mergePdf,
    category: ToolCategory.edit,
    icon: Symbols.merge_type,
    route: '/tools/merge-pdf',
  );

  static const splitPdf = ToolDefinition(
    id: ToolId.splitPdf,
    category: ToolCategory.edit,
    icon: Symbols.split_scene,
    route: '/tools/split-pdf',
  );

  static const extractPdf = ToolDefinition(
    id: ToolId.extractPdf,
    category: ToolCategory.edit,
    icon: Symbols.page_info,
    route: '/tools/extract-pdf',
  );

  static const compressPdf = ToolDefinition(
    id: ToolId.compressPdf,
    category: ToolCategory.optimize,
    icon: Symbols.compress,
    route: '/tools/compress-pdf',
  );

  static const pdfToImage = ToolDefinition(
    id: ToolId.pdfToImage,
    category: ToolCategory.convert,
    icon: Symbols.document_scanner,
    route: '/tools/pdf-to-image',
  );

  static const imageToPdf = ToolDefinition(
    id: ToolId.imageToPdf,
    category: ToolCategory.convert,
    icon: Symbols.upload_file,
    route: '/tools/image-to-pdf',
  );

  static const rotatePdf = ToolDefinition(
    id: ToolId.rotatePdf,
    category: ToolCategory.edit,
    icon: Symbols.rotate_right,
    route: '/tools/rotate-pdf',
  );

  static const protectPdf = ToolDefinition(
    id: ToolId.protectPdf,
    category: ToolCategory.security,
    icon: Symbols.lock,
    route: '/tools/protect-pdf',
  );

  static const unlockPdf = ToolDefinition(
    id: ToolId.unlockPdf,
    category: ToolCategory.security,
    icon: Symbols.lock_open,
    route: '/tools/unlock-pdf',
  );

  static const watermark = ToolDefinition(
    id: ToolId.watermark,
    category: ToolCategory.edit,
    icon: Symbols.water,
    route: '/tools/watermark',
  );

  static const all = [
    mergePdf,
    splitPdf,
    extractPdf,
    compressPdf,
    pdfToImage,
    imageToPdf,
    rotatePdf,
    protectPdf,
    unlockPdf,
    watermark,
  ];
}