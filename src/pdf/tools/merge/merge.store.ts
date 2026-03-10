import {
  notifyError,
  notifySuccess,
  notifyWarning,
} from "@/services/notifications";
import { mergePdfs } from "@/services/tauri";
import { create } from "zustand";
import { MergeInput } from "@/pdf/tools";

interface MergeState {
  inputs: MergeInput[];
  destinationPath: string;
  isLoading: boolean;
  addFiles: (filePaths: string[]) => void;
  setFiles: (files: MergeInput[]) => void;
  updateFileSelection: (filePath: string, selection: string | null) => void;
  removeFile: (filePath: string) => void;
  setDestinationPath: (path: string) => void;
  setIsLoading: (loading: boolean) => void;
  runMerge: () => Promise<void>;
}

export const useMergeState = create<MergeState>((set, get) => ({
  inputs: [],
  destinationPath: "",
  isLoading: false,

  addFiles: (filePaths: string[]) =>
    set((prev) => ({
      inputs: [
        ...prev.inputs,
        ...filePaths.map((file) => ({ file, selection: null })),
      ],
    })),

  setFiles: (inputs: MergeInput[]) => set({ inputs }),

  updateFileSelection: (filePath: string, selection: string | null) =>
    set((prev) => ({
      inputs: prev.inputs.map((f) =>
        f.file === filePath ? { ...f, selection: selection || null } : f,
      ),
    })),

  removeFile: (filePath: string) =>
    set((prev) => ({
      inputs: prev.inputs.filter((f) => f.file !== filePath),
    })),

  setDestinationPath: (path: string) => set({ destinationPath: path }),

  setIsLoading: (loading: boolean) => set({ isLoading: loading }),

  runMerge: async () => {
    const { inputs, destinationPath, isLoading, setIsLoading, setFiles } =
      get();
    if (inputs.length > 0 && !isLoading) {
      setIsLoading(true);
      const result = await mergePdfs(inputs, destinationPath);
      if (result.ok) {
        notifySuccess("PDF files merged successfully.");
        setFiles([]);
      } else {
        notifyError(
          result.error ?? "An unexpected error occurred while merging PDFs.",
        );
      }
      setIsLoading(false);
    } else {
      notifyWarning("Please add PDF files to merge.");
    }
  },
}));
