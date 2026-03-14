import { InvokeResult, safeInvoke } from "./invokeResult";
import { PageSelectionInput } from "@/pdf/tools";

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
