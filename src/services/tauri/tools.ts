import { InvokeResult, safeInvoke } from "./invokeResult";

export const mergePdfs = async (
  files: string[],
  dest: string,
): Promise<InvokeResult<void>> => {
  return safeInvoke("merge_pdfs", { files, dest });
};
