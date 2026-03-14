import { Compress, Extract, Merge, Split } from "@/pdf/tools";
import { ToolInfo, ToolPreferencesProps, TOOLS } from "@/pdf/tools";

export type ToolDefinition = {
  info: ToolInfo;
  Preferences: React.ComponentType<ToolPreferencesProps>;
};

export const mergeTool: ToolDefinition = {
  info: TOOLS.find((t) => t.id === "merge")!,
  Preferences: Merge,
};

export const splitTool: ToolDefinition = {
  info: TOOLS.find((t) => t.id === "split")!,
  Preferences: Split,
};

export const extractTool: ToolDefinition = {
  info: TOOLS.find((t) => t.id === "extract")!,
  Preferences: Extract,
};

export const compressTool: ToolDefinition = {
  info: TOOLS.find((t) => t.id === "compress")!,
  Preferences: Compress,
};

export const pdfToImageTool: ToolDefinition = {
  info: TOOLS.find((t) => t.id === "pdf-to-image")!,
  Preferences: Merge,
};

export const imageToPdfTool: ToolDefinition = {
  info: TOOLS.find((t) => t.id === "image-to-pdf")!,
  Preferences: Merge,
};

export const rotateTool: ToolDefinition = {
  info: TOOLS.find((t) => t.id === "rotate")!,
  Preferences: Merge,
};

export const protectTool: ToolDefinition = {
  info: TOOLS.find((t) => t.id === "protect")!,
  Preferences: Merge,
};

export const unlockTool: ToolDefinition = {
  info: TOOLS.find((t) => t.id === "unlock")!,
  Preferences: Merge,
};

export const watermarkTool: ToolDefinition = {
  info: TOOLS.find((t) => t.id === "watermark")!,
  Preferences: Merge,
};
