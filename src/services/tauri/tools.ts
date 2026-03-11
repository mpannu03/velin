import { InvokeResult, safeInvoke } from "./invokeResult";
import { PageSelectionInput } from "@/pdf/tools";

export const mergePdfs = async (
  inputs: PageSelectionInput[],
  dest: string,
): Promise<InvokeResult<void>> => {
  return safeInvoke("merge_pdfs", { rawInputs: inputs, dest });
};
