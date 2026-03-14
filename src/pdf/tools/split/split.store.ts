import { create } from "zustand";
import { SplitMode } from ".";
import {
  notifyError,
  notifySuccess,
  notifyWarning,
} from "@/services/notifications";
import { splitPdf } from "@/services/tauri";

interface SplitState {
  file: string;
  selection: string;
  isLoading: boolean;
  splitMode: SplitMode;

  setFile: (file: string) => void;
  setSelection: (selection: string) => void;
  removeFile: () => void;
  setIsLoading: (isLoading: boolean) => void;
  setSplitMode: (splitMode: SplitMode) => void;
  runSplit: () => Promise<void>;
}

export const useSplitStore = create<SplitState>((set, get) => ({
  file: "",
  selection: "",
  isLoading: false,
  splitMode: "ranges",

  setFile: (file) => set({ file }),
  setSelection: (selection) => set({ selection }),
  removeFile: () => set({ file: "", selection: "" }),
  setIsLoading: (isLoading) => set({ isLoading }),
  setSplitMode: (splitMode) => set({ splitMode }),
  runSplit: async () => {
    const { file, selection, isLoading, setIsLoading, splitMode } = get();
    if (file && !isLoading) {
      setIsLoading(true);
      let result: Awaited<ReturnType<typeof splitPdf>>;
      const input = { file, selection };
      const destinationDir = file.substring(
        0,
        file.lastIndexOf(file.split(/[/\\]/).pop() || ""),
      );
      const fileName = file.split(/[/\\]/).pop() || "";
      switch (splitMode) {
        case "ranges":
          if (!selection) {
            notifyWarning("Please select pages to split.");
            setIsLoading(false);
            return;
          }
          result = await splitPdf(input, destinationDir, fileName);
          break;
        case "fixedSize":
          if (!selection) {
            notifyWarning("Please select pages to split.");
            setIsLoading(false);
            return;
          }
          result = await splitPdf(input, destinationDir, fileName);
          break;
        case "allPages":
          result = await splitPdf(input, destinationDir, fileName);
          break;
      }
      if (result.ok) {
        notifySuccess("PDF file split successfully.");
      } else {
        notifyError(
          result.error ??
            "An unexpected error occurred while splitting the PDF.",
        );
      }
      setIsLoading(false);
    } else {
      notifyWarning("Please select a PDF file to split.");
    }
  },
}));
