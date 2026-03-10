import { InvokeResult, safeInvoke } from "./invokeResult";
import { MergeInput } from "@/pdf/tools";

export const mergePdfs = async (
  inputs: MergeInput[],
  dest: string,
): Promise<InvokeResult<void>> => {
  return safeInvoke("merge_pdfs", { rawInputs: inputs, dest });
};
