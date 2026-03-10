import {
  notifyError,
  notifySuccess,
  notifyWarning,
} from "@/services/notifications";
import { mergePdfs } from "@/services/tauri";
import { create } from "zustand";

interface MergeState {
  files: string[];
  destinationPath: string;
  isLoading: boolean;
  addFiles: (files: string[]) => void;
  setFiles: (files: string[]) => void;
  removeFile: (file: string) => void;
  setDestinationPath: (path: string) => void;
  setIsLoading: (loading: boolean) => void;
  runMerge: () => Promise<void>;
}

export const useMergeState = create<MergeState>((set, get) => ({
  files: [],
  destinationPath: "",
  isLoading: false,

  addFiles: (files: string[]) =>
    set((prev) => ({ files: [...prev.files, ...files] })),

  setFiles: (files: string[]) => set({ files }),

  removeFile: (file: string) =>
    set((prev) => ({ files: prev.files.filter((f) => f !== file) })),

  setDestinationPath: (path: string) => set({ destinationPath: path }),

  setIsLoading: (loading: boolean) => set({ isLoading: loading }),

  runMerge: async () => {
    const { files, destinationPath, isLoading, setIsLoading, setFiles } = get();
    if (files.length > 0 && !isLoading) {
      setIsLoading(true);
      const result = await mergePdfs(files, destinationPath);
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
