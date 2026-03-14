import {
  notifyError,
  notifySuccess,
  notifyWarning,
} from "@/services/notifications";
import { extractPdf } from "@/services/tauri";
import { create } from "zustand";

interface ExtractState {
  file: string;
  selection: string;
  destinationPath: string;
  isLoading: boolean;
  setFile: (file: string) => void;
  setSelection: (selection: string) => void;
  setDestinationPath: (path: string) => void;
  removeFile: () => void;
  setIsLoading: (loading: boolean) => void;
  runExtract: () => Promise<void>;
}

export const useExtractStore = create<ExtractState>((set, get) => ({
  file: "",
  selection: "",
  destinationPath: "",
  isLoading: false,

  setFile: (file: string) => set({ file }),

  setSelection: (selection: string) => set({ selection }),

  setDestinationPath: (path: string) => set({ destinationPath: path }),

  removeFile: () => set({ file: "", selection: "", destinationPath: "" }),

  setIsLoading: (loading: boolean) => set({ isLoading: loading }),

  runExtract: async () => {
    const {
      file,
      selection,
      destinationPath,
      isLoading,
      setIsLoading,
      removeFile,
    } = get();

    if (!file) {
      notifyWarning("Please select a PDF file.");
      return;
    }

    if (!selection) {
      notifyWarning("Please specify pages to extract.");
      return;
    }

    if (!isLoading) {
      setIsLoading(true);
      const input = { file, selection };
      const result = await extractPdf(input, destinationPath);

      if (result.ok) {
        notifySuccess("Pages extracted successfully.");
        removeFile();
      } else {
        notifyError(
          result.error ??
            "An unexpected error occurred while extracting pages.",
        );
      }
      setIsLoading(false);
    }
  },
}));
