import { InvokeResult, safeInvoke } from "./invokeResult";
import { PageSelectionInput, ProtectInput } from "@/pdf/tools";

export const mergePdfs = async (
  inputs: PageSelectionInput[],
  dest: string,
): Promise<InvokeResult<void>> => {
  return safeInvoke("merge_pdfs", { rawInputs: inputs, dest });
};

export const splitPdf = async (
  input: PageSelectionInput,
  destDir: string,
  fileName: string,
): Promise<InvokeResult<void>> => {
  return safeInvoke("split_pdf", { rawInput: input, destDir, fileName });
};

export const extractPdf = async (
  input: PageSelectionInput,
  dest: string,
): Promise<InvokeResult<void>> => {
  return safeInvoke("extract_pdf", { rawInput: input, dest });
};

export const pdfToImg = async (
  input: PageSelectionInput,
  destDir: string,
  options: {
    format: string;
    dpi: number;
    quality: number;
    mode: string;
    pattern: string;
  },
): Promise<InvokeResult<void>> => {
  return safeInvoke("pdf_to_image", { rawInput: input, destDir, options });
};

export const compressPdf = async (
  inputPath: string,
  outputPath: string,
  quality: number,
): Promise<InvokeResult<void>> => {
  return safeInvoke("compress_pdf", { inputPath, outputPath, quality });
};

export const imagesToPdf = async (
  imagePaths: string[],
  dest: string,
  options: {
    page_size: string;
    orientation: string;
    fit: string;
    margin: number;
  },
): Promise<InvokeResult<void>> => {
  return safeInvoke("image_to_pdf", { imagePaths, dest, options });
};

export const rotatePdf = async (
  input: PageSelectionInput,
  dest: string,
  angle: number,
): Promise<InvokeResult<void>> => {
  return safeInvoke("rotate_pdf", { rawInput: input, dest, angle });
};

export const protectPdf = async (
  input: ProtectInput,
): Promise<InvokeResult<void>> => {
  return safeInvoke("protect_pdf", { input });
};
