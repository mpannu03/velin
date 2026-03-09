import {
  mergeTool,
  splitTool,
  ToolDefinition,
  extractTool,
  compressTool,
  pdfToImageTool,
  imageToPdfTool,
  rotateTool,
  protectTool,
  unlockTool,
  watermarkTool,
} from "../registry";
import { ToolId } from "@/pdf/tools";

export const PREFS_REGISTRY: Record<ToolId, ToolDefinition> = {
  merge: mergeTool,
  split: splitTool,
  extract: extractTool,
  compress: compressTool,
  "pdf-to-image": pdfToImageTool,
  "image-to-pdf": imageToPdfTool,
  rotate: rotateTool,
  protect: protectTool,
  unlock: unlockTool,
  watermark: watermarkTool,
};
