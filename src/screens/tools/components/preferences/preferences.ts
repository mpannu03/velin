import { MergePreferences, SplitPreferences, ToolDefinition } from ".";
import { TOOLS } from "../../types";

export const mergeTool: ToolDefinition = {
  info: TOOLS.find((t) => t.id === "merge")!,
  Preferences: MergePreferences,
};

export const splitTool: ToolDefinition = {
  info: TOOLS.find((t) => t.id === "split")!,
  Preferences: SplitPreferences,
};

export const extractTool: ToolDefinition = {
  info: TOOLS.find((t) => t.id === "extract")!,
  Preferences: MergePreferences,
};

export const compressTool: ToolDefinition = {
  info: TOOLS.find((t) => t.id === "compress")!,
  Preferences: MergePreferences,
};

export const pdfToImageTool: ToolDefinition = {
  info: TOOLS.find((t) => t.id === "pdf-to-image")!,
  Preferences: MergePreferences,
};

export const imageToPdfTool: ToolDefinition = {
  info: TOOLS.find((t) => t.id === "image-to-pdf")!,
  Preferences: MergePreferences,
};

export const rotateTool: ToolDefinition = {
  info: TOOLS.find((t) => t.id === "rotate")!,
  Preferences: MergePreferences,
};

export const protectTool: ToolDefinition = {
  info: TOOLS.find((t) => t.id === "protect")!,
  Preferences: MergePreferences,
};

export const unlockTool: ToolDefinition = {
  info: TOOLS.find((t) => t.id === "unlock")!,
  Preferences: MergePreferences,
};

export const watermarkTool: ToolDefinition = {
  info: TOOLS.find((t) => t.id === "watermark")!,
  Preferences: MergePreferences,
};
